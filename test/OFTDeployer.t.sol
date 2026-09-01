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

import { OFTDeployer } from "src/OFTDeployer.sol";
import { LzOptions }   from "src/LzOptions.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

/// @notice Acceptance test for `OFTDeployer`: deploy as the deployer would, then run the
///         governance-side check that gates the spell.
/// @dev    `activateOft` re-reads the whole config and reverts on any mismatch, so it passing is the
///         real statement of agreement with lz-init-lib. The per-field assertions localise failures.
contract OFTDeployerTest is LZDeployTestBase {

    address deployerEOA = makeAddr("deployerEOA");
    address l2GovRelay  = makeAddr("l2GovRelay");
    address remotePeer  = makeAddr("remotePeer");

    OFTDeployer dep;
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

        vm.prank(deployerEOA);
        dep = new OFTDeployer(USDS, ENDPOINT);
        oft = dep.oft();
    }

    function _wire() internal {
        vm.prank(deployerEOA);
        dep.wireRemote(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    function test_activateOftAcceptsDeployedState() public {
        _wire();

        vm.prank(deployerEOA);
        dep.handOff(l2GovRelay);

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
            oftImp:           dep.implementation(),
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
        vm.prank(deployerEOA);
        dep.setAccountingType(RateLimitAccountingType.Gross);

        _wire();

        vm.prank(deployerEOA);
        dep.handOff(l2GovRelay);

        vm.startPrank(l2GovRelay);
        LZInit.activateOft({
            oft:              oft,
            oftImp:           dep.implementation(),
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

    function test_deployProxyAndImplementation() public view {
        assertEq(dep.deployer(), deployerEOA);
        assertEq(dep.endpoint(), ENDPOINT);
        assertTrue(dep.implementation() != address(0));
        assertTrue(oft != dep.implementation(), "proxy must not be the implementation");

        assertEq(OFTAdapterLike(oft).token(),    USDS);
        assertEq(OAppLike(oft).endpoint(),       ENDPOINT);
        assertEq(OFTAdapterLike(oft).owner(),    address(dep), "deployer must own during bring-up");
        assertEq(EndpointLike(ENDPOINT).delegates(oft), address(dep), "deployer must be the delegate");

        assertFalse(OFTAdapterLike(oft).paused());
        assertEq(OFTAdapterLike(oft).msgInspector(), address(0));
        assertEq(OFTAdapterLike(oft).defaultFeeBps(), 0);
    }

    /// @dev Only the proxy holds state.
    function test_implementationIsInitializerLocked() public {
        address impl = dep.implementation();

        vm.expectRevert();
        OFTDeployerInitLike(impl).initialize(address(this));
    }

    // ==================================
    //  Wiring
    // ==================================

    function test_wireRemoteConfiguresBothDirections() public {
        _wire();

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

        assertTrue(dep.wired());
    }

    /// @dev Zero by default: `activateOft` requires it, being where governance turns the bridge on.
    function test_wireRemoteLeavesRateLimitsZero() public {
        _wire();

        (,, , uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(DST_EID);
        (,, , uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(DST_EID);
        assertEq(outLimit, 0);
        assertEq(inLimit,  0);
    }

    function test_wireMultipleRemotes() public {
        _wire();

        uint32 otherEid = 30106; // Avalanche
        vm.prank(deployerEOA);
        dep.wireRemote(otherEid, oftCfg, RateLimits(0, 0, 0, 0));

        assertEq(OAppLike(oft).peers(DST_EID),  bytes32(uint256(uint160(remotePeer))));
        assertEq(OAppLike(oft).peers(otherEid), bytes32(uint256(uint160(remotePeer))));
    }

    function test_wireRemoteRevertsOnRewire() public {
        _wire();

        vm.prank(deployerEOA);
        vm.expectRevert("LZInit/already-wired");
        dep.wireRemote(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));
    }

    function test_setRateLimitsAndBackToZero() public {
        _wire();

        vm.prank(deployerEOA);
        dep.setRateLimits(DST_EID, RateLimits(1 days, 5e18, 1 days, 5e18));
        (,, , uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(DST_EID);
        assertEq(outLimit, 5e18);

        vm.prank(deployerEOA);
        dep.setRateLimits(DST_EID, RateLimits(0, 0, 0, 0));
        (,, , outLimit) = OFTAdapterLike(oft).outboundRateLimits(DST_EID);
        assertEq(outLimit, 0);
    }

    function test_setPausers() public {
        address breaker = makeAddr("breaker");

        address[] memory pausers = new address[](1);
        pausers[0] = breaker;

        vm.prank(deployerEOA);
        dep.setPausers(pausers, true);

        assertTrue(SkyOFTPauserLike(oft).pausers(breaker));
    }

    // ==================================
    //  Handoff
    // ==================================

    function test_handOffMovesOwnerAndDelegate() public {
        _wire();

        vm.prank(deployerEOA);
        dep.handOff(l2GovRelay);

        assertTrue(dep.handedOff());
        assertEq(OFTAdapterLike(oft).owner(),           l2GovRelay);
        assertEq(EndpointLike(ENDPOINT).delegates(oft), l2GovRelay);
    }

    function test_handOffRevertsWithNothingWired() public {
        vm.prank(deployerEOA);
        vm.expectRevert("OFTDeployer/nothing-wired");
        dep.handOff(l2GovRelay);
    }

    function test_handOffRevertsOnZeroGov() public {
        _wire();

        vm.prank(deployerEOA);
        vm.expectRevert("OFTDeployer/gov-is-zero");
        dep.handOff(address(0));
    }

    function test_noActionsAfterHandOff() public {
        _wire();
        vm.prank(deployerEOA);
        dep.handOff(l2GovRelay);

        vm.startPrank(deployerEOA);

        vm.expectRevert("OFTDeployer/handed-off");
        dep.wireRemote(30106, oftCfg, RateLimits(0, 0, 0, 0));

        vm.expectRevert("OFTDeployer/handed-off");
        dep.handOff(deployerEOA);

        vm.expectRevert("OFTDeployer/handed-off");
        dep.setRateLimits(DST_EID, RateLimits(0, 0, 0, 0));

        vm.stopPrank();
    }

    // ==================================
    //  Access control
    // ==================================

    function test_onlyDeployerCanWire() public {
        vm.expectRevert("OFTDeployer/not-deployer");
        dep.wireRemote(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));
    }

    function test_onlyDeployerCanHandOff() public {
        _wire();

        vm.expectRevert("OFTDeployer/not-deployer");
        dep.handOff(l2GovRelay);
    }

    function test_onlyDeployerCanSetAccountingType() public {
        vm.expectRevert("OFTDeployer/not-deployer");
        dep.setAccountingType(RateLimitAccountingType.Gross);
    }
}

interface OFTDeployerInitLike {
    function initialize(address delegate) external;
}

interface SkyOFTPauserLike {
    function pausers(address pauser) external view returns (bool);
}
