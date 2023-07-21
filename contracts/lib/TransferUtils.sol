// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

library TransferUtils {
    error TransferFailed(address recipient, uint256 amount);

    function transferNative(address recipient, uint256 amount) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = recipient.call{ value: amount }("");
        if (!success) {
            revert TransferFailed(recipient, amount);
        }
    }
}
