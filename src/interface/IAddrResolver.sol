// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IAddrResolver {
    event AddrChanged(bytes32 indexed node, address a);

    function setAddr(bytes32 node, address addr) external;

    /**
     * Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address payable);
}
