// commmand: forge test --match-test testFirstTest -vv

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyFirstTest is Test {
    address deployer = makeAddr("deployer");
    address owner = makeAddr("owner");
    address victim1 = makeAddr("victim1");
    address victim2 = makeAddr("victim2");

    function setUp() public {
        // need to fork
        // vm.createSelectFork(vm.rpcUrl("https://polygon-mainnet.g.alchemy.com/v2/kG1HifS-s10GWNUIhkZIwTmIZqe2tbD1"));
        // vm.createSelectFork(vm.rpcUrl("https://mainnet.infura.io/v3/95310f60af7b44bb8f3b13c043a00c8f"));
        
    }

    function testFirstTest() public {
       console2.log("Congratulations, you first test passed!");

       assertEq(owner, makeAddr("owner"));

    }

}
