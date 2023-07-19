// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";


contract DiamondRegistry {

    /// mapping between address and the current name.
    mapping(address => bytes) public names;

    /// mapping between the hash of the name and the address that owns it.abi
    mapping(bytes32 => address) public namesReverse;

    /// mapping of the costs for setting the name.
    mapping(address => uint) public costs;
    
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
        reinsertPotAddress = _reinsertPotAddress;
    }

    function getHashOfName(string memory name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(name));
    }

    function getHashOfNameBytes(bytes memory name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(name));
    }

    function name(address node) external view returns (string memory) {
      return string(names[node]);
    }

    function getSetNameCost(address node) public view returns (uint) {

        uint cost = costs[node]; 
        if (cost > 0) {
          return cost;
        } else {
          return 1 ether; // , "Fee is exactly 1 DMD");
        }
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

    function getAddressOfName(string calldata name) external view returns(address) {
      bytes32 nameHash = getHashOfName(name);
      return namesReverse[nameHash];
    }

    function setOwnName(string calldata name) 
      external
      payable {

        // require(node == tx.origin, "Only the own name can be set.");
        uint cost = getSetNameCost(tx.origin);
        require(cost == msg.value, "Amount requires to be exactly the costs");

        bytes32 nameHash = getHashOfName(name);
        // this could also be a hash collison. bad luck, we don't care about this case.
        require(namesReverse[nameHash] == address(0), "Name already taken");

        bytes storage original_string = names[tx.origin];
        
        // if there is already a name stored, we can delete it.
        if (original_string.length != 0) {
          bytes32 original_nameHash = getHashOfNameBytes(original_string);
          delete namesReverse[original_nameHash];
        } 

        names[tx.origin] = bytes(name);

        if (cost < maximumCosts) {
          costs[tx.origin] = cost * 2;
        }
        
        namesReverse[nameHash] = tx.origin;

        emit NameChanged(tx.origin, name);

        payable(reinsertPotAddress).call{value: msg.value};
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


    /// ENS compatible function to get the address of a node
    /// @param node The address of the node
    function addr(bytes32 node) public view returns (address) {
      return namesReverse[node];
    }

}
