// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

library TransferUtils {
    /**
     * @notice Thrown when a native token transfer fails.
     */
    error TransferFailed(address recipient, uint256 amount);

    /**
     * @notice Transfers native token to a recipient.
     * @param recipient Funds receiver address.
     * @param amount The amount to transfer.
     */
    function transferNative(address recipient, uint256 amount) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = recipient.call{ value: amount }("");
        if (!success) {
            revert TransferFailed(recipient, amount);
        }
    }
}
