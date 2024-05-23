// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { ByteUtils } from "../lib/ByteUtils.sol";

contract MockByteUtils {
    using ByteUtils for bytes1;

    function isAlpha(bytes1 _byte) public pure returns (bool) {
        return _byte.isAlpha();
    }

    function isDigit(bytes1 _byte) public pure returns (bool) {
        return _byte.isDigit();
    }

    function isAlphaNum(bytes1 _byte) public pure returns (bool) {
        return _byte.isAlphaNum();
    }

    function isHyphen(bytes1 _byte) public pure returns (bool) {
        return _byte.isHyphen();
    }
}
