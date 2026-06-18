// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { IERC721 } from "./IERC721.sol";

interface IDMDNames is IERC721 {
    function setTransferFee(uint256 fee) external;

    function register(uint256 id, address owner, uint256 expiration) external;

    function renew(uint256 id, uint256 expiration) external;

    function burn(uint256 id) external;

    function available(uint256 id) external view returns (bool);

    function expired(uint256 id) external view returns (bool);

    function exists(uint256 id) external view returns (bool);
}
