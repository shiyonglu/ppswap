// commmand: forge test --match-test testV3 -vv

/*
Testing Liquidity Provision, Swaps, and Fee Collection on an Existing Uniswap V3 Pool in a Forked Mainnet Environment

The test code interacts with an existing Uniswap V3 pool to validate liquidity provision, token swaps, and fee collection functionalities on a forked Ethereum mainnet environment.
Key Components and Steps:

    Environment Setup:
        Forks Ethereum mainnet at block 21061460 and defines addresses for several popular tokens (e.g., UNI, WETH9, GALA).
        Assigns simulated user addresses (e.g., john, deployer).

    Liquidity Provision:
        Uses an already deployed Uniswap V3 pool for the UNI/WETH token pair, specifying tick ranges for liquidity.
        Mints a new position for john, depositing UNI and WETH into the pool and logging balances to track liquidity impact.

    Swaps and Fee Collection:
        Executes two swaps: first, from UNI to WETH, and second, back from WETH to UNI, logging balances pre- and post-swap to observe token movement.
        Implements uniswapV3SwapCallback to handle the token transfers needed for the swap.
        After each swap, john collects accrued fees, and balance logs confirm that fees are correctly allocated.

    Utility Functions:
        Helper functions print token balances and sign messages, providing support for balance tracking and potential transaction simulation.

This test verifies key Uniswap V3 functionalities by interacting directly with an existing pool, using mainnet conditions to ensure realistic testing.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import  "lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
// import  "lib/v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import {IUniswapV3Factory} from "lib/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "lib/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IUniswapV3SwapCallback} from "lib/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";



contract UniswapV3Test is Test {

    address immutable WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address immutable GALA = 0x15D4c048F83bd7e37d49eA4C83a07267Ec4203dA;
    
    address immutable SHIBA=0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    address immutable USDT=0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address immutable DAI=0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address immutable MANA=0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
    address immutable QKNTL=0xbcd4D5AC29E06e4973a1dDcd782cd035d04BC0b7;
    address immutable LINK=0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address immutable UNI=0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;


    // UniswapV3
    INonfungiblePositionManager immutable nonfungiblePositionManager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    IUniswapV3Pool pool;
    

    address deployer = makeAddr("deployer");
    address owner = makeAddr("owner");
    address victim1 = makeAddr("victim1");
    address victim2 = makeAddr("victim2");
    address john = makeAddr("john");

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_MAINNET"), 21061460);  // for from a block of the ETH blockchain
        
    }

    function printBalances(address a, string memory name) public{
        console2.log("The balances for ", name);
        console2.log("GALA balance: ", IERC20(GALA).balanceOf(a));
        console2.log("WETH balance: ", IERC20(WETH9).balanceOf(a));
        console2.log("SHIBA INU balance: ", IERC20(SHIBA).balanceOf(a));
        console2.log("USDT balance: ", IERC20(USDT).balanceOf(a));
        console2.log("DAI balance: ", IERC20(DAI).balanceOf(a));
        console2.log("MANA balance: ", IERC20(MANA).balanceOf(a));
        console2.log("QKNTL: ", IERC20(QKNTL).balanceOf(a));
        console2.log("LINK: ", IERC20(LINK).balanceOf(a));
    }
    function printTokenBalances(address a, string memory name) public{
        console2.log("\n ===========================================================");
        console2.log(name);
        console2.log("UNI Balance: ", IERC20(UNI).balanceOf(a));
        console2.log("WETH9 Balance: ", IERC20(WETH9).balanceOf(a));
        console2.log("\n ===========================================================\n ");
    }

    function testV3() public {
       console2.log("Let's test Uniswap V3...");
       console2.log("WETH9 balance for ETH: ", WETH9.balance);
       printBalances(address(nonfungiblePositionManager), "NonfungiblePositionManager");
       IUniswapV3Factory factory = IUniswapV3Factory(nonfungiblePositionManager.factory());
       console2.log("factory: ", address(factory));

       INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
        token0: UNI,
        token1: WETH9,
        fee: 3000,
        tickLower: -59580,           // current tick:  -58101
        tickUpper: -36720,
        amount0Desired: 300 ether,
        amount1Desired: 1 ether,
        amount0Min: 0,
        amount1Min: 0,
        recipient: john,
        deadline: block.timestamp + 1
    });
       
       
       deal(UNI, john, 10000 ether);
       deal(WETH9, john, 10000 ether);

      
       pool = IUniswapV3Pool(factory.getPool(UNI, WETH9, 3000));
       console2.log("pool: ", address(pool)); //  = 0x1d42064Fc4Beb5F8aAF85F4617AE8b3b5B8Bd801;


       console2.log("Pool UNI balance before: ", IERC20(UNI).balanceOf(address(pool)));
       console2.log("WETH9 balance before: ", IERC20(WETH9).balanceOf(address(pool)));
       vm.startPrank(john);
       IERC20(UNI).approve(address(nonfungiblePositionManager), 10000 ether);
       IERC20(WETH9).approve(address(nonfungiblePositionManager), 10000 ether);
       (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        ) =  nonfungiblePositionManager.mint(params);
        vm.stopPrank();

        console2.log("john mint successfully:");
        console2.log("tokenId: ", tokenId);
        console2.log("liquidity: ", liquidity);
        console2.log("amount0: ", amount0);
        console2.log("amount1: ", amount1);
        console2.log("Pool UNI balance after: ", IERC20(UNI).balanceOf(address(pool)));
        console2.log("WETH9 balance after: ", IERC20(WETH9).balanceOf(address(pool)));
       


        // now this test contract can swap?
        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        console2.log("current sqrtPriceX96: ", sqrtPriceX96);
        console2.log("tick: ", tick);

        deal(UNI, address(this), 1000 ether);
        IERC20(WETH9).transfer(john, IERC20(WETH9).balanceOf(address(this)));  // clean it
        printTokenBalances(address(this), "test contract before swap...");  // swap UNI for WETH9
        bytes memory data;
        pool.swap(address(this), true, 1000 ether, 
            3338152207142507445535775762,               // current sqrtPriceX96: 4338152207142507445535775762
            data
        );
        printTokenBalances(address(this), "test contract after swap");

 
        console2.log("John now collects swap fees..."); // the fee generates from the input token
        INonfungiblePositionManager.CollectParams memory collectParams = INonfungiblePositionManager.CollectParams({
            tokenId: 845188,
            recipient: john,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        printTokenBalances(john, "john balances Before collect");
        vm.startPrank(john);
        (amount0, amount1) = nonfungiblePositionManager.collect(collectParams);
        console2.log("Collect Uni: ", amount0);
        console2.log("collecdt WETH9: ", amount1);
        vm.stopPrank();     
        printTokenBalances(john, "john balances after collect");  


        (sqrtPriceX96, tick,,,,,) = pool.slot0();
        console2.log("Final sqrtPriceX96: ", sqrtPriceX96);
        console2.log("Final tick: ", tick);

 
        // swap for the second time: from WETH9 to UNI
        console2.log("\n swap for the second time ...");
        pool.swap(address(this), false, 2988623975873937452,  // all WETH9
            6338152207142507445535775762,    // must be smaller than this one
            data
        );
        printTokenBalances(address(this), "test contract after second swap");


        console2.log("john collect swap fees again...");       // the fee generates from the input token
        vm.startPrank(john);
        (amount0, amount1) = nonfungiblePositionManager.collect(collectParams);
        console2.log("Collect Uni: ", amount0);
        console2.log("collecdt WETH9: ", amount1);
        vm.stopPrank();     
        printTokenBalances(john, "john balances after second collect");  
     }

     function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external{
        if(amount0Delta > 0) IERC20(UNI).transfer(msg.sender, uint256(amount0Delta));
        if(amount1Delta > 0) IERC20(WETH9).transfer(msg.sender, uint256(amount1Delta));
    }
    
    function signMsgHash(bytes32 MsgHash, uint256 userPk) internal view returns (uint8 v, bytes32 r, bytes32 s)
    {
        // uint256 userPk = 0x12341234;
        // address user = vm.addr(userPk);

       return vm.sign(userPk, MsgHash);
    }


}
