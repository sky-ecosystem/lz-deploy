// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { SSROracleForwarderLZ } from "xchain-ssr-oracle/forwarders/SSROracleForwarderLZ.sol";

import {
    LZInit,
    ForwarderConfig,
    SetConfigParam,
    EnforcedOptionParam,
    EndpointLike
} from "lz-init-lib/LZInit.sol";

import { LzOptions } from "./LzOptions.sol";

interface ChainlogLike {
    function getAddress(bytes32) external view returns (address);
}

interface ForwarderAdminLike {
    function setPeer(uint32 eid, bytes32 peer) external;
    function setEnforcedOptions(EnforcedOptionParam[] calldata opts) external;
    function setDelegate(address delegate) external;
    function transferOwnership(address newOwner) external;
}

/// @notice Deploys the mainnet half of an SSR oracle bridge and pre-configures it to the state
///         `LZInit.activateSsrForwarder` asserts before whitelisting it on the shared CCIP DVN adapter.
/// @dev    `remoteReceiver` is `SsrRemoteDeployer.predictedReceiver()`; see that contract for the
///         full ordering. Steps: constructor, `configure`, optional smoke test, `handOff`.
///
///         Unlike the OFT and governance bridges, this one can be smoke tested before any spell: both
///         halves are deployed here and `refresh()` is permissionless, so `sUSDS.drip()` then
///         `refresh()` should land on the remote oracle. The exception is a send DVN set containing
///         the shared CCIP DVN adapter, whose allowlist is deny-by-default — the forwarder is only
///         granted `ALLOWLIST` by `activateSsrForwarder`, so that path needs the spell first.
contract SsrForwarderDeployer {

    ChainlogLike internal constant CHAINLOG = ChainlogLike(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    address public immutable deployer;
    address public immutable endpoint;
    address public immutable forwarder;
    uint32  public immutable dstEid;

    bool public configured;
    bool public handedOff;

    event Configured();
    event HandedOff(address indexed gov);

    modifier onlyDeployer() {
        require(msg.sender == deployer, "SsrForwarderDeployer/not-deployer");
        _;
    }

    constructor(address susds, address endpoint_, address remoteReceiver, uint32 dstEid_) {
        require(remoteReceiver != address(0), "SsrForwarderDeployer/receiver-is-zero");

        deployer = msg.sender;
        endpoint = endpoint_;
        dstEid   = dstEid_;

        forwarder = address(new SSROracleForwarderLZ({
            _susds:    susds,
            _l2Oracle: remoteReceiver,
            _endpoint: endpoint_,
            _delegate: address(this),
            _owner:    address(this),
            _dstEid:   dstEid_
        }));
    }

    /// @notice Wire the forwarder's send side: peer, send library, executor and ULN configs, options.
    /// @dev    `cfg` is the same struct the spell hands to `activateSsrForwarder`, which re-reads all
    ///         of it from chain. `cfg.ccipDvnIndex` is unused here; it only tells the spell which
    ///         optional DVN is the shared CCIP adapter.
    ///
    ///         Enforced options cover the whole remote execution, `lzCompose` included: the remote is an
    ///         `LZComposeReceiver`, so the oracle write happens there. `refresh()` callers then need not
    ///         pass options of their own.
    function configure(ForwarderConfig memory cfg) external onlyDeployer {
        require(!configured,               "SsrForwarderDeployer/already-configured");
        require(cfg.peer    != address(0), "SsrForwarderDeployer/peer-is-zero");
        require(cfg.sendLib != address(0), "SsrForwarderDeployer/send-lib-is-zero");

        configured = true;

        ForwarderAdminLike(forwarder).setPeer(dstEid, bytes32(uint256(uint160(cfg.peer))));

        EndpointLike(endpoint).setSendLibrary(forwarder, dstEid, cfg.sendLib);

        SetConfigParam[] memory sendParams = new SetConfigParam[](2);
        sendParams[0] = SetConfigParam(dstEid, LZInit.EXECUTOR_CONFIG_TYPE, abi.encode(cfg.execCfg));
        sendParams[1] = SetConfigParam(dstEid, LZInit.ULN_CONFIG_TYPE,      abi.encode(cfg.sendUlnCfg));
        EndpointLike(endpoint).setConfig(forwarder, cfg.sendLib, sendParams);

        bytes memory options = LzOptions.encodeLzReceiveAndComposeOptions(cfg.optionsGas, cfg.composeGas);
        EnforcedOptionParam[] memory opts = new EnforcedOptionParam[](1);
        opts[0] = EnforcedOptionParam(dstEid, LZInit.MSG_TYPE_SEND, options);
        ForwarderAdminLike(forwarder).setEnforcedOptions(opts);

        emit Configured();
    }

    /// @notice Hand the forwarder to MCD_PAUSE_PROXY, as owner and endpoint delegate.
    /// @dev    Irreversible. `activateSsrForwarder` asserts both, so they move together.
    function handOff() external onlyDeployer {
        require(configured, "SsrForwarderDeployer/not-configured");
        require(!handedOff, "SsrForwarderDeployer/handed-off");

        handedOff = true;

        address pauseProxy = CHAINLOG.getAddress("MCD_PAUSE_PROXY");

        ForwarderAdminLike(forwarder).setDelegate(pauseProxy);
        ForwarderAdminLike(forwarder).transferOwnership(pauseProxy);

        emit HandedOff(pauseProxy);
    }
}
