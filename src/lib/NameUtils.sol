// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/**
 * @notice Helpers for ENS-style name hashing within the `.dmd` namespace.
 * Implements label hashing and the recursive namehash algorithm.
 */
library NameUtils {
    /**
     * @notice Namehash of the `dmd` TLD: `nameHash(bytes32(0), keccak256("dmd"))`.
     */
    bytes32 public constant DMD_NODE = 0x9904bf4b5751e3b6a8b75d14c49424160de1a8fa8a90fd5c9fccdeac0503e612;

    /**
     * @notice Computes the label hash of a name string.
     *
     * @param _name The label (without the `.dmd` suffix)
     *
     * @return The keccak256 label hash
     */
    function labelHash(string memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    /**
     * @notice Computes the label hash of a name given as bytes.
     *
     * @param _name The label bytes (without the `.dmd` suffix)
     *
     * @return The keccak256 label hash
     */
    function labelHash(bytes memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    /**
     * @notice Computes the full `.dmd` node hash for a label string.
     *
     * @param _name The label (without the `.dmd` suffix)
     *
     * @return The namehash of `<label>.dmd`
     */
    function nodeHash(string memory _name) internal pure returns (bytes32) {
        return nameHash(DMD_NODE, labelHash(_name));
    }

    /**
     * @notice Computes the full `.dmd` node hash for a label hash.
     *
     * @param _namehash The label hash of the name
     *
     * @return The namehash of `<label>.dmd`
     */
    function nodeHash(bytes32 _namehash) internal pure returns (bytes32) {
        return nameHash(DMD_NODE, _namehash);
    }

    /**
     * @dev Compute a child namehash from a parent namehash and child labelhash.
     *
     * @param _parentNode The namehash of the parent
     * @param _labelHash The labelhash of the child
     *
     * @return _node The namehash of the child
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
