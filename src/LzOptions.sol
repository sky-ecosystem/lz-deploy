// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

/// @notice Executor options encoding, byte-identical to the one Sky spells assert against.
/// @dev    `LZInit` declares its own encoder private, so it is reproduced here and must stay
///         byte-identical to it: `_verifyForwarderConfig` compares `enforcedOptions` against LZInit's
///         encoding by hash. `test/LzOptions.t.sol` pins both against LayerZero's `OptionsBuilder`.
library LzOptions {

    /// @dev Equivalent to OptionsBuilder.newOptions().addExecutorLzReceiveOption(gas, 0).
    function encodeLzReceiveOptions(uint128 gas) internal pure returns (bytes memory) {
        return abi.encodePacked(
            hex"0003",  // OPTIONS_TYPE_3
            uint8(1),   // WORKER_ID (executor)
            uint16(17), // option data length (1 byte option type + 16 bytes gas)
            uint8(1),   // OPTION_TYPE_LZRECEIVE
            gas
        );
    }

    /// @dev The above plus .addExecutorLzComposeOption(0, composeGas, 0), for a remote that composes.
    function encodeLzReceiveAndComposeOptions(uint128 gas, uint128 composeGas) internal pure returns (bytes memory) {
        return abi.encodePacked(
            encodeLzReceiveOptions(gas),
            uint8(1),   // WORKER_ID (executor)
            uint16(19), // option data length (1 byte option type + 2 bytes index + 16 bytes gas)
            uint8(3),   // OPTION_TYPE_LZCOMPOSE
            uint16(0),  // compose index
            composeGas
        );
    }
}
