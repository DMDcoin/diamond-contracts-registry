// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Controllable is Initializable, OwnableUpgradeable {
    /**
     * @custom:storage-location erc7201:dmd.storage.Controllable
     */
    struct ControllableStorage {
        mapping(address => bool) _controllers;
    }

    // keccak256(abi.encode(uint256(keccak256("dmd.storage.Controllable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ControllableStorageLocation =
        0x5264f32cb7240714a5615ea7631000b1311df01ce7bf92c794409654b10a3300;

    event ControllerChanged(address indexed controller, bool active);

    error UnauthorizedController();

    modifier onlyController() {
        if (!isController(msg.sender)) {
            revert UnauthorizedController();
        }
        _;
    }

    function __Controllable_init() internal onlyInitializing {
        __Controllable_init_unchained();
    }

    function __Controllable_init_unchained() internal onlyInitializing { }

    function setController(address controller, bool active) public onlyOwner {
        ControllableStorage storage $ = _getControllableStorage();

        $._controllers[controller] = active;

        emit ControllerChanged(controller, active);
    }

    function isController(address caller) public view returns (bool) {
        ControllableStorage storage $ = _getControllableStorage();

        return $._controllers[caller];
    }

    function _getControllableStorage() private pure returns (ControllableStorage storage $) {
        assembly {
            $.slot := ControllableStorageLocation
        }
    }
}
