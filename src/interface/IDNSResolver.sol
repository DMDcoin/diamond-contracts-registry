// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @notice Kind of the DNS record stored for a node.
enum DNSRecordKind {
    None,
    IPv4,
    IPv6,
    Cname
}

/// @notice DNS record of a node.
/// @dev Record value is 4 bytes IPv4 address, 16 bytes IPv6 address or ASCII hostname for `Cname` kind.
struct DNSRecord {
    DNSRecordKind kind;
    bytes value;
}

interface IDNSResolver {
    /// @notice Emitted when the DNS record associated with a node changes.
    event DNSRecordChanged(bytes32 indexed node, DNSRecordKind indexed kind, bytes value);

    /// @notice Returns the DNS record associated with a node.
    /// @param node The node to query
    /// @return The associated DNS record
    function dnsRecord(bytes32 node) external view returns (DNSRecord memory);
}
