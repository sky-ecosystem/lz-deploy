// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";
import { LZL2Spell }                                               from "lz-init-lib/LZL2Spell.sol";

import { UsdsDeploy }     from "usds/deploy/UsdsDeploy.sol";
import { UsdsL2Instance } from "usds/deploy/UsdsInstance.sol";
import { SUsdsDeploy }    from "sdai/deploy/l2/SUsdsDeploy.sol";
import { SUsdsInstance }  from "sdai/deploy/SUsdsInstance.sol";

import { L2OFTDeployer, L2OftDeployment, RemoteWiring } from "src/L2OFTDeployer.sol";
import { GovBridgeDeployer, GovRecvConfig }             from "src/GovBridgeDeployer.sol";

import { GovDvnSet } from "script/GovDvnSet.sol";

interface WardsLike {
    function rely(address usr) external;
    function deny(address usr) external;
}

/// @notice Brings a new chain onto SkyLink: its half of the governance bridge, plus one OFT adapter
///         per token, wired to every remote it serves at go-live and handed to the new relay.
/// @dev    Run on the NEW chain. The L1 and incumbent-L2 sides come afterwards, as a spell
///         (`LZInit.wireGovPeer`, `wireOftPeer`, `activateOft`) using the addresses printed here.
///
///         Template: the constants and `_extraRemotes()` below must be filled in and reviewed per
///         deployment. Nothing here is end-to-end testable before that spell: the far sides of the
///         routes are unwired and rate limits are 0.
///
///         Out of scope, but required beforehand: this chain's CCIP and multisig `DVNBroadcaster`s,
///         whose replicas make up the governance receive set read below.
///
///           forge script script/DeployNewChain.s.sol:DeployNewChain \
///             --rpc-url <new_chain_rpc> --broadcast --verify
contract DeployNewChain is Script {

    // ============================ FILL IN: chain constants ============================

    uint32  constant ETH_EID  = 30101;
    address constant ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c; // same address on every chain checked, but verify per chain
    /// @dev Unlike the endpoint, the ULN libraries differ on every chain; read them off the target
    ///      chain's endpoint (`defaultSendLibrary(dstEid)` / `defaultReceiveLibrary(dstEid)`).
    address constant SEND_LIB = address(0); // SendUln302
    address constant RECV_LIB = address(0); // ReceiveUln302
    address constant EXECUTOR = address(0);

    /// @dev The tokens the adapters mint and burn. Leave either at zero to have this script deploy
    ///      it, in which case it also relies the adapter and hands the token to the relay; set it to
    ///      a pre-existing token and both of those become someone else's step.
    address constant L2_USDS  = address(0);
    address constant L2_SUSDS = address(0);

    /// @dev The two `DVNBroadcaster`s deployed on this chain by lz-gov-dvns-deploy's
    ///      `RecvSideDeployer`. Their `DVNReplica`s are the governance receive set read below, so
    ///      they must exist before this script runs.
    address constant CCIP_BROADCASTER = address(0);
    address constant MSIG_BROADCASTER = address(0);

    // ============================ FILL IN: governance relay ============================

    uint256 constant RELAY_DELAY        = 2 days;
    uint256 constant RELAY_GRACE_PERIOD = 30 days;

    /// @dev Addresses allowed to cancel queued governance actions.
    function _bud() internal pure returns (address[] memory bud) {
        bud = new address[](0);
    }

    // ============================ FILL IN: LayerZero config ============================

    uint32 constant MAX_MESSAGE_SIZE = 10_000;

    /// @dev Revisit per remote: this gas is spent on the destination, and a lockbox's inbound path
    ///      costs more than an L2 adapter's because it also updates the global bucket.
    uint128 constant OFT_OPTIONS_GAS = 130_000;

    uint64 constant OFT_SEND_CONFIRMATIONS = 15;
    uint64 constant OFT_RECV_CONFIRMATIONS = 15;
    uint64 constant GOV_RECV_CONFIRMATIONS = 15;

    /// @dev Threshold no single wing reaches alone.
    uint8 constant GOV_RECV_THRESHOLD = 8;

    /// @dev The LZ-aligned DVNs that make up the rest of the governance receive set.
    function _govLzDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0);
    }

    /// @dev Governance receive side: the LZ DVNs plus both broadcasters' replicas.
    function _govRecvDVNs() internal view returns (address[] memory) {
        return GovDvnSet.read(CCIP_BROADCASTER, MSIG_BROADCASTER, _govLzDVNs());
    }

    /// @dev OFT routes use third-party DVNs directly. Sorted ascending.
    function _oftRequiredDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0);
    }

    struct Remote {
        string  name;
        uint32  eid;
        address usdsPeer;
        address susdsPeer;
    }

    /// @dev Remote-to-remote legs only; the Ethereum leg is added by `run()` from the chainlog. A spell
    ///      wiring this chain configures just the sides that already exist, so any other leg wanted at
    ///      go-live goes here.
    function _extraRemotes() internal pure returns (Remote[] memory remotes) {
        remotes = new Remote[](0);
        // remotes = new Remote[](1);
        // remotes[0] = Remote("avalanche", 30106, USDS_OFT_AVAX, SUSDS_OFT_AVAX);
    }

    // ============================ script ============================

    function run() external {
        // `address(0)` is LZ's "use the endpoint default" sentinel, so an unfilled library or executor
        // would configure silently and only be caught by the spell.
        require(SEND_LIB != address(0), "DeployNewChain/send-lib-unset");
        require(RECV_LIB != address(0), "DeployNewChain/recv-lib-unset");
        require(EXECUTOR != address(0), "DeployNewChain/executor-unset");

        uint256 newChainFork = vm.activeFork();

        // The chainlog is a mainnet contract, so the references come from a fork of it.
        uint256 l1Fork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(l1Fork);
        Remote memory ethereum = Remote({
            name:      "ethereum",
            eid:       ETH_EID,
            usdsPeer:  LZInit.chainlog.getAddress("USDS_OFT"),
            susdsPeer: LZInit.chainlog.getAddress("SUSDS_OFT")
        });
        vm.selectFork(newChainFork);

        Remote[] memory extra   = _extraRemotes();
        Remote[] memory remotes = new Remote[](extra.length + 1);
        remotes[0] = ethereum;
        for (uint256 i; i < extra.length; ++i) remotes[i + 1] = extra[i];

        address[] memory govDvns = _govRecvDVNs();

        vm.startBroadcast();

        GovBridgeDeployer govDep = new GovBridgeDeployer({
            endpoint:    ENDPOINT,
            delay:       RELAY_DELAY,
            gracePeriod: RELAY_GRACE_PERIOD,
            bud:         _bud(),
            cfg:         GovRecvConfig({
                recvLib:    RECV_LIB,
                recvUlnCfg: UlnConfig({
                    confirmations:        GOV_RECV_CONFIRMATIONS,
                    requiredDVNCount:     255,  // NIL: explicitly no required DVNs
                    optionalDVNCount:     uint8(govDvns.length),
                    optionalDVNThreshold: GOV_RECV_THRESHOLD,
                    requiredDVNs:         new address[](0),
                    optionalDVNs:         govDvns
                })
            })
        });

        address relay = govDep.relay();

        // Part of the bundle rather than of a deployer: stateless and unowned, so it only has to
        // exist and be known to the spell author.
        LZL2Spell l2Spell = new LZL2Spell();

        // Deployed here when unset, owned by this EOA for now: the adapters do not exist yet, so the
        // `rely` that lets them mint and the handover to the relay both come after they do.
        address l2Usds     = L2_USDS;
        address l2Susds    = L2_SUSDS;
        address l2UsdsImp;
        address l2SusdsImp;

        if (l2Usds == address(0)) {
            UsdsL2Instance memory usdsInstance = UsdsDeploy.deployL2(msg.sender, msg.sender);
            l2Usds    = usdsInstance.usds;
            l2UsdsImp = usdsInstance.usdsImp;
        }
        if (l2Susds == address(0)) {
            SUsdsInstance memory susdsInstance = SUsdsDeploy.deploy(msg.sender, msg.sender);
            l2Susds    = susdsInstance.sUsds;
            l2SusdsImp = susdsInstance.sUsdsImp;
        }

        RemoteWiring[] memory usdsRemotes  = new RemoteWiring[](remotes.length);
        RemoteWiring[] memory susdsRemotes = new RemoteWiring[](remotes.length);

        // Pass `Gross` below if a chain wants that instead of the default `Net`.
        for (uint256 i; i < remotes.length; ++i) {
            usdsRemotes[i]  = RemoteWiring(remotes[i].eid, _oftCfg(remotes[i].usdsPeer),  _zeroLimits());
            susdsRemotes[i] = RemoteWiring(remotes[i].eid, _oftCfg(remotes[i].susdsPeer), _zeroLimits());
        }

        L2OFTDeployer usdsDep  = new L2OFTDeployer(L2OftDeployment({
            token:          l2Usds,
            endpoint:       ENDPOINT,
            accountingType: RateLimitAccountingType.Net,
            pausers:        _pausers(),
            remotes:        usdsRemotes,
            gov:            relay
        }));
        L2OFTDeployer susdsDep = new L2OFTDeployer(L2OftDeployment({
            token:          l2Susds,
            endpoint:       ENDPOINT,
            accountingType: RateLimitAccountingType.Net,
            pausers:        _pausers(),
            remotes:        susdsRemotes,
            gov:            relay
        }));

        if (l2UsdsImp != address(0)) {
            WardsLike(l2Usds).rely(address(usdsDep.oft()));
            WardsLike(l2Usds).rely(relay);
            WardsLike(l2Usds).deny(msg.sender);
        }
        if (l2SusdsImp != address(0)) {
            WardsLike(l2Susds).rely(address(susdsDep.oft()));
            WardsLike(l2Susds).rely(relay);
            WardsLike(l2Susds).deny(msg.sender);
        }

        vm.stopBroadcast();

        console.log("--- tokens ---");
        console.log("USDS:                   ", l2Usds);
        console.log("SUSDS:                  ", l2Susds);
        if (l2UsdsImp  != address(0)) console.log("USDS  implementation:   ", l2UsdsImp);
        if (l2SusdsImp != address(0)) console.log("SUSDS implementation:   ", l2SusdsImp);
        console.log("--- governance bridge ---");
        console.log("GovBridgeDeployer:      ", address(govDep));
        console.log("GovernanceOAppReceiver: ", address(govDep.receiver()));
        console.log("L2GovernanceRelay:      ", relay);
        console.log("LZL2Spell:              ", address(l2Spell));
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
        if (l2UsdsImp == address(0) || l2SusdsImp == address(0)) {
            console.log("Next: grant each adapter mint/burn authority over its pre-existing token, then");
            console.log("the L1 spell (wireGovPeer + wireOftPeer, and activateOft to set rate limits).");
        } else {
            console.log("Next: the L1 spell (wireGovPeer + wireOftPeer, and activateOft to set rate limits).");
        }
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
