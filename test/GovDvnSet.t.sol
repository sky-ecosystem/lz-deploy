// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";

import { GovDvnSet } from "script/test/GovDvnSet.sol";

contract BroadcasterStub {
    address[] internal replicas;
    constructor(address[] memory replicas_) { replicas = replicas_; }
    function getReplicas() external view returns (address[] memory) { return replicas; }
}

/// @dev No fork: the library only reads `getReplicas()` off two addresses, so stubs are enough.
contract GovDvnSetTest is Test {

    function _sorted() internal pure returns (address[] memory dvns) {
        dvns = new address[](3);
        dvns[0] = address(0x10);
        dvns[1] = address(0x20);
        dvns[2] = address(0x30);
    }

    function _assertAscending(address[] memory dvns) internal pure {
        for (uint256 i = 1; i < dvns.length; ++i) assertLt(uint160(dvns[i - 1]), uint160(dvns[i]));
    }

    function test_readMergesBothBroadcastersAndSorts() public {
        address[] memory ccip = new address[](2);
        (ccip[0], ccip[1]) = (address(0x40), address(0x05));  // deliberately unsorted
        address[] memory msig = new address[](1);
        msig[0] = address(0x25);

        address[] memory dvns = GovDvnSet.read(
            address(new BroadcasterStub(ccip)),
            address(new BroadcasterStub(msig)),
            _sorted()
        );

        assertEq(dvns.length, 6);
        _assertAscending(dvns);
        assertEq(dvns[0], address(0x05));
        assertEq(dvns[5], address(0x40));
    }

    function test_readWithNoLzDVNs() public {
        address[] memory one = new address[](1);
        one[0] = address(0x99);

        address[] memory dvns = GovDvnSet.read(
            address(new BroadcasterStub(one)),
            address(new BroadcasterStub(new address[](0))),
            new address[](0)
        );

        assertEq(dvns.length, 1);
        assertEq(dvns[0], address(0x99));
    }

    function test_insertSortedReportsTheIndexItPlacedAt() public pure {
        (address[] memory out, uint256 index) = GovDvnSet.insertSorted(_sorted(), address(0x25));
        assertEq(index, 2);
        assertEq(out[2], address(0x25));
        _assertAscending(out);

        (out, index) = GovDvnSet.insertSorted(_sorted(), address(0x05));
        assertEq(index, 0);
        _assertAscending(out);

        (out, index) = GovDvnSet.insertSorted(_sorted(), address(0x40));
        assertEq(index, 3);
        _assertAscending(out);
    }
}
