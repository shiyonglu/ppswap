// Check other assert functions here: https://book.getfoundry.sh/reference/ds-test#asserting
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/TokenA.sol";
import "../src/payment/backend/Payment.sol";
import "../src/payment/backend/SendETH.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract AirdropTest is Test{
    Payment payment;
    SendETH sendETH;
    TokenA tokenA;

    address sponsor1 = makeAddr("sponsor1");
    address sponsor2 = 0xeccad5a26B2604b9878F3420B23b97f77a169043;

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    

    function setUp() public {
       // fork polygon since EName has been deployed there
       vm.createSelectFork(vm.rpcUrl("https://polygon-mainnet.g.alchemy.com/v2/kG1HifS-s10GWNUIhkZIwTmIZqe2tbD1"));

       payment = new Payment();
       sendETH = new SendETH();
       tokenA = new TokenA();
       deal(address(tokenA), sponsor1, 1000 ether);
       deal(address(tokenA), sponsor2, 1000 ether);

       deal(sponsor1, 20 ether);
       deal(sponsor2, 20 ether);
    }
   
    function testPayment() public {
        // address ENAME_ADDRESS = 0xBAA5c79d9a4C9E60a19D1C7884E2b400A6D8211A; // on polygon
     
        address[] memory userList = new address[](3);
        userList[0] =  user1;
        userList[1] = user2;
        userList[2] = user3;


        vm.startPrank(sponsor1);
        tokenA.approve(address(payment), 1000*3);
        payment.sendTokens(address(tokenA), userList, 3000);
        vm.stopPrank();

        console2.log("balance of payment: ", tokenA.balanceOf(address(payment)));
        console2.log("balance of user1: ", tokenA.balanceOf(user1));

        vm.startPrank(sponsor2);
        tokenA.approve(address(payment), 3000*3);
        payment.sendTokens(address(tokenA), userList, 3000);
        vm.stopPrank();

        console2.log("balance of payment: ", tokenA.balanceOf(address(payment)));
        console2.log("balance of user1: ", tokenA.balanceOf(user1));
    }

    function testSendETH() public{
        address[] memory userList = new address[](3);
        userList[0] =  user1;
        userList[1] = user2;
        userList[2] = user3;
        uint256[] memory amounts= new uint256[](3);
        amounts[0] = 1 ether;
        amounts[1] = 2 ether;
        amounts[2] = 3 ether;

        vm.expectRevert("Failure in sending ETH"); // not sufficient ETH
        sendETH.batchSend{value: 3 ether}(userList, amounts);

        console2.log("ETH baalance", sponsor1.balance);
        vm.prank(sponsor1);
        sendETH.batchSend{value: 6 ether}(userList, amounts);
        console2.log("ETH baalance", sponsor1.balance);
        console2.log("user1 ETH baalance", user1.balance);
        console2.log("user2 ETH baalance", user2.balance);
        console2.log("user 3ETH baalance", user3.balance);

        console2.log("ETH baalance", sponsor1.balance);
        vm.prank(sponsor1);
        sendETH.batchSend{value: 10 ether}(userList, amounts);
        console2.log("ETH baalance", sponsor1.balance);
        console2.log("user1 ETH baalance", user1.balance);
        console2.log("user2 ETH baalance", user2.balance);
        console2.log("user 3ETH baalance", user3.balance);

        vm.prank(sponsor1);
        (bool success, ) = address(sendETH).call{value: 1 ether}("");
        assertFalse(success);
    }

}
