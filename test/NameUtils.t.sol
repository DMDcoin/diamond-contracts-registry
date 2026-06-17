// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Test } from "forge-std/Test.sol";

import { NameUtils } from "src/lib/NameUtils.sol";

contract NameUtilsTest is Test {
    bytes32 public constant EXPECTED_DMD_NODE = 0x9904bf4b5751e3b6a8b75d14c49424160de1a8fa8a90fd5c9fccdeac0503e612;

    bytes32 public constant ROOT_NODE = bytes32(0);

    function test_DmdNode_MatchesIndependentlyComputedValue() public pure {
        assertEq(NameUtils.DMD_NODE, EXPECTED_DMD_NODE);
    }

    function test_DmdNode_MatchesNamehashDerivation() public pure {
        bytes32 labelHash = keccak256("dmd");
        bytes32 derived = keccak256(abi.encodePacked(ROOT_NODE, labelHash));

        assertEq(NameUtils.DMD_NODE, derived);
    }

    function test_NameHash_String() public pure {
        assertEq(NameUtils.labelHash(string("alice")), keccak256(bytes("alice")));
    }

    function test_NameHash_Bytes() public pure {
        assertEq(NameUtils.labelHash(bytes("alice")), keccak256(bytes("alice")));
    }

    function test_NameHash_EmptyString() public pure {
        assertEq(NameUtils.labelHash(string("")), keccak256(""));
    }

    function test_NameHash_StringAndBytesOverloadsAgree() public pure {
        string memory name = "alice-bob-1337";

        assertEq(NameUtils.labelHash(name), NameUtils.labelHash(bytes(name)));
    }

    function test_NameHash_DifferentNamesProduceDifferentHashes() public pure {
        assertTrue(NameUtils.labelHash(string("alice")) != NameUtils.labelHash(string("Alice")));
        assertTrue(NameUtils.labelHash(string("alice")) != NameUtils.labelHash(string("alicex")));
    }

    function test_Node_String() public pure {
        bytes32 labelHash = keccak256(bytes("alice"));
        bytes32 expected = keccak256(abi.encodePacked(NameUtils.DMD_NODE, labelHash));

        assertEq(NameUtils.nodeHash(string("alice")), expected);
    }

    function test_Node_LabelHash() public pure {
        bytes32 labelHash = keccak256(bytes("alice"));
        bytes32 expected = keccak256(abi.encodePacked(NameUtils.DMD_NODE, labelHash));

        assertEq(NameUtils.nodeHash(labelHash), expected);
    }

    function test_Node_OverloadsAgree() public pure {
        string memory name = "alice";

        assertEq(NameUtils.nodeHash(name), NameUtils.nodeHash(NameUtils.labelHash(name)));
    }

    function test_Node_DiffersFromNameHash() public pure {
        string memory name = "alice";

        assertTrue(NameUtils.nodeHash(name) != NameUtils.labelHash(name));
    }

    function testFuzz_NameHash_MatchesKeccak(string memory name) public pure {
        assertEq(NameUtils.labelHash(name), keccak256(abi.encodePacked(name)));
    }

    function testFuzz_NameHash_OverloadsAgree(bytes memory name) public pure {
        assertEq(NameUtils.labelHash(name), NameUtils.labelHash(string(name)));
    }

    function testFuzz_Node_OverloadsAgree(string memory name) public pure {
        assertEq(NameUtils.nodeHash(name), NameUtils.nodeHash(NameUtils.labelHash(name)));
    }

    function testFuzz_Node_MatchesNamehashDerivation(string memory name) public pure {
        bytes32 expected = keccak256(abi.encodePacked(NameUtils.DMD_NODE, keccak256(bytes(name))));

        assertEq(NameUtils.nodeHash(name), expected);
    }
}
