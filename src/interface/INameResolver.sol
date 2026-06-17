// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface INameResolver {
    event NameChanged(bytes32 indexed node, string name);

    function setName(bytes32 node, string calldata newName) external;

    /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory);
}
