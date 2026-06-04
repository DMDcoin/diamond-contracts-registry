// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { Controllable } from "./lib/Controllable.sol";

contract DiamondNames is OwnableUpgradeable, ERC721Upgradeable, Controllable {
    string public baseURI;

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialOwner, string calldata _baseUri) external initializer {
        __Ownable_init(_initialOwner);
        __Controllable_init();
        __ERC721_init("DMD Name Service", "DNS");

        baseURI = _baseUri;
    }

    function mint(address to, uint256 id) external onlyController {
        _mint(to, id);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
