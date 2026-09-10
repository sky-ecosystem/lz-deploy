// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import {
    LZInit,
    ForwarderConfig,
    EndpointLike,
    UlnLike,
    OAppLike
} from "lz-init-lib/LZInit.sol";

import { L1SsrBridgeDeployer } from "src/L1SsrBridgeDeployer.sol";
import { L2SsrBridgeDeployer } from "src/L2SsrBridgeDeployer.sol";

import { LZDeployTestBase } from "./LZDeployTestBase.sol";

interface OracleLike {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function DATA_PROVIDER_ROLE() external view returns (bytes32);
    function maxSSR() external view returns (uint256);
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

/// @notice Acceptance test for the SSR oracle bridge's two deployers: build both halves as the
///         deployer would, then run the mainnet function the spell itself calls.
/// @dev    Both halves run on one mainnet fork: the forwarder half is genuinely mainnet, and the
///         remote half only touches endpoint and OApp state, which is chain-agnostic. The remote side
///         is asserted directly, being unreadable from a mainnet spell.
contract SsrBridgeDeployersTest is LZDeployTestBase {

    uint128 constant FWD_OPTIONS_GAS = 100_000;
    uint128 constant FWD_COMPOSE_GAS = 200_000;
    uint256 constant MAX_SSR         = 1.00000001e27;

    address deployerEOA = makeAddr("deployerEOA");
    address l2GovRelay  = makeAddr("l2GovRelay");
    address oracleAdmin = makeAddr("oracleAdmin");

    L2SsrBridgeDeployer remoteDep;

    address forwarder;
    address receiver;

    ForwarderConfig fwdCfg;

    function setUp() public override {
        super.setUp();

        vm.startPrank(deployerEOA);

        // 1. remote: the oracle
        remoteDep = new L2SsrBridgeDeployer(MAX_SSR, oracleAdmin);

        // 2. L1: forwarder, wired and handed off in its constructor, against the receiver address
        //    the L2 deployer will use
        fwdCfg = ForwarderConfig({
            peer:         remoteDep.predictedReceiver(),
            sendLib:      SEND_LIB,
            execCfg:      execCfg,
            sendUlnCfg:   govUlnCfg,
            ccipDvnIndex: LZInit.NO_CCIP_DVN,
            optionsGas:   FWD_OPTIONS_GAS,
            composeGas:   FWD_COMPOSE_GAS
        });
        forwarder = address(new L1SsrBridgeDeployer(DST_EID, fwdCfg).forwarder());

        // 3. remote: receiver, now that the forwarder address is known, handed off in the same call
        remoteDep.deployReceiver(ENDPOINT, forwarder, RECV_LIB, govUlnCfg, l2GovRelay);
        receiver = address(remoteDep.receiver());

        vm.stopPrank();
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

    // ==================================
    //  Remote side
    // ==================================

    function test_configuresOracleAndRenouncesAdmin() public view {
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
        vm.prank(deployerEOA);
        L2SsrBridgeDeployer dep = new L2SsrBridgeDeployer(MAX_SSR, address(0));

        OracleLike oracle = OracleLike(address(dep.oracle()));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(0)));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(dep)));
    }

    function test_deploysWiresAndHandsOffReceiver() public view {
        ReceiverLike r = ReceiverLike(receiver);

        assertEq(receiver, remoteDep.predictedReceiver(), "receiver must match the prediction");
        assertEq(ForwarderLike(forwarder).l2Oracle(), receiver, "forwarder must point at the receiver");

        assertEq(OAppLike(receiver).endpoint(), ENDPOINT);
        assertEq(r.srcEid(),          ETH_EID);
        assertEq(r.sourceAuthority(), bytes32(uint256(uint160(forwarder))));
        assertEq(r.target(),          address(remoteDep.oracle()));
        assertEq(OAppLike(receiver).peers(ETH_EID), bytes32(uint256(uint160(forwarder))));

        (address recvLib, bool isDefault) = EndpointLike(ENDPOINT).getReceiveLibrary(receiver, ETH_EID);
        assertEq(recvLib, RECV_LIB);
        assertFalse(isDefault, "receive library must be set explicitly");
        assertEq(EndpointLike(ENDPOINT).receiveLibraryTimeout(receiver, ETH_EID), address(0));

        _assertUlnConfig(abi.encode(UlnLike(RECV_LIB).getAppUlnConfig(receiver, ETH_EID)), govUlnCfg);

        assertEq(r.owner(),                                  l2GovRelay);
        assertEq(EndpointLike(ENDPOINT).delegates(receiver), l2GovRelay);
    }

    // ==================================
    //  Access control
    // ==================================

    function test_onlyDeployerCanDeployTheReceiver() public {
        vm.expectRevert("L2SsrBridgeDeployer/not-deployer");
        remoteDep.deployReceiver(ENDPOINT, forwarder, RECV_LIB, govUlnCfg, l2GovRelay);
    }

    function test_receiverCannotBeDeployedTwice() public {
        vm.prank(deployerEOA);
        vm.expectRevert("L2SsrBridgeDeployer/receiver-already-deployed");
        remoteDep.deployReceiver(ENDPOINT, forwarder, RECV_LIB, govUlnCfg, l2GovRelay);
    }
}
