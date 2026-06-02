// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.33;

library ByteUtils {

    function isAlpha(bytes1 _byte) internal pure returns (bool) {
        return _byte > 0x60 && _byte < 0x7b; // a-z
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
