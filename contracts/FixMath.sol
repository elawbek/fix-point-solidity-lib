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

      let _point := 0x26

      if gt(_point, len) {
        mstore8(ptr, 0x30)
        mstore8(add(ptr, 0x01), 0x2e)

        for {
          let cc := sub(_point, len)
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
      let value := shr(mul(0x08, sub(0x20, mload(str))), mload(add(str, 0x20)))
      let counter := callvalue()
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

      let _point := 0x26

      if eq(pointExist, callvalue()) {
        counter := callvalue()
      }

      if gt(counter, _point) {
        for {
          let i := sub(counter, _point)
        } gt(i, callvalue()) {
          i := sub(i, 0x01)
        } {
          value := shr(0x08, value)
        }
      }

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
