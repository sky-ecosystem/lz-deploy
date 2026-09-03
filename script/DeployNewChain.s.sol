// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { OftConfig, RateLimits, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

import { L2OFTDeployer, L2OftDeployment, RemoteWiring } from "src/L2OFTDeployer.sol";
import { GovBridgeDeployer, GovRecvConfig }         from "src/GovBridgeDeployer.sol";

/// @notice Brings a new chain onto SkyLink: its half of the governance bridge, plus one OFT adapter
///         per token, wired to every remote it serves at go-live and handed to the new relay.
/// @dev    Run on the NEW chain. The L1 and incumbent-L2 sides come afterwards, as a spell
///         (`LZInit.wireGovPeer`, `wireOftPeer`, `activateOft`) using the addresses printed here.
///
///         Template: the constants and `_remotes()` below are per-chain and must be filled in and
///         reviewed per deployment. They are explicit rather than defaulted because each value is
///         something a spell later asserts on-chain.
///
///         Nothing here is end-to-end testable before that spell: the far sides of the routes are
///         unwired and rate limits are 0.
///
///         Out of scope, but required for the bridge to work: USDS/sUSDS deployed on the new chain
///         with mint/burn authority granted to each adapter, and the receive-side DVN infrastructure
///         from `lz-gov-dvns-deploy` whose replicas go into the governance ULN config.
///
///           forge script script/DeployNewChain.s.sol:DeployNewChain \
///             --rpc-url <new_chain_rpc> --broadcast --verify
contract DeployNewChain is Script {

    // ============================ FILL IN: chain constants ============================

    address constant ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address constant SEND_LIB = address(0); // SendUln302
    address constant RECV_LIB = address(0); // ReceiveUln302
    address constant EXECUTOR = address(0);

    address constant USDS  = address(0);
    address constant SUSDS = address(0);

    // ============================ FILL IN: L1 references ============================

    address constant L1_GOV_SENDER = address(0); // chainlog LZ_GOV_SENDER
    address constant L1_GOV_RELAY  = address(0); // chainlog LZ_GOV_RELAY

    // ============================ FILL IN: governance relay ============================

    uint256 constant RELAY_DELAY        = 2 days;
    uint256 constant RELAY_GRACE_PERIOD = 30 days;

    /// @dev Addresses allowed to cancel queued governance actions.
    function _bud() internal pure returns (address[] memory bud) {
        bud = new address[](0);
    }

    // ============================ FILL IN: LayerZero config ============================

    uint32 constant MAX_MESSAGE_SIZE = 10_000;

    /// @dev Revisit per chain: the V2 adapters' inbound path does more work than V1 (see
    ///      sky-oapp-oft's OFT_V2_NOTES.md).
    uint128 constant OFT_OPTIONS_GAS = 130_000;

    uint64 constant OFT_SEND_CONFIRMATIONS = 15;
    uint64 constant OFT_RECV_CONFIRMATIONS = 15;
    uint64 constant GOV_RECV_CONFIRMATIONS = 15;

    /// @dev Threshold no single wing reaches alone; see lz-dvn-broadcaster's README for the weights.
    uint8 constant GOV_RECV_THRESHOLD = 8;

    /// @dev Governance receive side: LZ-aligned DVNs plus the CCIP and multisig `DVNReplica`s.
    ///      Sorted ascending.
    function _govRecvDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0);
    }

    /// @dev OFT routes use third-party DVNs directly. Sorted ascending.
    function _oftRequiredDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0);
    }

    /// @dev Every remote this chain's OFTs must serve at go-live: L1 plus every incumbent L2. A spell
    ///      wiring the new chain only configures the sides that already exist, so these legs are set
    ///      up here.
    struct Remote {
        string  name;
        uint32  eid;
        address usdsPeer;
        address susdsPeer;
    }

    function _remotes() internal pure returns (Remote[] memory remotes) {
        remotes = new Remote[](0);
        // remotes = new Remote[](2);
        // remotes[0] = Remote("ethereum",  30101, USDS_OFT_L1,   SUSDS_OFT_L1);
        // remotes[1] = Remote("avalanche", 30106, USDS_OFT_AVAX, SUSDS_OFT_AVAX);
    }

    // ============================ script ============================

    function run() external {
        Remote[] memory remotes = _remotes();
        require(remotes.length > 0, "DeployNewChain/no-remotes");

        vm.startBroadcast();

        GovBridgeDeployer govDep = new GovBridgeDeployer({
            endpoint:    ENDPOINT,
            l1GovSender: L1_GOV_SENDER,
            l1GovRelay:  L1_GOV_RELAY,
            delay:       RELAY_DELAY,
            gracePeriod: RELAY_GRACE_PERIOD,
            bud:         _bud(),
            cfg:         GovRecvConfig({
                recvLib:    RECV_LIB,
                recvUlnCfg: UlnConfig({
                    confirmations:        GOV_RECV_CONFIRMATIONS,
                    requiredDVNCount:     255,  // NIL: explicitly no required DVNs
                    optionalDVNCount:     uint8(_govRecvDVNs().length),
                    optionalDVNThreshold: GOV_RECV_THRESHOLD,
                    requiredDVNs:         new address[](0),
                    optionalDVNs:         _govRecvDVNs()
                })
            })
        });

        address relay = address(govDep.relay());

        RemoteWiring[] memory usdsRemotes  = new RemoteWiring[](remotes.length);
        RemoteWiring[] memory susdsRemotes = new RemoteWiring[](remotes.length);

        // Rate limits stay at zero: governance turns the bridge on with `activateOft`, which verifies
        // the whole config and requires them to still be zero. Pass `Gross` below if a chain wants
        // that instead of the default `Net`.
        for (uint256 i; i < remotes.length; ++i) {
            usdsRemotes[i]  = RemoteWiring(remotes[i].eid, _oftCfg(remotes[i].usdsPeer),  _zeroLimits());
            susdsRemotes[i] = RemoteWiring(remotes[i].eid, _oftCfg(remotes[i].susdsPeer), _zeroLimits());
        }

        L2OFTDeployer usdsDep  = new L2OFTDeployer(L2OftDeployment({
            token:          USDS,
            endpoint:       ENDPOINT,
            accountingType: RateLimitAccountingType.Net,
            pausers:        _pausers(),
            remotes:        usdsRemotes,
            gov:            relay
        }));
        L2OFTDeployer susdsDep = new L2OFTDeployer(L2OftDeployment({
            token:          SUSDS,
            endpoint:       ENDPOINT,
            accountingType: RateLimitAccountingType.Net,
            pausers:        _pausers(),
            remotes:        susdsRemotes,
            gov:            relay
        }));

        vm.stopBroadcast();

        console.log("--- governance bridge ---");
        console.log("GovBridgeDeployer:      ", address(govDep));
        console.log("GovernanceOAppReceiver: ", address(govDep.receiver()));
        console.log("L2GovernanceRelay:      ", relay);
        console.log("LZL2Spell:              ", address(govDep.l2Spell()));
        console.log("--- OFT adapters ---");
        console.log("USDS  L2OFTDeployer:    ", address(usdsDep));
        console.log("USDS  adapter:          ", address(usdsDep.oft()));
        console.log("USDS  implementation:   ", address(usdsDep.implementation()));
        console.log("SUSDS L2OFTDeployer:    ", address(susdsDep));
        console.log("SUSDS adapter:          ", address(susdsDep.oft()));
        console.log("SUSDS implementation:   ", address(susdsDep.implementation()));
        console.log("--- wired remotes ---");
        for (uint256 i; i < remotes.length; ++i) {
            console.log(remotes[i].name, remotes[i].eid);
        }
        console.log("");
        console.log("Next: grant the adapters mint/burn authority over the tokens, then the L1 spell");
        console.log("(wireGovPeer + wireOftPeer, and activateOft to set rate limits).");
    }

    // --- helpers ---

    function _oftCfg(address peer) internal pure returns (OftConfig memory) {
        return OftConfig({
            peer:       peer,
            sendLib:    SEND_LIB,
            execCfg:    ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: EXECUTOR }),
            sendUlnCfg: UlnConfig({
                confirmations:        OFT_SEND_CONFIRMATIONS,
                requiredDVNCount:     uint8(_oftRequiredDVNs().length),
                optionalDVNCount:     0,
                optionalDVNThreshold: 0,
                requiredDVNs:         _oftRequiredDVNs(),
                optionalDVNs:         new address[](0)
            }),
            recvLib:    RECV_LIB,
            recvUlnCfg: UlnConfig({
                confirmations:        OFT_RECV_CONFIRMATIONS,
                requiredDVNCount:     uint8(_oftRequiredDVNs().length),
                optionalDVNCount:     0,
                optionalDVNThreshold: 0,
                requiredDVNs:         _oftRequiredDVNs(),
                optionalDVNs:         new address[](0)
            }),
            optionsGas: OFT_OPTIONS_GAS
        });
    }

    /// @dev None by default; pausing is a per-chain operational choice.
    function _pausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    function _zeroLimits() internal pure returns (RateLimits memory) {
        return RateLimits({ inboundWindow: 0, inboundLimit: 0, outboundWindow: 0, outboundLimit: 0 });
    }
}
