// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

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
