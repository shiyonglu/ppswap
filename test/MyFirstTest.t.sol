// commmand: forge test --match-test testFirstTest -vv

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";

contract MyFirstTest is Test {
    address deployer = makeAddr("deployer");
    address owner = makeAddr("owner");
    address victim1 = makeAddr("victim1");
    address victim2 = makeAddr("victim2");

    function setUp() public {
    }

    function testFirstTest() public view {
       console2.log("Congratulations, you first test passed!");

    }

}
