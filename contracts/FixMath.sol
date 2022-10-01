// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FixMath {
  // how many digits to the right before the point
  uint256 public point;

  constructor(uint256 _point) {
    point = _point;
  }

  function fixAdd(string calldata a, string calldata b)
    external
    view
    returns (string memory)
  {
    return toStr(toUint(a) + toUint(b));
  }

  function toStr(uint256 convertValue)
    public
    view
    returns (string memory result)
  {
    result = new string(32);

    assembly {
      // result string
      let ptr := sub(mload(0x40), 0x20)

      // length of value
      let len := callvalue()
      for {
        let value := convertValue
      } gt(value, callvalue()) {
        value := div(value, 0x0a)
      } {
        len := add(len, 0x01)
      }

      let _point := sload(point.slot)

      if gt(_point, sub(len, 0x01)) {
        len := add(len, 0x02)
        mstore8(ptr, 0x30)
        mstore8(add(ptr, 0x01), 0x2e)
      }

      for {
        let lenLoop := len
      } gt(convertValue, callvalue()) {
        lenLoop := sub(lenLoop, 0x01)
      } {
        // if the maximum fractional part of the contract has reached -> point
        if eq(sub(len, lenLoop), _point) {
          mstore8(add(ptr, lenLoop), 0x2e)
          lenLoop := sub(lenLoop, 0x01)
        }

        mstore8(add(ptr, lenLoop), add(mod(convertValue, 0x0a), 0x30))
        convertValue := div(convertValue, 0x0a)
      }

      len := add(len, 0x01)

      mstore(result, len)
    }
  }

  function toUint(string memory str) public view returns (uint256 result) {
    assembly {
      // 0xvalue000000...00 -> 0x0000...00value
      let value := shr(mul(0x08, sub(0x20, mload(str))), mload(add(str, 0x20)))
      // counter if the fractional part of the value is less than or greater than the maximum fractional part of the contract
      let counter := callvalue()
      // flag if the fractional part (point) exists
      let pointExist := callvalue()

      for {
        let valueLoop := value
      } gt(valueLoop, callvalue()) {
        valueLoop := shr(0x08, valueLoop)
      } {
        if eq(and(valueLoop, 0xff), 0x2e) {
          valueLoop := callvalue()
          pointExist := add(pointExist, 0x01)
          counter := sub(counter, 0x01)
        }
        counter := add(counter, 0x01)
      }

      let _point := sload(point.slot)

      // if the fractional part (point) non-exists -> counter = 0x00
      if eq(pointExist, callvalue()) {
        counter := callvalue()
      }

      // if the counter greater than the max fract part -> value >> (counter - point)
      if gt(counter, _point) {
        for {
          let i := sub(counter, _point)
        } gt(i, callvalue()) {
          i := sub(i, 0x01)
        } {
          value := shr(0x08, value)
        }
      }

      // if the counter less than the max fract part -> (value << (point - counter)) | 0x30 (ascii 0)
      if gt(_point, counter) {
        for {
          let i := sub(_point, counter)
        } gt(i, callvalue()) {
          i := sub(i, 0x01)
        } {
          value := shl(0x08, value)
          value := or(value, 0x30)
        }
      }

      // result is the sum of all tenths of a number
      for {
        let i := 0x01
      } gt(value, callvalue()) {
        i := mul(i, 0x0a)
      } {
        if eq(and(value, 0xff), 0x2e) {
          value := shr(0x08, value)
        }

        result := add(result, mul(i, sub(and(value, 0xff), 0x30)))
        value := shr(0x08, value)
      }
    }
  }
}
