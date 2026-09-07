// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

interface BroadcasterLike {
    function getReplicas() external view returns (address[] memory);
}

/// @notice Builds a governance-grade optional DVN set: the LZ-aligned DVNs plus the replicas of the
///         CCIP and multisig `DVNBroadcaster`s, read on-chain instead of copied by hand.
/// @dev    Both broadcasters must already be deployed on the chain this runs against, and the
///         `DVNReplica`s are their constructor output, so `getReplicas()` is the authority on the
///         addresses a ULN config must name.
library GovDvnSet {

    function read(address ccipBroadcaster, address msigBroadcaster, address[] memory lzDvns)
        internal view returns (address[] memory dvns)
    {
        address[] memory ccip = BroadcasterLike(ccipBroadcaster).getReplicas();
        address[] memory msig = BroadcasterLike(msigBroadcaster).getReplicas();

        dvns = new address[](lzDvns.length + ccip.length + msig.length);
        uint256 n;
        for (uint256 i; i < lzDvns.length; ++i) dvns[n++] = lzDvns[i];
        for (uint256 i; i < ccip.length;   ++i) dvns[n++] = ccip[i];
        for (uint256 i; i < msig.length;   ++i) dvns[n++] = msig[i];

        // Ascending order is LZ-enforced. Insertion sort: the set is 15 addresses at most.
        for (uint256 i = 1; i < dvns.length; ++i) {
            address v = dvns[i];
            uint256 j = i;
            while (j > 0 && dvns[j - 1] > v) { dvns[j] = dvns[j - 1]; --j; }
            dvns[j] = v;
        }
    }

    /// @notice Splices one address into an already-sorted set, returning its index.
    /// @dev    The index is what a spell dereferences to find the CCIP DVN adapter, so it has to come
    ///         from the same operation that places it.
    function insertSorted(address[] memory dvns, address extra)
        internal pure returns (address[] memory out, uint256 index)
    {
        out = new address[](dvns.length + 1);
        while (index < dvns.length && dvns[index] < extra) { out[index] = dvns[index]; ++index; }
        out[index] = extra;
        for (uint256 i = index; i < dvns.length; ++i) out[i + 1] = dvns[i];
    }
}
