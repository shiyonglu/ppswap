pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/TokenA.sol";
import "../src/TokenB.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenATest is Test{           // TokenB is a ERC4626 vault
    TokenA tokenA = TokenA(0xd03C5c70936B4f85e6B70e453d42c86d3a53f1cc); // TokenA already deployed on Polygon
    TokenB tokenB;
    address user1 = 0xdcad2395498A01E1dfD1B400a454b50ba8D420D7; // have all the tokenA
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("https://polygon-mainnet.g.alchemy.com/v2/kG1HifS-s10GWNUIhkZIwTmIZqe2tbD1"));

        tokenB = new TokenB(IERC20(address(tokenA)));
    }
   
    
    function testTokenA() public {
        console2.log("user1 tokenA balance:", tokenA.balanceOf(user1));
        assertEq(tokenA.balanceOf(user1), 1_000_000_000);

        deal(address(tokenA), user2, 20000);
        assertEq(tokenA.balanceOf(user2), 20000);
    }

    function testDeposit() public{
        deal(address(tokenA), user2, 20000);

        vm.startPrank(user2);
        tokenA.approve(address(tokenB), 20000);
        tokenB.deposit(20000, user2);
        vm.stopPrank();


        //shares I got
        console2.log("user2 shares:", tokenB.balanceOf(user2)); // 2009 shares
        assertEq(tokenB.balanceOf(user2), 20000);

        vm.prank(user1);               // user1 sends the rewards to the vault
        tokenA.transfer(address(tokenB), 1_000_000);
        assertEq(tokenA.balanceOf(address(tokenB)), 1_000_000+20000);

        // now each share has  1_000_000+2000 / 20000 tokens of token

        vm.prank(user2); // msg.sender
        tokenB.redeem(1, user2, user2); // redeem 1 share, receiver, owner

        assertEq(tokenB.balanceOf(user2), 20000-1); // remaining shares
        console2.log("user2 balance of tokenA:", tokenA.balanceOf(user2));
    }


}
