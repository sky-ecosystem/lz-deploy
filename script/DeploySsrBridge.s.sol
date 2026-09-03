// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { ForwarderConfig, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

import { SsrRemoteDeployer }    from "src/SsrRemoteDeployer.sol";
import { SsrForwarderDeployer } from "src/SsrForwarderDeployer.sol";

/// @notice Deploys an SSR oracle bridge over LayerZero: the mainnet forwarder, and the remote
///         oracle, adapters and receiver.
/// @dev    Ordering is forced by two immutables pointing at each other (the forwarder holds the
///         receiver, the receiver holds the forwarder): remote oracle first, then the mainnet
///         forwarder against the *predicted* receiver, then the receiver itself, which
///         `deployReceiver` asserts lands where the forwarder expects.
///
///         Both chains must be broadcast from the same key: each deployer only takes orders from its
///         creator. Template — fill in the constants and review them per deployment.
///
///           REMOTE_RPC_URL=<remote> forge script script/DeploySsrBridge.s.sol:DeploySsrBridge \
///             --rpc-url <mainnet_rpc> --broadcast --verify
contract DeploySsrBridge is Script {

    // ============================ mainnet constants ============================

    address constant L1_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address constant SUSDS       = 0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD;
    address constant L1_SEND_LIB = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1; // SendUln302
    address constant L1_EXECUTOR = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    // ============================ FILL IN: remote constants ============================

    uint32  constant DST_EID            = 0;
    address constant REMOTE_ENDPOINT    = 0x1a44076050125825900e736c501f859c50fE728c;
    address constant REMOTE_RECV_LIB    = address(0); // ReceiveUln302 on the remote
    uint256 constant MAX_SSR = 0; // 0 leaves maxSSR unset

    // Inputs to the manual handoff after the smoke test, not used by this script:
    //   remote:  remoteDep.handOff(l2GovernanceRelay, oracleAdmin)   oracleAdmin 0 leaves no admin
    //   mainnet: fwdDep.handOff()                                    always MCD_PAUSE_PROXY

    uint32  constant MAX_MESSAGE_SIZE = 10_000;
    uint128 constant FWD_OPTIONS_GAS  = 100_000;
    uint64  constant CONFIRMATIONS    = 15;

    /// @dev lzCompose gas for the remote `LZComposeReceiver`, where the oracle write happens. Covered by
    ///      the forwarder's enforced options so `refresh()` callers do not have to supply it.
    uint128 constant FWD_COMPOSE_GAS  = 200_000;

    /// @dev Send-side DVNs, sorted ascending. `_verifyForwarderConfig` requires a non-zero *optional*
    ///      count, hence optional-with-threshold. If the shared CCIP DVN adapter is among them, set
    ///      CCIP_DVN_INDEX to its position so the spell route-checks and whitelists on it.
    function _sendDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0); // FILL IN: sorted ascending
    }

    uint8 constant SEND_THRESHOLD = 2;

    uint256 constant CCIP_DVN_INDEX = type(uint256).max; // LZInit's NO_CCIP_DVN sentinel

    /// @dev Receive-side DVNs on the remote, sorted ascending.
    function _recvDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](0); // FILL IN: sorted ascending
    }

    uint8 constant RECV_THRESHOLD = 2;

    // ============================ script ============================

    function run() external {
        require(DST_EID != 0,                  "DeploySsrBridge/dst-eid-unset");
        require(REMOTE_RECV_LIB != address(0), "DeploySsrBridge/recv-lib-unset");

        uint256 l1Fork = vm.activeFork();

        // Both forks are created once and revisited by id: `createSelectFork` again would spin up a
        // second, fresh fork in which the first half of this script never happened.
        uint256 remoteFork = vm.createFork(vm.envString("REMOTE_RPC_URL"));

        // --- remote: oracle + adapters ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        SsrRemoteDeployer remoteDep = new SsrRemoteDeployer(REMOTE_ENDPOINT);
        if (MAX_SSR != 0) remoteDep.setMaxSSR(MAX_SSR);
        vm.stopBroadcast();

        address predictedReceiver = remoteDep.predictedReceiver();

        // --- mainnet: forwarder against the predicted receiver ---
        vm.selectFork(l1Fork);
        vm.startBroadcast();
        SsrForwarderDeployer fwdDep =
            new SsrForwarderDeployer(SUSDS, L1_ENDPOINT, predictedReceiver, DST_EID);
        address forwarder = fwdDep.forwarder();

        fwdDep.configure(ForwarderConfig({
            peer:         predictedReceiver,
            sendLib:      L1_SEND_LIB,
            execCfg:      ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: L1_EXECUTOR }),
            sendUlnCfg:   UlnConfig({
                confirmations:        CONFIRMATIONS,
                requiredDVNCount:     255,  // NIL: explicitly no required DVNs
                optionalDVNCount:     uint8(_sendDVNs().length),
                optionalDVNThreshold: SEND_THRESHOLD,
                requiredDVNs:         new address[](0),
                optionalDVNs:         _sendDVNs()
            }),
            ccipDvnIndex: CCIP_DVN_INDEX,
            optionsGas:   FWD_OPTIONS_GAS,
            composeGas:   FWD_COMPOSE_GAS
        }));
        vm.stopBroadcast();

        // --- remote: receiver, where the forwarder already expects it ---
        vm.selectFork(remoteFork);
        vm.startBroadcast();
        remoteDep.deployReceiver(forwarder, REMOTE_RECV_LIB, UlnConfig({
            confirmations:        CONFIRMATIONS,
            requiredDVNCount:     255,
            optionalDVNCount:     uint8(_recvDVNs().length),
            optionalDVNThreshold: RECV_THRESHOLD,
            requiredDVNs:         new address[](0),
            optionalDVNs:         _recvDVNs()
        }));
        vm.stopBroadcast();

        console.log("--- mainnet ---");
        console.log("SsrForwarderDeployer:  ", address(fwdDep));
        console.log("SSROracleForwarderLZ:  ", forwarder);
        console.log("--- remote ---");
        console.log("SsrRemoteDeployer:     ", address(remoteDep));
        console.log("SSRAuthOracle:         ", address(remoteDep.oracle()));
        console.log("LZComposeReceiver:     ", address(remoteDep.receiver()));
        console.log("BalancerRateProvider:  ", address(remoteDep.balancerAdapter()));
        console.log("ChainlinkRateProvider: ", address(remoteDep.chainlinkAdapter()));
        console.log("");
        console.log("Next: smoke test (sUSDS.drip() then forwarder.refresh(\"\", refundAddr)), then hand off:");
        console.log("  mainnet: fwdDep.handOff()                      -> MCD_PAUSE_PROXY");
        console.log("  remote:  remoteDep.handOff(relay, oracleAdmin) -> L2GovernanceRelay");
        console.log("Then the L1 spell: LZInit.activateSsrForwarder.");
    }
}
