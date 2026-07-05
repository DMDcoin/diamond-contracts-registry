// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { TransferUtils } from "../lib/TransferUtils.sol";

contract MockTransferUtils {
    receive() external payable { }

    constructor() { }

    function transferNative(address recipient, uint256 amount) external {
        TransferUtils.transferNative(recipient, amount);
    }
}
