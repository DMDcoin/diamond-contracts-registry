// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC165Upgradeable } from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IAddrResolver } from "./interface/IAddrResolver.sol";
import { IENS } from "./interface/IENS.sol";
import { INameResolver } from "./interface/INameResolver.sol";
import { IResolver } from "./interface/IResolver.sol";

import { Errors } from "./lib/Errors.sol";

contract DMDResolver is Initializable, ERC165Upgradeable, IResolver {
    IENS public registry;

    mapping(bytes32 => address) public addresses;

    mapping(bytes32 => string) public names;

    modifier authorised(bytes32 node) {
        address owner = registry.owner(node);

        if (msg.sender != owner && !registry.isApprovedForAll(owner, msg.sender)) {
            revert Errors.Unauthorised();
        }
        _;
    }

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    function initialize(address _registry) external initializer {
        if (_registry == address(0)) {
            revert Errors.InvalidRegistry();
        }

        __ERC165_init();

        registry = IENS(_registry);
    }

    function setAddr(bytes32 node, address a) external authorised(node) {
        addresses[node] = a;

        emit AddrChanged(node, a);
    }

    function setName(bytes32 node, string calldata newName) external authorised(node) {
        names[node] = newName;

        emit NameChanged(node, newName);
    }

    function addr(bytes32 node) external view override returns (address payable) {
        return payable(addresses[node]);
    }

    function name(bytes32 node) external view override returns (string memory) {
        return names[node];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165)
        returns (bool)
    {
        return interfaceId == type(IAddrResolver).interfaceId || interfaceId == type(INameResolver).interfaceId
            || super.supportsInterface(interfaceId);
    }
}
