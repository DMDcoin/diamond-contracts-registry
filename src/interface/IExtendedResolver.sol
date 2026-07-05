// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IExtendedResolver {
    /// @notice Resolves an ABI-encoded resolver call for a DNS-encoded name.
    /// @param name The DNS-encoded name being resolved.
    /// @param data The ABI-encoded inner resolver call (e.g. `addr(bytes32)`).
    /// @return The ABI-encoded result of the inner call.
    function resolve(bytes memory name, bytes memory data) external view returns (bytes memory);
}
