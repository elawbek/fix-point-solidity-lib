// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library FixPointLib {
    error UnsafeDotPosition(uint256 dot);
    error IncorrectStringLength(uint256 length, bool dotExists);
    error IncorrectIntegerPart(uint256 integerLength);

    /**
     * @notice unsafe convert decimal uint number to string
     * @dev
     * - the `dot` can have any value
     */
    function uintToStringUnsafe(
        uint256 convertValue,
        uint256 dot
    ) internal pure returns (string memory result) {
        result = _uintToString(convertValue, dot, 0);
    }

    /**
     * @notice convert decimal uint number to string
     * @dev
     * - max length of the returned `result` is 79 symbols (include dot)
     * - max `convertValue` value is type(uint256).max
     * - the `dot` value MUST be less than 78
     */
    function uintToString(
        uint256 convertValue,
        uint256 dot
    ) internal pure returns (string memory result) {
        assembly {
            if gt(dot, 0x4d) {
                // 0xbfb6d3c2 == bytes4(keccak256("UnsafeDotPosition(uint256)"))
                mstore(0x00, 0xbfb6d3c2)
                mstore(0x20, dot)

                revert(0x1c, 0x24)
            }
        }

        result = _uintToString(convertValue, dot, 0);
    }

    function _uintToString(
        uint256 convertValue,
        uint256 dot,
        uint256 minus
    ) private pure returns (string memory result) {
        assembly {
            // set the pointer value to the beginning of the string
            let ptr := add(result, 0x20)

            switch convertValue
            case 0 {
                mstore8(ptr, 0x30)
                mstore(result, 0x01)

                mstore(0x40, add(ptr, 0x20))
            }
            default {
                // a loop for calculating the length of a number in decimal places
                let len := minus
                for {
                    let value := convertValue
                } gt(value, 0x00) {
                    // each iteration divide the number by 0x0a (10)
                    value := div(value, 0x0a)
                } {
                    len := add(len, 0x01)
                }

                if iszero(lt(dot, sub(len, minus))) {
                    // put the zero
                    mstore8(add(ptr, minus), 0x30)
                    // put the dot
                    mstore8(add(ptr, add(0x01, minus)), 0x2e)
                    // put zeros after the dot before the significant numbers
                    for {
                        // position of the pointer after the dot
                        let i := add(0x02, minus)
                        // the difference to the numbers
                        let cc := sub(dot, sub(len, minus))
                        // string length update including zero, dot and zeros after the dot
                        len := add(len, add(0x01, cc))
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
                    let dotPosition := sub(lenLoop, dot)
                } gt(convertValue, 0x00) {
                    lenLoop := sub(lenLoop, 0x01)
                    convertValue := div(convertValue, 0x0a)
                } {
                    // put a dot if there is an integer part
                    if eq(dotPosition, lenLoop) {
                        mstore8(add(ptr, lenLoop), 0x2e)
                        lenLoop := sub(lenLoop, 0x01)
                    }

                    // write down the value of each tenth of a number one by one
                    mstore8(
                        add(ptr, lenLoop),
                        add(mod(convertValue, 0x0a), 0x30)
                    )
                }

                // truncate zeros without weight
                for {
                    let lenLoop := len
                } gt(lenLoop, 0x00) {

                } {
                    // pull the current value from the end of the line
                    switch shr(0xf8, mload(add(ptr, lenLoop)))
                    // if it is 0, then decrease the length by 1
                    case 0x30 {
                        len := sub(len, 0x01)
                        lenLoop := sub(lenLoop, 0x01)
                    }
                    // if dot, same then break loop
                    case 0x2e {
                        len := sub(len, 0x01)
                        break
                    }
                    // otherwise break
                    default {
                        break
                    }
                }

                // increase the length value by 1, so that the whole string is returned as a result
                len := add(len, 0x01)
                // write the correct length value
                mstore(result, len)

                mstore(0x40, add(ptr, len))
            }
        }
    }

    function stringToUint(
        string memory str,
        uint256 dot
    ) internal pure returns (uint256 result) {
        result = _convertFromString(str, dot, 0);
    }

    /**
     * @notice convert string to uint number, considering the dot
     *
     * @dev
     * - min safe string:
     *      "1.15792089237316195423570985008687907853269984665640564039457584007913129639935"
     * - max safe string:
     *      "115792089237316195423570985008687907853269984665640564039457584007913129639935"
     * - revert if interger part of number > (77 - dotPosition)
     */
    function _convertFromString(
        string memory str,
        uint256 dot,
        uint toInt
    ) private pure returns (uint256 result) {
        assembly {
            let minus := and(toInt, 0x01)
            toInt := shr(0x01, toInt)

            if gt(dot, sub(0x4d, toInt)) {
                // 0xbfb6d3c2 == bytes4(keccak256("UnsafeDotPosition(uint256)"))
                mstore(0x00, 0xbfb6d3c2)
                mstore(0x20, dot)

                revert(0x1c, 0x24)
            }

            // length for the pointer (-1 because the length is stored from 1 to N, and we need 0 to N-1)
            let strLen := sub(mload(str), add(0x01, minus))
            // so that in all loops each iteration does not execute shr(0xf8, value)
            let ptr := add(str, add(0x01, minus))

            // flag if a dot exists
            let dotExists
            let counter

            // count to a dot in the string
            for {
                let lenLoop := strLen
            } gt(lenLoop, 0x00) {

            } {
                switch and(mload(add(ptr, lenLoop)), 0xff)
                // if dot -> break
                case 0x2e {
                    dotExists := 0x01
                    break
                }
                default {
                    lenLoop := sub(lenLoop, 0x01)
                    counter := add(counter, 0x01)
                }
            }

            // trim zeros off the front
            let lengthHelper := add(strLen, 0x01)
            for {
                let lenLoop
                let c
            } lt(lenLoop, lengthHelper) {
                lenLoop := add(lenLoop, 0x01)
            } {
                switch and(mload(add(ptr, lenLoop)), 0xff)
                case 0x30 {
                    c := add(c, 0x01)
                    continue
                }
                case 0x2e {
                    c := sub(c, 0x01)
                    strLen := sub(strLen, c)
                    ptr := add(ptr, c)
                    break
                }
                default {
                    strLen := sub(strLen, c)
                    ptr := add(ptr, c)

                    break
                }
            }

            // a multiplier to convert the string to a number
            let multiplier := 0x01

            // if there is no dot, then increase the multiplier immediately to an integer part of the number
            if iszero(dotExists) {
                multiplier := exp(0x0a, dot)
                // not to fall into the following condition
                counter := 0x00
            }

            // if the number of characters before the point is greater than the maximum, trim the length so as not to take unnecessary
            if gt(counter, dot) {
                strLen := sub(strLen, sub(counter, dot))
                counter := dot
            }

            lengthHelper := add(strLen, 0x01)
            // ((len > 79) && dotExists) || ((len > 78) && !dotExists)
            if or(
                and(gt(lengthHelper, sub(0x4f, toInt)), dotExists),
                and(gt(lengthHelper, sub(0x4e, toInt)), iszero(dotExists))
            ) {
                // 0x81607476 == bytes4(keccak256("IncorrectStringLength(uint256,bool)"))
                mstore(0x00, 0x81607476)
                mstore(0x20, lengthHelper)
                mstore(0x40, dotExists)

                revert(0x1c, 0x44)
            }

            // if interger part of number gt 78 - dotPosition -> revert
            if gt(
                sub(lengthHelper, counter),
                sub(add(sub(0x4e, toInt), dotExists), dot)
            ) {
                // 0x8a94c678 == bytes4(keccak256("IncorrectIntegerPart()"))
                mstore(0x00, 0x4f885930)
                mstore(0x20, sub(lengthHelper, counter))
                revert(0x1c, 0x24)
            }

            // if it does not reach the maximum length, increase the multiplier to the first significant value of the number
            if and(gt(dot, counter), dotExists) {
                multiplier := exp(0x0a, sub(dot, counter))
            }

            let overflowHelper
            let lastDigit

            // if the length for the pointer is immediately 0, it won't get into the loop, so we have to calc a single value
            if iszero(strLen) {
                lastDigit := sub(and(mload(ptr), 0xff), 0x30)

                overflowHelper := mul(multiplier, lastDigit)

                result := add(result, overflowHelper)
            }

            for {
                let len := strLen
            } gt(len, 0x00) {

            } {
                // each iteration we pull the value
                let value := and(mload(add(ptr, len)), 0xff)

                switch value
                // if dot
                case 0x2e {
                    // decrease length
                    len := sub(len, 0x01)

                    // if the length is 0, count the last digit of the string
                    if iszero(len) {
                        lastDigit := sub(and(mload(ptr), 0xff), 0x30)

                        overflowHelper := mul(multiplier, lastDigit)
                        result := add(result, overflowHelper)
                    }
                }
                // otherwise
                default {
                    result := add(result, mul(multiplier, sub(value, 0x30)))
                    // change the decimal point to 1 to the left
                    multiplier := mul(multiplier, 0x0a)
                    len := sub(len, 0x01)

                    // if the length is 0, count the last digit of the string
                    if iszero(len) {
                        lastDigit := sub(and(mload(ptr), 0xff), 0x30)

                        overflowHelper := mul(multiplier, lastDigit)
                        result := add(result, overflowHelper)
                    }
                }
            }

            if iszero(lastDigit) {
                // avoid division zero
                lastDigit := 0x01
                multiplier := 0x00
            }

            let overflow := or(
                iszero(eq(multiplier, div(overflowHelper, lastDigit))),
                lt(result, overflowHelper)
            )

            switch minus
            case 0x00 {
                if overflow {
                    switch toInt
                    case 0x00 {
                        result := not(0x00)
                    }
                    default {
                        result := shr(0x01, not(0x00))
                    }
                }
            }
            default {
                result := not(sub(result, 0x01))

                if overflow {
                    result := shl(0xff, 0x01)
                }
            }
        }
    }

    /**
     * @notice unsafe convert decimal int number to string
     * @dev
     * - the `dot` can have any value
     */
    function intToStringUnsafe(
        int256 convertValue,
        uint256 dot
    ) internal pure returns (string memory result) {
        result = _intToString(convertValue, dot);
    }

    /**
     * @notice convert decimal int number to string
     * @dev
     * - max length of the returned string - 79 symbols (include dot and sign)
     * - max int value - type(int256).max
     * - min int value - type(int256).min
     * - dot value MUST be less than 77
     */
    function intToString(
        int256 convertValue,
        uint256 dot
    ) internal pure returns (string memory result) {
        assembly {
            if gt(dot, 0x4c) {
                // 0xbfb6d3c2 == bytes4(keccak256("UnsafeDotPosition(uint256)"))
                mstore(0x00, 0xbfb6d3c2)
                mstore(0x20, dot)

                revert(0x1c, 0x24)
            }
        }

        result = _intToString(convertValue, dot);
    }

    function _intToString(
        int256 convertValue,
        uint256 dot
    ) private pure returns (string memory result) {
        uint value;
        uint minus;
        assembly {
            // check for sign
            if shr(0xff, convertValue) {
                convertValue := add(not(convertValue), 0x01)
                // len := 0x01

                mstore8(add(result, 0x20), 0x2d) // "-"
                minus := 0x01
            }
            value := convertValue
        }

        result = _uintToString(value, dot, minus);
    }

    /**
     * @notice convert string to int, considering the dot
     *
     * @dev
     * - max length of string - 78 symbols
     * - max int value - type(int256).max
     * - revert if interger part of number > (76 - dotPosition)
     */
    function stringToInt(
        string memory str,
        uint256 dot
    ) internal pure returns (int256 result) {
        // 0b10
        uint toInt = 2;
        assembly {
            if eq(and(mload(add(str, 0x01)), 0xff), 0x2d) {
                // 0b11
                toInt := add(toInt, 0x01)
            }
        }

        result = int(_convertFromString(str, dot, toInt));
    }
}
