// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";


contract DiamondENSResolver {

    // mapping between node and name.
    mapping(address => string) public names;
    mapping(bytes32 => address) public namesReverse;
    mapping(address => uint) public costs;
    
    address public reinsertPotAddress;  
 
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

    function name(address node) external view returns (string memory) {
      return names[node];
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

    function setOwnName(string calldata name) 
      external
      payable {

        // require(node == tx.origin, "Only the own name can be set.");
        uint cost = getSetNameCost(tx.origin);
        require(cost == msg.value, "Amount requires to be exactly the costs");

        bytes32 nameHash = getHashOfName(name);
        // this could also be a hash collison. bad luck, we don't care about this case.
        require(namesReverse[nameHash] == address(0), "Name already taken");

        names[tx.origin] = name;
        costs[tx.origin] = cost * 2;
        namesReverse[nameHash] = tx.origin;

        emit NameChanged(tx.origin, name);

        payable(reinsertPotAddress).call{value: msg.value};
    }

    // function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) {
    // }
}
