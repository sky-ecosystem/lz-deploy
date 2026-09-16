// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import {
    LZInit,
    OftConfig,
    RateLimits,
    OFTAdapterLike
} from "lz-init-lib/LZInit.sol";

import { L2OFTDeployer, L2OftDeployment, RemoteWiring } from "src/L2OFTDeployer.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

interface SkyOFTPauserLike {
    function pausers(address pauser) external view returns (bool);
}

/// @notice Acceptance test for `L2OFTDeployer`: deploy as the deployer would, then run the
///         governance-side function the spell itself calls.
/// @dev    `activateOft` re-reads the whole config for one remote and reverts on any mismatch, each
///         with its own message, so running it per remote is the statement that the deployer's output
///         matches its inputs. The pauser set is all it never looks at.
contract L2OFTDeployerTest is LZDeployTestBase {

    address l2GovRelay = makeAddr("l2GovRelay");
    address remotePeer = makeAddr("remotePeer");
    address breaker    = makeAddr("breaker");

    uint32 constant OTHER_EID = 30106; // Avalanche, as a second remote at go-live

    L2OFTDeployer dep;
    address       oft;

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
            optionsGas: OFT_OPTIONS_GAS
        });

        dep = new L2OFTDeployer(_deployment());
        oft = address(dep.oft());
    }

    /// @dev The fixture's inputs; each scenario below changes the one field it is about.
    function _deployment() internal view returns (L2OftDeployment memory) {
        RemoteWiring[] memory remotes = new RemoteWiring[](2);
        remotes[0] = RemoteWiring(DST_EID,   oftCfg, RateLimits(0, 0, 0, 0));
        remotes[1] = RemoteWiring(OTHER_EID, oftCfg, RateLimits(0, 0, 0, 0));

        address[] memory pausers = new address[](1);
        pausers[0] = breaker;

        return L2OftDeployment({
            token:          USDS,
            endpoint:       ENDPOINT,
            accountingType: RateLimitAccountingType.Gross,
            pausers:        pausers,
            remotes:        remotes,
            gov:            l2GovRelay
        });
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    function test_activateOftAcceptsEveryRemote() public {
        RateLimits memory limits = RateLimits({
            inboundWindow:  1 days,
            inboundLimit:   10_000_000e18,
            outboundWindow: 1 days + 1,
            outboundLimit:  10_000_000e18 + 1
        });

        uint32[2] memory eids = [DST_EID, OTHER_EID];

        for (uint256 i; i < eids.length; ++i) {
            // Zero until the spell runs: `activateOft` requires that, and is what opens them.
            (, uint48 outWindow,, uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(eids[i]);
            (, uint48 inWindow,,  uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(eids[i]);
            assertEq(outLimit,  0);
            assertEq(outWindow, 0);
            assertEq(inLimit,   0);
            assertEq(inWindow,  0);

            vm.startPrank(l2GovRelay);
            LZInit.activateOft({
                oft:              oft,
                oftImp:           dep.implementation(),
                remoteEid:        eids[i],
                cfg:              oftCfg,
                rateLimits:       limits,
                rlAccountingType: uint8(RateLimitAccountingType.Gross),
                token:            USDS,
                owner:            l2GovRelay,
                endpoint:         ENDPOINT
            });
            vm.stopPrank();

            (, outWindow,, outLimit) = OFTAdapterLike(oft).outboundRateLimits(eids[i]);
            (, inWindow,,  inLimit)  = OFTAdapterLike(oft).inboundRateLimits(eids[i]);
            assertEq(outLimit,  limits.outboundLimit,  "outbound limit not activated");
            assertEq(outWindow, limits.outboundWindow, "outbound window not activated");
            assertEq(inLimit,   limits.inboundLimit,   "inbound limit not activated");
            assertEq(inWindow,  limits.inboundWindow,  "inbound window not activated");
        }
    }

    // ==================================
    //  Deployment
    // ==================================

    function test_setsPausers() public view {
        assertTrue(SkyOFTPauserLike(oft).pausers(breaker));
    }

    /// @dev The other model: live at handoff, with no `activateOft` to follow.
    function test_setsPerRemoteRateLimits() public {
        L2OftDeployment memory d = _deployment();
        d.remotes[0].rateLimits  = RateLimits(1 days, 5e18, 1 days + 1, 4e18);

        address live = address(new L2OFTDeployer(d).oft());

        (, uint48 outWindow,, uint256 outLimit) = OFTAdapterLike(live).outboundRateLimits(DST_EID);
        (, uint48 inWindow,,  uint256 inLimit)  = OFTAdapterLike(live).inboundRateLimits(DST_EID);
        assertEq(outLimit,  4e18);
        assertEq(outWindow, 1 days + 1);
        assertEq(inLimit,   5e18);
        assertEq(inWindow,  1 days);
    }

    function test_revertsOnDuplicateRemote() public {
        L2OftDeployment memory d = _deployment();
        d.remotes    = new RemoteWiring[](2);
        d.remotes[0] = RemoteWiring(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));
        d.remotes[1] = RemoteWiring(DST_EID, oftCfg, RateLimits(0, 0, 0, 0));

        vm.expectRevert("LZInit/already-wired");
        new L2OFTDeployer(d);
    }
}
