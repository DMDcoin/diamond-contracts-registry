// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IAddrResolver } from "./IAddrResolver.sol";
import { INameResolver } from "./INameResolver.sol";

interface IResolver is IERC165, IAddrResolver, INameResolver {
    function setAddr(bytes32 node, address addr) external;

    function setName(bytes32 node, string calldata newName) external;
}
