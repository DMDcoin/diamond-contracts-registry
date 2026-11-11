// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IEmailForwardingController {
    /// @notice Sets the email forwarding target of the caller's active name.
    /// @param label The active name (without the `.dmd` suffix)
    /// @param target The email address to forward emails to
    function setEmailForwarding(string calldata label, bytes calldata target) external;

    /// @notice Clears the email forwarding target of the caller's active name.
    /// @param label The active name (without the `.dmd` suffix)
    function clearEmailForwarding(string calldata label) external;
}
