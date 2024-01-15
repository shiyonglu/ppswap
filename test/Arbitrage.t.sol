pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Arbitrage.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


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
    address private constant MATIC = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;  // on ethereum
    address private constant SHIB = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE; // on thereum
    address private constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9; // on ethereum
    address private constant ANKR = 0x8290333ceF9e6D528dD5618Fb97a76f268f3EDD4; // on ethereum
    address private constant ARB = 0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1; // on ethereum

    IUniswapV2Router private immutable uniswapV2Router_ON_ETH = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV3Router private immutable uniswapV3Router_ON_ETH = IUniswapV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    ISushiSwapRouter private immutable sushiswapRouter_ON_ETH = ISushiSwapRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    address private immutable uniswapV2Router_ON_POLYGON = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address private immutable uniswapV3Router_ON_POLYGON = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private immutable sushiswapRouter_ON_POLYGON = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    address private constant WETH_ON_POLYGON = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address private constant SHIB_ON_POLYGON = 0x6f8a06447Ff6FcF75d803135a7de15CE88C1d4ec;
     address private constant LINK_ON_POLYGON = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;


    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("https://polygon-mainnet.g.alchemy.com/v2/kG1HifS-s10GWNUIhkZIwTmIZqe2tbD1"));
        // vm.createSelectFork(vm.rpcUrl("https://mainnet.infura.io/v3/95310f60af7b44bb8f3b13c043a00c8f"));
        

        arbitrage = new Arbitrage();
        arbitrage.setUniswapV2Router(address(uniswapV2Router_ON_POLYGON));
        arbitrage.setUniswapV3Router(address(uniswapV3Router_ON_POLYGON));
        arbitrage.setSushiswapRouter(address(sushiswapRouter_ON_POLYGON));
    }
   

 
    function testBuyTokenV2() public { // at uniswap V2
        address token = LINK_ON_POLYGON;
        uint256 amount = 0.1 ether;


        deal(WETH_ON_POLYGON,  address(this), amount);
        IERC20(WETH_ON_POLYGON).transfer(address(arbitrage), amount);
        arbitrage.swapTokensAtUniswapV2(WETH_ON_POLYGON, token, amount, 0);
        arbitrage.retrieveTokens(token, IERC20(token).balanceOf(address(arbitrage)));
       console2.log("My token balance: ", IERC20(token).balanceOf(address(this)));
    }

/*
     function testBuyTokenV3() public { // at Uniswap V3
        address token = PORT3;
        uint256 amount = 0.1 ether;


        deal(WETH, address(this), amount);
        IERC20(WETH).transfer(address(arbitrage), amount);
        arbitrage.swapTokensAtUniswapV3(WETH, token, amount, 0);
        arbitrage.retrieveTokens(token, IERC20(token).balanceOf(address(arbitrage)));
        console2.log("My token balance: ", IERC20(token).balanceOf(address(this)) / IERC20Metadata(token).decimals());
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
        address token = ANKR;
        uint256 amount = 1000 ether;

        deal(WETH, address(this), amount);
        console2.log("My WETH initial balance: ", IERC20(WETH).balanceOf(address(this)));

        
        IERC20(WETH).transfer(address(arbitrage), amount);

        arbitrage.performArbitrageFromUniswapV2ToV3(WETH, token, amount, 0);

        arbitrage.retrieveTokens(WETH, IERC20(WETH).balanceOf(address(arbitrage)));

        console2.log("My final WETH balance: ", IERC20(WETH).balanceOf(address(this)));
    }
    */
}
