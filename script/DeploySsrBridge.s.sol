// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { ForwarderConfig, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

import { SsrRemoteDeployer }    from "src/SsrRemoteDeployer.sol";
import { SsrForwarderDeployer } from "src/SsrForwarderDeployer.sol";

import { GovDvnSet } from "script/GovDvnSet.sol";

/// @notice Deploys an SSR oracle bridge over LayerZero, pre-filled for Base: the mainnet forwarder,
///         and the remote oracle and receiver.
/// @dev    Run with mainnet as the active fork and `BASE_RPC_URL` set, after `DeployNewChain`, which
///         deploys the DVN infrastructure this reuses and the relay it hands to. Those four addresses
///         are filled in below rather than read from a file: the two runs need not be consecutive, and
///         an SSR bridge can also be added to a chain brought up long ago.
///
///           BASE_RPC_URL=<base> forge script script/DeploySsrBridge.s.sol:DeploySsrBridge \
///             --rpc-url <mainnet_rpc> --broadcast --slow --skip-simulation --verify
///
///         The route duplicates the governance one over the same deployed DVNs: the shared CCIP DVN
///         adapter spliced into the LZ-aligned set on the send side, and both Sky wings' replicas plus
///         those providers on the receive side at threshold 2N.
///
///         Ordering is forced by the two halves holding each other immutably; `SsrRemoteDeployer`
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

    // The remote chain's own eid and receive library, pre-filled for Base.
    uint32  constant REMOTE_EID      = 30184;
    address constant REMOTE_RECV_LIB = 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf; // ReceiveUln302

    /// @dev FILL IN: from the run that brought this chain up. The mainnet CCIP DVN adapter is the
    ///      shared one the governance route uses; the broadcasters and the relay are this chain's.
    address constant ETH_CCIP_DVN_ADAPTER = address(0);
    address constant CCIP_BROADCASTER     = address(0);
    address constant MSIG_BROADCASTER     = address(0);
    address constant L2_GOV_RELAY         = address(0);

    // ============================ LayerZero config ============================

    /// @dev The governance route's 8 of 15: any two DVN wings reach it, no single wing does.
    uint8 constant RECV_THRESHOLD = 8;

    /// @dev The whole send set: nothing enforces this threshold — every DVN in the set is assigned
    ///      and paid, and delivery is gated by the destination's — it only has to exceed 1.
    uint8 constant SEND_THRESHOLD = 8;

    uint32 constant MAX_MESSAGE_SIZE = 10_000;
    uint64 constant CONFIRMATIONS    = 15;

    /// @dev lzReceive gas on the remote, for the forwarder's one outbound leg.
    uint128 constant OPTIONS_GAS = 100_000;

    /// @dev lzCompose gas for the remote `LZComposeReceiver`, where the oracle write happens. Covered
    ///      by the forwarder's enforced options so `refresh()` callers do not have to supply it.
    uint128 constant COMPOSE_GAS = 200_000;

    /// @dev Cap on the SSR the oracle accepts. Zero means none, which is the default here: the relay
    ///      holds the oracle's admin role, so governance can set one later.
    uint256 constant MAX_SSR = 0;

    // ============================ governance DVN wings ============================

    /// @dev The LZ-aligned wing at their mainnet addresses, sorted ascending.
    function _ethLzDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](7);
        dvns[0] = 0x06559EE34D85a88317Bf0bfE307444116c631b67; // P2P
        dvns[1] = 0x373a6E5c0C4E89E24819f00AA37ea370917AAfF4; // Deutsche Telekom
        dvns[2] = 0x380275805876Ff19055EA900CDb2B46a94ecF20D; // Horizen
        dvns[3] = 0x58249a2Ec05c1978bF21DF1f5eC1847e42455CF4; // Luganodes
        dvns[4] = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b; // LayerZero Labs
        dvns[5] = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd; // Canary
        dvns[6] = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5; // Nethermind
    }

    /// @dev The same seven providers at their addresses on the remote chain, sorted ascending.
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

    function run() external {
        require(ETH_CCIP_DVN_ADAPTER != address(0), "DeploySsrBridge/ccip-dvn-adapter-unset");
        require(CCIP_BROADCASTER     != address(0), "DeploySsrBridge/ccip-broadcaster-unset");
        require(MSIG_BROADCASTER     != address(0), "DeploySsrBridge/msig-broadcaster-unset");
        require(L2_GOV_RELAY         != address(0), "DeploySsrBridge/gov-relay-unset");

        uint256 l1Fork     = vm.activeFork();
        uint256 remoteFork = vm.createFork(vm.envString("BASE_RPC_URL"));

        // --- the new chain: the oracle, authorising the receiver of the last step ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        SsrRemoteDeployer remoteDep = new SsrRemoteDeployer(MAX_SSR, L2_GOV_RELAY);
        vm.stopBroadcast();

        // The deployer lives on this chain, so read its prediction before switching away.
        address predictedReceiver = remoteDep.predictedReceiver();

        // --- mainnet: the forwarder, against the receiver's predicted address ---
        vm.selectFork(l1Fork);
        vm.startBroadcast();
        address forwarder = _deployForwarder(predictedReceiver);
        vm.stopBroadcast();

        // --- the new chain: the receiver, where the forwarder already expects it ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        _deployReceiver(remoteDep, forwarder);
        vm.stopBroadcast();

        console.log("--- mainnet ---");
        console.log("SSROracleForwarderLZ:", forwarder);
        console.log("--- new chain ---");
        console.log("SsrRemoteDeployer:   ", address(remoteDep));
        console.log("SSRAuthOracle:       ", address(remoteDep.oracle()));
        console.log("LZComposeReceiver:   ", address(remoteDep.receiver()));
        console.log("");
        console.log("Next, as a spell: activateSsrForwarder on mainnet.");
    }

    // --- helpers ---

    function _deployForwarder(address receiver) internal returns (address) {
        (address[] memory dvns, uint256 ccipDvnIndex) =
            GovDvnSet.insertSorted(_ethLzDVNs(), ETH_CCIP_DVN_ADAPTER);

        SsrForwarderDeployer dep = new SsrForwarderDeployer(REMOTE_EID, ForwarderConfig({
            peer:         receiver,
            sendLib:      ETH_SEND_LIB,
            execCfg:      ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: ETH_EXECUTOR }),
            sendUlnCfg:   UlnConfig({
                confirmations:        CONFIRMATIONS,
                requiredDVNCount:     255,       // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(dvns.length),
                optionalDVNThreshold: SEND_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         dvns
            }),
            ccipDvnIndex: ccipDvnIndex,
            optionsGas:   OPTIONS_GAS,
            composeGas:   COMPOSE_GAS
        }));

        console.log("SsrForwarderDeployer:", address(dep));
        return address(dep.forwarder());
    }

    function _deployReceiver(SsrRemoteDeployer remoteDep, address forwarder) internal {
        address[] memory dvns = GovDvnSet.read(CCIP_BROADCASTER, MSIG_BROADCASTER, _remoteLzDVNs());

        remoteDep.deployReceiver({
            endpoint:   ENDPOINT,
            forwarder:  forwarder,
            recvLib:    REMOTE_RECV_LIB,
            recvUlnCfg: UlnConfig({
                confirmations:        CONFIRMATIONS,
                requiredDVNCount:     255,       // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(dvns.length),
                optionalDVNThreshold: RECV_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         dvns
            }),
            gov:        L2_GOV_RELAY             // the relay owns the receiver and is its delegate
        });
    }
}
