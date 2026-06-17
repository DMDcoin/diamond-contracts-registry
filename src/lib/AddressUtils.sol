// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { NameUtils } from "./NameUtils.sol";

// Original ENS library.
// Reference: https://github.com/ensdomains/ens-contracts/blob/staging/contracts/utils/AddressUtils.sol

library AddressUtils {
    // This is the hex encoding of the string 'abcdefghijklmnopqrstuvwxyz'
    // It is used as a constant to lookup the characters of the hex address
    bytes32 private constant LOOKUP = 0x3031323334353637383961626364656600000000000000000000000000000000;

    // Namehash of "addr.reverse":
    // nameHash(nameHash(bytes32(0), keccak256("reverse")), keccak256("addr"))
    bytes32 public constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) internal pure returns (bytes32 ret) {
        assembly {
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

    /**
     * @dev The ENS node for an address' reverse record:
     * namehash("<hexaddr>.addr.reverse").
     */
    function reverseNode(address _addr) internal pure returns (bytes32) {
        return NameUtils.nameHash(ADDR_REVERSE_NODE, sha3HexAddress(_addr));
    }
}
