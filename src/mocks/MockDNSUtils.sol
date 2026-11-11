// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { DNSUtils } from "../lib/DNSUtils.sol";

contract MockDNSUtils {
    function isValidHostname(bytes calldata _hostname) public pure returns (bool) {
        return DNSUtils.isValidHostname(_hostname);
    }

    function isValidEmail(bytes calldata _email) public pure returns (bool) {
        return DNSUtils.isValidEmail(_email);
    }
}
