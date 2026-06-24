// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @notice Original ENS address resolver interface
interface IAddrResolver {
    /// @notice Emitted when the address associated with a node changes.
    event AddrChanged(bytes32 indexed node, address a);

    /// @notice Returns the address associated with an ENS node.
    /// @param node The ENS node to query
    /// @return The associated address
    function addr(bytes32 node) external view returns (address payable);
}
