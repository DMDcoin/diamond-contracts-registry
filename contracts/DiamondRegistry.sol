// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ByteUtils} from "./lib/ByteUtils.sol";
import {TransferUtils} from "./lib/TransferUtils.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DiamondRegistry {
    using ByteUtils for bytes1;

    uint256 public constant MIN_NAME_LENGTH = 3;
    uint256 public constant MAX_NAME_LENGHT = 32;

    /// mapping between address and the current name.
    mapping(address => bytes) public names;

    /// mapping between the hash of the name and the address that owns it.abi
    mapping(bytes32 => address) public namesReverse;

    /// mapping of the costs for setting the name.
    mapping(address => uint256) public costs;

    /// funds are sent to this reinsert pot.
    address public reinsertPotAddress;

    /// maximum costs for setting the name.
    uint256 public maximumCosts = 256 ether;

    // event AddressChanged(address indexed node, uint coinType, bytes newAddress);
    event NameChanged(address indexed node, string name);

    // function isAuthorised(bytes32 node) internal view returns(bool) {
    //     address owner = ens.owner(node);
    //     return owner == msg.sender || authorisations[node][owner][msg.sender];
    // }

    constructor(address _reinsertPotAddress) {
        require(_reinsertPotAddress != address(0), "ReinsertPotAddress must not be 0");

        reinsertPotAddress = _reinsertPotAddress;
    }

    // function setOwnName(string calldata name)
    //   external
    //   payable {

    //     setName(tx.origin, name);

    //     uint currentCosts = currentCosts[node];
    //     if (currentCosts > 0) {
    //       require(msg.value == currentCosts, "Not enough funds to set name");
    //     } else {
    //       require(msg.value == 1 ether, "Fee is exactly 1 DMD");
    //     }

    //     // if
    //     // the sent value of the change
    // }

    function setOwnName(string calldata _name) external payable {
        // require(node == tx.origin, "Only the own name can be set.");
        uint cost = getSetNameCost(tx.origin);
        require(cost == msg.value, "Amount requires to be exactly the costs");

        bytes32 nameHash = getHashOfName(_name);

        require(valid(_name), "Name not valid");
        require(available(_name), "Name not available");

        bytes storage originalString = names[tx.origin];

        // if there is already a name stored, we can delete it.
        if (originalString.length != 0) {
            bytes32 original_nameHash = getHashOfNameBytes(originalString);
            delete namesReverse[original_nameHash];
        }

        if (cost < maximumCosts) {
            costs[tx.origin] = cost * 2;
        }

        names[tx.origin] = bytes(_name);
        namesReverse[nameHash] = tx.origin;

        TransferUtils.transferNative(reinsertPotAddress, msg.value);

        emit NameChanged(tx.origin, _name);
    }

    // function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
    // bytes memory b1 = bytes(s1);
    // bytes memory b2 = bytes(s2);
    // uint256 l1 = b1.length;
    // if (l1 != b2.length) return false;
    // for (uint256 i=0; i<l1; i++) {
    //     if (b1[i] != b2[i]) return false;
    // }
    // return true;
    // }

    function getAddressOfName(
        string calldata _name
    ) external view returns (address) {
        bytes32 nameHash = getHashOfName(_name);
        return namesReverse[nameHash];
    }

    function name(address node) external view returns (string memory) {
        return string(names[node]);
    }

    /// ENS compatible function to get the address of a node
    /// @param node The address of the node
    function addr(bytes32 node) public view returns (address) {
        return namesReverse[node];
    }

    function available(string memory _name) public view returns (bool) {
        bytes32 nameHash = getHashOfName(_name);

        // this could also be a hash collison. bad luck, we don't care about this case.
        return namesReverse[nameHash] == address(0);
    }

    function getSetNameCost(address node) public view returns (uint) {
        uint cost = costs[node];
        if (cost > 0) {
            return cost;
        } else {
            return 1 ether; // , "Fee is exactly 1 DMD");
        }
    }

    function getHashOfName(string memory _name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function getHashOfNameBytes(
        bytes memory _name
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
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

            if (!b.isAlpha() && !b.isDigit() && !b.isHyphen()) {
                return false;
            }

            // repeated use of hyphen '-' not allowed
            if (previousByte.isHyphen() && b.isHyphen()) {
                return false;
            }
        }

        return true;
    }
}
