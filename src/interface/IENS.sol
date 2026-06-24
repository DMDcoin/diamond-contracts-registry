// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @notice Original ENS registry interface.
 * Reference: https://github.com/ensdomains/ens-contracts/blob/staging/contracts/registry/ENS.sol
 */
interface IENS {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    /**
     * @notice Logged when the owner of a node assigns a new owner to a subnode.
     */
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    /**
     * @notice Logged when the owner of a node transfers ownership to a new account.
     */
    event Transfer(bytes32 indexed node, address owner);

    /**
     * @notice Logged when the resolver for a node changes.
     */
    event NewResolver(bytes32 indexed node, address resolver);

    /**
     * @notice Logged when the TTL of a node changes.
     */
    event NewTTL(bytes32 indexed node, uint64 ttl);

    /**
     * @notice Logged when an operator is added or removed.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @notice Sets the owner, resolver and TTL for a node.
     * @param node The node to update
     * @param owner The new owner
     * @param resolver The resolver address
     * @param ttl The TTL in seconds
     */
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;

    /**
     * @notice Sets the owner, resolver and TTL for a subnode.
     * @param node The parent node
     * @param label The label hash of the subnode
     * @param owner The new owner
     * @param resolver The resolver address
     * @param ttl The TTL in seconds
     */
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;

    /**
     * @notice Transfers ownership of a subnode to a new address.
     * @param node The parent node
     * @param label The label hash of the subnode
     * @param owner The new owner
     * @return The namehash of the subnode
     */
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns (bytes32);

    /**
     * @notice Sets the resolver for a node.
     * @param node The node to update
     * @param resolver The resolver address
     */
    function setResolver(bytes32 node, address resolver) external;

    /**
     * @notice Transfers ownership of a node to a new address.
     * @param node The node to transfer
     * @param owner The new owner
     */
    function setOwner(bytes32 node, address owner) external;

    /**
     * @notice Sets the TTL for a node.
     * @param node The node to update
     * @param ttl The TTL in seconds
     */
    function setTTL(bytes32 node, uint64 ttl) external;

    /**
     * @notice Enables or disables an operator to manage all of the caller's nodes.
     * @param operator The operator address
     * @param approved True to approve, false to revoke
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @notice Returns the owner of a node.
     * @param node The node to query
     * @return The owner address
     */
    function owner(bytes32 node) external view returns (address);

    /**
     * @notice Returns the resolver of a node.
     * @param node The node to query
     * @return The resolver address
     */
    function resolver(bytes32 node) external view returns (address);

    /**
     * @notice Returns the TTL of a node.
     * @param node The node to query
     * @return The TTL in seconds
     */
    function ttl(bytes32 node) external view returns (uint64);

    /**
     * @notice Check if ENS record exists for provided `node`.
     * @param node The node to query
     * @return True if the record exists
     */
    function recordExists(bytes32 node) external view returns (bool);

    /**
     * @notice Check operator approvals given by `owner` to `operator`.
     * @param owner The node owner
     * @param operator The operator to check
     * @return True if approved
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
