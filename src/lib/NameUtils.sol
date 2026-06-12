// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

library NameUtils {
    // keccak256(abi.encodePacked(bytes32(0), keccak256("dmd")))
    bytes32 public constant DMD_NODE = 0x9904bf4b5751e3b6a8b75d14c49424160de1a8fa8a90fd5c9fccdeac0503e612;

    function nameHash(string memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function nameHash(bytes memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function node(string memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(DMD_NODE, nameHash(_name)));
    }

    function node(bytes32 _namehash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(DMD_NODE, _namehash));
    }
}
