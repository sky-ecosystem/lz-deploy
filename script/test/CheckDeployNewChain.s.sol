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

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { GovDvnSet }      from "script/GovDvnSet.sol";
import { LzDvns }         from "script/LzDvns.sol";
import { DeployNewChain } from "script/DeployNewChain.s.sol";
import {
    SendSideDeployer,
    CCIPDVNCfg
} from "script/mocks/DvnDeployersFlat.sol";

/// @notice Runs `DeployNewChain`, then the spell that consumes what it deployed:
///
///           anvil --fork-url <mainnet> --port 8545 --silent &
///           anvil --fork-url <remote>  --port 8547 --silent &
///           until cast block-number --rpc-url http://localhost:8547 >/dev/null 2>&1; do sleep 1; done
///
///           BASE_RPC_URL=http://localhost:8547 \
///             forge script script/test/CheckDeployNewChain.s.sol:CheckDeployNewChain \
///             --sig "check()" --rpc-url http://localhost:8545 --sender <a funded account>
///
///           pkill -f "anvil --fork-url"
contract CheckDeployNewChain is DeployNewChain {

    /// @dev The shared CCIP DVN adapter this template only reads: the Avalanche migration deploys it,
    ///      so a check that runs before that has to stand in for it.
    address ccipDvnAdapter;

    uint32  constant REMOTE_EID           = 30184;
    uint64  constant REMOTE_CCIP_SELECTOR = 15971525489660198786;

    address constant ETH_SEND_LIB = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1;
    address constant ETH_EXECUTOR = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    uint128 constant CCIP_GAS     = 200_000;
    uint256 constant ADAPTER_FUND = 0.001 ether;

    function _ethCcipDvnAdapter() internal view override returns (address) {
        return ccipDvnAdapter;
    }

    function _skyMultisig() internal pure override returns (address) {
        return address(0xAAa1);
    }

    function check() external {
        uint256 l1Fork     = vm.activeFork();
        address govSender  = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        address pauseProxy = LZInit.chainlog.getAddress("MCD_PAUSE_PROXY");
        address usdsOft    = LZInit.chainlog.getAddress("USDS_OFT");
        address susdsOft   = LZInit.chainlog.getAddress("SUSDS_OFT");

        // The migration's mainnet half, which this chain's replicas verify against.
        address[] memory allowed = new address[](1);
        allowed[0] = govSender;
        SendSideDeployer sendDep = new SendSideDeployer(ETH_SEND_LIB, allowed);
        ccipDvnAdapter = address(sendDep.adapter());

        Deployed memory d = run();
        uint256 remoteFork = vm.activeFork();

        // --- mainnet: the adapter's route to this chain, then the spell ---
        vm.selectFork(l1Fork);

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

        vm.startPrank(pauseProxy);
        LZInit.wireGovPeer(REMOTE_EID, _govCfg(d));
        vm.stopPrank();

        // --- the new chain: the spell the relay executes over both adapters ---
        vm.selectFork(remoteFork);

        vm.startPrank(d.relay);
        _activate(d.usdsAdapter,  d.usds,  usdsOft,  d.relay);
        _activate(d.susdsAdapter, d.susds, susdsOft, d.relay);
        vm.stopPrank();

        console.log("");
        console.log("wireGovPeer and activateOft accepted the deployed state");
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

    function _activate(address oft, address token, address peer, address relay) internal {
        LZInit.activateOft({
            oft:              oft,
            oftImp:           OFTAdapterLike(oft).getImplementation(),
            remoteEid:        ETH_EID,
            cfg:              _remoteOftCfg(peer),
            rateLimits:       RateLimits(1 days, 1_000_000e18, 1 days, 1_000_000e18),
            rlAccountingType: uint8(PER_EID_ACCOUNTING),
            token:            token,
            owner:            relay,
            endpoint:         ENDPOINT
        });
    }

}
