// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/FixMath.sol";

contract FixMathTest is Test {
    FixMath public fixMath;

    function setUp() public {
        fixMath = new FixMath(15);
    }

    function testAddUint() public view {
        console2.log(fixMath.fixAddUint("2.5", "0.555555"));
    }
}
