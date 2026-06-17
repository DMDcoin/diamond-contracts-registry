// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { Controllable } from "./lib/Controllable.sol";

contract DMDNames is OwnableUpgradeable, ERC721Upgradeable, Controllable {
    string public baseURI;

    uint256 public transferFee;

    mapping(uint256 => uint256) private _expires;

    error NotAvailable(uint256 id);
    error Expired(uint256 id);

    event SetTransferFee(uint256 indexed fee);

    event Renew(uint256 indexed id, uint256 indexed expiration);

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialOwner, uint256 _transferFee, string calldata _baseUri) external initializer {
        __Ownable_init(_initialOwner);
        __Controllable_init();
        __ERC721_init("DMD Name Service", "DNS");

        baseURI = _baseUri;
        transferFee = _transferFee;
    }

    function setTransferFee(uint256 _transferFee) external onlyController {
        transferFee = _transferFee;

        emit SetTransferFee(_transferFee);
    }

    function register(uint256 id, address owner, uint256 expiration) external onlyController {
        _expires[id] = expiration;

        _mint(owner, id);
    }

    function renew(uint256 id, uint256 expiration) external onlyController {
        _requireOwned(id);

        if (_expires[id] < block.timestamp) {
            revert Expired(id);
        }

        _expires[id] = expiration;
    }

    function burn(uint256 id) external onlyController {
        _burn(id);
    }

    function available(uint256 id) public view returns (bool) {
        return _expires[id] < block.timestamp;
    }

    function nameExpires(uint256 id) public view returns (uint256) {
        return _expires[id];
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
