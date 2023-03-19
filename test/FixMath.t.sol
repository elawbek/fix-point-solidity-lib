// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {FixPointLib} from "src/FixPointLib.sol";

contract FixMathTest is Test {
    using FixPointLib for uint;
    using FixPointLib for int;
    using FixPointLib for string;

    function test() external {
        // uint256 a = type(uint).max;
        // console2.log(a.uintToString(77));
        // console2.log(a.uintToStringUnsafe(120));

        string memory b = "-10";
        console2.log(b.stringToInt(15));

        // int c = 1000;
        // for (uint i; i < 1001; ++i) {
        // vm.writeLine("output.txt", c.intToString(5));
        // vm.writeLine("output.txt", c.intToStringUnsafe(120));
        // ++c;
        // }
        // c = -100;
        // for (uint i; i < 1000; ++i) {
        //     // vm.writeLine("output.txt", c.intToString(5));
        //     // vm.writeLine("output.txt", c.intToStringUnsafe(120));
        //     // console2.logString(StdStyle.green(c.intToString(15)));
        //     // console2.logString(StdStyle.yellow(c.intToStringUnsafe(120)));
        //     --c;
        // }
    }
}
