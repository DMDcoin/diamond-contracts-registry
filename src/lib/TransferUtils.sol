// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.33;

library TransferUtils {

    error TransferFailed(address recipient, uint256 amount);

    function transferNative(address recipient, uint256 amount) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = recipient.call{ value: amount }("");
        if (!success) {
            revert TransferFailed(recipient, amount);
        }
    }

}
