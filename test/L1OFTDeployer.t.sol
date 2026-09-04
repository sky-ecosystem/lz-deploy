// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import {
    LZInit,
    OftConfig,
    RateLimits,
    EndpointLike,
    OAppLike,
    OFTAdapterLike
} from "lz-init-lib/LZInit.sol";

import { L1OFTDeployer, L1OftDeployment, RemoteWiring } from "src/L1OFTDeployer.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

/// @notice Acceptance test for `L1OFTDeployer`: deploy the lockbox as the deployer would, then run
///         the governance-side check that gates the spell.
/// @dev    Covers what a lockbox has and an L2 adapter does not — the global (sentinel) cap and its
///         own accounting type. The shared wiring assertions live in `L2OFTDeployer.t.sol`.
contract L1OFTDeployerTest is LZDeployTestBase {

    address remotePeer = makeAddr("remotePeer");

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
            optionsGas: OPTIONS_GAS
        });

        dep      = _deploy(RateLimitAccountingType.Net, RateLimitAccountingType.Gross, globalLimits);
        oft      = address(dep.oft());
        sentinel = OFTAdapterLike(oft).SENTINEL_EID();
    }

    function _deploy(
        RateLimitAccountingType accountingType,
        RateLimitAccountingType aggregateAccountingType,
        RateLimits       memory limits
    ) internal returns (L1OFTDeployer) {
        RemoteWiring[] memory remotes = new RemoteWiring[](1);
        remotes[0] = RemoteWiring(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));

        return new L1OFTDeployer(L1OftDeployment({
            token:                   USDS,
            accountingType:          accountingType,
            aggregateAccountingType: aggregateAccountingType,
            globalLimits:            limits,
            pausers:                 new address[](0),
            remotes:                 remotes
        }));
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    function test_activateOftAcceptsDeployedState() public {
        RateLimits memory perEid = RateLimits(1 days, 5_000_000e18, 1 days, 4_000_000e18);

        // `startPrank`, not `prank`: the library call is inlined here and makes many external calls.
        vm.startPrank(PAUSE_PROXY);
        LZInit.activateOft({
            oft:              oft,
            oftImp:           address(dep.implementation()),
            remoteEid:        DST_EID,
            cfg:              oftCfg,
            rateLimits:       perEid,
            rlAccountingType: uint8(RateLimitAccountingType.Net),
            token:            USDS,
            owner:            PAUSE_PROXY,
            endpoint:         ENDPOINT
        });
        vm.stopPrank();

        (,, , uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(DST_EID);
        assertEq(outLimit, perEid.outboundLimit, "per-eid limit not activated");
    }

    // ==================================
    //  Lockbox specifics
    // ==================================

    /// @dev The sentinel bucket is what makes this a lockbox: an unset one blocks every transfer.
    function test_setsGlobalCap() public view {
        (, uint48 outWindow,, uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(sentinel);
        (, uint48 inWindow,,  uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(sentinel);
        assertEq(outLimit,  globalLimits.outboundLimit);
        assertEq(outWindow, globalLimits.outboundWindow);
        assertEq(inLimit,   globalLimits.inboundLimit);
        assertEq(inWindow,  globalLimits.inboundWindow);
    }

    /// @dev Independent of the per-eid type, which stays `Net` here.
    function test_setsAggregateAccountingTypeIndependently() public view {
        assertEq(OFTAdapterLike(oft).rateLimitAccountingType(),          uint8(RateLimitAccountingType.Net));
        assertEq(SkyLockboxLike(oft).aggregateRateLimitAccountingType(), uint8(RateLimitAccountingType.Gross));
    }

    /// @dev Zero leaves the cap to a spell, which is the avax-migration shape.
    function test_leavesGlobalCapZeroWhenAsked() public {
        address zeroCap = address(_deploy(
            RateLimitAccountingType.Net, RateLimitAccountingType.Net, RateLimits(0, 0, 0, 0)
        ).oft());

        (,, , uint256 outLimit) = OFTAdapterLike(zeroCap).outboundRateLimits(sentinel);
        assertEq(outLimit, 0);
    }

    // ==================================
    //  Deployment
    // ==================================

    function test_deploysProxyAndHandsOff() public view {
        assertTrue(oft != address(dep.implementation()), "proxy must not be the implementation");

        assertEq(OFTAdapterLike(oft).token(), USDS);
        assertEq(OAppLike(oft).endpoint(),    ENDPOINT);

        assertEq(OFTAdapterLike(oft).owner(),           PAUSE_PROXY);
        assertEq(EndpointLike(ENDPOINT).delegates(oft), PAUSE_PROXY);
    }
}

interface SkyLockboxLike {
    function aggregateRateLimitAccountingType() external view returns (uint8);
}
