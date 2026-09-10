// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { ForwarderConfig, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

import { L1SsrBridgeDeployer } from "src/L1SsrBridgeDeployer.sol";
import { L2SsrBridgeDeployer } from "src/L2SsrBridgeDeployer.sol";

import { GovDvnSet } from "script/GovDvnSet.sol";
import { LzDvns }    from "script/LzDvns.sol";

/// @notice Deploys an SSR oracle bridge over LayerZero, pre-filled for Base: the mainnet forwarder,
///         and the remote oracle and receiver.
/// @dev    Run with mainnet as the active fork and `BASE_RPC_URL` set, after `DeployNewChain`, which
///         deploys the DVN infrastructure this reuses and the relay it hands to. Those four addresses
///         are filled in below rather than read from a file: the two runs need not be consecutive, and
///         an SSR bridge can also be added to a chain brought up long ago.
///
///           BASE_RPC_URL=<base> forge script script/DeploySsrBridge.s.sol:DeploySsrBridge \
///             --rpc-url <mainnet_rpc> --sender <deployer> --broadcast --slow
///
///         The route duplicates the governance one over the same deployed DVNs: the shared CCIP DVN
///         adapter spliced into the LZ-aligned set on the send side, and both Sky wings' replicas plus
///         those providers on the receive side at threshold 2N.
///
///         Ordering is forced by the two halves holding each other immutably; `L2SsrBridgeDeployer`
///         documents it. Both chains must be broadcast from the same key, since that deployer only
///         takes orders from its creator.
///
///         What this leaves undone is governance's: `LZInit.activateSsrForwarder` whitelists the
///         forwarder on the CCIP DVN adapter, and nothing can send until it does — the adapter gates
///         `getFee` and `assignJob` on that allowlist.
contract DeploySsrBridge is Script {

    // ============================ fixed references ============================

    address constant ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;

    address constant ETH_SEND_LIB = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1; // SendUln302
    address constant ETH_EXECUTOR = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    // The remote chain's own references, pre-filled for Base.
    uint32  constant REMOTE_EID           = 30184;
    uint64  constant REMOTE_CCIP_SELECTOR = 15971525489660198786;
    address constant REMOTE_RECV_LIB      = 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf; // ReceiveUln302

    /// @dev FILL IN: from the run that brought this chain up. The mainnet CCIP DVN adapter is the
    ///      shared one the governance route uses; the broadcasters and the relay are this chain's.
    address constant ETH_CCIP_DVN_ADAPTER = address(0);
    address constant CCIP_BROADCASTER     = address(0);
    address constant MSIG_BROADCASTER     = address(0);
    address constant L2_GOV_RELAY         = address(0);

    function _ethCcipDvnAdapter() internal view virtual returns (address) {
        return ETH_CCIP_DVN_ADAPTER;
    }

    function _l2GovRelay() internal view virtual returns (address) {
        return L2_GOV_RELAY;
    }

    /// @dev The replicas of both wings, read off the broadcasters of the run that brought this chain
    ///      up, alongside the LZ-aligned providers.
    function _recvDvns() internal view virtual returns (address[] memory) {
        require(CCIP_BROADCASTER != address(0), "DeploySsrBridge/ccip-broadcaster-unset");
        require(MSIG_BROADCASTER != address(0), "DeploySsrBridge/msig-broadcaster-unset");

        return GovDvnSet.read(CCIP_BROADCASTER, MSIG_BROADCASTER, _remoteLzDVNs());
    }

    // ============================ LayerZero config ============================

    /// @dev The governance route's 8 of 15: any two DVN wings reach it, no single wing does.
    uint8 constant RECV_THRESHOLD = 8;

    /// @dev The whole send set: nothing enforces this threshold — every DVN in the set is assigned
    ///      and paid, and delivery is gated by the destination's — it only has to exceed 1.
    uint8 constant SEND_THRESHOLD = 8;

    uint32 constant MAX_MESSAGE_SIZE = 10_000;

    /// @dev Ethereum blocks: the forwarder sends from mainnet and the receiver reads that same leg.
    uint64 constant ETH_CONFIRMATIONS = 15;

    /// @dev lzReceive gas on the remote, for the forwarder's one outbound leg.
    uint128 constant OPTIONS_GAS = 100_000;

    /// @dev lzCompose gas for the remote `LZComposeReceiver`, where the oracle write happens. Covered
    ///      by the forwarder's enforced options so `refresh()` callers do not have to supply it.
    uint128 constant COMPOSE_GAS = 200_000;

    /// @dev Cap on the SSR the oracle accepts. Zero means none, which is the default here: the relay
    ///      holds the oracle's admin role, so governance can set one later.
    uint256 constant MAX_SSR = 0;

    // ============================ governance DVN wings ============================

    /// @dev The LZ-aligned wing at their Base addresses, sorted ascending — replaced per remote,
    ///      like the `REMOTE_*` constants: every provider has its own address on every chain.
    function _remoteLzDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](7);
        dvns[0] = 0x554833698Ae0FB22ECC90B01222903fD62CA4B47; // Canary
        dvns[1] = 0x5b6735c66d97479cCD18294fc96B3084EcB2fa3f; // P2P
        dvns[2] = 0x9e059a54699a285714207b43B055483E78FAac25; // LayerZero Labs
        dvns[3] = 0xa0AF56164F02bDf9d75287ee77c568889F11d5f2; // Luganodes
        dvns[4] = 0xa7b5189bcA84Cd304D8553977c7C614329750d99; // Horizen
        dvns[5] = 0xc2A0C36f5939A14966705c7Cec813163FaEEa1F0; // Deutsche Telekom
        dvns[6] = 0xcd37CA043f8479064e10635020c65FfC005d36f6; // Nethermind
    }

    // ============================ script ============================

    /// @dev What the run produces, for a spell to consume.
    struct Deployed {
        address forwarder;
        address oracle;
        address receiver;
    }

    function run() public returns (Deployed memory d) {
        require(_ethCcipDvnAdapter() != address(0), "DeploySsrBridge/ccip-dvn-adapter-unset");
        require(_l2GovRelay()        != address(0), "DeploySsrBridge/gov-relay-unset");

        uint256 l1Fork     = vm.activeFork();
        uint256 remoteFork = vm.createFork(vm.envString("BASE_RPC_URL"));

        // --- the new chain: the oracle, authorising the receiver of the last step ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        L2SsrBridgeDeployer remoteDep = new L2SsrBridgeDeployer(MAX_SSR, _l2GovRelay());
        vm.stopBroadcast();

        // The deployer lives on this chain, so read its prediction before switching away.
        address predictedReceiver = remoteDep.predictedReceiver();

        // --- mainnet: the forwarder, against the receiver's predicted address ---
        vm.selectFork(l1Fork);
        vm.startBroadcast();
        d.forwarder = _deployForwarder(predictedReceiver);
        vm.stopBroadcast();

        // --- the new chain: the receiver, where the forwarder already expects it ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        _deployReceiver(remoteDep, d.forwarder);
        vm.stopBroadcast();

        d.oracle   = address(remoteDep.oracle());
        d.receiver = address(remoteDep.receiver());

        console.log("--- mainnet ---");
        console.log("SSROracleForwarderLZ:", d.forwarder);
        console.log("--- new chain ---");
        console.log("L2SsrBridgeDeployer:   ", address(remoteDep));
        console.log("SSRAuthOracle:       ", d.oracle);
        console.log("LZComposeReceiver:   ", d.receiver);
    }

    // --- helpers ---

    function _deployForwarder(address receiver) internal returns (address) {
        L1SsrBridgeDeployer dep = new L1SsrBridgeDeployer(REMOTE_EID, _forwarderCfg(receiver));

        console.log("L1SsrBridgeDeployer:", address(dep));
        return address(dep.forwarder());
    }

    function _forwarderCfg(address receiver) internal view returns (ForwarderConfig memory) {
        (address[] memory dvns, uint256 ccipDvnIndex) =
            GovDvnSet.insertSorted(LzDvns.ethGovDVNs(), _ethCcipDvnAdapter());

        return ForwarderConfig({
            peer:         receiver,
            sendLib:      ETH_SEND_LIB,
            execCfg:      ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: ETH_EXECUTOR }),
            sendUlnCfg:   UlnConfig({
                confirmations:        ETH_CONFIRMATIONS,
                requiredDVNCount:     255,       // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(dvns.length),
                optionalDVNThreshold: SEND_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         dvns
            }),
            ccipDvnIndex: ccipDvnIndex,
            optionsGas:   OPTIONS_GAS,
            composeGas:   COMPOSE_GAS
        });
    }

    function _deployReceiver(L2SsrBridgeDeployer remoteDep, address forwarder) internal {
        address[] memory dvns = _recvDvns();

        remoteDep.deployReceiver({
            endpoint:   ENDPOINT,
            forwarder:  forwarder,
            recvLib:    REMOTE_RECV_LIB,
            recvUlnCfg: UlnConfig({
                confirmations:        ETH_CONFIRMATIONS,
                requiredDVNCount:     255,       // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(dvns.length),
                optionalDVNThreshold: RECV_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         dvns
            }),
            gov:        _l2GovRelay()            // the relay owns the receiver and is its delegate
        });
    }
}
