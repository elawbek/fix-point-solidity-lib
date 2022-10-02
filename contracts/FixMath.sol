// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FixMath {
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
    result = new string(0x41);
    assembly {
      let ptr := sub(mload(0x40), 0x60)

      let len := callvalue()
      for {
        let value := convertValue
      } gt(value, callvalue()) {
        value := div(value, 0x0a)
      } {
        len := add(len, 0x01)
      }

      let point := 0x26

      if gt(point, sub(len, 0x01)) {
        mstore8(ptr, 0x30)
        mstore8(add(ptr, 0x01), 0x2e)

        for {
          let cc := sub(point, len)
          let i := 0x02
          len := add(len, add(i, cc))
        } gt(cc, callvalue()) {
          cc := sub(cc, 0x01)
          i := add(i, 0x01)
        } {
          mstore8(add(ptr, i), 0x30)
        }
      }

      for {
        let lenLoop := len
      } gt(convertValue, callvalue()) {
        lenLoop := sub(lenLoop, 0x01)
      } {
        if eq(sub(len, lenLoop), point) {
          mstore8(add(ptr, lenLoop), 0x2e)
          lenLoop := sub(lenLoop, 0x01)
        }

        mstore8(add(ptr, lenLoop), add(mod(convertValue, 0x0a), 0x30))
        convertValue := div(convertValue, 0x0a)
      }

      for {
        let cc := len
      } gt(cc, callvalue()) {

      } {
        switch shr(0xf8, mload(add(ptr, cc)))
        case 0x30 {
          len := sub(len, 0x01)
          cc := sub(cc, 0x01)
        }
        default {
          cc := callvalue()
        }
      }

      len := add(len, 0x01)
      mstore(result, len)
    }
  }

  function toUint(string memory str) public view returns (uint256 result) {
    assembly {
      let strLen := sub(mload(str), 0x01)
      let ptr := mload(0x40)

      switch div(strLen, 0x20)
      case 0x00 {
        ptr := sub(ptr, 0x20)
      }
      case 0x01 {
        ptr := sub(ptr, 0x40)
      }
      default {
        ptr := sub(ptr, 0x60)
      }

      let pointExist := callvalue()
      let counter := callvalue()

      for {
        let lenLoop := strLen
      } gt(lenLoop, callvalue()) {

      } {
        switch shr(0xf8, mload(add(ptr, lenLoop)))
        case 0x2e {
          pointExist := 0x01
          lenLoop := callvalue()
        }
        default {
          lenLoop := sub(lenLoop, 0x01)
          counter := add(counter, 0x01)
        }
      }

      let point := 0x26
      let multiplier := 0x01

      if eq(pointExist, callvalue()) {
        multiplier := exp(0x0a, point)
        counter := callvalue()
      }

      if gt(counter, point) {
        strLen := sub(strLen, sub(counter, point))
      }

      if gt(point, counter) {
        multiplier := exp(0x0a, sub(point, counter))
      }

      for {

      } gt(strLen, callvalue()) {

      } {
        let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)
        switch value
        case 0x2e {
          strLen := sub(strLen, 0x01)

          if eq(strLen, callvalue()) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
        default {
          result := add(result, mul(multiplier, sub(value, 0x30)))
          multiplier := mul(multiplier, 0x0a)
          strLen := sub(strLen, 0x01)

          if eq(strLen, callvalue()) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
      }
    }
  }
}
