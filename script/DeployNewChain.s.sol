// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

import { L2OFTDeployer, L2OftDeployment, RemoteWiring } from "src/L2OFTDeployer.sol";
import { L2GovBridgeDeployer, GovRecvConfig }           from "src/L2GovBridgeDeployer.sol";

import { GovDvnSet }               from "script/GovDvnSet.sol";
import { RecvSideDeployer }        from "script/mocks/DvnDeployersFlat.sol";
import { UsdsDeploy, SUsdsDeploy } from "script/mocks/TokenDeployFlat.sol";

interface WardsLike {
    function rely(address usr) external;
    function deny(address usr) external;
}

/// @notice Brings a new chain onto SkyLink, pre-filled for Base: Sky's governance DVNs, the chain's
///         half of the governance bridge, its USDS and sUSDS, and one OFT adapter per token.
/// @dev    Run with mainnet as the active fork and `BASE_RPC_URL` set. Needs a funded key on both.
///
///           BASE_RPC_URL=<base> forge script script/DeployNewChain.s.sol:DeployNewChain \
///             --rpc-url <mainnet_rpc> --broadcast --slow --skip-simulation --verify
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
    uint64 constant CONFIRMATIONS    = 15;

    /// @dev The only leg this script wires is outbound to mainnet, so one figure covers it; the spell
    ///      that wires the return leg sets its own.
    uint128 constant OFT_OPTIONS_GAS_TO_ETH = 130_000;

    uint8 constant CCIP_REPLICAS = 4;
    uint8 constant MSIG_REPLICAS = 4;

    /// @dev N CCIP slots, N multisig, 2N-1 LZ-aligned, threshold 2N: any two wings reach it, no single
    ///      wing does. N = 4 gives the governance route's 8 of 15.
    uint8 constant RECV_THRESHOLD = 8;

    /// @dev The LZ-aligned wing: the seven providers on `LZ_GOV_SENDER`'s own optional set, at their
    ///      addresses on the remote chain. Sorted ascending.
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
    ///      replicas, no threshold. These are the endpoint's own four defaults for the route, which
    ///      include both providers the live USDS lockbox uses today. Sorted ascending.
    function _remoteOftDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](4);
        dvns[0] = 0x554833698Ae0FB22ECC90B01222903fD62CA4B47; // Canary
        dvns[1] = 0x9e059a54699a285714207b43B055483E78FAac25; // LayerZero Labs
        dvns[2] = 0xa7b5189bcA84Cd304D8553977c7C614329750d99; // Horizen
        dvns[3] = 0xcd37CA043f8479064e10635020c65FfC005d36f6; // Nethermind
    }

    /// @dev None by default; pausing is a per-chain operational choice.
    function _pausers() internal pure returns (address[] memory) {
        return new address[](0);
    }

    // ============================ script ============================

    function run() external {
        require(ETH_CCIP_DVN_ADAPTER != address(0), "DeployNewChain/ccip-dvn-adapter-unset");
        require(SKY_MULTISIG         != address(0), "DeployNewChain/sky-multisig-unset");

        uint256 remoteFork = vm.createFork(vm.envString("BASE_RPC_URL"));

        // Read while mainnet is the active fork: the chainlog is a mainnet contract, and the two
        // lockboxes are the peers the adapters are wired to.
        address govSender  = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        address l1GovRelay = LZInit.chainlog.getAddress("LZ_GOV_RELAY");
        address usdsOft    = LZInit.chainlog.getAddress("USDS_OFT");
        address susdsOft   = LZInit.chainlog.getAddress("SUSDS_OFT");

        address relay;

        // --- the new chain: DVN replicas and the governance bridge ---
        {
            vm.selectFork(remoteFork);
            vm.startBroadcast();

            RecvSideDeployer recvDep = new RecvSideDeployer({
                ccipRouter:        REMOTE_CCIP_ROUTER,
                endpoint:          ENDPOINT,
                sourceCcipAdapter: ETH_CCIP_DVN_ADAPTER,
                multisig:          SKY_MULTISIG,
                nCcip:             CCIP_REPLICAS,
                nMsig:             MSIG_REPLICAS
            });

            relay = _deployGovBridge(govSender, l1GovRelay, recvDep);

            vm.stopBroadcast();

            console.log("--- new chain ---");
            console.log("RecvSideDeployer:      ", address(recvDep));
            console.log("CCIP DVN adapter:      ", address(recvDep.adapter()));
            console.log("CCIP broadcaster:      ", address(recvDep.ccipBroadcaster()));
            console.log("multisig broadcaster:  ", address(recvDep.msigBroadcaster()));
            console.log("L2GovernanceRelay:     ", relay);
        }

        // --- the new chain: the tokens and the adapters that mint them ---
        {
            vm.selectFork(remoteFork);
            vm.startBroadcast();
            _deployToken("USDS",  usdsOft,  relay, true);
            _deployToken("SUSDS", susdsOft, relay, false);
            vm.stopBroadcast();
        }

        console.log("");
        console.log("Next, as a spell on mainnet: wireCCIPDVN for this chain's route, then wireGovPeer,");
        console.log("wireOftPeer and activateOft. DeploySsrBridge takes the relay, both broadcasters and");
        console.log("the mainnet CCIP DVN adapter from the addresses above.");
    }

    // --- helpers ---

    function _deployGovBridge(address govSender, address l1GovRelay, RecvSideDeployer recvDep)
        internal returns (address)
    {
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
                    confirmations:        CONFIRMATIONS,
                    requiredDVNCount:     255,  // NIL: explicitly no required DVNs
                    optionalDVNCount:     uint8(dvns.length),
                    optionalDVNThreshold: RECV_THRESHOLD,
                    requiredDVNs:         new address[](0),
                    optionalDVNs:         dvns
                })
            })
        });

        console.log("GovernanceOAppReceiver:", address(govDep.receiver()));
        return govDep.relay();
    }

    /// @dev The token, its adapter, and the authority handover: the adapter mints and burns, the relay
    ///      administers, the key keeps nothing.
    function _deployToken(string memory label, address peer, address relay, bool isUsds) internal {
        address token;
        if (isUsds) token = UsdsDeploy.deployL2(msg.sender, msg.sender).usds;
        else        token = SUsdsDeploy.deploy(msg.sender, msg.sender).sUsds;

        L2OFTDeployer dep = new L2OFTDeployer(_oftDeployment(token, peer, relay));

        WardsLike(token).rely(address(dep.oft()));
        WardsLike(token).rely(relay);
        WardsLike(token).deny(msg.sender);

        console.log(label, "token:  ", token);
        console.log(label, "adapter:", address(dep.oft()));
    }

    /// @dev Rate limits stay zero: `activateOft` opens them, and requires them zero to do it.
    function _oftDeployment(address token, address peer, address relay)
        internal pure returns (L2OftDeployment memory)
    {
        address[] memory dvns = _remoteOftDVNs();
        UlnConfig memory uln  = UlnConfig({
            confirmations:        CONFIRMATIONS,
            requiredDVNCount:     uint8(dvns.length),
            optionalDVNCount:     0,
            optionalDVNThreshold: 0,
            requiredDVNs:         dvns,
            optionalDVNs:         new address[](0)
        });

        RemoteWiring[] memory remotes = new RemoteWiring[](1);
        remotes[0] = RemoteWiring({
            eid:        ETH_EID,
            cfg:        OftConfig({
                peer:       peer,
                sendLib:    REMOTE_SEND_LIB,
                execCfg:    ExecutorConfig({ maxMessageSize: MAX_MESSAGE_SIZE, executor: REMOTE_EXECUTOR }),
                sendUlnCfg: uln,
                recvLib:    REMOTE_RECV_LIB,
                recvUlnCfg: uln,
                optionsGas: OFT_OPTIONS_GAS_TO_ETH
            }),
            rateLimits: RateLimits(0, 0, 0, 0)
        });

        return L2OftDeployment({
            token:          token,
            endpoint:       ENDPOINT,
            accountingType: RateLimitAccountingType.Net,
            pausers:        _pausers(),
            remotes:        remotes,
            gov:            relay
        });
    }

}
