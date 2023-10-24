

/**
 *  How to fork the mainnet and call a contract on the mainnet
 *  
 *  test command:
 *  forge test --fork-url $ETH_RPC_URL -vv
 *  where $ETH_RPC_URL = https://mainnet.infura.io/v3/95310f60af7b44bb8f3b13c043a00c8f
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/src/Test.sol";
import "forge-std/src/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


interface IWETH9{
     function balanceOf(address account) external returns (uint);
     function deposit() external payable;
     function withdraw(uint wad) external;
     function totalSupply() external view returns (uint);
     function approve(address guy, uint wad) external returns (bool);
     function transfer(address dst, uint wad) external returns (bool);
     function transferFrom(address src, address dst, uint wad) external returns (bool);
}


contract MyForkTest is Test{
      address user1 = makeAddr("user1");
      address user2 = makeAddr("user2");

      IWETH9 weth9;

  function setUp() public {

      // set up WETH9
      weth9 = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  }

  function testWeth9() public{
      console2.log("weth9.totalSupply: %d", weth9.totalSupply());

      vm.deal(user1, 1000 ether);
      console2.log("weth9 ether balance before: %d:", address(weth9).balance);
      console2.log("user1's weth9 balance before: %d", weth9.balanceOf(user1));

      vm.prank(user1);
      weth9.deposit{value: 1000 ether}();
      console2.log("weth9 ether balance after: %d:", address(weth9).balance);
      console2.log("user1's weth9 balance after: %d", weth9.balanceOf(user1));

      assertEq(weth9.balanceOf(user1), 1000 ether);

  }
}

