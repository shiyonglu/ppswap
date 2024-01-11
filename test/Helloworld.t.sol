// Check other assert functions here: https://book.getfoundry.sh/reference/ds-test#asserting
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Helloworld.sol";

contract Helloworldtest is Test{
    Helloworld hello;

    function setUp() public {
        hello = new Helloworld(address(1111));
    }
   
    function testHello() public {
        assertEq(keccak256(abi.encodePacked(hello.greeting())),  keccak256(abi.encodePacked("hello")));
    }


}
