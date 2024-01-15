pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Arbitrage.sol";

contract ArbitrageTest is Test{           // TokenB is a ERC4626 vault
    Arbitrage arbitrage;
    

    address private constant KIRA = 0x16980b3B4a3f9D89E33311B5aa8f80303E5ca4F8;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // on ethereum
    address private constant WBNB = 0x418D75f65a02b3D53B2418FB8E1fe493759c7605; // on ethereum
    address private constant MANA = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942; // on ethereum
    address private constant DINGER = 0x9e5BD9D9fAd182ff0A93bA8085b664bcab00fA68; // on ethereum    
    address private constant POLC = 0xaA8330FB2B4D5D07ABFE7A72262752a8505C6B37; // on ethereum
    address private constant AIDI = 0xE3e24b4eA87935e15bbE99A24E9AcE9998e4614d; // on ethereum
    address private constant PORT3 = 0xb4357054c3dA8D46eD642383F03139aC7f090343; // on ethereum
    address private constant MATIC = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0; 


    function setUp() public {
        // vm.createSelectFork(vm.rpcUrl("https://polygon-mainnet.g.alchemy.com/v2/kG1HifS-s10GWNUIhkZIwTmIZqe2tbD1"));
        vm.createSelectFork(vm.rpcUrl("https://mainnet.infura.io/v3/95310f60af7b44bb8f3b13c043a00c8f"));
        

        arbitrage = new Arbitrage();
    }
   

 
    function testBuyToken1() public { // at uniswap V2
        address token = POLC;
        uint256 amount = 0.1 ether;


        deal(WETH, address(this), amount);
        IERC20(WETH).transfer(address(arbitrage), amount);
        arbitrage.swapTokensAtUniswapV2(WETH, token, amount, 0);
        arbitrage.retrieveTokens(token, IERC20(token).balanceOf(address(arbitrage)));
       console2.log("My token balance: ", IERC20(token).balanceOf(address(this)) / 1e18);
    }

     function testBuyToken2() public { // at Uniswap V3
        address token = MANA;
        uint256 amount = 0.1 ether;


        deal(WETH, address(this), amount);
        IERC20(WETH).transfer(address(arbitrage), amount);
        arbitrage.swapTokensAtUniswapV3(WETH, token, amount, 0);
        arbitrage.retrieveTokens(token, IERC20(token).balanceOf(address(arbitrage)));
        console2.log("My token balance: ", IERC20(token).balanceOf(address(this)) / 1e18);
    }

    function testBuysell() public{
        address token = DINGER;
        uint256 amount = 0.1 ether;

        deal(WETH, address(this), amount);
           console2.log("My WETH initial balance: ", IERC20(WETH).balanceOf(address(this)));

        IERC20(WETH).transfer(address(arbitrage), amount);

       console2.log("1111111111111");
        uint256 beforeTokenBalance = IERC20(token).balanceOf(address(arbitrage));
        console2.log("beforeTokenBalance", beforeTokenBalance);

        arbitrage.swapTokensAtUniswapV2(WETH, token, amount, 0);
        uint256 afterTokenBalance = IERC20(token).balanceOf(address(arbitrage));

        console2.log("afterTokenBalance", afterTokenBalance);
 
       vm.roll(block.number + 1);
        arbitrage.swapTokensAtUniswapV2(token, WETH, afterTokenBalance-beforeTokenBalance, 0);

        arbitrage.retrieveTokens(WETH, IERC20(WETH).balanceOf(address(arbitrage)));

        console2.log("My final WETH balance: ", IERC20(WETH).balanceOf(address(this)));

    }

    function testBuysell2() public{  // using shushiswap
        address token = MATIC;
        uint256 amount = 0.1 ether;

        deal(WETH, address(this), amount);
           console2.log("My WETH initial balance: ", IERC20(WETH).balanceOf(address(this)));

        IERC20(WETH).transfer(address(arbitrage), amount);

       console2.log("1111111111111");
        uint256 beforeTokenBalance = IERC20(token).balanceOf(address(arbitrage));
        console2.log("beforeTokenBalance", beforeTokenBalance);

        arbitrage.swapTokensAtSushiswap(WETH, token, amount, 0);
        uint256 afterTokenBalance = IERC20(token).balanceOf(address(arbitrage));

        console2.log("afterTokenBalance", afterTokenBalance);
 
       vm.roll(block.number + 1);
        arbitrage.swapTokensAtSushiswap(token, WETH, afterTokenBalance-beforeTokenBalance, 0);

        arbitrage.retrieveTokens(WETH, IERC20(WETH).balanceOf(address(arbitrage)));

        console2.log("My final WETH balance: ", IERC20(WETH).balanceOf(address(this)));
    }

    
    function testArbitrage1() public{  // using shushiswap
        address token = MATIC;
        uint256 amount = 1 ether;

        deal(WETH, address(this), amount);
        console2.log("My WETH initial balance: ", IERC20(WETH).balanceOf(address(this)));

        arbitrage(performArbitrageFromUniswapV2ToSushiswap(WETH, token, amount, 0);

        arbitrage.retrieveTokens(WETH, IERC20(WETH).balanceOf(address(arbitrage)));
        console2.log("My final WETH balance: ", IERC20(WETH).balanceOf(address(this)));
    }
}
