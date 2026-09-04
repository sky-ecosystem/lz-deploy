// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";
import { LZAvaxMigrationL2Spell }                                  from "lz-init-lib/LZAvaxMigrationL2Spell.sol";

import { GovernanceRelayDeploy } from "lz-governance-relay/deploy/GovernanceRelayDeploy.sol";

// The two deployers declare their own `RemoteWiring`, so the identical structs are distinct types.
import { L1OFTDeployer, L1OftDeployment, RemoteWiring as L1RemoteWiring } from "src/L1OFTDeployer.sol";
import { L2OFTDeployer, L2OftDeployment, RemoteWiring as L2RemoteWiring } from "src/L2OFTDeployer.sol";

/// @notice Deployer-side bundle for the Avalanche migration: everything `LZAvaxMigrationInit` expects
///         to already exist when the spell runs.
/// @dev    Run with mainnet as the active fork and `AVAX_RPC_URL` set:
///
///           AVAX_RPC_URL=<avalanche> forge script script/DeployAvaxMigration.s.sol:DeployAvaxMigration \
///             --rpc-url <mainnet_rpc> --broadcast --slow --skip-simulation --verify
///
///         Avalanche is deployed first, against *predicted* mainnet lockbox addresses, because each
///         side's peer is the other and both are wired in their constructors. Predicting the mainnet
///         side is the safe direction: if the prediction misses, the run reverts before anything on
///         mainnet is handed to the pause proxy, and the Avalanche contracts — which nothing points
///         at yet — are simply redeployed. The prediction assumes the broadcaster sends no other
///         mainnet transaction in between.
///
///         Template: the libraries, DVN sets, confirmations, gas and accounting types below are
///         per-deployment and must be filled in and reviewed. Everything readable from the chainlog
///         is read instead.
contract DeployAvaxMigration is Script {

    // ============================ fixed references ============================

    uint32  constant ETH_EID  = 30101;
    uint32  constant AVAX_EID = 30106;
    address constant AVAX_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c; // same address on every chain checked, but verify per chain

    /// @dev The migration hands the new Avalanche adapters over from the old relay, so they must be
    ///      owned by it at spell time, and the gov receiver already exists.
    address constant OLD_AVAX_GOV_RELAY = 0xe928885BCe799Ed933651715608155F01abA23cA;
    address constant AVAX_GOV_RECEIVER  = 0x6fdd46947ca6903c8c159d1dF2012Bc7fC5cEeec;

    address constant AVAX_USDS  = 0x86Ff09db814ac346a7C6FE2Cd648F27706D1D470;
    address constant AVAX_SUSDS = 0xb94D9613C7aAB11E548a327154Cc80eCa911B5c1;

    // ============================ FILL IN: libraries ============================

    /// @dev Unlike the endpoint, the ULN libraries differ on every chain; read each off its own
    ///      endpoint (`defaultSendLibrary(dstEid)` / `defaultReceiveLibrary(dstEid)`).
    address constant ETH_SEND_LIB  = address(0); // SendUln302 on mainnet
    address constant ETH_RECV_LIB  = address(0); // ReceiveUln302 on mainnet
    address constant ETH_EXECUTOR  = address(0);

    address constant AVAX_SEND_LIB = address(0);
    address constant AVAX_RECV_LIB = address(0);
    address constant AVAX_EXECUTOR = address(0);

    // ============================ FILL IN: new relay ============================

    uint256 constant RELAY_DELAY        = 2 days;
    uint256 constant RELAY_GRACE_PERIOD = 30 days;

    /// @dev Addresses allowed to cancel queued governance actions.
    function _bud() internal pure returns (address[] memory bud) {
        bud = new address[](0);
    }

    // ============================ FILL IN: LayerZero config ============================

    uint32 constant MAX_MESSAGE_SIZE = 10_000;

    /// @dev Spent on the destination, so the two directions differ: the mainnet lockbox also updates
    ///      the global bucket on the way in. Benchmark both rather than copying one.
    uint128 constant ETH_TO_AVAX_OPTIONS_GAS = 130_000;
    uint128 constant AVAX_TO_ETH_OPTIONS_GAS = 130_000;

    uint64 constant ETH_CONFIRMATIONS  = 15;
    uint64 constant AVAX_CONFIRMATIONS = 15;

    /// @dev The token bridge's own DVN set, sorted ascending, on each chain. Not the governance
    ///      bridge's replica set: the spell reconfigures that separately.
    function _ethOftDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0);
    }

    function _avaxOftDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0);
    }

    // ============================ FILL IN: accounting ============================

    RateLimitAccountingType constant PER_EID_ACCOUNTING   = RateLimitAccountingType.Net;
    RateLimitAccountingType constant AGGREGATE_ACCOUNTING = RateLimitAccountingType.Net;

    function _pausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    // ============================ script ============================

    function run() external {
        // `address(0)` is LZ's "use the endpoint default" sentinel, so an unfilled library or executor
        // would configure silently and only be caught by the spell.
        require(ETH_SEND_LIB  != address(0), "DeployAvaxMigration/eth-send-lib-unset");
        require(ETH_RECV_LIB  != address(0), "DeployAvaxMigration/eth-recv-lib-unset");
        require(ETH_EXECUTOR  != address(0), "DeployAvaxMigration/eth-executor-unset");
        require(AVAX_SEND_LIB != address(0), "DeployAvaxMigration/avax-send-lib-unset");
        require(AVAX_RECV_LIB != address(0), "DeployAvaxMigration/avax-recv-lib-unset");
        require(AVAX_EXECUTOR != address(0), "DeployAvaxMigration/avax-executor-unset");

        uint256 l1Fork   = vm.activeFork();
        uint256 avaxFork = vm.createFork(vm.envString("AVAX_RPC_URL"));

        address l1GovRelay = LZInit.chainlog.getAddress("LZ_GOV_RELAY");
        address usds       = LZInit.chainlog.getAddress("USDS");
        address susds      = LZInit.chainlog.getAddress("SUSDS");

        // The lockboxes are the Avalanche adapters' peers, so their addresses are needed before they
        // exist. Each `L1OFTDeployer` deploys its implementation at contract nonce 1 and the proxy at
        // 2, so both follow from the broadcaster's mainnet nonce.
        uint64  nonce             = vm.getNonce(msg.sender);
        address predictedUsdsOft  = _proxyOf(vm.computeCreateAddress(msg.sender, nonce));
        address predictedSusdsOft = _proxyOf(vm.computeCreateAddress(msg.sender, nonce + 1));

        // --- Avalanche: new relay, the relayed spell's target, and the two OFT adapters ---

        vm.selectFork(avaxFork);
        vm.startBroadcast();

        address newRelay = GovernanceRelayDeploy.deployL2({
            l1Eid:             ETH_EID,
            l2Oapp:            AVAX_GOV_RECEIVER,
            l1GovernanceRelay: l1GovRelay,
            delay:             RELAY_DELAY,
            gracePeriod:       RELAY_GRACE_PERIOD,
            bud:               _bud()
        });

        LZAvaxMigrationL2Spell l2Spell = new LZAvaxMigrationL2Spell();

        L2OFTDeployer avaxUsdsDep  = new L2OFTDeployer(_avaxDeployment(AVAX_USDS,  predictedUsdsOft));
        L2OFTDeployer avaxSusdsDep = new L2OFTDeployer(_avaxDeployment(AVAX_SUSDS, predictedSusdsOft));

        vm.stopBroadcast();

        // --- mainnet: the two lockboxes, wired to the adapters just deployed ---

        vm.selectFork(l1Fork);
        vm.startBroadcast();

        L1OFTDeployer usdsDep  = new L1OFTDeployer(_l1Deployment(usds,  address(avaxUsdsDep.oft())));
        L1OFTDeployer susdsDep = new L1OFTDeployer(_l1Deployment(susds, address(avaxSusdsDep.oft())));

        vm.stopBroadcast();

        require(address(usdsDep.oft())  == predictedUsdsOft,  "DeployAvaxMigration/usds-lockbox-mismatch");
        require(address(susdsDep.oft()) == predictedSusdsOft, "DeployAvaxMigration/susds-lockbox-mismatch");

        console.log("--- mainnet (owned by MCD_PAUSE_PROXY) ---");
        console.log("USDS  L1OFTDeployer:    ", address(usdsDep));
        console.log("USDS  lockbox:          ", address(usdsDep.oft()));
        console.log("USDS  implementation:   ", address(usdsDep.implementation()));
        console.log("SUSDS L1OFTDeployer:    ", address(susdsDep));
        console.log("SUSDS lockbox:          ", address(susdsDep.oft()));
        console.log("SUSDS implementation:   ", address(susdsDep.implementation()));
        console.log("--- avalanche (owned by the OLD relay until the spell) ---");
        console.log("L2GovernanceRelay (new):", newRelay);
        console.log("LZAvaxMigrationL2Spell: ", address(l2Spell));
        console.log("USDS  adapter:          ", address(avaxUsdsDep.oft()));
        console.log("USDS  implementation:   ", address(avaxUsdsDep.implementation()));
        console.log("SUSDS adapter:          ", address(avaxSusdsDep.oft()));
        console.log("SUSDS implementation:   ", address(avaxSusdsDep.implementation()));
        console.log("");
        console.log("Next: fill AvaxMigration with the addresses above - lockboxes and their");
        console.log("implementations as usds/susds, adapters as avaxUsds/avaxSusds, the new relay as");
        console.log("newL2GovRelay, and the spell as l2Spell. Token authority is moved by the spell.");
    }

    // --- helpers ---

    /// @dev A contract's nonce starts at 1 (EIP-161); the implementation takes 1 and the proxy 2.
    function _proxyOf(address deployer) internal pure returns (address) {
        return vm.computeCreateAddress(deployer, 2);
    }

    function _avaxDeployment(address token, address peer) internal pure returns (L2OftDeployment memory) {
        L2RemoteWiring[] memory remotes = new L2RemoteWiring[](1);
        remotes[0] = L2RemoteWiring({
            eid:        ETH_EID,
            cfg:        _oftCfg(peer, AVAX_SEND_LIB, AVAX_RECV_LIB, AVAX_EXECUTOR, _avaxOftDVNs(),
                                AVAX_CONFIRMATIONS, AVAX_TO_ETH_OPTIONS_GAS),
            rateLimits: RateLimits(0, 0, 0, 0)  // the spell opens them
        });

        return L2OftDeployment({
            token:          token,
            endpoint:       AVAX_ENDPOINT,
            accountingType: PER_EID_ACCOUNTING,
            pausers:        _pausers(),
            remotes:        remotes,
            gov:            OLD_AVAX_GOV_RELAY
        });
    }

    function _l1Deployment(address token, address peer)
        internal pure returns (L1OftDeployment memory)
    {
        L1RemoteWiring[] memory remotes = new L1RemoteWiring[](1);
        remotes[0] = L1RemoteWiring({
            eid:        AVAX_EID,
            cfg:        _oftCfg(peer, ETH_SEND_LIB, ETH_RECV_LIB, ETH_EXECUTOR, _ethOftDVNs(),
                                ETH_CONFIRMATIONS, ETH_TO_AVAX_OPTIONS_GAS),
            rateLimits: RateLimits(0, 0, 0, 0)  // the spell opens them
        });

        return L1OftDeployment({
            token:                   token,
            accountingType:          PER_EID_ACCOUNTING,
            aggregateAccountingType: AGGREGATE_ACCOUNTING,
            globalLimits:            RateLimits(0, 0, 0, 0),  // the spell sets the global cap
            pausers:                 _pausers(),
            remotes:                 remotes
        });
    }

    function _oftCfg(
        address          peer,
        address          sendLib,
        address          recvLib,
        address          executor,
        address[] memory dvns,
        uint64           confirmations,
        uint128          optionsGas
    ) internal pure returns (OftConfig memory) {
        UlnConfig memory uln = UlnConfig({
            confirmations:        confirmations,
            requiredDVNCount:     uint8(dvns.length),
            optionalDVNCount:     0,
            optionalDVNThreshold: 0,
            requiredDVNs:         dvns,
            optionalDVNs:         new address[](0)
        });

        return OftConfig({
            peer:       peer,
            sendLib:    sendLib,
            execCfg:    ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: executor }),
            sendUlnCfg: uln,
            recvLib:    recvLib,
            recvUlnCfg: uln,
            optionsGas: optionsGas
        });
    }
}
