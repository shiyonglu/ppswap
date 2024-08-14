/***
 *  
 *  
 *  To report the prices of some tokens on Ethereum
 *  
 *  Command: 
 *      forge script script/ethereum/BuyEth.s.sol:BuyEth --rpc-url $ETH_RPC_URL --broadcast
 * 
 *  
 *  ON 8/14/2024
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Router, ExactInputParams, ExactOutputParams} from "./vendor/IUniswapV3Router.sol";

interface IPriceFeed {
    /// @dev decimals of latestAnswer
    function decimals() external view returns (uint256);

    function latestAnswer() external view returns (int256 answer);
}

enum SwapType {
    EXACT_IN,
    EXACT_OUT
}


contract BuyEth is Script, Test {
    using SafeERC20 for IERC20;

    address internal constant UNISWAP_V3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    ERC20 internal constant DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 internal constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 internal constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 internal constant BOND = ERC20(0x0391D2021f89DC339F60Fff84546EA23E337750f);
    ERC20 internal constant BAL = ERC20(0xba100000625a3754423978a60c9317c58a424e3D);
    
    
     // Chainlink oracles
    IPriceFeed internal constant DAI_ETH_FEED = IPriceFeed(0x773616E4d11A78F511299002da57A0a94577F1f4); // DAI:ETH
    IPriceFeed internal constant USDC_ETH_FEED = IPriceFeed(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4); // USDC:ETH
    IPriceFeed internal constant BAL_USD_FEED = IPriceFeed(0xdF2917806E30300537aEB49A7663062F4d1F2b5F); // BAL:USD

    bytes internal constant WETH_USDC_PATH =
        abi.encodePacked(address(WETH), uint24(3000), address(USDC));

    IUniswapV3Router internal immutable uniRouter =  IUniswapV3Router(UNISWAP_V3);

    function setUp() public {
          
    }


    // Buy 1 WETH using USDC
    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john

        console2.log("eth balance of john", john.balance);
        console2.log("Weth balance of john", WETH.balanceOf(john));
        console2.log("USDC balance of john", USDC.balanceOf(john));
        
        uint256 amountInMax = 30e6;  // 3000 dollars
        uint256 amountOut = 0.01 ether;
        console2.log("john address:", john);
       
        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        uint256 amountIn = uniV3Swap(SwapType.EXACT_OUT, address(USDC), amountOut, amountInMax, john, block.timestamp+100, WETH_USDC_PATH);
        vm.stopBroadcast();

        console2.log("Input USDC: ", amountIn);
        console2.log("Output WETH", amountOut);
        console2.log("USDC balance: ", USDC.balanceOf(john));
        console2.log("WETH balance: ", WETH.balanceOf(john));
        
    }

    function uniV3Swap(
        SwapType swapType,
        address assetIn,
        uint256 amount,
        uint256 limit,
        address recipient,
        uint256 deadline,
        bytes memory args
    ) internal returns (uint256) {
        if (swapType == SwapType.EXACT_IN) {
            IERC20(assetIn).forceApprove(address(uniRouter), amount);
            return
                uniRouter.exactInput(
                    ExactInputParams({
                        path: args,
                        recipient: recipient,
                        amountIn: amount,
                        amountOutMinimum: limit,
                        deadline: deadline
                    })
                );
        } else {
            IERC20(assetIn).forceApprove(address(uniRouter), limit);
            return
                uniRouter.exactOutput(
                    ExactOutputParams({
                        path: args,
                        recipient: recipient,
                        amountOut: amount,
                        amountInMaximum: limit,
                        deadline: deadline
                    })
                );
        }
    }
}
