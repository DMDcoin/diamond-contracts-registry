// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { ByteUtils } from "./ByteUtils.sol";

/// @notice Helpers for validating DNS record and email forwarding values.
library DNSUtils {
    using ByteUtils for bytes1;

    uint256 public constant MAX_HOSTNAME_LENGTH = 253;
    uint256 public constant MAX_LABEL_LENGTH = 63;

    uint256 public constant MAX_EMAIL_LENGTH = 254;
    uint256 public constant MAX_LOCAL_PART_LENGTH = 64;

    /// @notice Check whether the bytes are a valid hostname (e.g. `www.example.com`).
    /// Hostname must consist of at least two labels, top-level label must begin with a letter.
    /// @param _hostname The hostname to check (without trailing dot)
    /// @return True if the hostname is valid
    function isValidHostname(bytes calldata _hostname) internal pure returns (bool) {
        uint256 length = _hostname.length;

        if (length == 0 || length > MAX_HOSTNAME_LENGTH) {
            return false;
        }

        uint256 labelStart = 0;

        for (uint256 i = 0; i < length; ++i) {
            if (_hostname[i].isDot()) {
                if (!_isValidLabel(_hostname[labelStart:i])) {
                    return false;
                }

                labelStart = i + 1;
            }
        }

        // Single label hostnames not allowed
        if (labelStart == 0) {
            return false;
        }

        bytes calldata topLevelLabel = _hostname[labelStart:];

        // Top-level label must begin with a letter, so IP addresses are not accepted
        return _isValidLabel(topLevelLabel) && topLevelLabel[0].isAlpha();
    }

    /// @notice Check whether the bytes are a valid email address (e.g. `alice@example.com`).
    /// @param _email The email address to check
    /// @return True if the email address is valid
    function isValidEmail(bytes calldata _email) internal pure returns (bool) {
        uint256 length = _email.length;

        if (length > MAX_EMAIL_LENGTH) {
            return false;
        }

        for (uint256 i = 0; i < length; ++i) {
            if (_email[i].isAt()) {
                return _isValidLocalPart(_email[:i]) && isValidHostname(_email[i + 1:]);
            }
        }

        return false;
    }

    /// @dev Check whether the bytes are a valid hostname label.
    /// @param _label The label to check
    /// @return True if the label is valid
    function _isValidLabel(bytes calldata _label) private pure returns (bool) {
        uint256 length = _label.length;

        if (length == 0 || length > MAX_LABEL_LENGTH) {
            return false;
        }

        // Label must begin and end with alphabetic character or digit
        if (!_label[0].isAlphaNum() || !_label[length - 1].isAlphaNum()) {
            return false;
        }

        // Repeated use of hyphen '-' allowed for punycode labels (e.g. `xn--`)
        for (uint256 i = 1; i < length - 1; ++i) {
            if (!_label[i].isAlphaNum() && !_label[i].isHyphen()) {
                return false;
            }
        }

        return true;
    }

    /// @dev Check whether the bytes are a valid local part of email address.
    /// @param _localPart The local part to check (before the `@` sign)
    /// @return True if the local part is valid
    function _isValidLocalPart(bytes calldata _localPart) private pure returns (bool) {
        uint256 length = _localPart.length;

        if (length == 0 || length > MAX_LOCAL_PART_LENGTH) {
            return false;
        }

        // Local part must not begin or end with dot
        if (_localPart[0].isDot() || _localPart[length - 1].isDot()) {
            return false;
        }

        for (uint256 i = 0; i < length; ++i) {
            bytes1 b = _localPart[i];

            if (!b.isAlphaNum() && !b.isDot() && !b.isHyphen() && !b.isUnderscore() && !b.isPlus()) {
                return false;
            }

            // repeated use of dot '.' not allowed
            if (b.isDot() && _localPart[i - 1].isDot()) {
                return false;
            }
        }

        return true;
    }
}
