// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { SSROracleForwarderLZ } from "xchain-ssr-oracle/forwarders/SSROracleForwarderLZ.sol";

import { EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import { OptionsBuilder }      from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

import { LZInit, ForwarderConfig, SetConfigParam, EndpointLike, OAppLike } from "lz-init-lib/LZInit.sol";

/// @notice Deploys the mainnet half of an SSR oracle bridge, wires its send side and hands it to
///         `MCD_PAUSE_PROXY`.
/// @dev    `cfg.peer` is the remote `LZComposeReceiver`, which the forwarder also holds immutably as
///         its oracle, so it must already be known: it is `L2SsrBridgeDeployer.predictedReceiver()`,
///         read before this runs. The README gives the cross-chain sequence.
contract L1SsrBridgeDeployer {

    using OptionsBuilder for bytes;

    SSROracleForwarderLZ public immutable forwarder;

    /// @dev `cfg.ccipDvnIndex` is unused here; it is carried for the spell, which whitelists the
    ///      forwarder on that DVN.
    constructor(uint32 dstEid, ForwarderConfig memory cfg) {
        address endpoint = OAppLike(LZInit.chainlog.getAddress("LZ_GOV_SENDER")).endpoint();

        forwarder = new SSROracleForwarderLZ({
            _susds:    LZInit.chainlog.getAddress("SUSDS"),
            _l2Oracle: cfg.peer,
            _endpoint: endpoint,
            _delegate: address(this),
            _owner:    address(this),
            _dstEid:   dstEid
        });

        forwarder.setPeer(dstEid, bytes32(uint256(uint160(cfg.peer))));

        EndpointLike(endpoint).setSendLibrary(address(forwarder), dstEid, cfg.sendLib);

        SetConfigParam[] memory sendParams = new SetConfigParam[](2);
        sendParams[0] = SetConfigParam(dstEid, LZInit.EXECUTOR_CONFIG_TYPE, abi.encode(cfg.execCfg));
        sendParams[1] = SetConfigParam(dstEid, LZInit.ULN_CONFIG_TYPE,      abi.encode(cfg.sendUlnCfg));
        EndpointLike(endpoint).setConfig(address(forwarder), cfg.sendLib, sendParams);

        EnforcedOptionParam[] memory opts = new EnforcedOptionParam[](1);
        opts[0] = EnforcedOptionParam(
            dstEid,
            LZInit.MSG_TYPE_SEND,
            OptionsBuilder.newOptions()
                .addExecutorLzReceiveOption(cfg.optionsGas, 0)
                .addExecutorLzComposeOption(0, cfg.composeGas, 0)
        );
        forwarder.setEnforcedOptions(opts);

        address pauseProxy = LZInit.chainlog.getAddress("MCD_PAUSE_PROXY");
        forwarder.setDelegate(pauseProxy);
        forwarder.transferOwnership(pauseProxy);
    }
}
