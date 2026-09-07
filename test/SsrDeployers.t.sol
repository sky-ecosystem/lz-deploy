// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import {
    LZInit,
    ForwarderConfig,
    UlnConfig,
    EndpointLike,
    UlnLike,
    OAppLike
} from "lz-init-lib/LZInit.sol";

import { SsrRemoteDeployer }    from "src/SsrRemoteDeployer.sol";
import { SsrForwarderDeployer } from "src/SsrForwarderDeployer.sol";
import { OptionsBuilder }       from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

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
    function susds() external view returns (address);
    function l2Oracle() external view returns (address);
    function dstEid() external view returns (uint32);
    function owner() external view returns (address);
    function enforcedOptions(uint32 eid, uint16 msgType) external view returns (bytes memory);
}

/// @dev Both halves run on one mainnet fork: the forwarder half is genuinely mainnet, and the
///      remote half only touches endpoint and OApp state, which is chain-agnostic.
contract SsrDeployersTest is LZDeployTestBase {

    using OptionsBuilder for bytes;

    uint128 constant FWD_OPTIONS_GAS = 100_000;
    uint128 constant FWD_COMPOSE_GAS = 200_000;
    uint256 constant MAX_SSR         = 1.00000001e27;

    address deployerEOA = makeAddr("deployerEOA");
    address l2GovRelay  = makeAddr("l2GovRelay");
    address oracleAdmin = makeAddr("oracleAdmin");

    SsrRemoteDeployer    remoteDep;
    SsrForwarderDeployer fwdDep;

    address forwarder;
    address receiver;

    UlnConfig       fwdSendUlnCfg;
    ForwarderConfig fwdCfg;

    function setUp() public override {
        super.setUp();

        // `_verifyForwarderConfig` requires non-zero optional, required (255 = NIL) and confirmations.
        address[] memory optionalDVNs = new address[](2);
        optionalDVNs[0] = DVN_LZ_LABS;
        optionalDVNs[1] = DVN_NETHERMIND;

        fwdSendUlnCfg = UlnConfig({
            confirmations:        15,
            requiredDVNCount:     255,
            optionalDVNCount:     2,
            optionalDVNThreshold: 2,
            requiredDVNs:         new address[](0),
            optionalDVNs:         optionalDVNs
        });

        vm.startPrank(deployerEOA);

        // 1. remote: the oracle
        remoteDep = new SsrRemoteDeployer(MAX_SSR, oracleAdmin);

        // 2. L1: forwarder, wired and handed off in its constructor, against the receiver address
        //    the remote deployer will use
        fwdCfg = ForwarderConfig({
            peer:         remoteDep.predictedReceiver(),
            sendLib:      SEND_LIB,
            execCfg:      execCfg,
            sendUlnCfg:   fwdSendUlnCfg,
            ccipDvnIndex: type(uint256).max, // LZInit.NO_CCIP_DVN
            optionsGas:   FWD_OPTIONS_GAS,
            composeGas:   FWD_COMPOSE_GAS
        });
        fwdDep    = new SsrForwarderDeployer(DST_EID, fwdCfg);
        forwarder = address(fwdDep.forwarder());

        // 3. remote: receiver, now that the forwarder address is known, handed off in the same call
        remoteDep.deployReceiver(ENDPOINT, forwarder, RECV_LIB, govUlnCfg, l2GovRelay);
        receiver = address(remoteDep.receiver());

        vm.stopPrank();
    }

    // ==================================
    //  Acceptance: lz-init-lib accepts what we deploy
    // ==================================

    /// @dev With the `NO_CCIP_DVN` sentinel this degrades to pure verification of the forwarder's
    ///      config — the part this repo produces. The CCIP adapter is deployed outside it.
    function test_activateSsrForwarderAcceptsDeployedState() public {
        vm.startPrank(PAUSE_PROXY);
        LZInit.activateSsrForwarder(forwarder, DST_EID, fwdCfg);
        vm.stopPrank();
    }

    // ==================================
    //  Address prediction
    // ==================================

    function test_receiverLandsAtPredictedAddress() public view {
        assertEq(receiver, remoteDep.predictedReceiver(), "receiver must match the prediction");
        assertEq(ForwarderLike(forwarder).l2Oracle(), receiver, "forwarder must point at the receiver");
    }

    function test_receiverCannotBeDeployedTwice() public {
        vm.prank(deployerEOA);
        vm.expectRevert("SsrRemoteDeployer/receiver-already-deployed");
        remoteDep.deployReceiver(ENDPOINT, forwarder, RECV_LIB, govUlnCfg, l2GovRelay);
    }

    // ==================================
    //  Remote side
    // ==================================

    function test_receiverWiring() public view {
        ReceiverLike r = ReceiverLike(receiver);

        assertEq(r.target(),          address(remoteDep.oracle()));
        assertEq(r.srcEid(),          ETH_EID);
        assertEq(r.sourceAuthority(), bytes32(uint256(uint160(forwarder))));
        assertEq(OAppLike(receiver).peers(ETH_EID), bytes32(uint256(uint160(forwarder))));

        (address recvLib, bool isDefault) = EndpointLike(ENDPOINT).getReceiveLibrary(receiver, ETH_EID);
        assertEq(recvLib, RECV_LIB);
        assertFalse(isDefault, "receive library must be set explicitly");

        _assertUlnConfig(abi.encode(UlnLike(RECV_LIB).getAppUlnConfig(receiver, ETH_EID)), govUlnCfg);
    }

    function test_oracleAuthorisesOnlyTheReceiver() public view {
        OracleLike oracle = OracleLike(address(remoteDep.oracle()));

        assertTrue(oracle.hasRole(oracle.DATA_PROVIDER_ROLE(), receiver));
        assertFalse(oracle.hasRole(oracle.DATA_PROVIDER_ROLE(), forwarder));
        assertFalse(oracle.hasRole(oracle.DATA_PROVIDER_ROLE(), address(remoteDep)));
    }

    function test_maxSSRSetAtConstruction() public view {
        assertEq(OracleLike(address(remoteDep.oracle())).maxSSR(), MAX_SSR);
    }

    function test_handOffMovesReceiverAndOracleAdmin() public view {
        OracleLike oracle = OracleLike(address(remoteDep.oracle()));

        assertEq(ReceiverLike(receiver).owner(),             l2GovRelay);
        assertEq(EndpointLike(ENDPOINT).delegates(receiver), l2GovRelay);

        assertTrue(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), oracleAdmin));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(remoteDep)), "deployer must renounce admin");
    }

    /// @dev No admin freezes `DATA_PROVIDER_ROLE` and `maxSSR` for good. Deliberate; asserted so it
    ///      cannot regress silently.
    function test_zeroOracleAdminLeavesNoAdmin() public {
        vm.prank(deployerEOA);
        SsrRemoteDeployer dep = new SsrRemoteDeployer(MAX_SSR, address(0));

        OracleLike oracle = OracleLike(address(dep.oracle()));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), address(dep)));
        assertFalse(oracle.hasRole(oracle.DEFAULT_ADMIN_ROLE(), l2GovRelay));
    }

    // ==================================
    //  Forwarder side
    // ==================================

    function test_forwarderImmutables() public view {
        ForwarderLike f = ForwarderLike(forwarder);

        assertEq(f.susds(),  SUSDS);
        assertEq(f.dstEid(), DST_EID);
        assertEq(OAppLike(forwarder).endpoint(), ENDPOINT);
    }

    function test_forwarderSendSideConfig() public view {
        assertEq(OAppLike(forwarder).peers(DST_EID), bytes32(uint256(uint160(receiver))));

        assertEq(EndpointLike(ENDPOINT).getSendLibrary(forwarder, DST_EID), SEND_LIB);
        assertFalse(EndpointLike(ENDPOINT).isDefaultSendLibrary(forwarder, DST_EID));

        (uint32 maxMsgSize, address exec) =
            abi.decode(EndpointLike(ENDPOINT).getConfig(forwarder, SEND_LIB, DST_EID, 1), (uint32, address));
        assertEq(maxMsgSize, execCfg.maxMessageSize);
        assertEq(exec,       execCfg.executor);

        _assertUlnConfig(abi.encode(UlnLike(SEND_LIB).getAppUlnConfig(forwarder, DST_EID)), fwdSendUlnCfg);

        // lzReceive + lzCompose: the remote's oracle write happens in lzCompose, so the enforced
        // options have to pay for it rather than leaving it to each refresh() caller.
        assertEq(
            ForwarderLike(forwarder).enforcedOptions(DST_EID, 1),
            OptionsBuilder.newOptions()
                .addExecutorLzReceiveOption(FWD_OPTIONS_GAS, 0)
                .addExecutorLzComposeOption(0, FWD_COMPOSE_GAS, 0)
        );
    }

    function test_forwarderHandedToPauseProxy() public view {
        assertEq(ForwarderLike(forwarder).owner(),            PAUSE_PROXY);
        assertEq(EndpointLike(ENDPOINT).delegates(forwarder), PAUSE_PROXY);
    }

    // ==================================
    //  Access control
    // ==================================

    function test_onlyDeployerCanDeployTheReceiver() public {
        vm.expectRevert("SsrRemoteDeployer/not-deployer");
        remoteDep.deployReceiver(ENDPOINT, forwarder, RECV_LIB, govUlnCfg, l2GovRelay);
    }
}
