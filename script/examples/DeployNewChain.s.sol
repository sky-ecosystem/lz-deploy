// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

// Unaudited example, provided without guarantee: fill in its addresses and re-check every step
// and parameter against the target deployment before use.

import { Script, console } from "forge-std/Script.sol";

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";
import { LZL2Spell }                                                from "lz-init-lib/LZL2Spell.sol";

import { L2OFTDeployer, L2OftDeployment, RemoteWiring } from "src/L2OFTDeployer.sol";
import { L2GovBridgeDeployer, GovRecvConfig }           from "src/L2GovBridgeDeployer.sol";

import { GovDvnSet }               from "script/examples/GovDvnSet.sol";
import { RecvSideDeployer }        from "script/examples/mocks/DvnDeployersFlat.sol";
import { UsdsDeploy, SUsdsDeploy } from "script/examples/mocks/TokenDeployFlat.sol";

interface WardsLike {
    function rely(address usr) external;
    function deny(address usr) external;
}

/// @notice Brings a new chain onto SkyLink, pre-filled for Base: Sky's governance DVNs, the chain's
///         half of the governance bridge, the L2 spell governance drives it with, its USDS and sUSDS,
///         and one OFT adapter per token.
/// @dev    Run with mainnet as the active fork. Needs a funded key on both chains. The remote fork
///         is `BASE_RPC_URL` when set, and forge's own endpoint for the chain otherwise.
///
///           forge script script/examples/DeployNewChain.s.sol:DeployNewChain \
///             --rpc-url <mainnet_rpc> --sender <deployer> --broadcast --slow
///
///         Retarget by replacing the `REMOTE_*` constants and the endpoint, which is not guaranteed
///         to be the same address on every chain. Two addresses need filling in:
///
///         `ETH_CCIP_DVN_ADAPTER` is the mainnet CCIP DVN adapter, which the Avalanche migration
///         deploys — this script only reads it, since by then it belongs to `MCD_PAUSE_PROXY`.
///         `SKY_MULTISIG` is the Sky Safe on the target chain: it is one of the three DVN wings, and
///         that wing is worthless if the deploying key holds it.
///
///         What this deliberately leaves undone is governance's: `LZDVNInit.wireCCIPDVN` adds this
///         chain's route to the mainnet adapter, `LZInit.wireGovPeer` and `wireOftPeer` add the mainnet
///         legs, and `activateOft` opens the rate limits, which is why they are written zero here.
contract DeployNewChain is Script {

    // ============================ fixed references ============================

    uint32 constant ETH_EID = 30101;

    address constant ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;

    /// @dev FILL IN: the mainnet CCIP DVN adapter, from the Avalanche migration. The remote replicas
    ///      below verify what it broadcasts, so they have to name it.
    address constant ETH_CCIP_DVN_ADAPTER = address(0);

    /// @dev FILL IN: the Sky Safe on this chain, which drives the multisig DVN wing.
    address constant SKY_MULTISIG = address(0);

    function _ethCcipDvnAdapter() internal view virtual returns (address) {
        return ETH_CCIP_DVN_ADAPTER;
    }

    function _skyMultisig() internal view virtual returns (address) {
        return SKY_MULTISIG;
    }

    // The remote chain's own deployments, pre-filled for Base.
    address constant REMOTE_SEND_LIB    = 0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2; // SendUln302
    address constant REMOTE_RECV_LIB    = 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf; // ReceiveUln302
    address constant REMOTE_EXECUTOR    = 0x2CCA08ae69E0C44b18a57Ab2A87644234dAebaE4;
    address constant REMOTE_CCIP_ROUTER = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;

    // ============================ governance relay ============================

    uint256 constant RELAY_DELAY        = 3 days;
    uint256 constant RELAY_GRACE_PERIOD = 7 days;

    /// @dev Addresses allowed to cancel queued governance actions.
    function _bud() internal pure returns (address[] memory bud) {
        bud = new address[](0);
    }

    // ============================ LayerZero config ============================

    uint32 constant MAX_MESSAGE_SIZE = 10_000;

    /// @dev Source-chain blocks, so each leg carries its own: 15 Ethereum blocks inbound, 10 Base
    ///      blocks outbound. Both are the respective endpoint's default for the route.
    uint64 constant ETH_CONFIRMATIONS    = 15;
    uint64 constant REMOTE_CONFIRMATIONS = 10;

    /// @dev The only leg this script wires is outbound to mainnet, so one figure covers it; the spell
    ///      that wires the return leg sets its own.
    uint128 constant OFT_OPTIONS_GAS_TO_ETH = 130_000;

    uint8 constant CCIP_REPLICAS = 4;
    uint8 constant MSIG_REPLICAS = 4;

    /// @dev N CCIP slots, N multisig, 2N-1 LZ-aligned, threshold 2N: any two wings reach it, no single
    ///      wing does. N = 4 gives the governance route's 8 of 15.
    uint8 constant RECV_THRESHOLD = 8;

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

    /// @dev The token routes run a small required set, not the governance wings: no CCIP or multisig
    ///      replicas, no threshold. Base's own four, sorted ascending, replaced per remote.
    function _remoteOftDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](4);
        dvns[0] = 0x554833698Ae0FB22ECC90B01222903fD62CA4B47; // Canary
        dvns[1] = 0x9e059a54699a285714207b43B055483E78FAac25; // LayerZero Labs
        dvns[2] = 0xa7b5189bcA84Cd304D8553977c7C614329750d99; // Horizen
        dvns[3] = 0xcd37CA043f8479064e10635020c65FfC005d36f6; // Nethermind
    }

    // ============================ OFT adapter inputs ============================

    RateLimitAccountingType constant PER_EID_ACCOUNTING = RateLimitAccountingType.Net;

    function _remotePausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    // ============================ script ============================

    /// @dev What the run produces, for a spell to consume.
    struct Deployed {
        address ccipDvnAdapter;
        address ccipBroadcaster;
        address msigBroadcaster;
        address receiver;
        address relay;
        address l2Spell;
        address usds;
        address usdsAdapter;
        address usdsAdapterImp;
        address susds;
        address susdsAdapter;
        address susdsAdapterImp;
    }

    /// @return d          what a spell needs to name
    /// @return remoteFork the fork this run created, for a caller relaying the spell's message
    function run() public returns (Deployed memory d, uint256 remoteFork) {
        require(_ethCcipDvnAdapter() != address(0), "DeployNewChain/ccip-dvn-adapter-unset");
        require(_skyMultisig()       != address(0), "DeployNewChain/sky-multisig-unset");

        remoteFork = vm.createFork(getChain("base").rpcUrl);

        // Read while mainnet is the active fork: the chainlog is a mainnet contract, and the two
        // lockboxes are the peers the adapters are wired to.
        address govSender  = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        address l1GovRelay = LZInit.chainlog.getAddress("LZ_GOV_RELAY");
        address usdsOft    = LZInit.chainlog.getAddress("USDS_OFT");
        address susdsOft   = LZInit.chainlog.getAddress("SUSDS_OFT");

        // --- the new chain: DVN replicas and the governance bridge ---
        {
            vm.selectFork(remoteFork);
            vm.startBroadcast();

            RecvSideDeployer recvDep = new RecvSideDeployer({
                ccipRouter:        REMOTE_CCIP_ROUTER,
                endpoint:          ENDPOINT,
                sourceCcipAdapter: _ethCcipDvnAdapter(),
                multisig:          _skyMultisig(),
                nCcip:             CCIP_REPLICAS,
                nMsig:             MSIG_REPLICAS
            });

            d.ccipDvnAdapter  = address(recvDep.adapter());
            d.ccipBroadcaster = address(recvDep.ccipBroadcaster());
            d.msigBroadcaster = address(recvDep.msigBroadcaster());

            _deployGovBridge(d, govSender, l1GovRelay, recvDep);

            // Stateless and unowned: a spell passes it to `relayToL2`, and the relay delegatecalls it.
            d.l2Spell = address(new LZL2Spell());

            vm.stopBroadcast();

            console.log("--- new chain ---");
            console.log("RecvSideDeployer:      ", address(recvDep));
            console.log("CCIP DVN adapter:      ", d.ccipDvnAdapter);
            console.log("CCIP broadcaster:      ", d.ccipBroadcaster);
            console.log("multisig broadcaster:  ", d.msigBroadcaster);
            console.log("GovernanceOAppReceiver:", d.receiver);
            console.log("L2GovernanceRelay:     ", d.relay);
            console.log("LZL2Spell:             ", d.l2Spell);
        }

        // --- the new chain: the tokens and the adapters that mint them ---
        {
            vm.selectFork(remoteFork);
            vm.startBroadcast();
            (d.usds,  d.usdsAdapter,  d.usdsAdapterImp)  = _deployToken("USDS",  usdsOft,  d.relay, true);
            (d.susds, d.susdsAdapter, d.susdsAdapterImp) = _deployToken("SUSDS", susdsOft, d.relay, false);
            vm.stopBroadcast();
        }

    }

    // --- helpers ---

    function _deployGovBridge(
        Deployed         memory d,
        address                 govSender,
        address                 l1GovRelay,
        RecvSideDeployer        recvDep
    ) internal {
        address[] memory dvns = GovDvnSet.read(
            address(recvDep.ccipBroadcaster()),
            address(recvDep.msigBroadcaster()),
            _remoteLzDVNs()
        );

        L2GovBridgeDeployer govDep = new L2GovBridgeDeployer({
            endpoint:    ENDPOINT,
            l1GovSender: govSender,
            l1GovRelay:  l1GovRelay,
            delay:       RELAY_DELAY,
            gracePeriod: RELAY_GRACE_PERIOD,
            bud:         _bud(),
            cfg:         GovRecvConfig({
                recvLib:    REMOTE_RECV_LIB,
                recvUlnCfg: UlnConfig({
                    confirmations:        ETH_CONFIRMATIONS,
                    requiredDVNCount:     255,  // NIL: explicitly no required DVNs
                    optionalDVNCount:     uint8(dvns.length),
                    optionalDVNThreshold: RECV_THRESHOLD,
                    requiredDVNs:         new address[](0),
                    optionalDVNs:         dvns
                })
            })
        });

        d.receiver = address(govDep.receiver());
        d.relay    = govDep.relay();
    }

    /// @dev The token, its adapter, and the authority handover: the adapter mints and burns, the relay
    ///      administers, the key keeps nothing.
    function _deployToken(string memory label, address peer, address relay, bool isUsds)
        internal returns (address token, address oft, address oftImp)
    {
        if (isUsds) token = UsdsDeploy.deployL2(msg.sender, msg.sender).usds;
        else        token = SUsdsDeploy.deploy(msg.sender, msg.sender).sUsds;

        L2OFTDeployer dep = new L2OFTDeployer(_oftDeployment(token, peer, relay));
        oft    = address(dep.oft());
        oftImp = dep.implementation();

        WardsLike(token).rely(oft);
        WardsLike(token).rely(relay);
        WardsLike(token).deny(msg.sender);

        console.log(label, "token:         ", token);
        console.log(label, "adapter:       ", oft);
        console.log(label, "implementation:", oftImp);
    }

    function _remoteOftCfg(address peer) internal pure returns (OftConfig memory) {
        address[] memory dvns = _remoteOftDVNs();

        return OftConfig({
            peer:       peer,
            sendLib:    REMOTE_SEND_LIB,
            execCfg:    ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: REMOTE_EXECUTOR }),
            sendUlnCfg: _oftUlnCfg(dvns, REMOTE_CONFIRMATIONS),
            recvLib:    REMOTE_RECV_LIB,
            recvUlnCfg: _oftUlnCfg(dvns, ETH_CONFIRMATIONS),
            optionsGas: OFT_OPTIONS_GAS_TO_ETH
        });
    }

    function _oftUlnCfg(address[] memory dvns, uint64 confirmations)
        internal pure returns (UlnConfig memory)
    {
        return UlnConfig({
            confirmations:        confirmations,
            requiredDVNCount:     uint8(dvns.length),
            optionalDVNCount:     0,
            optionalDVNThreshold: 0,
            requiredDVNs:         dvns,
            optionalDVNs:         new address[](0)
        });
    }

    /// @dev Rate limits stay zero: `activateOft` opens them, and requires them zero to do it.
    function _oftDeployment(address token, address peer, address relay)
        internal pure returns (L2OftDeployment memory)
    {
        RemoteWiring[] memory remotes = new RemoteWiring[](1);
        remotes[0] = RemoteWiring({
            eid:        ETH_EID,
            cfg:        _remoteOftCfg(peer),
            rateLimits: RateLimits(0, 0, 0, 0)
        });

        return L2OftDeployment({
            token:          token,
            endpoint:       ENDPOINT,
            accountingType: PER_EID_ACCOUNTING,
            pausers:        _remotePausers(),
            remotes:        remotes,
            gov:            relay
        });
    }
}
