// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { console } from "forge-std/Script.sol";

import {
    LZInit,
    GovConfig,
    RateLimits,
    UlnConfig,
    ExecutorConfig,
    OFTAdapterLike
} from "lz-init-lib/LZInit.sol";
import { LZL2Spell } from "lz-init-lib/LZL2Spell.sol";

import { Bridge }                from "xchain-helpers/testing/Bridge.sol";
import { Domain, DomainHelpers } from "xchain-helpers/testing/Domain.sol";
import { LZBridgeTesting }       from "xchain-helpers/testing/bridges/LZBridgeTesting.sol";

import { GovDvnSet }      from "script/GovDvnSet.sol";
import { LzDvns }         from "script/LzDvns.sol";
import { DeployNewChain } from "script/DeployNewChain.s.sol";
import {
    SendSideDeployer,
    CCIPDVNCfg
} from "script/mocks/DvnDeployersFlat.sol";

interface RelayLike {
    function exec(uint256 actionId) external;
}

/// @notice Runs `DeployNewChain`, then the spell that consumes what it deployed, on both sides:
///
///           anvil --fork-url <mainnet> --port 8545 --silent &
///           anvil --fork-url <remote>  --port 8547 --silent &
///           until cast block-number --rpc-url http://localhost:8547 >/dev/null 2>&1; do sleep 1; done
///
///           MAINNET_RPC_URL=http://localhost:8545 BASE_RPC_URL=http://localhost:8547 \
///             forge script script/test/CheckDeployNewChain.s.sol:CheckDeployNewChain \
///             --sig "check()" --rpc-url http://localhost:8545 --sender <a funded account>
///
///           pkill -f "anvil --fork-url"
contract CheckDeployNewChain is DeployNewChain {

    using DomainHelpers   for *;
    using LZBridgeTesting for *;

    Domain mainnet;
    Bridge bridge;

    /// @dev The shared CCIP DVN adapter this template only reads: the Avalanche migration deploys it,
    ///      so a check that runs before that has to stand in for it.
    address ccipDvnAdapter;

    uint32  constant REMOTE_EID           = 30184;
    uint64  constant REMOTE_CCIP_SELECTOR = 15971525489660198786;

    address constant ETH_SEND_LIB = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1;
    address constant ETH_EXECUTOR = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    uint128 constant CCIP_GAS     = 200_000;
    uint256 constant ADAPTER_FUND = 0.001 ether;

    uint128 constant RELAY_GAS     = 500_000;
    uint256 constant RELAY_MAX_FEE = 1 ether;

    function _ethCcipDvnAdapter() internal view override returns (address) {
        return ccipDvnAdapter;
    }

    function _skyMultisig() internal pure override returns (address) {
        return address(0xAAa1);
    }

    function check() external {
        mainnet = Domain({ chain: getChain("mainnet"), forkId: vm.activeFork() });

        address govSender  = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        address pauseProxy = LZInit.chainlog.getAddress("MCD_PAUSE_PROXY");
        address usdsOft    = LZInit.chainlog.getAddress("USDS_OFT");
        address susdsOft   = LZInit.chainlog.getAddress("SUSDS_OFT");

        // The migration's mainnet half, which this chain's replicas verify against.
        address[] memory allowed = new address[](1);
        allowed[0] = govSender;
        SendSideDeployer sendDep = new SendSideDeployer(ETH_SEND_LIB, allowed);
        ccipDvnAdapter = address(sendDep.adapter());

        (Deployed memory d, uint256 remoteFork) = run();

        bridge = LZBridgeTesting.createLZBridge(
            mainnet,
            Domain({ chain: getChain("base"), forkId: remoteFork })
        );

        // --- mainnet: the adapter's route to this chain, then the spell ---
        mainnet.selectFork();

        sendDep.configure(CCIPDVNCfg({
            remoteEid:               REMOTE_EID,
            remoteCcipChainSelector: REMOTE_CCIP_SELECTOR,
            remoteCcipAdapter:       d.ccipDvnAdapter,
            remoteCcipBroadcaster:   d.ccipBroadcaster,
            sendLib:                 ETH_SEND_LIB,
            multiplierBps:           0,
            gas:                     CCIP_GAS
        }));
        vm.deal(ccipDvnAdapter, ADAPTER_FUND);
        sendDep.handOff(new address[](0));

        vm.deal(LZInit.chainlog.getAddress("LZ_GOV_RELAY"), RELAY_MAX_FEE);

        vm.startPrank(pauseProxy);
        LZInit.wireGovPeer(REMOTE_EID, _govCfg(d));
        LZInit.relayToL2({
            remoteEid:  REMOTE_EID,
            l2GovRelay: d.relay,
            l2Spell:    d.l2Spell,
            targetData: _activationCalls(d, usdsOft, susdsOft),
            gas:        RELAY_GAS,
            maxFee:     RELAY_MAX_FEE
        });
        vm.stopPrank();

        // --- the new chain: the action the relay queues, executed once its delay has passed ---
        bridge.relayMessagesToDestination(true, govSender, d.receiver);

        vm.warp(block.timestamp + RELAY_DELAY);
        RelayLike(d.relay).exec(0);

        _assertActivated(d.usdsAdapter);
        _assertActivated(d.susdsAdapter);

        console.log("");
        console.log("wireGovPeer and the relayed activateOft accepted the deployed state");
    }

    // --- helpers ---

    function _govCfg(Deployed memory d) internal view returns (GovConfig memory) {
        (address[] memory dvns, uint256 ccipDvnIndex) =
            GovDvnSet.insertSorted(LzDvns.ethGovDVNs(), ccipDvnAdapter);

        return GovConfig({
            peer:         d.receiver,
            sendLib:      ETH_SEND_LIB,
            execCfg:      ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: ETH_EXECUTOR }),
            sendUlnCfg:   UlnConfig({
                confirmations:        ETH_CONFIRMATIONS,
                requiredDVNCount:     255,       // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(dvns.length),
                optionalDVNThreshold: uint8(dvns.length),
                requiredDVNs:         new address[](0),
                optionalDVNs:         dvns
            }),
            ccipDvnIndex: ccipDvnIndex,
            l2GovRelay:   d.relay
        });
    }

    /// @dev Both adapters in one action, as the spell relays it.
    function _activationCalls(Deployed memory d, address usdsOft, address susdsOft)
        internal pure returns (bytes memory)
    {
        bytes[] memory calls = new bytes[](2);
        calls[0] = _activation(d.usdsAdapter,  d.usdsAdapterImp,  d.usds,  usdsOft,  d.relay);
        calls[1] = _activation(d.susdsAdapter, d.susdsAdapterImp, d.susds, susdsOft, d.relay);

        return abi.encodeCall(LZL2Spell.multicall, (calls));
    }

    function _activation(address oft, address oftImp, address token, address peer, address relay)
        internal pure returns (bytes memory)
    {
        return abi.encodeCall(LZL2Spell.activateOft, (
            oft,
            oftImp,
            ETH_EID,
            _remoteOftCfg(peer),
            _limits(),
            uint8(PER_EID_ACCOUNTING),
            token,
            relay,
            ENDPOINT
        ));
    }

    function _assertActivated(address oft) internal view {
        (, uint48 outWindow,, uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(ETH_EID);
        (, uint48 inWindow,,  uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(ETH_EID);

        RateLimits memory rl = _limits();

        require(outLimit  == rl.outboundLimit,  "CheckDeployNewChain/outbound-limit-not-activated");
        require(outWindow == rl.outboundWindow, "CheckDeployNewChain/outbound-window-not-activated");
        require(inLimit   == rl.inboundLimit,   "CheckDeployNewChain/inbound-limit-not-activated");
        require(inWindow  == rl.inboundWindow,  "CheckDeployNewChain/inbound-window-not-activated");
    }

    function _limits() internal pure returns (RateLimits memory) {
        return RateLimits(1 days, 1_000_000e18, 1 days + 1, 1_000_000e18 + 1);
    }
}
