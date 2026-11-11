// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC165Upgradeable } from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IAddrResolver } from "./interface/IAddrResolver.sol";
import { DNSRecord, DNSRecordKind, IDNSResolver } from "./interface/IDNSResolver.sol";
import { IENS } from "./interface/IENS.sol";
import { IEmailForwardingResolver } from "./interface/IEmailForwardingResolver.sol";
import { IExtendedResolver } from "./interface/IExtendedResolver.sol";
import { INameResolver } from "./interface/INameResolver.sol";
import { IResolver } from "./interface/IResolver.sol";

import { Errors } from "./lib/Errors.sol";

/// @notice ENS-compatible resolver that stores the records of the DMD naming
/// system for forward (node -> address) and reverse (node -> name) resolution,
/// DNS records and email forwarding targets.
contract DMDResolver is Initializable, ERC165Upgradeable, IResolver, IExtendedResolver {
    IENS public registry;

    /// @notice Forward records: node namehash -> resolved address.
    mapping(bytes32 => address) public addresses;

    /// @notice Reverse records: node namehash -> human-readable name.
    mapping(bytes32 => string) public names;

    /// @notice DNS records: node namehash -> DNS record.
    mapping(bytes32 => DNSRecord) public dnsRecords;

    /// @notice Email forwarding records: node namehash -> email address.
    mapping(bytes32 => bytes) public emailForwardingTargets;

    /// @notice Thrown when `resolve` is called with an unsupported selector.
    error UnsupportedResolverFunc(bytes4 selector);

    /// @notice Thrown when the DNS record value does not match the record kind.
    error InvalidDNSRecord(DNSRecordKind kind);

    /// @dev Restricts a write to the owner of `node` or one of its approved operators
    /// @param node The node whose record is being written.
    modifier authorised(bytes32 node) {
        address owner = registry.owner(node);

        if (msg.sender != owner && !registry.isApprovedForAll(owner, msg.sender)) {
            revert Errors.Unauthorised();
        }
        _;
    }

    /// @dev Prevents initialization of the implementation contract.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the resolver contract.
    /// @param _registry The address of the {DMDRegistry}.
    function initialize(address _registry) external initializer {
        if (_registry == address(0)) {
            revert Errors.InvalidRegistry();
        }

        __ERC165_init();

        registry = IENS(_registry);
    }

    /// @notice Sets the forward (address) record for a node.
    /// @param node The node to update
    /// @param a The address the node resolves to
    function setAddr(bytes32 node, address a) external authorised(node) {
        addresses[node] = a;

        emit AddrChanged(node, a);
    }

    /// @notice Sets the reverse (name) record for a node.
    /// @param node The reverse node to update - namehash(`<hexaddr>.addr.reverse`)
    /// @param newName The human-readable name the node resolves to
    function setName(bytes32 node, string calldata newName) external authorised(node) {
        names[node] = newName;

        emit NameChanged(node, newName);
    }

    /// @notice Sets the DNS record for a node.
    /// @param node The node to update
    /// @param kind The kind of the record, `None` clears the record
    /// @param value The record value, must be empty for `None` kind
    function setDNSRecord(bytes32 node, DNSRecordKind kind, bytes calldata value) external authorised(node) {
        if (!_validDNSRecord(kind, value)) {
            revert InvalidDNSRecord(kind);
        }

        dnsRecords[node] = DNSRecord({ kind: kind, value: value });

        emit DNSRecordChanged(node, kind, value);
    }

    /// @notice Sets the email forwarding target for a node.
    /// @param node The node to update
    /// @param target The email address to forward emails to, empty bytes clears the target
    function setEmailForwardingTarget(bytes32 node, bytes calldata target) external authorised(node) {
        emailForwardingTargets[node] = target;

        emit EmailForwardingTargetChanged(node, target);
    }

    /// @notice Returns the address a node resolves to.
    /// @param node The node to query
    /// @return The resolved address, address(0) otherwise
    function addr(bytes32 node) external view override returns (address payable) {
        return payable(addresses[node]);
    }

    /// @notice Returns the name a node resolves to.
    /// @param node The reverse node to query
    /// @return The resolved name, empty string otherwise
    function name(bytes32 node) external view override returns (string memory) {
        return names[node];
    }

    /// @notice Returns the DNS record of a node.
    /// @param node The node to query
    /// @return The DNS record, record of `None` kind otherwise
    function dnsRecord(bytes32 node) external view override returns (DNSRecord memory) {
        return dnsRecords[node];
    }

    /// @notice Returns the email forwarding target of a node.
    /// @param node The node to query
    /// @return The email address, empty bytes otherwise
    function emailForwardingTarget(bytes32 node) external view override returns (bytes memory) {
        return emailForwardingTargets[node];
    }

    /// @notice Resolves an ABI-encoded resolver call for a DNS-encoded name (ENSIP-10).
    /// @param data The ABI-encoded inner resolver call (e.g. `addr(bytes32)`).
    /// @return The ABI-encoded result of the inner call.
    function resolve(bytes calldata, bytes calldata data) external view override returns (bytes memory) {
        bytes4 selector = bytes4(data);
        if (
            selector != IAddrResolver.addr.selector && selector != INameResolver.name.selector
                && selector != IDNSResolver.dnsRecord.selector
                && selector != IEmailForwardingResolver.emailForwardingTarget.selector
        ) {
            revert UnsupportedResolverFunc(selector);
        }

        // 4 bytes selector + 32 bytes hash
        if (data.length != 36) {
            revert UnsupportedResolverFunc(selector);
        }

        (bool success, bytes memory result) = address(this).staticcall(data);

        if (success) {
            return result;
        } else {
            // Revert with the reason provided by the call
            assembly ("memory-safe") {
                revert(add(result, 0x20), mload(result))
            }
        }
    }

    /// @inheritdoc ERC165Upgradeable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165)
        returns (bool)
    {
        return interfaceId == type(IAddrResolver).interfaceId || interfaceId == type(INameResolver).interfaceId
            || interfaceId == type(IDNSResolver).interfaceId
            || interfaceId == type(IEmailForwardingResolver).interfaceId
            || interfaceId == type(IExtendedResolver).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Checks that the record value length matches the record kind.
    /// @param kind The kind of the record
    /// @param value The record value
    /// @return True if the record is valid
    function _validDNSRecord(DNSRecordKind kind, bytes calldata value) private pure returns (bool) {
        if (kind == DNSRecordKind.IPv4) {
            return value.length == 4;
        }

        if (kind == DNSRecordKind.IPv6) {
            return value.length == 16;
        }

        if (kind == DNSRecordKind.Cname) {
            return value.length != 0;
        }

        return value.length == 0;
    }
}
