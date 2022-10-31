// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// TODO: overflows/underflows
// TODO: int math
contract FixMath {
  uint256 public dotPosition;
  uint256 public one;

  constructor(uint256 _dotPosition) {
    dotPosition = _dotPosition;
    one = 10 * 10**_dotPosition;
  }

  function fixAdd(string calldata a, string calldata b)
    external
    view
    returns (string memory)
  {
    return toStr(toUint(a) + toUint(b));
  }

  function fixSub(string calldata a, string calldata b)
    external
    view
    returns (string memory)
  {
    return toStr(toUint(a) - toUint(b));
  }

  function fixDiv(string calldata a, string calldata b)
    external
    view
    returns (string memory)
  {
    (uint256 result, uint256 multiplier) = toUintMulDiv(b);
    return toStr((toUint(a) * multiplier) / result);
  }

  function fixMul(string calldata a, string calldata b)
    external
    view
    returns (string memory)
  {
    (uint256 result, uint256 multiplier) = toUintMulDiv(b);
    return toStr((toUint(a) * result) / multiplier);
  }

  /**
   * @notice convert decimal uint number to string
   *
   * @dev
   * - max length of string - 78 symbols
   * - max uint value - type(uint256).max
   */
  function toStr(uint256 convertValue)
    public
    view
    returns (string memory result)
  {
    // allocate 0x60 (96) bytes to the future line
    result = new string(0x41);

    assembly {
      // set the pointer value to the beginning of the string
      let ptr := sub(mload(0x40), 0x60)

      // a loop for calculating the length of a number in decimal places
      let len := 0x00
      for {
        let value := convertValue
      } gt(value, 0x00) {
        // each iteration divide the number by 0x0a (10)
        value := div(value, 0x0a)
      } {
        len := add(len, 0x01)
      }

      // load from the storage the maximum value of decimal places in the decimal representation of the number
      let dot := sload(dotPosition.slot)

      // the condition that there is no integer part of the number
      if gt(dot, len) {
        // put a zero as first symbol of the string
        mstore8(ptr, 0x30)
        // put a dot as second symbol of the string
        mstore8(add(ptr, 0x01), 0x2e)

        // put zeros after the dot before the significant numbers
        for {
          // the difference to the numbers
          let cc := sub(dot, len)
          // position of the pointer after the dot
          let i := 0x02
          // string length update including zero, dot and zeros after the dot
          len := add(len, add(i, cc))
        } gt(cc, 0x00) {
          cc := sub(cc, 0x01)
          i := add(i, 0x01)
        } {
          mstore8(add(ptr, i), 0x30)
        }
      }

      // put numbers to string
      for {
        let lenLoop := len
      } gt(convertValue, 0x00) {
        lenLoop := sub(lenLoop, 0x01)
      } {
        // put a dot if there is an integer part
        if eq(sub(len, lenLoop), dot) {
          mstore8(add(ptr, lenLoop), 0x2e)
          lenLoop := sub(lenLoop, 0x01)
        }

        // write down the value of each tenth of a number one by one
        mstore8(add(ptr, lenLoop), add(mod(convertValue, 0x0a), 0x30))
        convertValue := div(convertValue, 0x0a)
      }

      // truncate zeros without weight
      for {
        let cc := len
      } gt(cc, 0x00) {

      } {
        // pull the current value from the end of the line
        switch shr(0xf8, mload(add(ptr, cc)))
        // if it is 0, then decrease the length by 1
        case 0x30 {
          len := sub(len, 0x01)
          cc := sub(cc, 0x01)
        }
        // if dot, same thing
        case 0x2e {
          len := sub(len, 0x01)
          cc := 0x00
        }
        // otherwise break
        default {
          cc := 0x00
        }
      }

      // increase the length value by 1, so that the whole string is returned as a result
      len := add(len, 0x01)
      // write the correct length value
      mstore(result, len)
    }
  }

  /**
   * @notice convert string to decimal number, considering the dot
   *
   * @dev
   * - max length of string - 78 symbols
   * - max uint value - type(uint256).max
   * - revert if interger part of number > (77 - dotPosition)
   */
  function toUint(string calldata _str) public view returns (uint256 result) {
    string memory str = _str;

    assembly {
      // length for the pointer (-1 because the length is stored from 1 to N, and we need 0 to N-1)
      let strLen := sub(mload(str), 0x01)
      let ptr := mload(0x40)

      // choose pointer if string length is 0x20 (32), 0x40 (64) or 0x60 (96) bytes
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

      // flag if a dot exists
      let dotExist := 0x00
      let counter := 0x00

      // count to a dot in the string
      for {
        let lenLoop := strLen
      } gt(lenLoop, 0x00) {

      } {
        switch shr(0xf8, mload(add(ptr, lenLoop)))
        // if dot -> break
        case 0x2e {
          dotExist := 0x01
          lenLoop := 0x00
        }
        default {
          lenLoop := sub(lenLoop, 0x01)
          counter := add(counter, 0x01)
        }
      }

      let dot := sload(dotPosition.slot)

      // a multiplier to convert the string to a number
      let multiplier := 0x01

      // if there is no dot, then increase the multiplier immediately to an integer part of the number
      if eq(dotExist, 0x00) {
        multiplier := exp(0x0a, dot)
        // not to fall into the following condition
        counter := 0x00
      }

      // if the number of characters before the point is greater than the maximum, trim the length so as not to take unnecessary
      if gt(counter, dot) {
        strLen := sub(strLen, sub(counter, dot))
        counter := dot
      }

      // revert if interger part of number > (77 - dotPosition)
      if gt(sub(strLen, counter), sub(0x4d, dot)) {
        mstore(0x00, shl(0xe0, 0x08c379a0))
        mstore(0x04, 0x20)
        mstore(0x24, 0x08)
        // overflow
        mstore(0x44, shl(0xc0, 0x6f766572666c6f77))
        revert(0x00, 0x64)
      }

      // if it does not reach the maximum length, increase the multiplier to the first significant value of the number
      if and(gt(dot, counter), eq(dotExist, 0x01)) {
        multiplier := exp(0x0a, sub(dot, counter))
      }

      // if the length for the pointer is immediately 0, it won't get into the loop, so we have to calc a single value
      if eq(strLen, 0x00) {
        result := add(
          result,
          mul(multiplier, sub(and(shr(0xf8, mload(ptr)), 0xff), 0x30))
        )
      }

      for {

      } gt(strLen, 0x00) {

      } {
        // each iteration we pull the value
        let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)

        switch value
        // if dot
        case 0x2e {
          // decrease length
          strLen := sub(strLen, 0x01)

          // if the length is 0, count the last digit of the string
          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
        // otherwise
        default {
          // plus what's needed
          result := add(result, mul(multiplier, sub(value, 0x30)))
          // change the decimal point to 1 to the left
          multiplier := mul(multiplier, 0x0a)
          strLen := sub(strLen, 0x01)

          // if the length is 0, count the last digit of the string
          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplier, sub(value, 0x30)))
          }
        }
      }
    }
  }

  /**
   * @notice convert string to decimal number for mul/div, considering the dot
   *
   * @dev
   * - revert if the fractional part of the number is greater in length than the maximum
   */
  function toUintMulDiv(string calldata _str)
    public
    view
    returns (uint256 result, uint256 multiplier)
  {
    string memory str = _str;

    assembly {
      // length for the pointer (-1 because the length is stored from 1 to N, and we need 0 to N-1)
      let strLen := sub(mload(str), 0x01)
      let ptr := mload(0x40)

      // choose pointer if string length is 0x20 (32), 0x40 (64) or 0x60 (96) bytes
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

      // flag if a dot exists
      let dotExist := 0x00

      // for multiplication/division, if there is a fractional part
      // in the second multiplier/divisor, we must divide/multiply
      // the first multiplier/divisor by some multiplier
      multiplier := 0x01

      let counterToDot := 0x00

      // count to a dot in the string
      for {
        let lenLoop := strLen
      } gt(lenLoop, 0x00) {

      } {
        switch shr(0xf8, mload(add(ptr, lenLoop)))
        case 0x2e {
          // if dot -> break
          dotExist := 0x01
          lenLoop := 0x00
        }
        default {
          lenLoop := sub(lenLoop, 0x01)
          multiplier := mul(multiplier, 0x0a)
          counterToDot := add(counterToDot, 0x01)
        }
      }

      // if there is no dot, then the multiplier is unnecessary, make it one
      if eq(dotExist, 0x00) {
        multiplier := 0x01
      }

      let dot := sload(dotPosition.slot)

      // revert if the fractional part of the number is greater in length than the maximum
      if gt(counterToDot, dot) {
        revert(0x00, 0x00)
      }

      // if the length for the pointer is immediately 0, it won't get into the loop, so we have to calc a single value
      if eq(strLen, 0x00) {
        result := add(result, sub(and(shr(0xf8, mload(ptr)), 0xff), 0x30))
      }

      // a multiplier to convert the string to a number
      let multiplierForNumber := 0x01

      for {

      } gt(strLen, 0x00) {

      } {
        // each iteration we pull the value
        let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)
        switch value
        // if dot
        case 0x2e {
          // decrease length
          strLen := sub(strLen, 0x01)

          // if the length is 0, count the last digit of the string
          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplierForNumber, sub(value, 0x30)))
          }
        }
        // otherwise
        default {
          // plus what's needed
          result := add(result, mul(multiplierForNumber, sub(value, 0x30)))
          // change the decimal point to 1 to the left
          multiplierForNumber := mul(multiplierForNumber, 0x0a)
          strLen := sub(strLen, 0x01)

          // if the length is 0, count the last digit of the string
          if eq(strLen, 0x00) {
            value := and(shr(0xf8, mload(ptr)), 0xff)
            result := add(result, mul(multiplierForNumber, sub(value, 0x30)))
          }
        }
      }
    }
  }

  /**
   * @notice convert string to int256 decimal number, considering the dot
   *
   * @dev
   * - max length of string - 78 symbols
   * - max uint value - type(int256).max
   * - revert if interger part of number > (76 - dotPosition)
   */
  function toInt(string calldata _str) public view returns (int256 result) {
    string memory str = _str;

    assembly {
      // length for the pointer (-2 because the length is stored from 1 to N, and we need 0 to N-1, excluded sign)
      let strLen := sub(mload(str), 0x02)
      let ptr := mload(0x40)

      // choose pointer if string length is 0x20 (32), 0x40 (64) or 0x60 (96) bytes
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

      // flag if a minus exists
      let minus := 0x00
      //2d
      if eq(shr(0xf8, mload(ptr)), 0x2d) {
        minus := 0x01
      }
      ptr := add(ptr, 0x01)

      // flag if a dot exists
      let dotExist := 0x00
      let counter := 0x00

      // count to a dot in the string
      for {
        let lenLoop := strLen
      } gt(lenLoop, 0x00) {

      } {
        switch shr(0xf8, mload(add(ptr, lenLoop)))
        // if dot -> break
        case 0x2e {
          dotExist := 0x01
          lenLoop := 0x00
        }
        default {
          lenLoop := sub(lenLoop, 0x01)
          counter := add(counter, 0x01)
        }
      }

      let dot := sload(dotPosition.slot)

      // a multiplier to convert the string to a number
      let multiplier := 0x01

      // if there is no dot, then increase the multiplier immediately to an integer part of the number
      if eq(dotExist, 0x00) {
        multiplier := exp(0x0a, dot)
        // not to fall into the following condition
        counter := 0x00
      }

      // if the number of characters before the point is greater than the maximum, trim the length so as not to take unnecessary
      if gt(counter, dot) {
        strLen := sub(strLen, sub(counter, dot))
        counter := dot
      }

      // revert if interger part of number > (76 - dotPosition)
      if gt(sub(strLen, counter), sub(0x4c, dot)) {
        mstore(0x00, shl(0xe0, 0x08c379a0))
        mstore(0x04, 0x20)
        mstore(0x24, 0x08)
        // overflow
        mstore(0x44, shl(0xc0, 0x6f766572666c6f77))
        revert(0x00, 0x64)
      }

      // if it does not reach the maximum length, increase the multiplier to the first significant value of the number
      if and(gt(dot, counter), eq(dotExist, 0x01)) {
        multiplier := exp(0x0a, sub(dot, counter))
      }

      switch minus
      case 0x00 {
        // if the length for the pointer is immediately 0, it won't get into the loop, so we have to calc a single value
        if eq(strLen, 0x00) {
          result := add(
            result,
            mul(multiplier, sub(and(shr(0xf8, mload(ptr)), 0xff), 0x30))
          )
        }

        for {

        } gt(strLen, 0x00) {

        } {
          // each iteration we pull the value
          let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)

          switch value
          // if dot
          case 0x2e {
            // decrease length
            strLen := sub(strLen, 0x01)

            // if the length is 0, count the last digit of the string
            if eq(strLen, 0x00) {
              value := and(shr(0xf8, mload(ptr)), 0xff)
              result := add(result, mul(multiplier, sub(value, 0x30)))
            }
          }
          // otherwise
          default {
            // plus what's needed
            result := add(result, mul(multiplier, sub(value, 0x30)))
            // change the decimal point to 1 to the left
            multiplier := mul(multiplier, 0x0a)
            strLen := sub(strLen, 0x01)

            // if the length is 0, count the last digit of the string
            if eq(strLen, 0x00) {
              value := and(shr(0xf8, mload(ptr)), 0xff)
              result := add(result, mul(multiplier, sub(value, 0x30)))
            }
          }
        }
      }
      default {
        // result := sub(0x00, multiplier)

        // if the length for the pointer is immediately 0, it won't get into the loop, so we have to calc a single value
        if eq(strLen, 0x00) {
          result := sub(
            result,
            mul(multiplier, sub(and(shr(0xf8, mload(ptr)), 0xff), 0x30))
          )
        }

        for {

        } gt(strLen, 0x00) {

        } {
          // each iteration we pull the value
          let value := and(shr(0xf8, mload(add(ptr, strLen))), 0xff)

          switch value
          // if dot
          case 0x2e {
            // decrease length
            strLen := sub(strLen, 0x01)

            // if the length is 0, count the last digit of the string
            if eq(strLen, 0x00) {
              value := and(shr(0xf8, mload(ptr)), 0xff)
              result := sub(result, mul(multiplier, sub(value, 0x30)))
            }
          }
          // otherwise
          default {
            // plus what's needed
            result := sub(result, mul(multiplier, sub(value, 0x30)))
            // change the decimal point to 1 to the left
            multiplier := mul(multiplier, 0x0a)
            strLen := sub(strLen, 0x01)

            // if the length is 0, count the last digit of the string
            if eq(strLen, 0x00) {
              value := and(shr(0xf8, mload(ptr)), 0xff)
              result := sub(result, mul(multiplier, sub(value, 0x30)))
            }
          }
        }
      }
    }
  }
}
