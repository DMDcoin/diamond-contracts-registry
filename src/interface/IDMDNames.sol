// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

interface IDMDNames {
    function register(uint256 id, address owner, uint256 expiration) external;

    function burn(uint256 id) external;

    function ownerOf(uint256 id) external view returns (address);

    function available(uint256 id) external view returns (bool);
}
