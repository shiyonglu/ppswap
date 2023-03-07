// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ppswap.sol";

/* this contract, Bob: deployer
   address(1): Alice: trustAccount, 
*/

contract PPSwapTest is Test {
    PPSwap ppswap; 
    Borrower Attacker;

    function setUp() public {
        ppswap = new PPSwap(payable(address(this))); // Bob
        Attacker = new Borrower(address(ppswap));
        ppswap.transfer(address(ppswap), 1e6);
    }

    function testDepositSavings() public {
        uint balBefore = ppswap.balanceOf(address(ppswap));
        assertEq(balBefore, 1e6);
        uint myBal = ppswap.balanceOf(address(this));
        uint totalSupply = ppswap.totalSupply();
        assertEq(myBal, totalSupply-1e6);

        ppswap.depositSavings(1234);
        uint balAfter = ppswap.balanceOf(address(ppswap));
        assertEq(balAfter-balBefore, 1234);
    }

/*
    function testFlashLoanAttack() public {
        uint totalSupply = ppswap.totalSupply();
        uint balInPPswap = ppswap.balanceOf(address(ppswap));
        assertEq(balInPPswap, totalSupply);

       Attacker.callFlashLoan(1000);
       uint balAttacker = ppswap.balanceOf(address(Attacker));
       assertEq(balAttacker, 1000);
    }
*/

}
