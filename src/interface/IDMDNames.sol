// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { IERC721 } from "./IERC721.sol";

interface IDMDNames is IERC721 {
    /// @notice Updates fee value, payed by users for token transfer.
    /// @param fee The new transfer fee
    function setTransferFee(uint256 fee) external;

    /// @notice Mints a name token with an expiration.
    /// @param id The token id
    /// @param owner The recipient
    /// @param expiration The expiration timestamp
    function register(uint256 id, address owner, uint256 expiration) external;

    /// @notice Extends the expiration of a non-expired name.
    /// @param id The token id
    /// @param expiration The new expiration timestamp
    function renew(uint256 id, uint256 expiration) external;

    /// @notice Burns a name token.
    /// @param id The token id to burn
    function burn(uint256 id) external;

    /// @notice Returns whether a name is available to register.
    /// @param id The token id
    /// @return bool True if free or expired
    function available(uint256 id) external view returns (bool);

    /// @notice Returns whether a name has expired.
    /// @param id The token id to query
    /// @return bool True if name token expired
    function expired(uint256 id) external view returns (bool);

    /// @notice Returns whether a token exists.
    /// @param id The token id to query
    /// @return bool True if name token exists (minted)
    function exists(uint256 id) external view returns (bool);
}
