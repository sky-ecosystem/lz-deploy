// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { LZInit, UlnConfig, ExecutorConfig } from "lz-init-lib/LZInit.sol";

/// @notice Shared mainnet-fork setup for the deployer tests.
/// @dev    The remote-side deployers are exercised on a mainnet fork too: what they configure is
///         endpoint and OApp state, which is chain-agnostic, and their L2-specific inputs (token,
///         relay, DVN set) are parameters. The constants below are the live mainnet deployments.
abstract contract LZDeployTestBase is Test {

    address constant ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address constant SEND_LIB = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1; // SendUln302
    address constant RECV_LIB = 0xc02Ab410f0734EFa3F14628780e6e695156024C2; // ReceiveUln302
    address constant EXECUTOR = 0x173272739Bd7Aa6e4e214714048a9fE699453059;

    // Ethereum DVN addresses (sorted — required by UlnConfig)
    address constant DVN_P2P              = 0x06559EE34D85a88317Bf0bfE307444116c631b67;
    address constant DVN_DEUTSCHE_TELEKOM = 0x373a6E5c0C4E89E24819f00AA37ea370917AAfF4;
    address constant DVN_HORIZEN          = 0x380275805876Ff19055EA900CDb2B46a94ecF20D;
    address constant DVN_LUGANODES        = 0x58249a2Ec05c1978bF21DF1f5eC1847e42455CF4;
    address constant DVN_LZ_LABS          = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b;
    address constant DVN_CANARY           = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd;
    address constant DVN_NETHERMIND       = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5;

    uint32 constant ETH_EID  = 30101;
    uint32 constant DST_EID  = 30184; // Base, standing in for "the other side of the route"

    uint128 constant OFT_OPTIONS_GAS = 130_000;

    /// @dev The suite asserts against live mainnet state, so the block is pinned rather than
    ///      overridable: at another height those references are different values.
    uint256 constant FORK_BLOCK = 24871363;

    address PAUSE_PROXY;
    address GOV_SENDER;
    address L1_GOV_RELAY;
    address USDS;

    ExecutorConfig execCfg;
    UlnConfig      oftSendUlnCfg;
    UlnConfig      oftRecvUlnCfg;
    UlnConfig      govUlnCfg;

    function setUp() public virtual {
        vm.createSelectFork(getChain("mainnet").rpcUrl, FORK_BLOCK);

        PAUSE_PROXY  = LZInit.chainlog.getAddress("MCD_PAUSE_PROXY");
        GOV_SENDER   = LZInit.chainlog.getAddress("LZ_GOV_SENDER");
        L1_GOV_RELAY = LZInit.chainlog.getAddress("LZ_GOV_RELAY");
        USDS         = LZInit.chainlog.getAddress("USDS");

        execCfg = ExecutorConfig({ maxMessageSize: 10_000, executor: EXECUTOR });

        // OFT routes: a small required set, no wings and no threshold — the four the templates wire.
        address[] memory oftRequiredDVNs = new address[](4);
        oftRequiredDVNs[0] = DVN_HORIZEN;
        oftRequiredDVNs[1] = DVN_LZ_LABS;
        oftRequiredDVNs[2] = DVN_CANARY;
        oftRequiredDVNs[3] = DVN_NETHERMIND;

        oftSendUlnCfg = UlnConfig({
            confirmations:        15,
            requiredDVNCount:     4,
            optionalDVNCount:     0,
            optionalDVNThreshold: 0,
            requiredDVNs:         oftRequiredDVNs,
            optionalDVNs:         new address[](0)
        });

        oftRecvUlnCfg = UlnConfig({
            confirmations:        12,
            requiredDVNCount:     4,
            optionalDVNCount:     0,
            optionalDVNThreshold: 0,
            requiredDVNs:         oftRequiredDVNs,
            optionalDVNs:         new address[](0)
        });

        // Governance routes: no required DVNs (255 = NIL), 4 of the 7 LZ-aligned providers.
        address[] memory govDVNs = new address[](7);
        govDVNs[0] = DVN_P2P;
        govDVNs[1] = DVN_DEUTSCHE_TELEKOM;
        govDVNs[2] = DVN_HORIZEN;
        govDVNs[3] = DVN_LUGANODES;
        govDVNs[4] = DVN_LZ_LABS;
        govDVNs[5] = DVN_CANARY;
        govDVNs[6] = DVN_NETHERMIND;

        govUlnCfg = UlnConfig({
            confirmations:        15,
            requiredDVNCount:     255,
            optionalDVNCount:     7,
            optionalDVNThreshold: 4,
            requiredDVNs:         new address[](0),
            optionalDVNs:         govDVNs
        });
    }

    function _assertUlnConfig(bytes memory raw, UlnConfig memory expected) internal pure {
        assertEq(keccak256(raw), keccak256(abi.encode(expected)), "uln config mismatch");
    }
}
