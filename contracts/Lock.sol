// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DiamondENSResolver {
 
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);

    event NameChanged(bytes32 indexed node, string name);

    constructor() {
        
    }

     function setAddr(bytes32 node, uint coinType, bytes calldata a)
      external {

      }

      

    function withdraw()
     external {   
    }

    function name(bytes32 node) external view returns (string memory) {

    }

    function setName(bytes32 node, string calldata name) external {

    }


    // Content:

    function contenthash(bytes32 node) external view returns (bytes memory) {
    }

    function setContenthash(bytes32 node, bytes calldata hash) external {
    }

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) {
    }

}
