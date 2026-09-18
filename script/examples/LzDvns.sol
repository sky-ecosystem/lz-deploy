// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

/// @notice The mainnet DVN sets these deployments use, sorted ascending as a `UlnConfig` requires.
///         A remote chain's sets stay in the script that targets it, being part of what a retarget
///         replaces.
library LzDvns {

    /// @notice The LZ-aligned wing of a governance set; the CCIP DVN adapter is spliced in by the
    ///         caller.
    function ethGovDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](7);
        dvns[0] = 0x06559EE34D85a88317Bf0bfE307444116c631b67; // P2P
        dvns[1] = 0x373a6E5c0C4E89E24819f00AA37ea370917AAfF4; // Deutsche Telekom
        dvns[2] = 0x380275805876Ff19055EA900CDb2B46a94ecF20D; // Horizen
        dvns[3] = 0x58249a2Ec05c1978bF21DF1f5eC1847e42455CF4; // Luganodes
        dvns[4] = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b; // LayerZero Labs
        dvns[5] = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd; // Canary
        dvns[6] = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5; // Nethermind
    }

    /// @notice The token routes' required set.
    function ethOftDVNs() internal pure returns (address[] memory dvns) {
        dvns = new address[](4);
        dvns[0] = 0x380275805876Ff19055EA900CDb2B46a94ecF20D; // Horizen
        dvns[1] = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b; // LayerZero Labs
        dvns[2] = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd; // Canary
        dvns[3] = 0xa59BA433ac34D2927232918Ef5B2eaAfcF130BA5; // Nethermind
    }
}
