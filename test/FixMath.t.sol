// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {FixPointLib} from "../src/FixPointLib.sol";

contract FixMathTest is Test {
    using FixPointLib for uint256;
    using FixPointLib for int256;
    using FixPointLib for string;

    function test() external {}
}
