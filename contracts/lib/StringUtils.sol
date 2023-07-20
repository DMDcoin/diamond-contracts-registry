// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

library StringUtils {
    function isAlpha(bytes1 _byte) internal pure returns (bool) {
        return
            (_byte > 0x40 && _byte < 0x5b)      // A-Z
            || (_byte > 0x60 && _byte < 0x7b); // a-z
    }

    function isDigit(bytes1 _byte) internal pure returns (bool) {
        return _byte > 0x2f && _byte < 0x3a;
    }

    function isAllowedSpecial(bytes1 _byte) internal pure returns (bool) {
        return _byte == 0x2d || _byte == 0x2e; // '-' or '.'
    }
}
