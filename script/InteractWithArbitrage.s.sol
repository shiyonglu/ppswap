/***
 *  Goal: to interact with an already-deployed contract Arbitage on Polgyon
 *  Already deployed Arbitrage contract address:  0x922F3E9a47ba2ca85b3B9E3E2c4828C44Da41a70
 *  
 *  If you need to simulate, you have to write a test file under test and then for the mainnet of POLYGON 
 *  
 *  Command: 
 *      forge script script/InteractWithArbitrage.s.sol:InteractWithArbitrageScript --rpc-url $POLYGON_RPC_URL --broadcast
 * 
 *  
 *  ON 1/15/2024, paid 0.00003 WETH and get  0.004931474253248950 LINK by interacting with arbitrage.swapTokensAtUniswapV3().
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../src/Arbitrage.sol";

interface IWETH {
    function deposit(address receiver, bytes memory data) external payable;
    function withdraw(uint256 wad) external;
 }


contract InteractWithArbitrageScript is Script {
    address private constant ARBITRAGE_ON_POLYGON = 0x53fa78DA6aEDd264288fE63383AdB610e3804F86;
    address private constant MANA_ON_POLYGON=0xA1c57f48F0Deb89f569dFbE6E2B7f46D33606fD4;
    address private constant WETH_ON_POLYGON = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address private constant SHIB_ON_POLYGON = 0x6f8a06447Ff6FcF75d803135a7de15CE88C1d4ec;
     address private constant LINK_ON_POLYGON = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    

    function setUp() public {}


    // try to exchange MATIC for MANA using Arbitrage:
    // 1. MANA is on  UNISWAP V3: MANA/WETH
    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john
        
        console2.log("john address:", john);
        

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        //***************************************************************************** */
        Arbitrage arbitrage = Arbitrage(ARBITRAGE_ON_POLYGON); // no need to deploy
        // https://www.coingecko.com/en/coins/shiba-inu#markets, thus we use UNISWAP V3 on polygon
        address token = LINK_ON_POLYGON;
        uint256 amountIn = 0.00003 ether;
        uint256 minAmountOut = 0.004 ether;


        // make sure LINK is on this market and chain, see https://www.coingecko.com/en/coins/chainlink#markets
        IERC20(WETH_ON_POLYGON).transfer(address(arbitrage), amountIn);
        arbitrage.swapTokensAtUniswapV3(WETH_ON_POLYGON, token, amountIn, minAmountOut); // expected 0.00493862 LINKS, 18 decimals
        arbitrage.retrieveTokens(token, IERC20(token).balanceOf(address(arbitrage)));

      
        //***************************************************************************** */   
        vm.stopBroadcast();

        console2.log("John's balance on new token: ", IERC20(token).balanceOf(john));
        
    }
}
