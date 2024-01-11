// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ppswap.sol";
import {FlashLoanAttacker} from "../src/FlashloanAttacker.sol";

/* 
Check other assert functions here: https://book.getfoundry.sh/reference/ds-test#asserting

this contract, Bob: deployer
   address(1): Alice: trustAccount, 
*/

contract ppswapTest is Test {
    PPSwap ppswap; 
    FlashLoanAttacker attacker;
    uint initialAmt = 1_000_000e18;

    function setUp() public {
        ppswap = new PPSwap(payable(address(this))); // Bob
        attacker = new FlashLoanAttacker(address(ppswap));
        ppswap.transfer(address(ppswap), initialAmt); // Bob send 1e6 to ppswap
    }

    function testDepositSavings() public {
        uint balBefore = ppswap.balanceOf(address(ppswap));
        assertEq(balBefore, initialAmt);
        uint myBal = ppswap.balanceOf(address(this)); // Bob's balance
        uint totalSupply = ppswap.totalSupply();
        assertEq(myBal, totalSupply-initialAmt);

        ppswap.depositSavings(1234);
        uint balAfter = ppswap.balanceOf(address(ppswap));
        assertEq(balAfter-balBefore, 1234);
    }

    function testWithdrawSavings() public{
        ppswap.depositSavings(5000);
        uint balBefore = ppswap.balanceOf(address(this));
        ppswap.withdrawSavings(1500);
        uint balAfter = ppswap.balanceOf(address(this));
        assertEq(balAfter-balBefore, 1500);
    }

    function testFlashLoanAttack() public {
       
       attacker.callFlashLoan(1000);
       uint balAttacker = ppswap.balanceOf(address(attacker));
       assertEq(balAttacker, 1000);
    }

    function testBuy() public
    {
        uint balBefore = address(ppswap).balance;

        (bool success, ) = address(ppswap).call{value: 1000}("");
        if(!success) revert("Sending ETH fails");
        uint balAfter = address(ppswap).balance;
        assertEq(balAfter-balBefore, 1000);

        uint bal1 = ppswap.balanceOf(address(this));         
        ppswap.buyPPS{value: 0.5e18}();
        uint bal2 = ppswap.balanceOf(address(this));    
        assertEq(bal2-bal1, 250000*10**18);
    }
}
