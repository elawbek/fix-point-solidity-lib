// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FixMath {
  function toBytes(uint256 convertValue) external view returns (string memory) {
    assembly {
      let ptr := mload(0x40)
      mstore(ptr, 0x20)
      ptr := add(ptr, 0x40)

      let part := shr(0x10, convertValue)
      let intLen := getLen(part)

      for {
        let intLenLoop := sub(intLen, 0x01)
      } gt(part, callvalue()) {
        intLenLoop := sub(intLenLoop, 0x01)
      } {
        mstore8(add(ptr, intLenLoop), add(mod(part, 0x0a), 0x30))
        part := div(part, 0x0a)
      }

      ptr := add(ptr, intLen)
      mstore8(ptr, 0x2e)
      intLen := add(intLen, 0x01)
      ptr := add(ptr, 0x01)

      part := and(convertValue, 0xffff)
      let fractLen := getLen(part)

      for {
        let fractLenLoop := sub(fractLen, 0x01)
      } gt(part, callvalue()) {
        fractLenLoop := sub(fractLenLoop, 0x01)
      } {
        mstore8(add(ptr, fractLenLoop), add(mod(part, 0x0a), 0x30))
        part := div(part, 0x0a)
      }
      ptr := add(ptr, fractLen)

      let oldPtr := mload(0x40)
      mstore(add(oldPtr, 0x20), add(fractLen, intLen))

      return(oldPtr, 0x60)

      function getLen(value) -> len {
        for {

        } gt(value, callvalue()) {
          value := div(value, 0x0a)
        } {
          len := add(len, 0x01)
        }
      }
    }
  }
}
