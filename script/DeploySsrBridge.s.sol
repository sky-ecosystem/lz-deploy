// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { ForwarderConfig, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

import { SsrRemoteDeployer }    from "src/SsrRemoteDeployer.sol";
import { SsrForwarderDeployer } from "src/SsrForwarderDeployer.sol";

import { GovDvnSet } from "script/GovDvnSet.sol";

/// @notice Deploys an SSR oracle bridge over LayerZero: the mainnet forwarder, and the remote oracle
///         and receiver.
/// @dev    The ordering is forced by the two halves holding each other immutably; the README gives the
///         sequence. Both chains must be broadcast from the same key, since `SsrRemoteDeployer` only
///         takes orders from its creator. Template — fill in the constants per deployment.
///
///           REMOTE_RPC_URL=<remote> forge script script/DeploySsrBridge.s.sol:DeploySsrBridge \
///             --rpc-url <mainnet_rpc> --broadcast --verify
contract DeploySsrBridge is Script {

    // ============================ mainnet constants ============================

    address constant L1_SEND_LIB = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1; // SendUln302
    address constant L1_EXECUTOR = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    // ============================ FILL IN: remote constants ============================

    uint32  constant DST_EID            = 0;
    address constant REMOTE_ENDPOINT    = 0x1a44076050125825900e736c501f859c50fE728c; // same address on every chain checked, but verify per chain
    /// @dev The ULN libraries differ on every chain, so this one cannot be defaulted like the
    ///      endpoint above; read it off the remote endpoint's `defaultReceiveLibrary(ETH_EID)`.
    address constant REMOTE_RECV_LIB    = address(0); // ReceiveUln302 on the remote
    uint256 constant MAX_SSR = 0; // 0 for no cap

    /// @dev The remote chain's two `DVNBroadcaster`s, deployed by lz-gov-dvns-deploy's
    ///      `RecvSideDeployer`. Their `DVNReplica`s are the receive set read below, so they must
    ///      exist before this script runs.
    address constant CCIP_BROADCASTER = address(0);
    address constant MSIG_BROADCASTER = address(0);

    /// @dev `L2_GOV_RELAY` takes the receiver; `ORACLE_ADMIN` takes the oracle's admin role, and zero
    ///      leaves the oracle with no admin at all.
    address constant L2_GOV_RELAY = address(0);
    address constant ORACLE_ADMIN = address(0);

    uint32  constant MAX_MESSAGE_SIZE = 10_000;
    uint128 constant FWD_OPTIONS_GAS  = 100_000;
    uint64  constant CONFIRMATIONS    = 15;

    /// @dev lzCompose gas for the remote `LZComposeReceiver`, where the oracle write happens. Covered by
    ///      the forwarder's enforced options so `refresh()` callers do not have to supply it.
    uint128 constant FWD_COMPOSE_GAS  = 200_000;

    /// @dev The shared CCIP DVN adapter on mainnet, the Sky-owned wing of the send set. Zero leaves it
    ///      out, and with it the spell's route check and `ALLOWLIST` grant.
    address constant CCIP_DVN_ADAPTER = address(0);

    /// @dev The 7 LZ-aligned DVNs on `LZ_GOV_SENDER`'s route, read off mainnet. Sorted ascending.
    ///      Confirm each one serves DST_EID before using them: availability is per destination.
    function _sendLzDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](7);
        dvns[0] = 0x06559EE34D85a88317Bf0bfE307444116c631b67;
        dvns[1] = 0x373a6E5c0C4E89E24819f00AA37ea370917AAfF4;
        dvns[2] = 0x380275805876Ff19055EA900CDb2B46a94ecF20D;
        dvns[3] = 0x58249a2Ec05c1978bF21DF1f5eC1847e42455CF4;
        dvns[4] = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b;
        dvns[5] = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd;
        dvns[6] = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5;
    }

    /// @dev Send side: the LZ DVNs plus the CCIP adapter, as on the governance route. Mainnet has the
    ///      adapter itself rather than broadcasters, so there are no replicas to read here.
    ///      `_verifyForwarderConfig` requires a non-zero *optional* count, hence optional-with-threshold.
    function _sendDVNs() internal pure returns (address[] memory dvns) {
        if (CCIP_DVN_ADAPTER == address(0)) return _sendLzDVNs();
        (dvns,) = GovDvnSet.insertSorted(_sendLzDVNs(), CCIP_DVN_ADAPTER);
    }

    /// @dev The adapter's index in the sorted send set, which is what the spell dereferences.
    function _ccipDvnIndex() internal pure returns (uint256) {
        if (CCIP_DVN_ADAPTER == address(0)) return type(uint256).max; // LZInit's NO_CCIP_DVN sentinel
        (, uint256 index) = GovDvnSet.insertSorted(_sendLzDVNs(), CCIP_DVN_ADAPTER);
        return index;
    }

    /// @dev 4, as on the live governance send route. Not load-bearing: the send library assigns and
    ///      pays every listed DVN regardless, and delivery is gated by the remote threshold below.
    uint8 constant SEND_THRESHOLD = 4;

    /// @dev The LZ-aligned DVNs that make up the rest of the remote receive set.
    function _recvLzDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0); // FILL IN
    }

    /// @dev Receive side on the remote: the LZ DVNs plus both broadcasters' replicas. This duplicates
    ///      the governance bridge's receive set, over the same deployed DVNs.
    function _recvDVNs() internal view returns (address[] memory) {
        return GovDvnSet.read(CCIP_BROADCASTER, MSIG_BROADCASTER, _recvLzDVNs());
    }

    /// @dev 8, as on the governance route: no single wing reaches it alone.
    uint8 constant RECV_THRESHOLD = 8;

    // ============================ script ============================

    function run() external {
        // `address(0)` is LZ's "use the endpoint default" sentinel, so an unfilled library would
        // configure silently and only be caught by the spell.
        require(DST_EID         != 0,          "DeploySsrBridge/dst-eid-unset");
        require(REMOTE_RECV_LIB != address(0), "DeploySsrBridge/recv-lib-unset");

        uint256 l1Fork = vm.activeFork();

        // Both forks are created once and revisited by id: `createSelectFork` again would spin up a
        // second, fresh fork in which the first half of this script never happened.
        uint256 remoteFork = vm.createFork(vm.envString("REMOTE_RPC_URL"));

        // --- remote: the oracle ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        SsrRemoteDeployer remoteDep = new SsrRemoteDeployer(MAX_SSR, ORACLE_ADMIN);
        vm.stopBroadcast();

        address predictedReceiver = remoteDep.predictedReceiver();

        // --- mainnet: forwarder against the predicted receiver ---
        vm.selectFork(l1Fork);

        address[] memory sendDvns = _sendDVNs();

        vm.startBroadcast();
        SsrForwarderDeployer fwdDep = new SsrForwarderDeployer(DST_EID, ForwarderConfig({
            peer:         predictedReceiver,
            sendLib:      L1_SEND_LIB,
            execCfg:      ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: L1_EXECUTOR }),
            sendUlnCfg:   UlnConfig({
                confirmations:        CONFIRMATIONS,
                requiredDVNCount:     255,  // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(sendDvns.length),
                optionalDVNThreshold: SEND_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         sendDvns
            }),
            ccipDvnIndex: _ccipDvnIndex(),
            optionsGas:   FWD_OPTIONS_GAS,
            composeGas:   FWD_COMPOSE_GAS
        }));
        address forwarder = address(fwdDep.forwarder());
        vm.stopBroadcast();

        // --- remote: receiver, where the forwarder already expects it ---
        vm.selectFork(remoteFork);

        // Read here, not earlier: the broadcasters live on the remote chain.
        address[] memory recvDvns = _recvDVNs();

        vm.startBroadcast();
        remoteDep.deployReceiver({
            endpoint:    REMOTE_ENDPOINT,
            forwarder:   forwarder,
            recvLib:     REMOTE_RECV_LIB,
            recvUlnCfg:  UlnConfig({
                confirmations:        CONFIRMATIONS,
                requiredDVNCount:     255,
                optionalDVNCount:     uint8(recvDvns.length),
                optionalDVNThreshold: RECV_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         recvDvns
            }),
            gov:         L2_GOV_RELAY
        });
        vm.stopBroadcast();

        console.log("--- mainnet ---");
        console.log("SsrForwarderDeployer:  ", address(fwdDep));
        console.log("SSROracleForwarderLZ:  ", forwarder);
        console.log("--- remote ---");
        console.log("SsrRemoteDeployer:     ", address(remoteDep));
        console.log("SSRAuthOracle:         ", address(remoteDep.oracle()));
        console.log("LZComposeReceiver:     ", address(remoteDep.receiver()));
        console.log("");
        console.log("Both sides are handed off. Remaining: the L1 spell, LZInit.activateSsrForwarder.");
    }
}
