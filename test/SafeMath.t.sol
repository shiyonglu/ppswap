/*
 *  Test command: forge test --match-path test/SafeMath.t.sol -vv
 */


pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/SafeMath.sol";



contract SafeMathTest is Test{
    SafeMath safeMath;

    function setUp() public {
        safeMath = new SafeMath();
    }
   
    function testAdd() public {
        uint256 x = 77;
        uint256 y = 33;

        assertEq(safeMath.safeAdd(x, y), 110);
    }

    function testSub() public{
        uint256 x = 77;
        uint256 y = 33;

        assertEq(safeMath.safeSub(x, y), 44);
    }

    function testMul() public{
        uint256 x = 9;
        uint256 y = 3;

        assertEq(safeMath.safeMul(x, y), 27);
    }

    function testDiv() public{
        uint256 x = 9;
        uint256 y = 3;

        assertEq(safeMath.safeDiv(x, y), 3);
    }

    function testFailDiv() public{
        uint256 x = 9;
        uint256 y = 0;

        assertEq(safeMath.safeDiv(x, y), 3);
    }
}

