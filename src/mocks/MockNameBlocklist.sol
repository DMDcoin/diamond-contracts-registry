// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { NameBlocklist } from "../lib/NameBlocklist.sol";

contract MockNameBlocklist is NameBlocklist {
    function initialize(address _initialOwner) external initializer {
        __Ownable_init(_initialOwner);
        __NameBlocklist_init();
    }
}
