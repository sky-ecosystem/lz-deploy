// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { console } from "forge-std/Script.sol";

import { LZInit } from "lz-init-lib/LZInit.sol";

import { DeploySsrBridge } from "script/DeploySsrBridge.s.sol";
import { SendSideDeployer, CCIPDVNCfg } from "script/mocks/DvnDeployersFlat.sol";

/// @notice Runs `DeploySsrBridge`, then the spell that consumes what it deployed:
///
///           anvil --fork-url <mainnet> --port 8545 --silent &
///           anvil --fork-url <remote>  --port 8547 --silent &
///           until cast block-number --rpc-url http://localhost:8547 >/dev/null 2>&1; do sleep 1; done
///
///           BASE_RPC_URL=http://localhost:8547 \
///             forge script script/test/CheckDeploySsrBridge.s.sol:CheckDeploySsrBridge \
///             --sig "check()" --rpc-url http://localhost:8545 --sender <a funded account>
///
///           pkill -f "anvil --fork-url"
contract CheckDeploySsrBridge is DeploySsrBridge {

    /// @dev The shared CCIP DVN adapter this template only reads: the Avalanche migration deploys it,
    ///      so a check that runs before that has to stand in for it.
    address ccipDvnAdapter;

    /// @dev Four CCIP and four multisig replicas, as `DeployNewChain` deploys.
    uint256 constant REPLICAS = 8;

    uint128 constant CCIP_GAS     = 200_000;
    uint256 constant ADAPTER_FUND = 0.001 ether;

    function _ethCcipDvnAdapter() internal view override returns (address) {
        return ccipDvnAdapter;
    }

    function _l2GovRelay() internal pure override returns (address) {
        return address(0xAAa5);
    }

    /// @dev `DeployNewChain`'s broadcasters are not deployed here, so the replica half of the set is
    ///      stood in for: the receive side is verified on the remote chain, not by this spell, and a
    ///      ULN config asks nothing of a DVN address but that the set be ascending and distinct.
    function _recvDvns() internal pure override returns (address[] memory dvns) {
        address[] memory providers = _remoteLzDVNs();

        dvns = new address[](providers.length + REPLICAS);
        for (uint256 i; i < providers.length; ++i) dvns[i] = providers[i];
        for (uint256 i; i < REPLICAS; ++i) {
            dvns[providers.length + i] = address(uint160(0xf0F0000000000000000000000000000000000000) + uint160(i));
        }
    }

    function check() external {
        address govSender = LZInit.chainlog.getAddress("LZ_GOV_SENDER");

        // The migration's mainnet half, which the forwarder's send set names.
        address[] memory allowed = new address[](1);
        allowed[0] = govSender;
        SendSideDeployer sendDep = new SendSideDeployer(ETH_SEND_LIB, allowed);
        ccipDvnAdapter = address(sendDep.adapter());

        sendDep.configure(CCIPDVNCfg({
            remoteEid:               REMOTE_EID,
            remoteCcipChainSelector: REMOTE_CCIP_SELECTOR,
            remoteCcipAdapter:       address(0xAAa1),
            remoteCcipBroadcaster:   address(0xAAa2),
            sendLib:                 ETH_SEND_LIB,
            multiplierBps:           0,
            gas:                     CCIP_GAS
        }));
        vm.deal(ccipDvnAdapter, ADAPTER_FUND);
        sendDep.handOff(new address[](0));

        uint256 l1Fork = vm.activeFork();

        Deployed memory d = run();

        // --- mainnet: the spell that whitelists the forwarder on the adapter ---
        vm.selectFork(l1Fork);

        vm.startPrank(LZInit.chainlog.getAddress("MCD_PAUSE_PROXY"));
        LZInit.activateSsrForwarder(d.forwarder, REMOTE_EID, _forwarderCfg(d.receiver));
        vm.stopPrank();

        console.log("");
        console.log("activateSsrForwarder accepted the deployed state");
    }
}
