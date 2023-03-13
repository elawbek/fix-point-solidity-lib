// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {FixPointLib} from "src/FixPointLib.sol";

contract FixMathTest is Test {
    using FixPointLib for uint;
    using FixPointLib for string;

    function test() external view {
        // uint256 a = 1;
        // console2.log(a);
        // console2.log(a.uintToString(15));
        // console2.log(a.uintToStringUnsafe(120));

        string memory b = "6666666666666666666666666666";
        console2.log(b.stringToUint(18));

        // int256 c = 123;
        // console2.logString(c.toStrInt(12));
        // c = -2312312312;
        // console2.logString(c.toStrInt(12));
    }
}
