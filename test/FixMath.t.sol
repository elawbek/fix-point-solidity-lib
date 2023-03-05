// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {FixPointLib} from "src/FixPointLib.sol";

contract FixMathTest is Test {
    using FixPointLib for *;

    function test() external {
        // uint256 a = 12121;
        // console2.log(a.toStrUint(0));
        string
            memory b = "115792089237316195423570985008687907853269984665640564039457584007913129639936";
        console2.log(b.toUint(0));
        // int256 a = 123;
        // console2.logString(a.toStrInt(12));
        // a = -2312312312;
        // console2.logString(a.toStrInt(12));
    }
}
