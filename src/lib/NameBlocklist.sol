// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import { NameUtils } from "./NameUtils.sol";

/// @notice Managed blocklist of names that may not be registered or resolved.
abstract contract NameBlocklist is Initializable, OwnableUpgradeable {
    /// @custom:storage-location erc7201:dmd.storage.NameBlocklist
    struct NameBlocklistStorage {
        mapping(bytes32 => bool) _blocklist;
    }

    // keccak256(abi.encode(uint256(keccak256("dmd.storage.NameBlocklist")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant NAME_BLOCKLIST_STORAGE_LOCATION =
        0x698f631cd62c2499a873e75c9c22c0e53d3435a34fb25ebf1fc1d8de9ceb3300;

    /// @notice Thrown when blocked name was used.
    error NameBlocked(string name);

    /// @notice Emitted when name added/removed to/from blocklist.
    event NameBlockedSet(bytes32 indexed labelHash, string name, bool blocked);

    function __NameBlocklist_init() internal onlyInitializing {
        __NameBlocklist_init_unchained();
    }

    function __NameBlocklist_init_unchained() internal onlyInitializing { }

    /// @notice Sets the blocked status of a name.
    /// @param _name The name to block/unblock
    /// @param _blocked True to block, false to unblock
    function setNameBlocked(string calldata _name, bool _blocked) external onlyOwner {
        _setNameBlocked(_name, _blocked);
    }

    /// @notice Sets the blocked status of multiple names.
    /// @param _names Names array to block/unlock
    /// @param _blocked True to block, false to unblock
    function setNamesBlocked(string[] calldata _names, bool _blocked) external onlyOwner {
        for (uint256 i = 0; i < _names.length; ++i) {
            _setNameBlocked(_names[i], _blocked);
        }
    }

    /// @notice Returns whether a name is blocked.
    /// @param _name The name to check
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
            $.slot := NAME_BLOCKLIST_STORAGE_LOCATION
        }
    }
}
