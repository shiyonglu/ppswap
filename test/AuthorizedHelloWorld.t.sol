pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/AuthorizedHelloworld.sol";

contract AuthorizedHelloworldtest is Test{
    AuthorizedHelloworld hello;

    function setUp() public {
        hello = new AuthorizedHelloworld(address(1111));
    }
   
    function testFailHello() public {
        assertEq(keccak256(abi.encodePacked(hello.greeting())),  keccak256(abi.encodePacked("hello")));
    }

    function testSuccessHello() public {
        vm.prank(address(1111));
        assertEq(keccak256(abi.encodePacked(hello.greeting())),  keccak256(abi.encodePacked("hello")));
    }

}

