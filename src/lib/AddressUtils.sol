// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { NameUtils } from "./NameUtils.sol";

/// @notice Original ENS library used for computing reverse-resolution nodes for addresses.
/// Reference: https://github.com/ensdomains/ens-contracts/blob/staging/contracts/utils/AddressUtils.sol
/// @dev Reverse records stored under `addr.reverse` node.
library AddressUtils {
    /// @dev Hex character lookup table (`0-9a-f`) used to encode an address.
    bytes32 private constant LOOKUP = 0x3031323334353637383961626364656600000000000000000000000000000000;

    /// @notice Namehash of `addr.reverse` - the parent node of all reverse records.
    /// @dev Computed as nameHash(nameHash(bytes32(0), keccak256("reverse")), keccak256("addr"))
    bytes32 public constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    /// @notice Computes the keccak256 of the lower-case hex representation of an address.
    /// @param addr The address to hash
    /// @return ret The hash of the lower-case hexadecimal encoding of the address
    function sha3HexAddress(address addr) internal pure returns (bytes32 ret) {
        assembly ("memory-safe") {
            for {
                let i := 40
            } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), LOOKUP))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), LOOKUP))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }

    /// @notice Computes the ENS reverse node for an address: `namehash("<hexaddr>.addr.reverse")`.
    /// @param _addr The address to compute reverse node from
    /// @return The reverse-record node hash
    function reverseNode(address _addr) internal pure returns (bytes32) {
        return NameUtils.nameHash(ADDR_REVERSE_NODE, sha3HexAddress(_addr));
    }
}
