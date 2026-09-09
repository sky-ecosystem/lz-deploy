// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { console } from "forge-std/Script.sol";

import { LZInit, OftConfig, RateLimits, OFTAdapterLike } from "lz-init-lib/LZInit.sol";
import {
    LZAvaxMigrationInit,
    AvaxMigration,
    OftActivation
} from "lz-init-lib/LZAvaxMigrationInit.sol";

import { DeployAvaxMigration } from "script/DeployAvaxMigration.s.sol";

/// @notice Runs `DeployAvaxMigration`, then the spell that consumes what it deployed:
///
///           anvil --fork-url <mainnet>   --port 8545 --silent &
///           anvil --fork-url <avalanche> --port 8546 --silent &
///           until cast block-number --rpc-url http://localhost:8546 >/dev/null 2>&1; do sleep 1; done
///
///           AVAX_RPC_URL=http://localhost:8546 \
///             forge script script/test/CheckDeployAvaxMigration.s.sol:CheckDeployAvaxMigration \
///             --sig "check()" --rpc-url http://localhost:8545 --sender <a funded account>
///
///           pkill -f "anvil --fork-url"
contract CheckDeployAvaxMigration is DeployAvaxMigration {

    uint128 constant RELAY_GAS     = 500_000;
    uint256 constant RELAY_MAX_FEE = 1 ether;

    function _skyMultisig() internal pure override returns (address) {
        return address(0xAAa1);
    }

    function check() external {
        Deployed memory d = run();

        vm.deal(LZInit.chainlog.getAddress("LZ_GOV_RELAY"), RELAY_MAX_FEE);

        vm.startPrank(LZInit.chainlog.getAddress("MCD_PAUSE_PROXY"));
        LZAvaxMigrationInit.migrateAvax(_migration(d));
        vm.stopPrank();

        require(LZInit.chainlog.getAddress("USDS_OFT")  == d.usdsLockbox,  "CheckDeployAvaxMigration/usds-oft-not-repointed");
        require(LZInit.chainlog.getAddress("SUSDS_OFT") == d.susdsLockbox, "CheckDeployAvaxMigration/susds-oft-not-repointed");

        console.log("");
        console.log("migrateAvax accepted the deployed state");
    }

    // --- helpers ---

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

        m.usds  = _activation(d.usdsLockbox,  _l1OftCfg(d.avaxUsdsOft));
        m.susds = _activation(d.susdsLockbox, _l1OftCfg(d.avaxSusdsOft));

        // Relayed for the L2 spell to verify on Avalanche, which this run does not execute, so the
        // remote implementations are not read here.
        m.avaxUsds  = OftActivation(d.avaxUsdsOft,  address(0), _avaxOftCfg(d.usdsLockbox),  _limits(), uint8(PER_EID_ACCOUNTING));
        m.avaxSusds = OftActivation(d.avaxSusdsOft, address(0), _avaxOftCfg(d.susdsLockbox), _limits(), uint8(PER_EID_ACCOUNTING));

        m.usdsGlobalLimits  = _limits();
        m.susdsGlobalLimits = _limits();
        m.usdsGlobalRlType  = uint8(AGGREGATE_ACCOUNTING);
        m.susdsGlobalRlType = uint8(AGGREGATE_ACCOUNTING);
        m.legacyCLKey       = "USDS_OFT_LEGACY";

        m.gas    = RELAY_GAS;
        m.maxFee = RELAY_MAX_FEE;
    }

    function _activation(address oft, OftConfig memory cfg) internal view returns (OftActivation memory) {
        return OftActivation({
            oft:              oft,
            oftImp:           OFTAdapterLike(oft).getImplementation(),
            cfg:              cfg,
            rateLimits:       _limits(),
            rlAccountingType: uint8(PER_EID_ACCOUNTING)
        });
    }

    function _limits() internal pure returns (RateLimits memory) {
        return RateLimits(1 days, 1_000_000e18, 1 days, 1_000_000e18);
    }
}
