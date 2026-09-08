// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import {
    LZInit,
    OftConfig,
    RateLimits,
    OFTAdapterLike
} from "lz-init-lib/LZInit.sol";

import { L1OFTDeployer, L1OftDeployment, RemoteWiring } from "src/L1OFTDeployer.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

interface SkyLockboxLike {
    function aggregateRateLimitAccountingType() external view returns (uint8);
}

interface SkyOFTPauserLike {
    function pausers(address pauser) external view returns (bool);
}

/// @notice Acceptance test for `L1OFTDeployer`: deploy the lockbox as the deployer would, then run
///         the governance-side function the spell itself calls.
/// @dev    `activateOft` re-reads the per-remote config and the handoff, so what is asserted
///         directly is only what it does not look at: the sentinel cap and its own accounting type,
///         and the pauser set. The endpoint this deployer derives from the chainlog is one of the
///         things it checks, against the address the acceptance test passes in.
contract L1OFTDeployerTest is LZDeployTestBase {

    address remotePeer = makeAddr("remotePeer");
    address breaker    = makeAddr("breaker");

    uint32 constant OTHER_EID = 30106; // Avalanche, as a second remote at go-live

    L1OFTDeployer dep;
    address       oft;
    uint32        sentinel;

    OftConfig  oftCfg;
    RateLimits globalLimits = RateLimits(1 days, 9_000_000e18, 1 days, 8_000_000e18);

    function setUp() public override {
        super.setUp();

        oftCfg = OftConfig({
            peer:       remotePeer,
            sendLib:    SEND_LIB,
            execCfg:    execCfg,
            sendUlnCfg: oftSendUlnCfg,
            recvLib:    RECV_LIB,
            recvUlnCfg: oftRecvUlnCfg,
            optionsGas: OFT_OPTIONS_GAS
        });

        dep      = new L1OFTDeployer(_deployment());
        oft      = address(dep.oft());
        sentinel = OFTAdapterLike(oft).SENTINEL_EID();
    }

    /// @dev The fixture's inputs; each scenario below changes the one field it is about.
    function _deployment() internal view returns (L1OftDeployment memory) {
        RemoteWiring[] memory remotes = new RemoteWiring[](2);
        remotes[0] = RemoteWiring(DST_EID,   oftCfg, RateLimits(0, 0, 0, 0));
        remotes[1] = RemoteWiring(OTHER_EID, oftCfg, RateLimits(0, 0, 0, 0));

        address[] memory pausers = new address[](1);
        pausers[0] = breaker;

        return L1OftDeployment({
            token:                   USDS,
            accountingType:          RateLimitAccountingType.Net,
            aggregateAccountingType: RateLimitAccountingType.Gross,
            globalLimits:            globalLimits,
            pausers:                 pausers,
            remotes:                 remotes
        });
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    function test_activateOftAcceptsEveryRemote() public {
        RateLimits memory perEid = RateLimits(1 days, 5_000_000e18, 1 days, 4_000_000e18);

        uint32[2] memory eids = [DST_EID, OTHER_EID];

        for (uint256 i; i < eids.length; ++i) {
            // Zero until the spell runs: `activateOft` requires that, and is what opens them.
            (,,, uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(eids[i]);
            (,,, uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(eids[i]);
            assertEq(outLimit, 0);
            assertEq(inLimit,  0);

            vm.startPrank(PAUSE_PROXY);
            LZInit.activateOft({
                oft:              oft,
                oftImp:           address(dep.implementation()),
                remoteEid:        eids[i],
                cfg:              oftCfg,
                rateLimits:       perEid,
                rlAccountingType: uint8(RateLimitAccountingType.Net),
                token:            USDS,
                owner:            PAUSE_PROXY,
                endpoint:         ENDPOINT
            });
            vm.stopPrank();

            (,,, outLimit) = OFTAdapterLike(oft).outboundRateLimits(eids[i]);
            (,,, inLimit)  = OFTAdapterLike(oft).inboundRateLimits(eids[i]);
            assertEq(outLimit, perEid.outboundLimit, "outbound limit not activated");
            assertEq(inLimit,  perEid.inboundLimit,  "inbound limit not activated");
        }
    }

    // ==================================
    //  Deployment
    // ==================================

    function test_deploysAndConfiguresLockbox() public view {
        assertEq(SkyLockboxLike(oft).aggregateRateLimitAccountingType(), uint8(RateLimitAccountingType.Gross));

        assertTrue(SkyOFTPauserLike(oft).pausers(breaker));

        (, uint48 outWindow,, uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(sentinel);
        (, uint48 inWindow,,  uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(sentinel);
        assertEq(outLimit,  globalLimits.outboundLimit);
        assertEq(outWindow, globalLimits.outboundWindow);
        assertEq(inLimit,   globalLimits.inboundLimit);
        assertEq(inWindow,  globalLimits.inboundWindow);
    }

    /// @dev The other model: live at handoff, with no `activateOft` to follow.
    function test_setsPerRemoteRateLimits() public {
        L1OftDeployment memory d = _deployment();
        d.remotes[0].rateLimits  = RateLimits(1 days, 5e18, 1 days, 4e18);

        address live = address(new L1OFTDeployer(d).oft());

        (,,, uint256 outLimit) = OFTAdapterLike(live).outboundRateLimits(DST_EID);
        (,,, uint256 inLimit)  = OFTAdapterLike(live).inboundRateLimits(DST_EID);
        assertEq(outLimit, 4e18);
        assertEq(inLimit,  5e18);
    }

    function test_revertsOnDuplicateRemote() public {
        L1OftDeployment memory d = _deployment();
        d.remotes    = new RemoteWiring[](2);
        d.remotes[0] = RemoteWiring(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));
        d.remotes[1] = RemoteWiring(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));

        vm.expectRevert("LZInit/already-wired");
        new L1OFTDeployer(d);
    }
}
