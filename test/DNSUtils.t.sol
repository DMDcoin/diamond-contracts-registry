// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { Test } from "forge-std/Test.sol";

import { MockDNSUtils } from "../src/mocks/MockDNSUtils.sol";

contract DNSUtilsTest is Test {
    struct ValidationTestCase {
        string value;
        bool expected;
    }

    MockDNSUtils internal mockUtils;

    function setUp() public {
        mockUtils = new MockDNSUtils();
    }

    function test_IsValidHostname_MaxLength() public view {
        string memory label = _repeat("a", 63);
        string memory hostname = string.concat(label, ".", label, ".", label, ".", _repeat("a", 61));

        assertEq(bytes(hostname).length, 253);
        assertTrue(mockUtils.isValidHostname(bytes(hostname)));
    }

    function test_IsValidHostname_TooLong() public view {
        string memory label = _repeat("a", 63);
        string memory hostname = string.concat(label, ".", label, ".", label, ".", _repeat("a", 62));

        assertEq(bytes(hostname).length, 254);
        assertFalse(mockUtils.isValidHostname(bytes(hostname)));
    }

    function test_IsValidHostname_LabelMaxLength() public view {
        assertTrue(mockUtils.isValidHostname(bytes(string.concat(_repeat("a", 63), ".com"))));
        assertTrue(mockUtils.isValidHostname(bytes(string.concat("example.", _repeat("a", 63)))));
    }

    function test_IsValidHostname_LabelTooLong() public view {
        assertFalse(mockUtils.isValidHostname(bytes(string.concat(_repeat("a", 64), ".com"))));
        assertFalse(mockUtils.isValidHostname(bytes(string.concat("example.", _repeat("a", 64)))));
    }

    function test_IsValidEmail_MaxLength() public view {
        string memory hostname = string.concat(_repeat("a", 63), ".", _repeat("a", 63), ".", _repeat("a", 61));
        string memory email = string.concat(_repeat("a", 64), "@", hostname);

        assertEq(bytes(email).length, 254);
        assertTrue(mockUtils.isValidEmail(bytes(email)));
    }

    function test_IsValidEmail_TooLong() public view {
        string memory hostname = string.concat(_repeat("a", 63), ".", _repeat("a", 63), ".", _repeat("a", 62));
        string memory email = string.concat(_repeat("a", 64), "@", hostname);

        assertEq(bytes(email).length, 255);
        assertTrue(mockUtils.isValidHostname(bytes(hostname)));
        assertFalse(mockUtils.isValidEmail(bytes(email)));
    }

    function test_IsValidEmail_LocalPartTooLong() public view {
        assertTrue(mockUtils.isValidEmail(bytes(string.concat(_repeat("a", 64), "@example.com"))));
        assertFalse(mockUtils.isValidEmail(bytes(string.concat(_repeat("a", 65), "@example.com"))));
    }

    function fixtureHostnames() public pure returns (ValidationTestCase[] memory) {
        ValidationTestCase[] memory cases = new ValidationTestCase[](22);

        cases[0] = ValidationTestCase({ value: "example.com", expected: true });
        cases[1] = ValidationTestCase({ value: "www.example.com", expected: true });
        cases[2] = ValidationTestCase({ value: "a.b", expected: true });
        cases[3] = ValidationTestCase({ value: "xn--80ak6aa92e.com", expected: true });
        cases[4] = ValidationTestCase({ value: "my-site.example.io", expected: true });
        cases[5] = ValidationTestCase({ value: "123.example.com", expected: true });
        cases[6] = ValidationTestCase({ value: "example.c0m", expected: true });
        cases[7] = ValidationTestCase({ value: "", expected: false });
        cases[8] = ValidationTestCase({ value: "example", expected: false });
        cases[9] = ValidationTestCase({ value: "1.2.3.4", expected: false });
        cases[10] = ValidationTestCase({ value: "example.1com", expected: false });
        cases[11] = ValidationTestCase({ value: ".example.com", expected: false });
        cases[12] = ValidationTestCase({ value: "example.com.", expected: false });
        cases[13] = ValidationTestCase({ value: "example..com", expected: false });
        cases[14] = ValidationTestCase({ value: "-example.com", expected: false });
        cases[15] = ValidationTestCase({ value: "example-.com", expected: false });
        cases[16] = ValidationTestCase({ value: "example.-com", expected: false });
        cases[17] = ValidationTestCase({ value: "Example.com", expected: false });
        cases[18] = ValidationTestCase({ value: "exa_mple.com", expected: false });
        cases[19] = ValidationTestCase({ value: "exa mple.com", expected: false });
        cases[20] = ValidationTestCase({ value: "example.com/path", expected: false });
        cases[21] = ValidationTestCase({ value: "alice@example.com", expected: false });

        return cases;
    }

    function tableIsValidHostnameTests(ValidationTestCase memory hostnames) public view {
        assertEq(mockUtils.isValidHostname(bytes(hostnames.value)), hostnames.expected);
    }

    function fixtureEmails() public pure returns (ValidationTestCase[] memory) {
        ValidationTestCase[] memory cases = new ValidationTestCase[](22);

        cases[0] = ValidationTestCase({ value: "alice@example.com", expected: true });
        cases[1] = ValidationTestCase({ value: "alice.bob@example.com", expected: true });
        cases[2] = ValidationTestCase({ value: "alice+dmd@mail.example.com", expected: true });
        cases[3] = ValidationTestCase({ value: "a_b-c@example.io", expected: true });
        cases[4] = ValidationTestCase({ value: "1337@example.com", expected: true });
        cases[5] = ValidationTestCase({ value: "", expected: false });
        cases[6] = ValidationTestCase({ value: "alice", expected: false });
        cases[7] = ValidationTestCase({ value: "alice.example.com", expected: false });
        cases[8] = ValidationTestCase({ value: "@example.com", expected: false });
        cases[9] = ValidationTestCase({ value: "alice@", expected: false });
        cases[10] = ValidationTestCase({ value: "alice@@example.com", expected: false });
        cases[11] = ValidationTestCase({ value: "alice@bob@example.com", expected: false });
        cases[12] = ValidationTestCase({ value: ".alice@example.com", expected: false });
        cases[13] = ValidationTestCase({ value: "alice.@example.com", expected: false });
        cases[14] = ValidationTestCase({ value: "ali..ce@example.com", expected: false });
        cases[15] = ValidationTestCase({ value: "Alice@example.com", expected: false });
        cases[16] = ValidationTestCase({ value: "ali ce@example.com", expected: false });
        cases[17] = ValidationTestCase({ value: "alice\n@example.com", expected: false });
        cases[18] = ValidationTestCase({ value: "\"alice\"@example.com", expected: false });
        cases[19] = ValidationTestCase({ value: "alice@example", expected: false });
        cases[20] = ValidationTestCase({ value: "alice@exa_mple.com", expected: false });
        cases[21] = ValidationTestCase({ value: "alice@1.2.3.4", expected: false });

        return cases;
    }

    function tableIsValidEmailTests(ValidationTestCase memory emails) public view {
        assertEq(mockUtils.isValidEmail(bytes(emails.value)), emails.expected);
    }

    function _repeat(string memory char, uint256 count) private pure returns (string memory result) {
        for (uint256 i = 0; i < count; ++i) {
            result = string.concat(result, char);
        }
    }
}
