// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { console } from "forge-std/Script.sol";

import { MessagingFee } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import { LZInit } from "lz-init-lib/LZInit.sol";

import { SSROracleForwarderLZ } from "xchain-ssr-oracle/forwarders/SSROracleForwarderLZ.sol";

import { Bridge }                from "xchain-helpers/testing/Bridge.sol";
import { Domain, DomainHelpers } from "xchain-helpers/testing/Domain.sol";
import { LZBridgeTesting }       from "xchain-helpers/testing/bridges/LZBridgeTesting.sol";

import { DeploySsrBridge }              from "script/examples/DeploySsrBridge.s.sol";
import { SendSideDeployer, CCIPDVNCfg } from "script/examples/mocks/DvnDeployersFlat.sol";

interface SUsdsLike {
    function ssr() external view returns (uint256);
    function chi() external view returns (uint192);
    function rho() external view returns (uint64);
}

interface OracleLike {
    function getSSR() external view returns (uint256);
    function getChi() external view returns (uint256);
    function getRho() external view returns (uint256);
}

/// @dev `refresh()` is payable and a script contract cannot be dealt a balance, so this stands in for
///      whoever pays for a refresh.
contract RefreshPayer {

    function refresh(address forwarder, uint256 fee) external {
        SSROracleForwarderLZ(forwarder).refresh{ value: fee }("", address(this));
    }
}

/// @notice Runs `DeploySsrBridge`, then the spell that consumes what it deployed, and finally a
///         `refresh()` relayed to the remote oracle:
///
///           anvil --fork-url <mainnet> --port 8545 --silent &
///           anvil --fork-url <remote>  --port 8547 --silent &
///           until cast block-number --rpc-url http://localhost:8545 >/dev/null 2>&1 \
///              && cast block-number --rpc-url http://localhost:8547 >/dev/null 2>&1; do sleep 1; done
///
///           MAINNET_RPC_URL=http://localhost:8545 BASE_RPC_URL=http://localhost:8547 \
///             forge script script/examples/test/CheckDeploySsrBridge.s.sol:CheckDeploySsrBridge \
///             --sig "check()" --rpc-url http://localhost:8545 --sender <a funded account>
///
///           pkill -f "anvil --fork-url"
contract CheckDeploySsrBridge is DeploySsrBridge {

    using DomainHelpers   for *;
    using LZBridgeTesting for *;

    Domain mainnet;
    Bridge bridge;

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
            dvns[providers.length + i] =
                address(uint160(0xf0F0000000000000000000000000000000000000) + uint160(i));
        }
    }

    function check() external {
        mainnet = Domain({ chain: getChain("mainnet"), forkId: vm.activeFork() });

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

        (Deployed memory d, uint256 remoteFork) = run();

        bridge = LZBridgeTesting.createLZBridge(
            mainnet,
            Domain({ chain: getChain("base"), forkId: remoteFork })
        );

        mainnet.selectFork();

        vm.startPrank(LZInit.chainlog.getAddress("MCD_PAUSE_PROXY"));
        LZInit.activateSsrForwarder(d.forwarder, REMOTE_EID, _forwarderCfg(d.receiver));
        vm.stopPrank();

        // A refresh, now that the CCIP DVN will verify for this forwarder.
        SUsdsLike susds = SUsdsLike(LZInit.chainlog.getAddress("SUSDS"));
        uint256 ssr = susds.ssr();
        uint256 chi = susds.chi();
        uint256 rho = susds.rho();

        _refresh(d.forwarder);

        // --- the new chain: the message, and the compose call that writes the oracle ---
        bridge.relayMessagesToDestination(true, d.forwarder, d.receiver);
        bridge.relayComposeMessagesToDestination(true);

        OracleLike oracle = OracleLike(d.oracle);
        require(oracle.getSSR() == ssr, "CheckDeploySsrBridge/ssr-not-delivered");
        require(oracle.getChi() == chi, "CheckDeploySsrBridge/chi-not-delivered");
        require(oracle.getRho() == rho, "CheckDeploySsrBridge/rho-not-delivered");

        console.log("");
        console.log("activateSsrForwarder accepted the deployed state, and a refresh reached the oracle");
    }

    // --- helpers ---

    /// @dev No `extraOptions`: the forwarder's enforced options already carry both the lzReceive and
    ///      the lzCompose gas.
    function _refresh(address forwarder) internal {
        MessagingFee memory fee = SSROracleForwarderLZ(forwarder).quote("");

        RefreshPayer payer = new RefreshPayer();
        vm.deal(address(payer), fee.nativeFee);
        payer.refresh(forwarder, fee.nativeFee);
    }
}
