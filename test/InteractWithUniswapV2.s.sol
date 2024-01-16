/***
 *  Goal: to interact with Uniswap V2 on ETH
 *  
 * 
 *  
 *  Command: 
 *      forge script script/InteractWithArbitrage.s.sol:InteractWithUniswpV2Script --rpc-url $ETH_RPC_MAINNET --broadcast
 * 
 *  
 *  
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


interface IWETH {
    function deposit(address receiver, bytes memory data) external payable;
    function withdraw(uint256 wad) external;
 }

 
interface IUniswapV2Router {

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] calldata path, 
        address to, 
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut, 
        uint256 amountInMax, 
        address[] calldata path, 
        address to, 
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}


contract InteractWithUniswapV2Script is Script {
    address private constant PORT3 = 0xb4357054c3dA8D46eD642383F03139aC7f090343; // on ethereum
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // on ethereum

    function setUp() public {}



    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john
        address token = PORT3;
        
        console2.log("john address:", john);
        

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        //***************************************************************************** */
        IUniswapV2Router uniswapV2Router =  IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        address[] memory path = new address[](2);
        path[0] = WETH; 
        path[1] = token;
        uint256 amountIn = 0.05 ether;
        uint256 minTokens = 180;


        // Swap ETH for tokens
        uniswapV2Router.swapExactETHForTokens{value: amountIn}(
            minTokens,     // Minimum amount of tokens to receive
            path,          // Token path
            msg.sender,    // Recipient address
            block.timestamp + 600       // Deadline for the transaction
        );

      
        //***************************************************************************** */   
        vm.stopBroadcast();

        console2.log("John's balance on new token: ", IERC20(token).balanceOf(john));
        
    }
}
