// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

library ByteUtils {
    function isAlpha(bytes1 _byte) internal pure returns (bool) {
        return
            (_byte > 0x40 && _byte < 0x5b)      // A-Z
            || (_byte > 0x60 && _byte < 0x7b);  // a-z
    }

    function isDigit(bytes1 _byte) internal pure returns (bool) {
        return _byte > 0x2f && _byte < 0x3a; // 0-9
    }

    function isAlphaNum(bytes1 _byte) internal pure returns (bool) {
        return isAlpha(_byte) || isDigit(_byte);
    }

    function isHyphen(bytes1 _byte) internal pure returns (bool) {
        return _byte == 0x2d; // '-'
    }
}
