// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {FixPointLib} from "src/FixPointLib.sol";

contract FixMathTest is Test {
    using FixPointLib for *;

    function test() external {
        uint256 a = type(uint256).max;

        console2.log(a.toStrUint(0));

        string memory b = "0";

        console2.log(b.toUint(15));
    }
}
