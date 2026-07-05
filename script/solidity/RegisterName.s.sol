// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { DMDNames } from "src/DMDNames.sol";
import { DMDRegistrarController } from "src/DMDRegistrarController.sol";
import { DMDRegistry } from "src/DMDRegistry.sol";
import { DMDResolver } from "src/DMDResolver.sol";
import { AddressUtils } from "src/lib/AddressUtils.sol";
import { NameUtils } from "src/lib/NameUtils.sol";

contract RegisterName is Script {
    DMDRegistrarController public controller;
    DMDNames public names;
    DMDRegistry public registry;
    DMDResolver public resolver;

    function setUp() public {
        controller = DMDRegistrarController(0x26EeECc60964C219bFBeA25aBb86aB8b4590467B);
        names = DMDNames(0x857C95B69b5dD7EFE4e5591B2e0C0a79aeBE9899);
        registry = DMDRegistry(0xeaE3181b1d04Af815672368E721d05AD89a5b3DA);
        resolver = DMDResolver(0xe4330911b85c4d7edcDef335490302684D991392);
    }

    function run(string memory name) public {
        uint256 mintingFee = controller.mintingFee();

        vm.startBroadcast();

        (, address caller,) = vm.readCallers();
        console.log("Registering name %s for address %s", name, caller);

        controller.register{ value: mintingFee }(name);

        vm.stopBroadcast();

        bytes32 forwardNode = NameUtils.nodeHash(name);
        console.log("Forward node: ");
        console.logBytes32(forwardNode);

        bytes32 reverseNode = AddressUtils.reverseNode(caller);
        console.log("Reverse node: ");
        console.logBytes32(reverseNode);

        address resolvedAddr = resolver.addr(forwardNode);
        string memory resolvedName = resolver.name(reverseNode);

        console.log("Resolved address: %s", resolvedAddr);
        console.log("Resolved name: %s", resolvedName);
    }
}
