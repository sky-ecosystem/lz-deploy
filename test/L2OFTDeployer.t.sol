// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import {
    LZInit,
    OftConfig,
    RateLimits,
    EndpointLike,
    UlnLike,
    OAppLike,
    OFTAdapterLike
} from "lz-init-lib/LZInit.sol";

import { L2OFTDeployer, L2OftDeployment, RemoteWiring } from "src/L2OFTDeployer.sol";
import { LzOptions }                                 from "src/LzOptions.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

/// @notice Acceptance test for `L2OFTDeployer`: deploy as the deployer would, then run the
///         governance-side check that gates the spell.
/// @dev    `activateOft` re-reads the whole config and reverts on any mismatch, so it passing is the
///         real statement of agreement with lz-init-lib. The per-field assertions localise failures.
contract L2OFTDeployerTest is LZDeployTestBase {

    address l2GovRelay = makeAddr("l2GovRelay");
    address remotePeer = makeAddr("remotePeer");

    L2OFTDeployer dep;
    address     oft;

    OftConfig oftCfg;

    function setUp() public override {
        super.setUp();

        oftCfg = OftConfig({
            peer:       remotePeer,
            sendLib:    SEND_LIB,
            execCfg:    execCfg,
            sendUlnCfg: oftSendUlnCfg,
            recvLib:    RECV_LIB,
            recvUlnCfg: oftRecvUlnCfg,
            optionsGas: OPTIONS_GAS
        });

        dep = _deploy(RateLimitAccountingType.Net, _noPausers(), _remotes(DST_EID, _zero()));
        oft = address(dep.oft());
    }

    function _deploy(
        RateLimitAccountingType accountingType,
        address[]        memory pausers,
        RemoteWiring[]   memory remotes
    ) internal returns (L2OFTDeployer) {
        return new L2OFTDeployer(_params(accountingType, pausers, remotes, l2GovRelay));
    }

    function _params(
        RateLimitAccountingType accountingType,
        address[]        memory pausers,
        RemoteWiring[]   memory remotes,
        address                 gov
    ) internal view returns (L2OftDeployment memory) {
        return L2OftDeployment({
            token:          USDS,
            endpoint:       ENDPOINT,
            accountingType: accountingType,
            pausers:        pausers,
            remotes:        remotes,
            gov:            gov
        });
    }

    function _remotes(uint32 eid, RateLimits memory limits) internal view returns (RemoteWiring[] memory rs) {
        rs    = new RemoteWiring[](1);
        rs[0] = RemoteWiring(eid, oftCfg, limits);
    }

    function _noPausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    function _zero() internal pure returns (RateLimits memory) {
        return RateLimits(0, 0, 0, 0);
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    function test_activateOftAcceptsDeployedState() public {
        RateLimits memory limits = RateLimits({
            inboundWindow:  1 days,
            inboundLimit:   10_000_000e18,
            outboundWindow: 1 days,
            outboundLimit:  10_000_000e18
        });

        // `startPrank`, not `prank`: the library call is inlined here and makes many external calls.
        vm.startPrank(l2GovRelay);
        LZInit.activateOft({
            oft:              oft,
            oftImp:           address(dep.implementation()),
            remoteEid:        DST_EID,
            cfg:              oftCfg,
            rateLimits:       limits,
            rlAccountingType: uint8(RateLimitAccountingType.Net),
            token:            USDS,
            owner:            l2GovRelay,
            endpoint:         ENDPOINT
        });
        vm.stopPrank();

        (,, , uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(DST_EID);
        (,, , uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(DST_EID);
        assertEq(outLimit, limits.outboundLimit, "outbound limit not activated");
        assertEq(inLimit,  limits.inboundLimit,  "inbound limit not activated");
    }

    /// @dev `activateOft` asserts the exact accounting type, so the deployer must be able to set it.
    function test_activateOftAcceptsGrossAccounting() public {
        L2OFTDeployer grossDep = _deploy(RateLimitAccountingType.Gross, _noPausers(), _remotes(DST_EID, _zero()));

        vm.startPrank(l2GovRelay);
        LZInit.activateOft({
            oft:              address(grossDep.oft()),
            oftImp:           address(grossDep.implementation()),
            remoteEid:        DST_EID,
            cfg:              oftCfg,
            rateLimits:       RateLimits(1 days, 1e18, 1 days, 1e18),
            rlAccountingType: uint8(RateLimitAccountingType.Gross),
            token:            USDS,
            owner:            l2GovRelay,
            endpoint:         ENDPOINT
        });
        vm.stopPrank();
    }

    // ==================================
    //  Deployment
    // ==================================

    function test_deploysProxyAndImplementation() public view {
        assertTrue(address(dep.implementation()) != address(0));
        assertTrue(oft != address(dep.implementation()), "proxy must not be the implementation");

        assertEq(OFTAdapterLike(oft).token(), USDS);
        assertEq(OAppLike(oft).endpoint(),    ENDPOINT);

        assertFalse(OFTAdapterLike(oft).paused());
        assertEq(OFTAdapterLike(oft).msgInspector(), address(0));
        assertEq(OFTAdapterLike(oft).defaultFeeBps(), 0);
    }

    /// @dev Only the proxy holds state.
    function test_implementationIsInitializerLocked() public {
        address impl = address(dep.implementation());

        vm.expectRevert();
        OFTDeployerInitLike(impl).initialize(address(this));
    }

    /// @dev Handed over in the same transaction, so the deployer never holds it afterwards.
    function test_handsOffOwnerAndDelegate() public view {
        assertEq(OFTAdapterLike(oft).owner(),           l2GovRelay);
        assertEq(EndpointLike(ENDPOINT).delegates(oft), l2GovRelay);
    }

    // ==================================
    //  Wiring
    // ==================================

    function test_wiresBothDirections() public view {
        assertEq(OAppLike(oft).peers(DST_EID), bytes32(uint256(uint160(remotePeer))));

        assertEq(EndpointLike(ENDPOINT).getSendLibrary(oft, DST_EID), SEND_LIB);
        assertFalse(EndpointLike(ENDPOINT).isDefaultSendLibrary(oft, DST_EID), "send lib must not be the default");

        (address recvLib, bool isDefaultRecv) = EndpointLike(ENDPOINT).getReceiveLibrary(oft, DST_EID);
        assertEq(recvLib, RECV_LIB);
        assertFalse(isDefaultRecv, "recv lib must not be the default");
        assertEq(EndpointLike(ENDPOINT).receiveLibraryTimeout(oft, DST_EID), address(0));

        (uint32 maxMsgSize, address exec) =
            abi.decode(EndpointLike(ENDPOINT).getConfig(oft, SEND_LIB, DST_EID, 1), (uint32, address));
        assertEq(maxMsgSize, execCfg.maxMessageSize);
        assertEq(exec,       execCfg.executor);

        _assertUlnConfig(abi.encode(UlnLike(SEND_LIB).getAppUlnConfig(oft, DST_EID)), oftSendUlnCfg);
        _assertUlnConfig(abi.encode(UlnLike(RECV_LIB).getAppUlnConfig(oft, DST_EID)), oftRecvUlnCfg);

        bytes memory expectedOptions = LzOptions.encodeLzReceiveOptions(OPTIONS_GAS);
        assertEq(OFTAdapterLike(oft).enforcedOptions(DST_EID, 1), expectedOptions, "msgType 1 options");
        assertEq(OFTAdapterLike(oft).enforcedOptions(DST_EID, 2), expectedOptions, "msgType 2 options");
    }

    /// @dev Zero by default: `activateOft` requires it, being where governance turns the bridge on.
    function test_leavesRateLimitsZero() public view {
        (,, , uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(DST_EID);
        (,, , uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(DST_EID);
        assertEq(outLimit, 0);
        assertEq(inLimit,  0);
    }

    /// @dev The other model: live at handoff, with no `activateOft` to follow.
    function test_setsNonZeroRateLimits() public {
        L2OFTDeployer liveDep = _deploy(
            RateLimitAccountingType.Net,
            _noPausers(),
            _remotes(DST_EID, RateLimits(1 days, 5e18, 1 days, 4e18))
        );

        (,, , uint256 outLimit) = OFTAdapterLike(address(liveDep.oft())).outboundRateLimits(DST_EID);
        (,, , uint256 inLimit)  = OFTAdapterLike(address(liveDep.oft())).inboundRateLimits(DST_EID);
        assertEq(outLimit, 4e18);
        assertEq(inLimit,  5e18);
    }

    function test_wiresMultipleRemotes() public {
        uint32 otherEid = 30106; // Avalanche

        RemoteWiring[] memory remotes = new RemoteWiring[](2);
        remotes[0] = RemoteWiring(DST_EID,  oftCfg, _zero());
        remotes[1] = RemoteWiring(otherEid, oftCfg, _zero());

        address multi = address(_deploy(RateLimitAccountingType.Net, _noPausers(), remotes).oft());

        assertEq(OAppLike(multi).peers(DST_EID),  bytes32(uint256(uint160(remotePeer))));
        assertEq(OAppLike(multi).peers(otherEid), bytes32(uint256(uint160(remotePeer))));
    }

    function test_revertsOnDuplicateRemote() public {
        RemoteWiring[] memory remotes = new RemoteWiring[](2);
        remotes[0] = RemoteWiring(DST_EID, oftCfg, _zero());
        remotes[1] = RemoteWiring(DST_EID, oftCfg, _zero());

        vm.expectRevert("LZInit/already-wired");
        _deploy(RateLimitAccountingType.Net, _noPausers(), remotes);
    }

    function test_setsPausers() public {
        address breaker = makeAddr("breaker");

        address[] memory pausers = new address[](1);
        pausers[0] = breaker;

        address paused = address(_deploy(RateLimitAccountingType.Net, pausers, _remotes(DST_EID, _zero())).oft());

        assertTrue(SkyOFTPauserLike(paused).pausers(breaker));
    }
}

interface OFTDeployerInitLike {
    function initialize(address delegate) external;
}

interface SkyOFTPauserLike {
    function pausers(address pauser) external view returns (bool);
}
