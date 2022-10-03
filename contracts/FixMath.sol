// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// TODO: overflows/underflows
contract FixMath {
  function fixAdd(string calldata a, string calldata b)
    external
    pure
    returns (string memory)
  {
    return toStr(toUint(a) + toUint(b));
  }

  function fixSub(string calldata a, string calldata b)
    external
    pure
    returns (string memory)
  {
    return toStr(toUint(a) - toUint(b));
  }

  function fixDiv(string calldata a, string calldata b)
    external
    pure
    returns (string memory)
  {
    (uint256 result, uint256 multiplier) = toUintMulDiv(b);
    return toStr((toUint(a) * 10**multiplier) / result);
  }

  function fixMul(string calldata a, string calldata b)
    external
    pure
    returns (string memory)
  {
    (uint256 result, uint256 multiplier) = toUintMulDiv(b);
    return toStr((toUint(a) / 10**multiplier) * result);
  }

  function toStr(uint256 convertValue)
    public
    pure
    returns (string memory result)
  {
    result = new string(0x41);
    assembly {
      let ptr := sub(mload(0x40), 0x60)

      let len := 0x00
      for {
        let value := convertValue
      } gt(value, 0x00) {
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
        } gt(cc, 0x00) {
          cc := sub(cc, 0x01)
          i := add(i, 0x01)
        } {
          mstore8(add(ptr, i), 0x30)
        }
      }

      for {
        let lenLoop := len
      } gt(convertValue, 0x00) {
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
      } gt(cc, 0x00) {

      } {
        switch shr(0xf8, mload(add(ptr, cc)))
        case 0x30 {
          len := sub(len, 0x01)
          cc := sub(cc, 0x01)
        }
        case 0x2e {
          len := sub(len, 0x01)
          cc := 0x00
        }
        default {
          cc := 0x00
        }
      }

      len := add(len, 0x01)
      mstore(result, len)
    }
  }

  function toUint(string memory str) public pure returns (uint256 result) {
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

      let pointExist := 0x00
      let counter := 0x00

      for {
        let lenLoop := strLen
      } gt(lenLoop, 0x00) {

      } {
        switch shr(0xf8, mload(add(ptr, lenLoop)))
        case 0x2e {
          pointExist := 0x01
          lenLoop := 0x00
        }
        default {
          lenLoop := sub(lenLoop, 0x01)
          counter := add(counter, 0x01)
        }
      }

      let point := 0x26
      let multiplier := 0x01

      if eq(pointExist, 0x00) {
        multiplier := exp(0x0a, point)
        counter := 0x00
      }

      if gt(counter, point) {
        strLen := sub(strLen, sub(counter, point))
      }

      if gt(point, counter) {
        multiplier := exp(0x0a, sub(point, counter))
      }

      if eq(strLen, 0x00) {
        result := add(
          result,
          mul(multiplier, sub(and(shr(0xf8, mload(ptr)), 0xff), 0x30))
        )
      }

      for {

      } gt(strLen, 0x00) {

      } {
        let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)
        switch value
        case 0x2e {
          strLen := sub(strLen, 0x01)

          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
        default {
          result := add(result, mul(multiplier, sub(value, 0x30)))
          multiplier := mul(multiplier, 0x0a)
          strLen := sub(strLen, 0x01)

          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
      }
    }
  }

  function toUintMulDiv(string memory str)
    public
    pure
    returns (uint256 result, uint256 counter)
  {
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

      let pointExist := 0x00
      counter := 0x00

      for {
        let lenLoop := strLen
      } gt(lenLoop, 0x00) {

      } {
        switch shr(0xf8, mload(add(ptr, lenLoop)))
        case 0x2e {
          pointExist := 0x01
          lenLoop := 0x00
        }
        default {
          lenLoop := sub(lenLoop, 0x01)
          counter := add(counter, 0x01)
        }
      }

      let multiplier := 0x01

      if eq(pointExist, 0x00) {
        counter := 0x01
      }

      if eq(strLen, 0x00) {
        result := add(result, sub(and(shr(0xf8, mload(ptr)), 0xff), 0x30))
      }

      for {

      } gt(strLen, 0x00) {

      } {
        let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)
        switch value
        case 0x2e {
          strLen := sub(strLen, 0x01)

          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
        default {
          result := add(result, mul(multiplier, sub(value, 0x30)))
          multiplier := mul(multiplier, 0x0a)
          strLen := sub(strLen, 0x01)

          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
      }
    }
  }
}
