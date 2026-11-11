// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IDNSController {
    /// @notice Sets the IPv4 address (A record) of the caller's active name.
    /// @param label The active name (without the `.dmd` suffix)
    /// @param ipv4 The IPv4 address
    function setARecord(string calldata label, bytes4 ipv4) external;

    /// @notice Sets the IPv6 address (AAAA record) of the caller's active name.
    /// @param label The active name (without the `.dmd` suffix)
    /// @param ipv6 The IPv6 address
    function setAAAARecord(string calldata label, bytes16 ipv6) external;

    /// @notice Sets the canonical hostname (CNAME record) of the caller's active name.
    /// @param label The active name (without the `.dmd` suffix)
    /// @param cname The hostname (without trailing dot)
    function setCnameRecord(string calldata label, bytes calldata cname) external;

    /// @notice Clears the DNS record of the caller's active name.
    /// @param label The active name (without the `.dmd` suffix)
    function clearDNSRecord(string calldata label) external;
}
