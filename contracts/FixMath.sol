// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FixMath {
  uint256 public point;

  constructor(uint256 _point) {
    point = _point;
  }

  function fixAdd(string calldata a, string calldata b)
    external
    view
    returns (string memory)
  {
    // uint256 _a = toUint(a);
    // uint256 _b = toUint(b);

    return toStr(toUint(a) + toUint(b));
  }

  function toStr(uint256 convertValue) public view returns (string memory) {
    assembly {
      let ptr := mload(0x40)
      mstore(ptr, 0x20)
      ptr := add(ptr, 0x40)

      let len := callvalue()
      let value := convertValue
      for {

      } gt(value, callvalue()) {
        value := div(value, 0x0a)
      } {
        len := add(len, 0x01)
      }

      let _point := sload(point.slot)

      for {
        let lenLoop := len
      } gt(convertValue, callvalue()) {
        lenLoop := sub(lenLoop, 0x01)
      } {
        if eq(sub(len, lenLoop), _point) {
          mstore8(add(ptr, lenLoop), 0x2e)
          lenLoop := sub(lenLoop, 0x01)
        }

        mstore8(add(ptr, lenLoop), add(mod(convertValue, 0x0a), 0x30))
        convertValue := div(convertValue, 0x0a)
      }

      len := add(len, 0x01)
      ptr := add(ptr, len)

      let oldPtr := mload(0x40)
      mstore(add(oldPtr, 0x20), len)

      return(oldPtr, 0x60)
    }
  }

  function toUint(string memory str) public view returns (uint256 result) {
    assembly {
      // let result := callvalue()
      let value := mload(add(str, 0x20))

      value := shr(mul(0x08, sub(0x20, mload(str))), value)

      for {
        let i := callvalue()
      } gt(value, callvalue()) {
        i := add(i, 0x01)
      } {
        if eq(and(value, 0xff), 0x2e) {
          value := shr(0x08, value)
        }

        result := add(result, mul(exp(0x0a, i), sub(and(value, 0xff), 0x30)))
        value := shr(0x08, value)
      }

      // mstore(callvalue(), result)
      // return(callvalue(), 0x20)
    }
  }
}
