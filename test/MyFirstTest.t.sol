// commmand: forge test --match-test testFirstTest -vv

// SPDX-License-Identifier: MIT
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
        // vm.createSelectFork(vm.envString("ETH_RPC_MAINNET"), 21061460);  // fork this block of ETH, 10/27/2024, where ETH_RPC_URL is the environment variable name
        // vm.createSelectFork(vm.rpcUrl("https://polygon-mainnet.g.alchemy.com/v2/kG1HifS-s10GWNUIhkZIwTmIZqe2tbD1"));
        // vm.createSelectFork(vm.rpcUrl("https://mainnet.infura.io/v3/95310f60af7b44bb8f3b13c043a00c8f"));
        
    }

    function testFirstTest() public {
       console2.log("Congratulations, you first test passed!");

       assertEq(owner, makeAddr("owner"));

    }

    function signMsgHash(bytes32 MsgHash, uint256 userPk) internal view returns (uint8 v, bytes32 r, bytes32 s)
    {
        // uint256 userPk = 0x12341234;
        // address user = vm.addr(userPk);

       return vm.sign(userPk, MsgHash);
    }

    function printBalances(address a, string memory desc) public{
        console2.log("\n ---------------------------------------------------------------------------------------");
        console2.log(desc);
        console2.log("ETH balance: ", a.balance);
        console2.log("---------------------------------------------------------------------------------------\n ");
    }


}
