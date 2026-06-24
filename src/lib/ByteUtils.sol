// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

library ByteUtils {
    /// @notice Check wheter the byte is a lower-case letter (a-z)
    /// @param _byte The byte to check
    function isAlpha(bytes1 _byte) internal pure returns (bool) {
        return _byte > 0x60 && _byte < 0x7b;
    }

    /// @notice Check wheter the byte is a digit (0-9).
    /// @param _byte The byte to check
    function isDigit(bytes1 _byte) internal pure returns (bool) {
        return _byte > 0x2f && _byte < 0x3a;
    }

    /// @notice Check wheter the byte is alphanumeric (a-z or 0-9).
    /// @param _byte The byte to check.
    function isAlphaNum(bytes1 _byte) internal pure returns (bool) {
        return isAlpha(_byte) || isDigit(_byte);
    }

    /// @notice Check wheter the byte is a hyphen (-).
    /// @param _byte The byte to test.
    /// @return True if the byte is `-`.
    function isHyphen(bytes1 _byte) internal pure returns (bool) {
        return _byte == 0x2d; // '-'
    }
}
