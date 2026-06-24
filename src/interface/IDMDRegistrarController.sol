// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IDMDRegistrarController {
    /// @notice Resets the resolver records of a transferred name.
    /// @param from The previous owner of the token
    /// @param tokenId The transferred token id (name label hash)
    function resetRecordsOnTransfer(address from, uint256 tokenId) external;
}
