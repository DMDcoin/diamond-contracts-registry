// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import { IDMDRegistrarController } from "./interface/IDMDRegistrarController.sol";
import { ERC721Base } from "./lib/ERC721Base.sol";
import { Errors } from "./lib/Errors.sol";
import { TransferUtils } from "./lib/TransferUtils.sol";

contract DMDNames is Initializable, OwnableUpgradeable, ERC721Base {
    address public reinsertPot;

    string public baseURI;

    uint256 public transferFee;

    IDMDRegistrarController public registrar;

    mapping(uint256 => uint256) private _expires;

    error Expired(uint256 id);
    error InvalidTransferFee(uint256 expected, uint256 provided);

    event SetTransferFee(uint256 indexed fee);

    event SetRegistrar(address indexed registrar);

    event Renew(uint256 indexed id, uint256 indexed expiration);

    modifier onlyRegistrar() {
        _checkRegistrar();
        _;
    }

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        address _reinsertPot,
        uint256 _transferFee,
        string calldata _baseUri
    ) external initializer {
        if (_reinsertPot == address(0)) {
            revert Errors.InvalidReinsertPot();
        }

        __Ownable_init(_initialOwner);
        __ERC721_init("DMD Name Service", "DNS");

        reinsertPot = _reinsertPot;
        baseURI = _baseUri;
        transferFee = _transferFee;
    }

    function setTransferFee(uint256 _transferFee) external onlyRegistrar {
        transferFee = _transferFee;

        emit SetTransferFee(_transferFee);
    }

    function setRegistrar(address _registrar) external onlyOwner {
        registrar = IDMDRegistrarController(_registrar);

        emit SetRegistrar(_registrar);
    }

    function register(uint256 id, address owner, uint256 expiration) external onlyRegistrar {
        _expires[id] = expiration;

        _mint(owner, id);
    }

    function renew(uint256 id, uint256 expiration) external onlyRegistrar {
        _requireOwned(id);

        if (_expires[id] < block.timestamp) {
            revert Expired(id);
        }

        _expires[id] = expiration;

        emit Renew(id, expiration);
    }

    function burn(uint256 id) external onlyRegistrar {
        delete _expires[id];

        _burn(id);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override {
        if (msg.sender != address(registrar) && msg.value != transferFee) {
            revert InvalidTransferFee(transferFee, msg.value);
        }

        super.transferFrom(from, to, tokenId);

        // Reset any live ENS/resolver records so the new owner must re-activate.
        if (address(registrar) != address(0)) {
            registrar.resetRecordsOnTransfer(from, tokenId);
        }

        if (msg.value != 0) {
            TransferUtils.transferNative(reinsertPot, msg.value);
        }
    }

    function available(uint256 id) public view returns (bool) {
        return !exists(id) || expired(id);
    }

    function expired(uint256 id) public view returns (bool) {
        return _expires[id] < block.timestamp;
    }

    function exists(uint256 id) public view returns (bool) {
        return _ownerOf(id) != address(0);
    }

    function nameExpires(uint256 id) public view returns (uint256) {
        return _expires[id];
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _checkRegistrar() private view {
        if (msg.sender != address(registrar)) {
            revert Errors.Unauthorised();
        }
    }
}
