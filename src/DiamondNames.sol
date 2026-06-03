// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract DiamondNames is OwnableUpgradeable, ERC721Upgradeable {
    address public registrar;
    string public baseURI;

    error Unauthorized();

    modifier onlyRegistrar() {
        if (msg.sender != registrar) {
            revert Unauthorized();
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        address _registrar,
        string calldata _baseUri
    ) external initializer {
        __Ownable_init(_initialOwner);

        registrar = _registrar;
        baseURI = _baseUri;
    }

    function mint(address to, uint256 id) external onlyRegistrar {
        _mint(to, id);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
