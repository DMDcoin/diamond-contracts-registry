// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IEmailForwardingResolver {
    /// @notice Emitted when the email forwarding target associated with a node changes.
    event EmailForwardingTargetChanged(bytes32 indexed node, bytes target);

    /// @notice Returns the email forwarding target associated with a node.
    /// @param node The node to query
    /// @return The associated email address
    function emailForwardingTarget(bytes32 node) external view returns (bytes memory);
}
