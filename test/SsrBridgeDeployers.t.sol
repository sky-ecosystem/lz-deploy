// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import {
    LZInit,
    ForwarderConfig,
    EndpointLike,
    UlnLike,
    OAppLike
} from "lz-init-lib/LZInit.sol";

import { MessagingFee } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import { Bridge }                from "xchain-helpers/testing/Bridge.sol";
import { Domain, DomainHelpers } from "xchain-helpers/testing/Domain.sol";
import { LZBridgeTesting }       from "xchain-helpers/testing/bridges/LZBridgeTesting.sol";

import { SSROracleForwarderLZ } from "xchain-ssr-oracle/forwarders/SSROracleForwarderLZ.sol";

import { L1SsrBridgeDeployer } from "src/L1SsrBridgeDeployer.sol";
import { L2SsrBridgeDeployer } from "src/L2SsrBridgeDeployer.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

interface OracleLike {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function DATA_PROVIDER_ROLE() external view returns (bytes32);
    function maxSSR() external view returns (uint256);
    function getSSR() external view returns (uint256);
    function getChi() external view returns (uint256);
    function getRho() external view returns (uint256);
}

interface ReceiverLike {
    function target() external view returns (address);
    function srcEid() external view returns (uint32);
    function sourceAuthority() external view returns (bytes32);
    function owner() external view returns (address);
}

interface ForwarderLike {
    function l2Oracle() external view returns (address);
}

interface SUsdsLike {
    function ssr() external view returns (uint256);
    function chi() external view returns (uint192);
    function rho() external view returns (uint64);
}

