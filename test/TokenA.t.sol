pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/TokenA.sol";

contract TokenATest is Test{
    TokenA tokenA;
    address user1;
    address user2; 
    address user3; 

    function setUp() public {
        tokenA = new TokenA();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
    }
   
    function testTotalSupply() public {
        assertEq(tokenA.totalSupply(), 1_000_000_000);
    }

    function testTransfer() public {
        assertEq(tokenA.balanceOf(address(this)), 1_000_000_000);
        tokenA.transfer(user1, 5000);
        assertEq(tokenA.balanceOf(user1), 5000);       
    }

    function testTransferFrom() public {
        assertEq(tokenA.balanceOf(address(this)), 1_000_000_000);
        tokenA.transfer(user1, 5000);
        assertEq(tokenA.balanceOf(user1), 5000);     

        vm.prank(user1);
        tokenA.approve(user2, 500);  // now user2 can conduct tranfer on behalf of user1

        vm.prank(user2);
        tokenA.transferFrom(user1, user3, 300);

        assertEq(tokenA.balanceOf(user1), 4700);    
        assertEq(tokenA.balanceOf(user3), 300); 

    }

    function testAllowance() public {
        assertEq(tokenA.balanceOf(address(this)), 1_000_000_000);
        
     
        vm.prank(user2);
        vm.expectRevert();
        tokenA.transferFrom(address(this), user3, 300); // without allowance
    
        tokenA.approve(user2, 300);
        vm.prank(user2);
        tokenA.transferFrom(address(this), user3, 300); // with allowance
    }

}
