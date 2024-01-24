// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {EName} from "../src/EName.sol";

contract CounterTest is Test {
    EName eName;
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address user5 = makeAddr("user5");
    address user6 = makeAddr("user6");
    address user7 = makeAddr("user7");
    
    function setUp() public {
        vm.startPrank(deployer);
        eName = new EName();
        eName.transfer(address(eName), 1_000_000 ether);
        vm.stopPrank();

        deal(user1, 10 ether);
        deal(user2, 10 ether);
        deal(user3, 10 ether);
        deal(user4, 10 ether);
        deal(user5, 10 ether);
        deal(user6, 10 ether);
        deal(user7, 10 ether);
    }

    function testRegister() public {
        console2.log("totalSupply: ", eName.totalSupply());
        console2.log("reserve balance: ", eName.balanceOf(address(eName)));
        console2.log("deployer balance: ", eName.balanceOf(deployer));
        
        vm.prank(user1);
        eName.register{value: 0.1 ether}("user1.e");

        vm.prank(user2);
        eName.register{value: 0.1 ether}("user2.e");
        
        vm.prank(user3);
        eName.register{value: 0.1 ether}("user3.e");

        console2.log("user1 ename: ", eName.ename(user1));
        console2.log("eaddress: ", eName.eaddress("user1.e"));
        
        console2.log("user2 ename: ", eName.ename(user2));
        console2.log("eaddress o fuser2.e: ", eName.eaddress("user2.e"));

        console2.log("user3 ename: ", eName.ename(user3));
        console2.log("eaddress of usre3.e: ", eName.eaddress("user3.e"));

        vm.prank(user4);
        vm.expectRevert();
        eName.register{value: 0.1 ether}("user3.e");

        console2.log("\n user3 register a new name.");
        vm.prank(user3);
        eName.register{value: 0.1 ether}("fancy.e");

        console2.log("user3 ename: ", eName.ename(user3));
        console2.log("eaddress of usre3.e: ", eName.eaddress("user3.e"));

        console2.log("\n user4 now takes the ename of user3.e."); 
        vm.prank(user4);
        eName.register{value: 0.1 ether}("user3.e");
        console2.log("user4 address: ", user4);
        console2.log("user4 ename: ", eName.ename(user4));
        console2.log("eaddress of usre3.e: ", eName.eaddress("user3.e"));

        console2.log("\n user2 now takes the ename of empty string."); 
        console2.log("user2 address: ", user2);
        vm.prank(user2);
        eName.register{value: 0.1 ether}("");
        console2.log("user2 ename: ", eName.ename(user2));
        console2.log("eaddress of empty string ", eName.eaddress(""));
         console2.log("eaddress of user2.e ", eName.eaddress("user2.e"));

        vm.prank(user7);
        eName.register{value: 0.1 ether}("user2.e");
        console2.log("user7 address: ", user7);
        console2.log("user7 ename: ", eName.ename(user7));
        console2.log("eaddress of user2.e ", eName.eaddress("user2.e"));
        
        // balance of each user
        console2.log("balance of user1", eName.balanceOf(user1));
        console2.log("balance of user2", eName.balanceOf(user2));
        console2.log("balance of user3", eName.balanceOf(user3));
        console2.log("balance of user4", eName.balanceOf(user4));
        console2.log("balance of user5", eName.balanceOf(user5));
        console2.log("balance of user6", eName.balanceOf(user6));
        console2.log("balance of user7", eName.balanceOf(user7));

        vm.prank(user6);
        // eName.register{value: 0.1 ether}("uSer2.e");
      
        console2.log("eaddress of usER2.e ", eName.eaddress("usER2.e"));
         console2.log("eaddress of usER2.e ", eName.eaddress("USER2.e"));
          console2.log("eaddress of usER2.e ", eName.eaddress("useR2.E"));

    }
   
    receive() external payable {

    }
}
