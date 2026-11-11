// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { Options, Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract Upgrade is Script {
    string public constant RESOLVER_CONTRACT = "DMDResolver";
    string public constant CONTROLLER_CONTRACT = "DMDRegistrarController";

    function run() external {
        address resolver = vm.envAddress("RESOLVER_ADDRESS");
        address controller = vm.envAddress("REGISTRAR_CONTROLLER_ADDRESS");

        // Build info directory of the currently deployed version, used for storage layout checks
        string memory referenceBuildInfoDir = vm.envOr("REFERENCE_BUILD_INFO_DIR", string(""));

        upgrade(resolver, controller, referenceBuildInfoDir);
    }

    function upgrade(address resolver, address controller, string memory referenceBuildInfoDir) public {
        vm.startBroadcast();

        address resolverImpl = _deployImplementation(RESOLVER_CONTRACT, referenceBuildInfoDir);
        address controllerImpl = _deployImplementation(CONTROLLER_CONTRACT, referenceBuildInfoDir);

        vm.stopBroadcast();

        // Resolver must be upgraded first, new controller calls resolver DNS and email forwarding setters
        _logUpgradeCalldata(RESOLVER_CONTRACT, resolver, resolverImpl);
        _logUpgradeCalldata(CONTROLLER_CONTRACT, controller, controllerImpl);
    }

    function _deployImplementation(
        string memory contractName,
        string memory referenceBuildInfoDir
    ) private returns (address) {
        Options memory opts;

        string memory artifact = string.concat(contractName, ".sol:", contractName);

        if (bytes(referenceBuildInfoDir).length == 0) {
            console.log("WARNING: Storage layout checks skipped!");

            return Upgrades.deployImplementation(artifact, opts);
        }

        string[] memory path = vm.split(referenceBuildInfoDir, "/");

        opts.referenceBuildInfoDir = referenceBuildInfoDir;
        opts.referenceContract = string.concat(path[path.length - 1], ":", contractName);

        return Upgrades.prepareUpgrade(artifact, opts);
    }

    function _logUpgradeCalldata(string memory contractName, address proxy, address implementation) private view {
        address proxyAdmin = Upgrades.getAdminAddress(proxy);

        bytes memory data =
            abi.encodeCall(ProxyAdmin.upgradeAndCall, (ITransparentUpgradeableProxy(proxy), implementation, ""));

        console.log("contract: %s", contractName);
        console.log("    impl: %s", implementation);
        console.log("  target: %s", proxyAdmin);
        console.log("calldata: %s", vm.toString(data));
    }
}
