// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import { NameUtils } from "./NameUtils.sol";

abstract contract NameBlocklist is Initializable, OwnableUpgradeable {
    /**
     * @custom:storage-location erc7201:dmd.storage.NameBlocklist
     */
    struct NameBlocklistStorage {
        mapping(bytes32 => bool) _blocklist;
    }

    // keccak256(abi.encode(uint256(keccak256("dmd.storage.NameBlocklist")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant NameBlocklistStorageLocation =
        0x698f631cd62c2499a873e75c9c22c0e53d3435a34fb25ebf1fc1d8de9ceb3300;

    error NameBlocked(string name);

    event NameBlockedSet(bytes32 indexed labelHash, string name, bool blocked);

    function __NameBlocklist_init() internal onlyInitializing {
        __NameBlocklist_init_unchained();
    }

    function __NameBlocklist_init_unchained() internal onlyInitializing { }

    function setNameBlocked(string calldata _name, bool _blocked) external onlyOwner {
        _setNameBlocked(_name, _blocked);
    }

    function setNamesBlocked(string[] calldata _names, bool _blocked) external onlyOwner {
        for (uint256 i = 0; i < _names.length; ++i) {
            _setNameBlocked(_names[i], _blocked);
        }
    }

    function isNameBlocked(string memory _name) public view returns (bool) {
        NameBlocklistStorage storage $ = _getNameBlocklistStorage();

        return $._blocklist[NameUtils.labelHash(_name)];
    }

    function _setNameBlocked(string calldata _name, bool _blocked) internal {
        NameBlocklistStorage storage $ = _getNameBlocklistStorage();

        bytes32 labelHash = NameUtils.labelHash(_name);
        $._blocklist[labelHash] = _blocked;

        emit NameBlockedSet(labelHash, _name, _blocked);
    }

    function _getNameBlocklistStorage() private pure returns (NameBlocklistStorage storage $) {
        assembly {
            $.slot := NameBlocklistStorageLocation
        }
    }
}
