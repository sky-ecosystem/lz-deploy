// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";
import { LZAvaxMigrationL2Spell }                                  from "lz-init-lib/LZAvaxMigrationL2Spell.sol";

import { GovernanceRelayDeploy } from "lz-governance-relay/deploy/GovernanceRelayDeploy.sol";

import { GovDvnSet } from "script/GovDvnSet.sol";
import { LzDvns }    from "script/LzDvns.sol";
import {
    SendSideDeployer,
    RecvSideDeployer,
    CCIPDVNCfg
} from "script/mocks/DvnDeployersFlat.sol";

// The two deployers declare their own `RemoteWiring`, so the identical structs are distinct types.
import { L1OFTDeployer, L1OftDeployment, RemoteWiring as L1RemoteWiring } from "src/L1OFTDeployer.sol";
import { L2OFTDeployer, L2OftDeployment, RemoteWiring as L2RemoteWiring } from "src/L2OFTDeployer.sol";

/// @notice Deployer-side bundle for the Avalanche migration: everything `LZAvaxMigrationInit` expects
///         to already exist when the spell runs.
/// @dev    Run with mainnet as the active fork and `AVAX_RPC_URL` set:
///
///           AVAX_RPC_URL=<avalanche> forge script \
///             script/DeployAvaxMigration.s.sol:DeployAvaxMigration \
///             --rpc-url <mainnet_rpc> --sender <deployer> --broadcast --slow
///
///         Avalanche is deployed first, against *predicted* mainnet lockbox addresses, because each
///         side's peer is the other and both are wired in their constructors. The prediction is made
///         for `--sender`, and assumes the two lockbox deployments are that account's next two
///         mainnet transactions; anything else in between makes the run revert.
///
///         The libraries and confirmations below are each endpoint's own defaults for the route;
///         everything available from the chainlog is read from it.
///
///         This is where Sky's governance DVNs first appear, so the run deploys both halves: the
///         mainnet CCIP DVN adapter, allowlisting the live `LZ_GOV_SENDER`, and Avalanche's adapter
///         with its four CCIP and four multisig replicas. It prints the ULN sets the spell then needs,
///         since the spell — not this script — installs the governance route: 8 of 15 on the receive
///         side, and the adapter spliced into the seven LZ-aligned providers on the send side.
///
///         `SKY_MULTISIG` must be filled in: it drives the multisig DVN wing, which is worthless if
///         the deploying key holds it.
contract DeployAvaxMigration is Script {

    // ============================ fixed references ============================

    uint32  constant ETH_EID  = 30101;
    uint32  constant AVAX_EID = 30106;

    address constant AVAX_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;

    /// @dev The migration hands the new Avalanche adapters over from the old relay, so they must be
    ///      owned by it at spell time, and the gov receiver already exists.
    address constant OLD_AVAX_GOV_RELAY = 0xe928885BCe799Ed933651715608155F01abA23cA;
    address constant AVAX_GOV_RECEIVER  = 0x6fdd46947ca6903c8c159d1dF2012Bc7fC5cEeec;

    address constant AVAX_USDS  = 0x86Ff09db814ac346a7C6FE2Cd648F27706D1D470;
    address constant AVAX_SUSDS = 0xb94D9613C7aAB11E548a327154Cc80eCa911B5c1;

    /// @dev Chainlink CCIP on Avalanche: the router the remote adapter sends through, and the chain
    ///      selector the mainnet adapter routes to.
    address constant AVAX_CCIP_ROUTER   = 0xF4c7E640EdA248ef95972845a62bdC74237805dB;
    uint64  constant AVAX_CCIP_SELECTOR = 6433500567565415381;

    /// @dev FILL IN: the Sky Safe on Avalanche, which drives the multisig DVN wing.
    address constant SKY_MULTISIG = address(0);

    function _skyMultisig() internal pure virtual returns (address) {
        return SKY_MULTISIG;
    }

    uint8 constant CCIP_REPLICAS = 4;
    uint8 constant MSIG_REPLICAS = 4;

    /// @dev N CCIP slots, N multisig, 2N-1 LZ-aligned, threshold 2N: any two wings reach it, no single
    ///      wing does. N = 4 gives the governance route's 8 of 15.
    uint8 constant GOV_RECV_THRESHOLD = 8;

    /// @dev The whole send set: nothing enforces this threshold — every DVN in the set is assigned
    ///      and paid, and delivery is gated by the destination's — it only has to exceed 1.
    uint8 constant GOV_SEND_THRESHOLD = 8;

    uint128 constant CCIP_GAS = 200_000;

    /// @dev The CCIP fee is taken before the send library's deposit lands on the first send.
    uint256 constant ADAPTER_FUND = 0.001 ether;

    // ============================ libraries ============================

    address constant ETH_SEND_LIB  = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1; // SendUln302
    address constant ETH_RECV_LIB  = 0xc02Ab410f0734EFa3F14628780e6e695156024C2; // ReceiveUln302
    address constant ETH_EXECUTOR  = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    address constant AVAX_SEND_LIB = 0x197D1333DEA5Fe0D6600E9b396c7f1B1cFCc558a; // SendUln302
    address constant AVAX_RECV_LIB = 0xbf3521d309642FA9B1c91A08609505BA09752c61; // ReceiveUln302
    address constant AVAX_EXECUTOR = 0x90E595783E43eb89fF07f63d27B8430e6B44bD9c;

    // ============================ new relay ============================

    uint256 constant RELAY_DELAY        = 3 days;
    uint256 constant RELAY_GRACE_PERIOD = 7 days;

    /// @dev Addresses allowed to cancel queued governance actions.
    function _bud() internal pure returns (address[] memory bud) {
        bud = new address[](0);
    }

    // ============================ LayerZero config ============================

    uint32 constant MAX_MESSAGE_SIZE = 10_000;

    /// @dev One figure per leg: the gas is spent on the destination, so benchmark each direction
    ///      rather than copying the other.
    uint128 constant ETH_TO_AVAX_OPTIONS_GAS = 130_000;
    uint128 constant AVAX_TO_ETH_OPTIONS_GAS = 130_000;

    /// @dev Each endpoint's own default for this route.
    uint64 constant ETH_CONFIRMATIONS  = 15;
    uint64 constant AVAX_CONFIRMATIONS = 12;

    function _avaxOftDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](4);
        dvns[0] = 0x07C05EaB7716AcB6f83ebF6268F8EECDA8892Ba1; // Horizen
        dvns[1] = 0x962F502A63F5FBeB44DC9ab932122648E8352959; // LayerZero Labs
        dvns[2] = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5; // Nethermind
        dvns[3] = 0xcC49E6fca014c77E1Eb604351cc1E08C84511760; // Canary
    }

    // ============================ OFT adapter inputs ============================

    RateLimitAccountingType constant PER_EID_ACCOUNTING   = RateLimitAccountingType.Net;
    RateLimitAccountingType constant AGGREGATE_ACCOUNTING = RateLimitAccountingType.Net;

    function _ethPausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    function _avaxPausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    // ============================ governance DVN wings ============================

    /// @dev The same seven providers at their Avalanche addresses. Sorted ascending.
    function _avaxLzDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](7);
        dvns[0] = 0x07C05EaB7716AcB6f83ebF6268F8EECDA8892Ba1; // Horizen
        dvns[1] = 0x962F502A63F5FBeB44DC9ab932122648E8352959; // LayerZero Labs
        dvns[2] = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5; // Nethermind
        dvns[3] = 0xbe57e9E7d9eB16B92C6383792aBe28D64a18c0F1; // Deutsche Telekom
        dvns[4] = 0xcC49E6fca014c77E1Eb604351cc1E08C84511760; // Canary
        dvns[5] = 0xE4193136B92bA91402313e95347c8e9FAD8d27d0; // Luganodes
        dvns[6] = 0xE94aE34DfCC87A61836938641444080B98402c75; // P2P
    }

    // ============================ script ============================

    function run() public returns (Deployed memory d) {
        require(_skyMultisig() != address(0), "DeployAvaxMigration/sky-multisig-unset");

        uint256 l1Fork   = vm.activeFork();
        uint256 avaxFork = vm.createFork(vm.envString("AVAX_RPC_URL"));

        // Read while mainnet is the active fork: the chainlog is a mainnet contract.
        address govSender  = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        address l1GovRelay = LZInit.chainlog.getAddress("LZ_GOV_RELAY");
        address usds       = LZInit.chainlog.getAddress("USDS");
        address susds      = LZInit.chainlog.getAddress("SUSDS");

        // --- mainnet: the CCIP DVN adapter, allowlisting the governance sender ---
        vm.selectFork(l1Fork);
        vm.startBroadcast();

        address[] memory allowed = new address[](1);
        allowed[0] = govSender;
        SendSideDeployer sendDep = new SendSideDeployer(ETH_SEND_LIB, allowed);
        d.ethCcipAdapter = address(sendDep.adapter());

        vm.stopBroadcast();

        // The lockboxes are the Avalanche adapters' peers, so their addresses are needed before they
        // exist. Each `L1OFTDeployer` deploys its implementation at its own nonce 1 and the proxy at
        // 2, so each lockbox address follows from its deployer's, and each deployer's from the
        // broadcaster's mainnet nonce.
        uint64 nonce   = vm.getNonce(msg.sender);
        d.usdsLockbox  = _proxyOf(vm.computeCreateAddress(msg.sender, nonce));
        d.susdsLockbox = _proxyOf(vm.computeCreateAddress(msg.sender, nonce + 1));

        // --- Avalanche: DVN replicas, the new relay, the relayed spell, and the two OFT adapters ---
        vm.selectFork(avaxFork);
        vm.startBroadcast();
        RecvSideDeployer recvDep = _deployAvalanche(d, l1GovRelay);
        vm.stopBroadcast();

        // The replicas are Avalanche contracts, so read the receive-side set before switching back.
        d.recvDvns = GovDvnSet.read(d.ccipBroadcaster, d.msigBroadcaster, _avaxLzDVNs());

        // --- mainnet: the two lockboxes, then the adapter's route to Avalanche and its handoff ---
        vm.selectFork(l1Fork);
        vm.startBroadcast();

        _deployLockboxes(d, usds, susds);

        (bool funded, ) = d.ethCcipAdapter.call{ value: ADAPTER_FUND }("");
        require(funded, "DeployAvaxMigration/adapter-fund-failed");

        _routeSendSide(sendDep, d);

        vm.stopBroadcast();

        _log(d, address(sendDep), recvDep);
    }

    /// @dev Everything the run produces, carried between steps so no frame holds them all.
    struct Deployed {
        address ethCcipAdapter;
        address avaxCcipAdapter;
        address ccipBroadcaster;
        address msigBroadcaster;
        address newRelay;
        address l2Spell;
        address avaxUsdsOft;
        address avaxSusdsOft;
        address usdsLockbox;
        address susdsLockbox;
        address[] recvDvns;
    }

    /// @dev Its own function to keep `run()` clear of the stack depth this struct costs. The
    ///      handoff leaves the governance sender allowlisted, so the revocation array is empty.
    function _routeSendSide(SendSideDeployer sendDep, Deployed memory d) internal {
        sendDep.configure(CCIPDVNCfg({
            remoteEid:               AVAX_EID,
            remoteCcipChainSelector: AVAX_CCIP_SELECTOR,
            remoteCcipAdapter:       d.avaxCcipAdapter,
            remoteCcipBroadcaster:   d.ccipBroadcaster,
            sendLib:                 ETH_SEND_LIB,
            multiplierBps:           0,       // the adapter's break-even default
            gas:                     CCIP_GAS
        }));

        sendDep.handOff(new address[](0));
    }

    function _deployAvalanche(Deployed memory d, address l1GovRelay)
        internal returns (RecvSideDeployer recvDep)
    {
        recvDep = new RecvSideDeployer({
            ccipRouter:        AVAX_CCIP_ROUTER,
            endpoint:          AVAX_ENDPOINT,
            sourceCcipAdapter: d.ethCcipAdapter,
            multisig:          _skyMultisig(),
            nCcip:             CCIP_REPLICAS,
            nMsig:             MSIG_REPLICAS
        });
        d.avaxCcipAdapter = address(recvDep.adapter());
        d.ccipBroadcaster = address(recvDep.ccipBroadcaster());
        d.msigBroadcaster = address(recvDep.msigBroadcaster());

        d.newRelay = GovernanceRelayDeploy.deployL2({
            l1Eid:             ETH_EID,
            l2Oapp:            AVAX_GOV_RECEIVER,
            l1GovernanceRelay: l1GovRelay,
            delay:             RELAY_DELAY,
            gracePeriod:       RELAY_GRACE_PERIOD,
            bud:               _bud()
        });

        d.l2Spell      = address(new LZAvaxMigrationL2Spell());
        d.avaxUsdsOft  = address(new L2OFTDeployer(_avaxDeployment(AVAX_USDS,  d.usdsLockbox)).oft());
        d.avaxSusdsOft = address(new L2OFTDeployer(_avaxDeployment(AVAX_SUSDS, d.susdsLockbox)).oft());
    }

    function _deployLockboxes(Deployed memory d, address usds, address susds) internal {
        address usdsOft  = address(new L1OFTDeployer(_l1Deployment(usds,  d.avaxUsdsOft)).oft());
        address susdsOft = address(new L1OFTDeployer(_l1Deployment(susds, d.avaxSusdsOft)).oft());

        require(usdsOft  == d.usdsLockbox,  "DeployAvaxMigration/usds-lockbox-mismatch");
        require(susdsOft == d.susdsLockbox, "DeployAvaxMigration/susds-lockbox-mismatch");
    }

    function _log(Deployed memory d, address sendDep, RecvSideDeployer recvDep) internal pure {
        console.log("--- mainnet (owned by MCD_PAUSE_PROXY) ---");
        console.log("SendSideDeployer:       ", sendDep);
        console.log("CCIP DVN adapter:       ", d.ethCcipAdapter);
        console.log("USDS  lockbox:          ", d.usdsLockbox);
        console.log("SUSDS lockbox:          ", d.susdsLockbox);
        console.log("--- avalanche (owned by the OLD relay until the spell) ---");
        console.log("RecvSideDeployer:       ", address(recvDep));
        console.log("CCIP DVN adapter:       ", d.avaxCcipAdapter);
        console.log("L2GovernanceRelay (new):", d.newRelay);
        console.log("LZAvaxMigrationL2Spell: ", d.l2Spell);
        console.log("USDS  adapter:          ", d.avaxUsdsOft);
        console.log("SUSDS adapter:          ", d.avaxSusdsOft);

        _logGovUlnSets(d);
    }

    // --- helpers ---

    /// @dev The governance route is the spell's to install, so print the two sets it takes: the send
    ///      side with the adapter spliced into the LZ-aligned providers, and the receive side with
    ///      both wings' replicas alongside them.
    function _logGovUlnSets(Deployed memory d) internal pure {
        (UlnConfig memory sendUlnCfg, uint256 ccipDvnIndex) = _govSendUlnCfg(d.ethCcipAdapter);
        UlnConfig memory recvUlnCfg = _govRecvUlnCfg(d.recvDvns);

        console.log("");
        console.log("Governance send set for the spell's sendUlnCfg - 255 required (NIL), optional");
        console.log(sendUlnCfg.optionalDVNThreshold, "of", sendUlnCfg.optionalDVNCount);
        for (uint256 i; i < sendUlnCfg.optionalDVNs.length; ++i) console.log("  ", sendUlnCfg.optionalDVNs[i]);
        console.log("ccipDvnIndex:", ccipDvnIndex);

        console.log("");
        console.log("Governance receive set for migrateAvaxRemote's recvUlnCfg - optional");
        console.log(recvUlnCfg.optionalDVNThreshold, "of", recvUlnCfg.optionalDVNCount);
        for (uint256 i; i < recvUlnCfg.optionalDVNs.length; ++i) console.log("  ", recvUlnCfg.optionalDVNs[i]);
    }

    /// @dev The adapter spliced into the LZ-aligned providers, and the index the spell dereferences
    ///      to find it.
    function _govSendUlnCfg(address l1Adapter)
        internal pure returns (UlnConfig memory, uint256 ccipDvnIndex)
    {
        address[] memory dvns;
        (dvns, ccipDvnIndex) = GovDvnSet.insertSorted(LzDvns.ethGovDVNs(), l1Adapter);

        return (UlnConfig({
            confirmations:        ETH_CONFIRMATIONS,
            requiredDVNCount:     255,       // NIL: explicitly no required DVNs
            optionalDVNCount:     uint8(dvns.length),
            optionalDVNThreshold: GOV_SEND_THRESHOLD,
            requiredDVNs:         new address[](0),
            optionalDVNs:         dvns
        }), ccipDvnIndex);
    }

    function _govRecvUlnCfg(address[] memory recvDvns) internal pure returns (UlnConfig memory) {
        return UlnConfig({
            confirmations:        AVAX_CONFIRMATIONS,
            requiredDVNCount:     255,
            optionalDVNCount:     uint8(recvDvns.length),
            optionalDVNThreshold: GOV_RECV_THRESHOLD,
            requiredDVNs:         new address[](0),
            optionalDVNs:         recvDvns
        });
    }

    /// @dev A contract's nonce starts at 1 (EIP-161); the implementation takes 1 and the proxy 2.
    function _proxyOf(address deployer) internal pure returns (address) {
        return vm.computeCreateAddress(deployer, 2);
    }

    function _avaxDeployment(address token, address peer) internal pure returns (L2OftDeployment memory) {
        L2RemoteWiring[] memory remotes = new L2RemoteWiring[](1);
        remotes[0] = L2RemoteWiring({
            eid:        ETH_EID,
            cfg:        _avaxOftCfg(peer),
            rateLimits: RateLimits(0, 0, 0, 0)  // the spell opens them
        });

        return L2OftDeployment({
            token:          token,
            endpoint:       AVAX_ENDPOINT,
            accountingType: PER_EID_ACCOUNTING,
            pausers:        _avaxPausers(),
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
            cfg:        _l1OftCfg(peer),
            rateLimits: RateLimits(0, 0, 0, 0)  // the spell opens them
        });

        return L1OftDeployment({
            token:                   token,
            accountingType:          PER_EID_ACCOUNTING,
            aggregateAccountingType: AGGREGATE_ACCOUNTING,
            globalLimits:            RateLimits(0, 0, 0, 0),  // the spell sets the global cap
            pausers:                 _ethPausers(),
            remotes:                 remotes
        });
    }

    function _l1OftCfg(address peer) internal pure returns (OftConfig memory) {
        return _oftCfg(peer, ETH_SEND_LIB, ETH_RECV_LIB, ETH_EXECUTOR, LzDvns.ethOftDVNs(),
                       ETH_CONFIRMATIONS, ETH_TO_AVAX_OPTIONS_GAS);
    }

    function _avaxOftCfg(address peer) internal pure returns (OftConfig memory) {
        return _oftCfg(peer, AVAX_SEND_LIB, AVAX_RECV_LIB, AVAX_EXECUTOR, _avaxOftDVNs(),
                       AVAX_CONFIRMATIONS, AVAX_TO_ETH_OPTIONS_GAS);
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
