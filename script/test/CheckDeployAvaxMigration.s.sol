// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { console } from "forge-std/Script.sol";

import { LZInit, OftConfig, RateLimits, UlnConfig, OFTAdapterLike, UlnLike, EndpointLike } from "lz-init-lib/LZInit.sol";
import {
    LZAvaxMigrationInit,
    AvaxMigration,
    OftActivation
} from "lz-init-lib/LZAvaxMigrationInit.sol";

import { Bridge }                from "xchain-helpers/testing/Bridge.sol";
import { Domain, DomainHelpers } from "xchain-helpers/testing/Domain.sol";
import { LZBridgeTesting }       from "xchain-helpers/testing/bridges/LZBridgeTesting.sol";

import { DeployAvaxMigration } from "script/DeployAvaxMigration.s.sol";

interface TokenLike   { function wards(address) external view returns (uint256); }
interface OwnableLike { function owner() external view returns (address); }

/// @notice Runs `DeployAvaxMigration`, then the spell that consumes what it deployed, on both sides:
///
///           anvil --fork-url <mainnet>   --port 8545 --silent &
///           anvil --fork-url <avalanche> --port 8546 --silent &
///           until cast block-number --rpc-url http://localhost:8546 >/dev/null 2>&1; do sleep 1; done
///
///           MAINNET_RPC_URL=http://localhost:8545 AVALANCHE_RPC_URL=http://localhost:8546 \
///             forge script script/test/CheckDeployAvaxMigration.s.sol:CheckDeployAvaxMigration \
///             --sig "check()" --rpc-url http://localhost:8545 --sender <a funded account>
///
///           pkill -f "anvil --fork-url"
contract CheckDeployAvaxMigration is DeployAvaxMigration {

    using DomainHelpers   for *;
    using LZBridgeTesting for *;

    Domain mainnet;
    Bridge bridge;

    uint128 constant RELAY_GAS     = 500_000;
    uint256 constant RELAY_MAX_FEE = 1 ether;

    function _skyMultisig() internal pure override returns (address) {
        return address(0xAAa1);
    }

    function check() external {
        mainnet = Domain({ chain: getChain("mainnet"), forkId: vm.activeFork() });

        (Deployed memory d, uint256 avaxFork) = run();

        bridge = LZBridgeTesting.createLZBridge(
            mainnet,
            Domain({ chain: getChain("avalanche"), forkId: avaxFork })
        );

        // --- mainnet: the spell, as the pause proxy executes it ---
        mainnet.selectFork();

        address govSender = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        vm.deal(LZInit.chainlog.getAddress("LZ_GOV_RELAY"), RELAY_MAX_FEE);

        AvaxMigration memory m = _migration(d);

        vm.startPrank(LZInit.chainlog.getAddress("MCD_PAUSE_PROXY"));
        LZAvaxMigrationInit.migrateAvax(m);
        vm.stopPrank();

        require(
            LZInit.chainlog.getAddress("USDS_OFT") == d.usdsLockbox,
            "CheckDeployAvaxMigration/usds-oft-not-repointed"
        );
        require(
            LZInit.chainlog.getAddress("SUSDS_OFT") == d.susdsLockbox,
            "CheckDeployAvaxMigration/susds-oft-not-repointed"
        );

        // --- Avalanche: the half the spell relays through the old relay ---
        bridge.relayMessagesToDestination(true, govSender, AVAX_GOV_RECEIVER);

        _assertRemote(d, m);

        console.log("");
        console.log("migrateAvax accepted the deployed state, on both sides");
    }

    // --- helpers ---

    /// @dev What `migrateAvaxRemote` was asked to do with the Avalanche half.
    function _assertRemote(Deployed memory d, AvaxMigration memory m) internal view {
        _assertActivated(d.avaxUsdsOft,  m.avaxUsds.rateLimits);
        _assertActivated(d.avaxSusdsOft, m.avaxSusds.rateLimits);

        require(
            keccak256(abi.encode(_readRecvUln(AVAX_GOV_RECEIVER, ETH_EID))) == keccak256(abi.encode(m.recvUlnCfg)),
            "CheckDeployAvaxMigration/gov-recv-uln-mismatch"
        );

        _assertAuthority(AVAX_USDS,  d.avaxUsdsOft,  LZAvaxMigrationInit.OLD_AVAX_USDS_OFT,  d.newRelay);
        _assertAuthority(AVAX_SUSDS, d.avaxSusdsOft, LZAvaxMigrationInit.OLD_AVAX_SUSDS_OFT, d.newRelay);

        require(
            OwnableLike(AVAX_GOV_RECEIVER).owner() == d.newRelay,
            "CheckDeployAvaxMigration/receiver-not-handed-over"
        );
    }

    function _assertActivated(address oft, RateLimits memory rl) internal view {
        (, uint48 outWindow,, uint256 outLimit) = OFTAdapterLike(oft).outboundRateLimits(ETH_EID);
        (, uint48 inWindow,,  uint256 inLimit)  = OFTAdapterLike(oft).inboundRateLimits(ETH_EID);

        require(outLimit  == rl.outboundLimit,  "CheckDeployAvaxMigration/outbound-limit-not-activated");
        require(outWindow == rl.outboundWindow, "CheckDeployAvaxMigration/outbound-window-not-activated");
        require(inLimit   == rl.inboundLimit,   "CheckDeployAvaxMigration/inbound-limit-not-activated");
        require(inWindow  == rl.inboundWindow,  "CheckDeployAvaxMigration/inbound-window-not-activated");
    }

    function _assertAuthority(address token, address newOft, address oldOft, address newRelay) internal view {
        require(TokenLike(token).wards(newOft)   == 1, "CheckDeployAvaxMigration/new-adapter-not-relied");
        require(TokenLike(token).wards(oldOft)   == 0, "CheckDeployAvaxMigration/old-adapter-not-denied");
        require(TokenLike(token).wards(newRelay) == 1, "CheckDeployAvaxMigration/new-relay-not-relied");
        require(
            TokenLike(token).wards(LZAvaxMigrationInit.OLD_AVAX_GOV_RELAY) == 0,
            "CheckDeployAvaxMigration/old-relay-not-denied"
        );
    }

    function _readRecvUln(address oapp, uint32 srcEid) internal view returns (UlnConfig memory) {
        (address recvLib,) = EndpointLike(AVAX_ENDPOINT).getReceiveLibrary(oapp, srcEid);
        return UlnLike(recvLib).getAppUlnConfig(oapp, srcEid);
    }

    /// @dev Every field the deployer decided is read back from `Deployed` or from the template's own
    ///      config helpers; what is left is the spell's policy: the limits it opens, the legacy
    ///      chainlog key, and the relay's gas budget.
    function _migration(Deployed memory d) internal view returns (AvaxMigration memory m) {
        (m.sendUlnCfg, m.ccipDvnIndex) = _govSendUlnCfg(d.ethCcipAdapter);
        m.recvUlnCfg = _govRecvUlnCfg(d.recvDvns);

        m.newL2GovRelay     = d.newRelay;
        m.ccipAllowlistSize = 1;             // the governance sender, kept through the handoff
        m.ccipRemoteAdapter = d.avaxCcipAdapter;
        m.ccipBroadcaster   = d.ccipBroadcaster;
        m.ccipGas           = CCIP_GAS;
        m.l2Spell           = d.l2Spell;

        m.usds  = _activation(d.usdsLockbox,  d.usdsLockboxImp,  _l1OftCfg(d.avaxUsdsOft));
        m.susds = _activation(d.susdsLockbox, d.susdsLockboxImp, _l1OftCfg(d.avaxSusdsOft));

        m.avaxUsds  = _activation(d.avaxUsdsOft,  d.avaxUsdsOftImp,  _avaxOftCfg(d.usdsLockbox));
        m.avaxSusds = _activation(d.avaxSusdsOft, d.avaxSusdsOftImp, _avaxOftCfg(d.susdsLockbox));

        m.usdsGlobalLimits  = _limits();
        m.susdsGlobalLimits = _limits();
        m.usdsGlobalRlType  = uint8(AGGREGATE_ACCOUNTING);
        m.susdsGlobalRlType = uint8(AGGREGATE_ACCOUNTING);
        m.legacyCLKey       = "USDS_OFT_LEGACY";

        m.gas    = RELAY_GAS;
        m.maxFee = RELAY_MAX_FEE;
    }

    function _activation(address oft, address oftImp, OftConfig memory cfg)
        internal pure returns (OftActivation memory)
    {
        return OftActivation({
            oft:              oft,
            oftImp:           oftImp,
            cfg:              cfg,
            rateLimits:       _limits(),
            rlAccountingType: uint8(PER_EID_ACCOUNTING)
        });
    }

    function _limits() internal pure returns (RateLimits memory) {
        return RateLimits(1 days, 1_000_000e18, 1 days + 1, 1_000_000e18 + 1);
    }
}