/// @notice Acceptance test for the SSR oracle bridge's two deployers: build both halves as the
///         deployer would, then run the mainnet function the spell itself calls and deliver one
///         refresh over the route.
/// @dev    Two forks, since the refresh has to cross. The remote side is asserted directly, being
///         unreadable from a mainnet spell.
contract SsrBridgeDeployersTest is LZDeployTestBase {

    using DomainHelpers   for *;
    using LZBridgeTesting for *;

    uint128 constant FWD_OPTIONS_GAS = 100_000;
    uint128 constant FWD_COMPOSE_GAS = 200_000;
    uint256 constant MAX_SSR         = 1.00000001e27;

    address deployerEOA = makeAddr("deployerEOA");
    address l2GovRelay  = makeAddr("l2GovRelay");
    address oracleAdmin = makeAddr("oracleAdmin");

    Domain remote;
    Bridge bridge;

    L2SsrBridgeDeployer remoteDep;

    address forwarder;
    address receiver;

    ForwarderConfig fwdCfg;

    function setUp() public override {
        super.setUp();

        remote = getChain("base").createFork(REMOTE_FORK_BLOCK);
        bridge = LZBridgeTesting.createLZBridge(mainnet, remote);

        // 1. remote: the oracle
        remote.selectFork();
        vm.startPrank(deployerEOA);
        remoteDep = new L2SsrBridgeDeployer(MAX_SSR, oracleAdmin);
        vm.stopPrank();

        // The deployer lives on this chain, so read its prediction before switching away.
        address predictedReceiver = remoteDep.predictedReceiver();

        // 2. L1: forwarder, wired and handed off in its constructor, against the receiver address
        //    the L2 deployer will use
        mainnet.selectFork();
        fwdCfg = ForwarderConfig({
            peer:         predictedReceiver,
            sendLib:      SEND_LIB,
            execCfg:      execCfg,
            sendUlnCfg:   govUlnCfg,
            ccipDvnIndex: LZInit.NO_CCIP_DVN,
            optionsGas:   FWD_OPTIONS_GAS,
            composeGas:   FWD_COMPOSE_GAS
        });
        vm.startPrank(deployerEOA);
        forwarder = address(new L1SsrBridgeDeployer(DST_EID, fwdCfg).forwarder());
        vm.stopPrank();

        // 3. remote: receiver, now that the forwarder address is known, handed off in the same call
        remote.selectFork();
        vm.startPrank(deployerEOA);
        remoteDep.deployReceiver(ENDPOINT, forwarder, REMOTE_RECV_LIB, remoteGovUlnCfg, l2GovRelay);
        vm.stopPrank();
        receiver = address(remoteDep.receiver());

        mainnet.selectFork();
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    /// @dev `_verifyForwarderConfig` re-reads the forwarder end to end — endpoint, `dstEid`,
    ///      `susds`, peer, owner, delegate, send library and that it is not the default, executor and
    ///      ULN configs, enforced options — so this call is the whole assertion for the mainnet half.
    ///      With the `NO_CCIP_DVN` sentinel it writes nothing: the adapter it would otherwise
    ///      whitelist the forwarder on is deployed outside this repo.
    function test_activateSsrForwarderAcceptsDeployedState() public {
        vm.startPrank(PAUSE_PROXY);
        LZInit.activateSsrForwarder(forwarder, DST_EID, fwdCfg);
        vm.stopPrank();
    }

    /// @dev The oracle write is deferred to `lzCompose`, which the forwarder's enforced options pay
    ///      for, so no `extraOptions` are needed on the call.
    function test_refreshWritesTheRemoteOracle() public {
        remote.selectFork();
        assertEq(OracleLike(address(remoteDep.oracle())).getSSR(), 0);

        mainnet.selectFork();
        SUsdsLike susds = SUsdsLike(LZInit.chainlog.getAddress("SUSDS"));
        uint256 ssr = susds.ssr();
        uint256 chi = susds.chi();
        uint256 rho = susds.rho();

        MessagingFee memory fee = SSROracleForwarderLZ(forwarder).quote("");
        vm.deal(address(this), fee.nativeFee);
        SSROracleForwarderLZ(forwarder).refresh{ value: fee.nativeFee }("", address(this));

        bridge.relayMessagesToDestination(true, forwarder, receiver);
        bridge.relayComposeMessagesToDestination(true);

        OracleLike oracle = OracleLike(address(remoteDep.oracle()));
        assertEq(oracle.getSSR(), ssr);
        assertEq(oracle.getChi(), chi);
        assertEq(oracle.getRho(), rho);
    }

    // ==================================
    //  Remote side
    // ==================================

    function test_configuresOracleAndRenouncesAdmin() public {
        remote.selectFork();

        OracleLike oracle = OracleLike(address(remoteDep.oracle()));

        assertEq(oracle.maxSSR(), MAX_SSR);

        assertTrue(oracle.hasRole(oracle.DATA_PROVIDER_ROLE(), receiver));
        assertTrue(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), oracleAdmin));
        assertFalse(
            oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(remoteDep)),
            "deployer must renounce admin"
        );
    }

    /// @dev A zero admin leaves the oracle with none, freezing `maxSSR` and `DATA_PROVIDER_ROLE` for
    ///      good.
    function test_zeroOracleAdminLeavesNoAdmin() public {
        remote.selectFork();

        vm.prank(deployerEOA);
        L2SsrBridgeDeployer dep = new L2SsrBridgeDeployer(MAX_SSR, address(0));

        OracleLike oracle = OracleLike(address(dep.oracle()));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(0)));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(dep)));
    }

    function test_deploysWiresAndHandsOffReceiver() public {
        assertEq(ForwarderLike(forwarder).l2Oracle(), receiver, "forwarder must point at the receiver");

        remote.selectFork();
        ReceiverLike r = ReceiverLike(receiver);

        assertEq(receiver, remoteDep.predictedReceiver(), "receiver must match the prediction");

        assertEq(OAppLike(receiver).endpoint(), ENDPOINT);
        assertEq(r.srcEid(),          ETH_EID);
        assertEq(r.sourceAuthority(), bytes32(uint256(uint160(forwarder))));
        assertEq(r.target(),          address(remoteDep.oracle()));
        assertEq(OAppLike(receiver).peers(ETH_EID), bytes32(uint256(uint160(forwarder))));

        (address recvLib, bool isDefault) = EndpointLike(ENDPOINT).getReceiveLibrary(receiver, ETH_EID);
        assertEq(recvLib, REMOTE_RECV_LIB);
        assertFalse(isDefault, "receive library must be set explicitly");
        assertEq(EndpointLike(ENDPOINT).receiveLibraryTimeout(receiver, ETH_EID), address(0));

        _assertUlnConfig(
            abi.encode(UlnLike(REMOTE_RECV_LIB).getAppUlnConfig(receiver, ETH_EID)),
            remoteGovUlnCfg
        );

        assertEq(r.owner(),                                  l2GovRelay);
        assertEq(EndpointLike(ENDPOINT).delegates(receiver), l2GovRelay);
    }

    // ==================================
    //  Access control
    // ==================================

    function test_onlyDeployerCanDeployTheReceiver() public {
        remote.selectFork();

        vm.expectRevert("L2SsrBridgeDeployer/not-deployer");
        remoteDep.deployReceiver(ENDPOINT, forwarder, REMOTE_RECV_LIB, remoteGovUlnCfg, l2GovRelay);
    }

    function test_receiverCannotBeDeployedTwice() public {
        remote.selectFork();

        vm.prank(deployerEOA);
        vm.expectRevert("L2SsrBridgeDeployer/receiver-already-deployed");
        remoteDep.deployReceiver(ENDPOINT, forwarder, REMOTE_RECV_LIB, remoteGovUlnCfg, l2GovRelay);
    }
}
