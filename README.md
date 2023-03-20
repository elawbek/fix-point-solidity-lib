## Fix point solidity library

### Solidity library for converting uint256/int256 numbers to string and vice versa.

### Very convenient for running tests in foundry.

## Install

run the install:

```
forge install elawbek/fix-point-solidity-lib
```

then, add this to your `remappings.txt` file:

```
fp/lib/=lib/fix-point-solidity-lib/src/
```

## Usage

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {FixPointLib} from "fp/lib/FixPointLib.sol";

contract FixMathTest is Test {
    using FixPointLib for uint256;
    using FixPointLib for int256;
    using FixPointLib for string;

    function testUint() external {
        string memory str = "0.123";

        console2.log("String initial value: %s", str);

        uint256 value = str.stringToUint(18);
        console2.log("Converted initial value to uint256: %s", value);

        value += 1e18;
        str = value.uintToString(18);
        console2.log("String value after change: %s", str);
    }

    function testInt() external {
        string memory str = "-42.00320100";

        console2.log("String initial value: %s", str);

        int256 value = str.stringToInt(18);

        console2.log("Converted initial value to int256: %s", value);

        value -= 1e18;
        str = value.intToString(18);
        console2.log("String value after change: %s", str);
    }
}
```

after running the command

```
forge test --mp test/FixMathTest.sol -vvv
```

you will see

```
[PASS] testInt() (gas: 14407)
Logs:
  String initial value: -42.00320100
  Converted initial value to uint256: -42003201000000000000
  String value after change: -43.003201

[PASS] testUint() (gas: 12948)
Logs:
  String initial value: 0.123
  Converted initial value to uint256: 123000000000000000
  String value after change: 1.123

```
