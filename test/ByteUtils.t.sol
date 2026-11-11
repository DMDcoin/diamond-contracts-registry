// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Test } from "forge-std/Test.sol";

import { MockByteUtils } from "../src/mocks/MockByteUtils.sol";

// forge-lint: disable-start(unsafe-typecast)

contract ByteUtilsTest is Test {
    MockByteUtils internal mockUtils;

    uint256 public constant HYPHEN_CODE = 45;
    uint256 public constant DOT_CODE = 46;
    uint256 public constant AT_CODE = 64;
    uint256 public constant UNDERSCORE_CODE = 95;
    uint256 public constant PLUS_CODE = 43;

    function setUp() public {
        mockUtils = new MockByteUtils();
    }

    function _isAlpha(uint256 c) private pure returns (bool) {
        return c >= 97 && c <= 122; // a-z
    }

    function _isDigit(uint256 c) private pure returns (bool) {
        return c >= 48 && c <= 57; // 0-9
    }

    function test_IsAlpha() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            assertEq(mockUtils.isAlpha(char), _isAlpha(c));
        }
    }

    function test_IsDigit() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            assertEq(mockUtils.isDigit(char), _isDigit(c));
        }
    }

    function test_IsAlphaNum() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            assertEq(mockUtils.isAlphaNum(char), _isAlpha(c) || _isDigit(c));
        }
    }

    function test_IsHyphen() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            if (c == HYPHEN_CODE) {
                assertEq(mockUtils.isHyphen(char), true);
            } else {
                assertEq(mockUtils.isHyphen(char), false);
            }
        }
    }

    function test_IsDot() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            if (c == DOT_CODE) {
                assertEq(mockUtils.isDot(char), true);
            } else {
                assertEq(mockUtils.isDot(char), false);
            }
        }
    }

    function test_IsAt() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            if (c == AT_CODE) {
                assertEq(mockUtils.isAt(char), true);
            } else {
                assertEq(mockUtils.isAt(char), false);
            }
        }
    }

    function test_IsUnderscore() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            if (c == UNDERSCORE_CODE) {
                assertEq(mockUtils.isUnderscore(char), true);
            } else {
                assertEq(mockUtils.isUnderscore(char), false);
            }
        }
    }

    function test_IsPlus() public view {
        for (uint256 c = 0; c < 128; ++c) {
            bytes1 char = bytes1(uint8(c));

            if (c == PLUS_CODE) {
                assertEq(mockUtils.isPlus(char), true);
            } else {
                assertEq(mockUtils.isPlus(char), false);
            }
        }
    }
}

// forge-lint: disable-end(unsafe-typecast)
