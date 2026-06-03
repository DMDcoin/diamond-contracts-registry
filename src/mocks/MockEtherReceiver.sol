// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

contract MockEtherReceiver {
    bool public allowReceive;

    constructor() {
        allowReceive = false;
    }

    receive() external payable {
        if (!allowReceive) {
            revert();
        }
    }

    function toggleReceive(bool allow) external {
        allowReceive = allow;
    }
}
