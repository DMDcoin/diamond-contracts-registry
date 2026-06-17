// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import { DateTimeLib } from "solady/utils/DateTimeLib.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { ValueGuards } from "diamond-contracts-core/lib/ValueGuards.sol";

import { IDMDNames } from "./interface/IDMDNames.sol";
import { IENS } from "./interface/IENS.sol";
import { IResolver } from "./interface/IResolver.sol";
import { AddressUtils } from "./lib/AddressUtils.sol";
import { ByteUtils } from "./lib/ByteUtils.sol";
import { Errors } from "./lib/Errors.sol";
import { NameBlocklist } from "./lib/NameBlocklist.sol";
import { NameUtils } from "./lib/NameUtils.sol";
import { TransferUtils } from "./lib/TransferUtils.sol";

contract DMDRegistrarController is Initializable, OwnableUpgradeable, NameBlocklist, ValueGuards {
    using ByteUtils for bytes1;

    uint256 public constant MIN_NAME_LENGTH = 2;
    uint256 public constant MAX_NAME_LENGHT = 63;

    uint256 public constant DEFAULT_MINTING_FEE = 5 ether;
    uint256 public constant BASE_MINTING_FEE = 78_125_000 gwei; // 0.078125 DMD

    uint256 public constant EXPIRATION_TIME_YEARS = 10;

    uint256 public constant MAX_ACTIVATION_FEE_NOMINATOR = 3;
    uint256 public constant ACTIVATION_FEE_DENOMINATOR = 10;

    uint256 public constant TRANSFER_FEE_NOMINATOR = 10; // 10%
    uint256 public constant TRANSFER_FEE_DENOMINATOR = 100;

    mapping(address => bytes) public names;

    mapping(address => uint256) public activations;

    IDMDNames public diamondNames;

    IENS public registry;

    IResolver public resolver;

    /**
     * Minting/activation fees are sent to the reinsert pot.
     */
    address public reinsertPotAddress;

    /**
     * current cost for setting the name.
     */
    uint256 public mintingFee;

    error InvalidMintingFee(uint256 want, uint256 sent);
    error InvalidName();
    error NotAvailable();
    error RegistrarInactive();
    error NameOwnerMismatch(address expected, address actual);
    error NotNameOwner();
    error InvalidActivationFee(uint256 want, uint256 sent);
    error AlreadyActive();

    event NameRegistered(address indexed node, bytes32 indexed labelHash, uint256 indexed expiration, string name);

    event NameActivated(address indexed owner, bytes32 indexed labelHash, string name);

    event NameDeactivated(address indexed owner, bytes32 indexed labelHash, string name);

    event NameRenewed(address indexed owner, bytes32 indexed labelHash, uint256 indexed expiration, string name);

    event SetMintingFee(uint256 indexed value);

    modifier activeRegistrar() {
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
        address _reinsertPotAddress,
        address _diamondNames,
        address _registry,
        address _resolver
    ) external initializer {
        if (_reinsertPotAddress == address(0)) {
            revert Errors.InvalidReinsertPotAddress();
        }

        if (_diamondNames == address(0)) {
            revert Errors.InvalidNamesContract();
        }

        if (_registry == address(0)) {
            revert Errors.InvalidRegistry();
        }

        if (_resolver == address(0)) {
            revert Errors.InvalidResolver();
        }

        __Ownable_init(_initialOwner);
        __NameBlocklist_init();

        diamondNames = IDMDNames(_diamondNames);
        registry = IENS(_registry);
        resolver = IResolver(_resolver);
        reinsertPotAddress = _reinsertPotAddress;

        mintingFee = DEFAULT_MINTING_FEE;

        __initAllowedChangeableParameter(
            this.setMintingFee.selector, this.mintingFee.selector, _mintingFeeAllowedValues()
        );
    }

    function setMintingFee(uint256 _value) public onlyOwner withinAllowedRange(_value) {
        uint256 transferFee = _value * TRANSFER_FEE_NOMINATOR / TRANSFER_FEE_DENOMINATOR;

        mintingFee = _value;

        emit SetMintingFee(_value);

        diamondNames.setTransferFee(transferFee);
    }

    function blockName(string calldata _name, address _owner) external activeRegistrar onlyOwner {
        bytes32 node = NameUtils.nodeHash(_name);

        address nodeOwner = registry.owner(node);
        address registrant = nodeOwner == address(this) ? address(0) : nodeOwner;

        if (registrant != _owner) {
            revert NameOwnerMismatch(registrant, _owner);
        }

        if (registrant != address(0)) {
            _deactivateName(registrant, bytes(_name));
        }

        _setNameBlocked(_name, true);
    }

    function register(string calldata _name) external payable activeRegistrar {
        if (msg.value != mintingFee) {
            revert InvalidMintingFee(mintingFee, msg.value);
        }

        if (!valid(_name)) {
            revert InvalidName();
        }

        if (!available(_name)) {
            revert NotAvailable();
        }

        if (isNameBlocked(_name)) {
            revert NameBlocked(_name);
        }

        bytes32 labelHash = NameUtils.labelHash(_name);
        uint256 tokenId = uint256(labelHash);

        uint256 expirationTimestamp = DateTimeLib.addYears(block.timestamp, EXPIRATION_TIME_YEARS);

        diamondNames.register(tokenId, msg.sender, expirationTimestamp);

        if (names[msg.sender].length == 0) {
            _activate(msg.sender, bytes(_name));
        }

        TransferUtils.transferNative(reinsertPotAddress, msg.value);

        emit NameRegistered(msg.sender, labelHash, expirationTimestamp, _name);
    }

    function activate(string calldata _name) external payable activeRegistrar {
        bytes32 labelHash = NameUtils.labelHash(_name);
        uint256 tokenId = uint256(labelHash);

        if (diamondNames.ownerOf(tokenId) != msg.sender) {
            revert NotNameOwner();
        }

        if (isNameBlocked(_name)) {
            revert NameBlocked(_name);
        }

        bytes memory current = names[msg.sender];
        if (current.length != 0 && NameUtils.labelHash(current) == labelHash) {
            revert AlreadyActive();
        }

        uint256 fee = getActivationFee(msg.sender);
        if (msg.value != fee) {
            revert InvalidActivationFee(fee, msg.value);
        }

        _activate(msg.sender, bytes(_name));

        if (msg.value != 0) {
            TransferUtils.transferNative(reinsertPotAddress, msg.value);
        }
    }

    function renew(string calldata _name) external activeRegistrar {
        bytes32 labelHash = NameUtils.labelHash(_name);
        uint256 tokenId = uint256(labelHash);

        if (diamondNames.ownerOf(tokenId) != msg.sender) {
            revert NotNameOwner();
        }

        uint256 expirationTimestamp = DateTimeLib.addYears(block.timestamp, EXPIRATION_TIME_YEARS);

        diamondNames.renew(tokenId, expirationTimestamp);

        emit NameRenewed(msg.sender, labelHash, expirationTimestamp, _name);
    }

    function available(string calldata _name) public view returns (bool) {
        bytes32 labelHash = NameUtils.labelHash(_name);

        return diamondNames.available(uint256(labelHash));
    }

    function getActivationFee(address _who) public view returns (uint256) {
        // Fee scales 10% per activation, capped at 30% of the minting fee:
        // 0 -> free, 1 -> 10%, 2 -> 20%, 3+ -> 30%.
        uint256 nominator = FixedPointMathLib.min(activations[_who], MAX_ACTIVATION_FEE_NOMINATOR);

        return mintingFee * nominator / ACTIVATION_FEE_DENOMINATOR;
    }

    function getHashOfName(string memory _name) public pure returns (bytes32) {
        return NameUtils.labelHash(_name);
    }

    function getHashOfNameBytes(bytes memory _name) public pure returns (bytes32) {
        return NameUtils.labelHash(_name);
    }

    function valid(string memory _name) public pure returns (bool) {
        bytes memory nameBytes = bytes(_name);
        uint256 byteLength = nameBytes.length;

        // Name length must be in range [MIN_NAME_LENTGH, MAX_NAME_LENGTH]
        if (byteLength < MIN_NAME_LENGTH || byteLength > MAX_NAME_LENGHT) {
            return false;
        }

        // Name must begin and end with alphabetic character or digit
        if (!nameBytes[0].isAlphaNum() || !nameBytes[byteLength - 1].isAlphaNum()) {
            return false;
        }

        for (uint256 i = 1; i < byteLength; ++i) {
            bytes1 previousByte = nameBytes[i - 1];
            bytes1 b = nameBytes[i];

            if (!b.isAlphaNum() && !b.isHyphen()) {
                return false;
            }

            // repeated use of hyphen '-' not allowed
            if (previousByte.isHyphen() && b.isHyphen()) {
                return false;
            }
        }

        return true;
    }

    function _activate(address _user, bytes memory _name) private {
        bytes32 labelHash = NameUtils.labelHash(_name);
        bytes32 node = NameUtils.nodeHash(labelHash);

        bytes memory current = names[_user];
        if (current.length != 0) {
            _deactivateName(_user, current);
        }

        names[_user] = _name;

        // Forward resolution: name -> address
        registry.setSubnodeRecord(NameUtils.DMD_NODE, labelHash, address(this), address(resolver), 0);
        resolver.setAddr(node, _user);
        registry.setOwner(node, _user);

        // Reverse resolution: address -> name
        bytes32 reverseLabel = AddressUtils.sha3HexAddress(_user);
        bytes32 reverseNode = AddressUtils.reverseNode(_user);
        registry.setSubnodeRecord(AddressUtils.ADDR_REVERSE_NODE, reverseLabel, address(this), address(resolver), 0);
        resolver.setName(reverseNode, _fullName(_name));

        activations[_user] += 1;

        emit NameActivated(_user, labelHash, string(_name));
    }

    function _deactivateName(address _owner, bytes memory _name) private {
        bytes32 labelHash = NameUtils.labelHash(_name);
        bytes32 node = NameUtils.nodeHash(labelHash);

        registry.setSubnodeOwner(NameUtils.DMD_NODE, labelHash, address(this));
        resolver.setAddr(node, address(0));
        registry.setResolver(node, address(0));

        bytes32 reverseNode = AddressUtils.reverseNode(_owner);
        resolver.setName(reverseNode, "");
        registry.setResolver(reverseNode, address(0));

        delete names[_owner];

        emit NameDeactivated(_owner, labelHash, string(_name));
    }

    function _fullName(bytes memory _label) private pure returns (string memory) {
        return string(abi.encodePacked(_label, ".dmd"));
    }

    function _checkRegistrar() private view {
        if (registry.owner(NameUtils.DMD_NODE) != address(this)) {
            revert RegistrarInactive();
        }
    }

    function _mintingFeeAllowedValues() private pure returns (uint256[] memory) {
        uint256[] memory values = new uint256[](10);

        values[0] = BASE_MINTING_FEE;

        for (uint256 i = 1; i < values.length; ++i) {
            values[i] = values[i - 1] * 2;
        }

        return values;
    }
}
