/***
 *  
 *  
 *  To report the prices of some tokens on Ethereum
 *  
 *  Command: 
 *      forge script script/ethereum/GetPrice.s.sol:GetPrice --rpc-url $ETH_RPC_URL --broadcast
 * 
 *  
 *  ON 8/14/2024
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IPriceFeed {
    /// @dev decimals of latestAnswer
    function decimals() external view returns (uint256);

    function latestAnswer() external view returns (int256 answer);
}


contract GetPrice is Script {
     // Chainlink oracles
    IPriceFeed internal constant DAI_ETH_FEED = IPriceFeed(0x773616E4d11A78F511299002da57A0a94577F1f4); // DAI:ETH
    IPriceFeed internal constant USDC_ETH_FEED = IPriceFeed(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4); // USDC:ETH
    IPriceFeed internal constant BAL_USD_FEED = IPriceFeed(0xdF2917806E30300537aEB49A7663062F4d1F2b5F); // BAL:USD


    function setUp() public {}


    // try to exchange MATIC for MANA using Arbitrage:
    // 1. MANA is on  UNISWAP V3: MANA/WETH
    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john
        
        console2.log("john address:", john);
        uint256 usdcPrice = uint256(USDC_ETH_FEED.latestAnswer());
        uint256 ethPrice = 1 ether * 1e6 / usdcPrice;
        console2.log("USDC price in ETH: ", uint256(USDC_ETH_FEED.latestAnswer())); // the price of usdc in terms of ETH
        console2.log("ETH price in USDC: ", ethPrice);

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key


        vm.stopBroadcast();

        // console2.log("John's balance on new token: ", IERC20(token).balanceOf(john));
        
    }
}
