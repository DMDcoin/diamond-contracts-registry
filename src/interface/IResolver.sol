// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IAddrResolver } from "./IAddrResolver.sol";
import { INameResolver } from "./INameResolver.sol";

/// @title IResolver
/// @notice Aggregate resolver interface. Includes ENS getters and
/// DMD naming system record setters.
interface IResolver is IERC165, IAddrResolver, INameResolver {
    /// @notice Sets the forward (address) record for a node.
    /// @param node The node to update
    /// @param addr The address the node resolves to
    function setAddr(bytes32 node, address addr) external;

    /// @notice Sets the reverse (name) record for a node.
    /// @param node The reverse node to update
    /// @param newName The name the node resolves to
    function setName(bytes32 node, string calldata newName) external;
}
