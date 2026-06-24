// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/**
 * @notice Origianl ENS name resolver interface
 */
interface INameResolver {
    /**
     * @notice Emitted when the reverse name associated with a node changes.
     */
    event NameChanged(bytes32 indexed node, string name);

    /**
     * @notice Returns the name associated with an ENS node, for reverse records.
     * @param node The ENS node to query
     * @return The associated name
     */
    function name(bytes32 node) external view returns (string memory);
}
