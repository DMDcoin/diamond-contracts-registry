// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

library NameUtils {
    // nameHash(bytes32(0), keccak256("dmd"))
    bytes32 public constant DMD_NODE = 0x9904bf4b5751e3b6a8b75d14c49424160de1a8fa8a90fd5c9fccdeac0503e612;

    function labelHash(string memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function labelHash(bytes memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function nodeHash(string memory _name) internal pure returns (bytes32) {
        return nameHash(DMD_NODE, labelHash(_name));
    }

    function nodeHash(bytes32 _namehash) internal pure returns (bytes32) {
        return nameHash(DMD_NODE, _namehash);
    }

    /**
     * @dev Compute a child namehash from a parent namehash and child labelhash.
     *
     * @param _parentNode The namehash of the parent.
     * @param _labelHash The labelhash of the child.
     *
     * @return _node The namehash of the child.
     */
    function nameHash(bytes32 _parentNode, bytes32 _labelHash) internal pure returns (bytes32 _node) {
        // ~100 gas less than: keccak256(abi.encode(parentNode, labelHash))
        assembly ("memory-safe") {
            mstore(0, _parentNode)
            mstore(32, _labelHash)
            _node := keccak256(0, 64)
        }
    }
}
