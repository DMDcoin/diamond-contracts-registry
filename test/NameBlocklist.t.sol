// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Test } from "forge-std/Test.sol";

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { NameBlocklist } from "src/lib/NameBlocklist.sol";
import { NameUtils } from "src/lib/NameUtils.sol";
import { MockNameBlocklist } from "src/mocks/MockNameBlocklist.sol";

contract NameBlocklistTest is Test {
    MockNameBlocklist public blocklist;

    address public owner;
    address public unauthorised;

    function setUp() public {
        owner = makeAddr("owner");
        unauthorised = makeAddr("unauthorised");

        blocklist = new MockNameBlocklist();
        blocklist.initialize(owner);
    }

    function _names() internal pure returns (string[] memory names) {
        names = new string[](3);
        names[0] = "alice";
        names[1] = "bob";
        names[2] = "charlie";
    }

    function test_IsNameBlocked_DefaultsToFalse() public view {
        assertFalse(blocklist.isNameBlocked("alice"));
        assertFalse(blocklist.isNameBlocked(""));
    }

    function test_SetNameBlocked_BlocksName() public {
        vm.prank(owner);
        blocklist.setNameBlocked("alice", true);

        assertTrue(blocklist.isNameBlocked("alice"));
    }

    function test_SetNameBlocked_UnblocksName() public {
        vm.prank(owner);
        blocklist.setNameBlocked("alice", true);
        assertTrue(blocklist.isNameBlocked("alice"));

        vm.prank(owner);
        blocklist.setNameBlocked("alice", false);
        assertFalse(blocklist.isNameBlocked("alice"));
    }

    function test_SetNameBlocked_EmitsEvent() public {
        string memory name = "alice";
        bytes32 labelHash = keccak256(bytes(name));

        vm.expectEmit(true, false, false, true, address(blocklist));
        emit NameBlocklist.NameBlockedSet(labelHash, name, true);

        vm.prank(owner);
        blocklist.setNameBlocked(name, true);
    }

    function test_SetNameBlocked_UnblockEmitsEvent() public {
        string memory name = "alice";
        bytes32 labelHash = keccak256(bytes(name));

        vm.prank(owner);
        blocklist.setNameBlocked(name, true);

        vm.expectEmit(true, false, false, true, address(blocklist));
        emit NameBlocklist.NameBlockedSet(labelHash, name, false);

        vm.prank(owner);
        blocklist.setNameBlocked(name, false);
    }

    function test_SetNameBlocked_UnauthorizedCaller_Reverts() public {
        vm.prank(unauthorised);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, unauthorised));
        blocklist.setNameBlocked("alice", true);
    }

    function test_SetNamesBlocked_BlocksAllNames() public {
        string[] memory names = _names();

        vm.prank(owner);
        blocklist.setNamesBlocked(names, true);

        for (uint256 i = 0; i < names.length; ++i) {
            assertTrue(blocklist.isNameBlocked(names[i]));
        }
    }

    function test_SetNamesBlocked_UnblocksAllNames() public {
        string[] memory names = _names();

        vm.prank(owner);
        blocklist.setNamesBlocked(names, true);

        vm.prank(owner);
        blocklist.setNamesBlocked(names, false);

        for (uint256 i = 0; i < names.length; ++i) {
            assertFalse(blocklist.isNameBlocked(names[i]));
        }
    }

    function test_SetNamesBlocked_EmitsEventPerName() public {
        string[] memory names = _names();

        for (uint256 i = 0; i < names.length; ++i) {
            vm.expectEmit(true, false, false, true, address(blocklist));
            emit NameBlocklist.NameBlockedSet(keccak256(bytes(names[i])), names[i], true);
        }

        vm.prank(owner);
        blocklist.setNamesBlocked(names, true);
    }

    function test_SetNamesBlocked_EmptyArray_Noop() public {
        string[] memory names = new string[](0);

        vm.prank(owner);
        blocklist.setNamesBlocked(names, true);
    }

    function test_SetNamesBlocked_UnauthorizedCaller_Reverts() public {
        vm.prank(unauthorised);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, unauthorised));
        blocklist.setNamesBlocked(_names(), true);
    }

    function test_IsNameBlocked_ExactMatchOnly() public {
        vm.prank(owner);
        blocklist.setNameBlocked("alice", true);

        assertFalse(blocklist.isNameBlocked("Alice"));
        assertFalse(blocklist.isNameBlocked("alicex"));
        assertFalse(blocklist.isNameBlocked("alic"));
        assertFalse(blocklist.isNameBlocked(" alice"));
    }
}
