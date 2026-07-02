// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @notice Shared custom errors used across contracts.
library Errors {
    /// @notice Thrown when the caller is not authorised for the operation.
    error Unauthorised();

    /// @notice Thrown when a zero address is supplied for the reinsert pot.
    error InvalidReinsertPot();

    /// @notice Thrown when a zero address is supplied for the registry.
    error InvalidRegistry();

    /// @notice Thrown when a zero address is supplied for the resolver.
    error InvalidResolver();

    /// @notice Thrown when a zero address is supplied for the names contract.
    error InvalidNamesContract();
}
