// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import {
    LZInit,
    GovConfig,
    UlnConfig,
    EndpointLike,
    UlnLike,
    OAppLike
} from "lz-init-lib/LZInit.sol";
import { LZL2Spell } from "lz-init-lib/LZL2Spell.sol";

import { Bridge }                from "xchain-helpers/testing/Bridge.sol";
import { Domain, DomainHelpers } from "xchain-helpers/testing/Domain.sol";
import { LZBridgeTesting }       from "xchain-helpers/testing/bridges/LZBridgeTesting.sol";

import { L2GovBridgeDeployer, GovRecvConfig } from "src/L2GovBridgeDeployer.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

interface L2GovernanceRelayLike {
    function l1Eid() external view returns (uint32);
    function l2Oapp() external view returns (address);
    function l1GovernanceRelay() external view returns (address);
    function delay() external view returns (uint256);
    function gracePeriod() external view returns (uint256);
    function bud(address usr) external view returns (uint256);
    function exec(uint256 actionId) external;
}

interface OwnableLike {
    function owner() external view returns (address);
}

interface GovSenderLike {
    function canCallTarget(address srcSender, uint32 dstEid, bytes32 dstTarget) external view returns (bool);
}

/// @notice Acceptance test for `L2GovBridgeDeployer`: deploy the new chain's half of the governance
///         bridge as the deployer would, run the mainnet function the spell itself calls, and carry
///         one governance action across.
/// @dev    Two forks, since the action has to cross. Nothing on a remote chain can be read by a
///         mainnet spell, so the receiver and the relay its constructor deploys are asserted directly.
///         The peer is the real chainlog `LZ_GOV_SENDER`, which is what lets `wireGovPeer` run
///         against them.
contract L2GovBridgeDeployerTest is LZDeployTestBase {

    using DomainHelpers   for *;
    using LZBridgeTesting for *;

    address deployerEOA = makeAddr("deployerEOA");
    address freezer     = makeAddr("freezer");

    uint256 constant DELAY        = 2 days;
    uint256 constant GRACE_PERIOD = 30 days;

    uint128 constant RELAY_GAS     = 500_000;
    uint256 constant RELAY_MAX_FEE = 1 ether;

    Domain remote;
    Bridge bridge;

    L2GovBridgeDeployer dep;
    address           receiver;
    address           relay;
    address           l2Spell;

    GovRecvConfig recvCfg;

    function setUp() public override {
        super.setUp();

        remote = getChain("base").createFork(REMOTE_FORK_BLOCK);
        bridge = LZBridgeTesting.createLZBridge(mainnet, remote);

        recvCfg = GovRecvConfig({ recvLib: REMOTE_RECV_LIB, recvUlnCfg: remoteGovUlnCfg });

        address[] memory bud = new address[](1);
        bud[0] = freezer;

        remote.selectFork();

        vm.prank(deployerEOA);
        dep = new L2GovBridgeDeployer({
            endpoint:    ENDPOINT,
            l1GovSender: GOV_SENDER,
            l1GovRelay:  L1_GOV_RELAY,
            delay:       DELAY,
            gracePeriod: GRACE_PERIOD,
            bud:         bud,
            cfg:         recvCfg
        });

        receiver = address(dep.receiver());
        relay    = dep.relay();

        // Stateless and unowned, as a real bring-up leaves it: what the relay delegatecalls.
        l2Spell = address(new LZL2Spell());

        mainnet.selectFork();
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    /// @dev `wireGovPeer` completes the bridge and consumes both addresses this deployer produces:
    ///      the receiver as peer, the relay as the whitelisted target. `NO_CCIP_DVN` skips the shared
    ///      CCIP adapter's route check, which is configured outside this repo.
    function test_wireGovPeerAcceptsDeployedReceiver() public {
        assertEq(OAppLike(GOV_SENDER).peers(DST_EID), bytes32(0), "route must not exist yet");
        assertFalse(
            GovSenderLike(GOV_SENDER).canCallTarget(L1_GOV_RELAY, DST_EID, bytes32(uint256(uint160(relay)))),
            "L1 relay must not be whitelisted yet"
        );

        vm.startPrank(PAUSE_PROXY);
        LZInit.wireGovPeer(DST_EID, _govCfg());
        vm.stopPrank();

        assertEq(OAppLike(GOV_SENDER).peers(DST_EID), bytes32(uint256(uint160(receiver))));
        assertTrue(
            GovSenderLike(GOV_SENDER).canCallTarget(L1_GOV_RELAY, DST_EID, bytes32(uint256(uint160(relay)))),
            "L1 relay must be whitelisted to call the L2 relay"
        );
    }

    /// @dev The bridge end to end: a relayed action reaches the receiver, queues on the relay, and
    ///      applies once the delay has passed. The action reconfigures the receiver's own DVN set,
    ///      which the relay can do because the deployer left it as the endpoint delegate.
    function test_relayedActionExecutesAfterTheDelay() public {
        UlnConfig memory newCfg = remoteGovUlnCfg;
        newCfg.optionalDVNThreshold = 5;

        bytes memory targetData = abi.encodeCall(
            LZL2Spell.setUlnConfig,
            (receiver, ETH_EID, REMOTE_RECV_LIB, newCfg)
        );

        vm.deal(L1_GOV_RELAY, RELAY_MAX_FEE);

        vm.startPrank(PAUSE_PROXY);
        LZInit.wireGovPeer(DST_EID, _govCfg());
        LZInit.relayToL2(DST_EID, relay, l2Spell, targetData, RELAY_GAS, RELAY_MAX_FEE);
        vm.stopPrank();

        bridge.relayMessagesToDestination(true, GOV_SENDER, receiver);

        _assertUlnConfig(
            abi.encode(UlnLike(REMOTE_RECV_LIB).getAppUlnConfig(receiver, ETH_EID)),
            remoteGovUlnCfg
        );

        vm.warp(block.timestamp + DELAY);
        L2GovernanceRelayLike(relay).exec(0);

        _assertUlnConfig(
            abi.encode(UlnLike(REMOTE_RECV_LIB).getAppUlnConfig(receiver, ETH_EID)),
            newCfg
        );
    }

    // ==================================
    //  Deployment
    // ==================================

    function test_deploysWiresAndHandsOffBridge() public {
        remote.selectFork();

        assertEq(OAppLike(receiver).peers(ETH_EID), bytes32(uint256(uint160(GOV_SENDER))));
        assertEq(OAppLike(receiver).endpoint(),     ENDPOINT);

        L2GovernanceRelayLike r = L2GovernanceRelayLike(relay);

        assertEq(r.l1Eid(),             ETH_EID);
        assertEq(r.l2Oapp(),            receiver, "relay must listen to the receiver we deployed");
        assertEq(r.l1GovernanceRelay(), L1_GOV_RELAY);
        assertEq(r.delay(),             DELAY);
        assertEq(r.gracePeriod(),       GRACE_PERIOD);
        assertEq(r.bud(freezer),        1, "freezer must be budded");

        (address recvLib, bool isDefault) = EndpointLike(ENDPOINT).getReceiveLibrary(receiver, ETH_EID);
        assertEq(recvLib, REMOTE_RECV_LIB);
        assertFalse(isDefault, "receive library must be set explicitly, not inherited");
        assertEq(EndpointLike(ENDPOINT).receiveLibraryTimeout(receiver, ETH_EID), address(0));

        _assertUlnConfig(
            abi.encode(UlnLike(REMOTE_RECV_LIB).getAppUlnConfig(receiver, ETH_EID)),
            remoteGovUlnCfg
        );

        assertEq(OwnableLike(receiver).owner(),              relay, "relay must own the receiver");
        assertEq(EndpointLike(ENDPOINT).delegates(receiver), relay, "relay must be the delegate");
    }

    // --- helpers ---

    function _govCfg() internal view returns (GovConfig memory) {
        return GovConfig({
            peer:         receiver,
            sendLib:      SEND_LIB,
            execCfg:      execCfg,
            sendUlnCfg:   govUlnCfg,
            ccipDvnIndex: LZInit.NO_CCIP_DVN,
            l2GovRelay:   relay
        });
    }
}
