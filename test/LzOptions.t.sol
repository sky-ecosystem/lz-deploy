// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { OptionsBuilder }  from "layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { ExecutorOptions } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/libs/ExecutorOptions.sol";

import { LzOptions } from "src/LzOptions.sol";

/// @notice Pins the enforced-options encoding this repo writes on-chain.
/// @dev    A spell asserts `keccak256(enforcedOptions(...))` against the same encoding produced
///         inside lz-init-lib. Nothing links the two implementations at compile time, so this test
///         is the link: it checks ours against LayerZero's own builder, which is what lz-init-lib's
///         encoder documents itself as equivalent to.
contract LzOptionsTest is Test {

    using OptionsBuilder for bytes;

    function test_matchesOptionsBuilder() public pure {
        uint128[5] memory gases = [uint128(0), 1, 100_000, 130_000, type(uint128).max];

        for (uint256 i; i < gases.length; ++i) {
            assertEq(
                LzOptions.encodeLzReceiveOptions(gases[i]),
                OptionsBuilder.newOptions().addExecutorLzReceiveOption(gases[i], 0),
                "options encoding drifted from OptionsBuilder"
            );
        }
    }

    function testFuzz_matchesOptionsBuilder(uint128 gas) public pure {
        assertEq(
            LzOptions.encodeLzReceiveOptions(gas),
            OptionsBuilder.newOptions().addExecutorLzReceiveOption(gas, 0)
        );
    }

    function test_forwarderOptionsMatchOptionsBuilder() public pure {
        assertEq(
            LzOptions.encodeLzReceiveAndComposeOptions(100_000, 200_000),
            OptionsBuilder.newOptions()
                .addExecutorLzReceiveOption(100_000, 0)
                .addExecutorLzComposeOption(0, 200_000, 0),
            "compose options encoding drifted from OptionsBuilder"
        );
    }

    function testFuzz_forwarderOptionsMatchOptionsBuilder(uint128 gas, uint128 composeGas) public pure {
        assertEq(
            LzOptions.encodeLzReceiveAndComposeOptions(gas, composeGas),
            OptionsBuilder.newOptions()
                .addExecutorLzReceiveOption(gas, 0)
                .addExecutorLzComposeOption(0, composeGas, 0)
        );
    }

    struct Decoded {
        uint8   recvType;
        uint128 recvGas;
        uint128 recvValue;
        uint8   composeType;
        uint16  composeIndex;
        uint128 composeGas;
        uint128 composeValue;
        uint256 end;
    }

    /// @dev Round-trip through LayerZero's own decoder, which enforces exact option lengths (16/32 for
    ///      lzReceive, 18/34 for lzCompose): any wrong integer width misframes the TLV and reverts here.
    function testFuzz_decodesThroughExecutorOptions(uint128 gas, uint128 composeGas) public view {
        bytes memory opts = LzOptions.encodeLzReceiveAndComposeOptions(gas, composeGas);
        Decoded memory d  = this.decodeForwarderOptions(opts);

        assertEq(d.recvType,     ExecutorOptions.OPTION_TYPE_LZRECEIVE);
        assertEq(d.recvGas,      gas);
        assertEq(d.recvValue,    0);
        assertEq(d.composeType,  ExecutorOptions.OPTION_TYPE_LZCOMPOSE);
        assertEq(d.composeIndex, 0);
        assertEq(d.composeGas,   composeGas);
        assertEq(d.composeValue, 0);
        assertEq(d.end,          opts.length, "cursor must land at the end, no trailing bytes");
    }

    /// @dev External so the options arrive as calldata, which `nextExecutorOption` requires.
    function decodeForwarderOptions(bytes calldata opts) external pure returns (Decoded memory d) {
        bytes calldata opt;
        uint256 cursor;

        (d.recvType, opt, cursor) = ExecutorOptions.nextExecutorOption(opts, 2);  // skip the type-3 header
        (d.recvGas, d.recvValue)  = ExecutorOptions.decodeLzReceiveOption(opt);

        (d.composeType, opt, d.end) = ExecutorOptions.nextExecutorOption(opts, cursor);
        (d.composeIndex, d.composeGas, d.composeValue) = ExecutorOptions.decodeLzComposeOption(opt);
    }

    /// @dev The shape spells depend on: type-3 options, executor worker, one lzReceive option.
    function test_encodingShape() public pure {
        bytes memory opts = LzOptions.encodeLzReceiveOptions(130_000);

        assertEq(opts.length, 22);          // 2 (type) + 1 (worker) + 2 (len) + 17 (option)
        assertEq(uint8(opts[0]), 0x00);
        assertEq(uint8(opts[1]), 0x03);     // OPTIONS_TYPE_3
        assertEq(uint8(opts[2]), 1);        // executor worker id
        assertEq(uint8(opts[5]), 1);        // OPTION_TYPE_LZRECEIVE
    }
}
