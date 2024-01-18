
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps amountIn of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as ExactInputSingleParams in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
    }

    /// @notice Swaps amountIn of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as ExactInputParams in calldata
    /// @return amountOut The amount of the received token
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint amountOut);
}

interface ISushiSwapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}


contract Arbitrage {
    address public owner;
    IUniswapV2Router private  uniswapV2Router;
    IUniswapV3Router private  uniswapV3Router;
    ISushiSwapRouter private  sushiswapRouter;
    address  private weth;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    


    constructor() {
        owner = msg.sender;
    }



  // Setter function for uniswapV2Router
    function setUniswapV2Router(address _router) external onlyOwner {
        uniswapV2Router = IUniswapV2Router(_router);
    }

    // Setter function for uniswapV3Router
    function setUniswapV3Router(address _router) external onlyOwner {
        uniswapV3Router = IUniswapV3Router(_router);
    }

    // Setter function for sushiswapRouter
    function setSushiswapRouter(address _router) external onlyOwner {
        sushiswapRouter = ISushiSwapRouter(_router);
    }

    function setWETHAddress( address weth_) external onlyOwner{
        weth = weth_;
    }


    function swapExactETHForTokensAtUniswapV2(
        address tokenAddress, // Address of the token you want to receive
        uint256 minTokens    // Minimum amount of tokens to receive
    ) external payable onlyOwner {
        // Ensure that the contract has sufficient ETH to perform the swap
        require(msg.value > 0, "ETH amount should be greater than 0");


        address[] memory path = new address[](2);
        path[0] = weth; 
        path[1] = tokenAddress; 


        // Swap ETH for tokens
        uniswapV2Router.swapExactETHForTokens{value: msg.value}(
            minTokens,     // Minimum amount of tokens to receive
            path,          // Token path
            msg.sender,    // Recipient address
            block.timestamp + 600       // Deadline for the transaction
        );

    }

    // Swap tokens using Uniswap V2
 // Swap tokens using Uniswap V2
    function swapTokensAtUniswapV2(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external onlyOwner {

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        // Approve the router to spend the tokenIn
        IERC20(_tokenIn).approve(address(uniswapV2Router), _amountIn);
        // Create a path array with just the input and output tokens
        address[] memory _path = new address[](2);
        _path[0] = _tokenIn;
        _path[1] = _tokenOut;
                
        // Perform the swap
        uniswapV2Router.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            _path,
            msg.sender,
            block.timestamp + 600
        );
        
    }


    function swapTokensAtUniswapV3(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external onlyOwner { 
       IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
       IERC20(_tokenIn).approve(address(uniswapV3Router),  _amountIn);

        IUniswapV3Router.ExactInputSingleParams memory params = IUniswapV3Router
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: 3000,     // 500, 3000, 10000
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMin,
                sqrtPriceLimitX96: 0
            });

        uniswapV3Router.exactInputSingle(params);
    }


    function swapTokensAtSushiswap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external onlyOwner {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        // Approve the router to spend the tokenIn
        IERC20(_tokenIn).approve(address(sushiswapRouter), _amountIn);

        // Create a path array with just the input and output tokens
        address[] memory _path = new address[](2);
        _path[0] = _tokenIn;
        _path[1] = _tokenOut;

        // Perform the swap
        sushiswapRouter.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            _path,
            msg.sender,
            block.timestamp + 600
        );
    }

    // Arbitrage function: Buy token on Uniswap V2 and sell on Uniswap V3
    function performArbitrageFromUniswapV2ToV3(
        address _tokenIn,           // Input token (WETH)
        address _tokenOut,          // Output token to be traded
        uint256 _amountIn,          // Amount of input token to be traded
        uint256 _minProfit         // Minimum profit desired
    ) external onlyOwner {
        // Get the initial balance of the input token (WETH)
        uint256 initialBalance = IERC20(_tokenIn).balanceOf(address(this));

        // Approve the Uniswap V2 Router to spend the input token (WETH)
        IERC20(_tokenIn).approve(address(uniswapV2Router), _amountIn);

        // Create a path array for Uniswap V2 with WETH as input and the desired token as output
        address[] memory uniswapV2Path = new address[](2);
        uniswapV2Path[0] = _tokenIn;
        uniswapV2Path[1] = _tokenOut;

        // Perform the swap on Uniswap V2
         uint256[] memory amountsOut = uniswapV2Router.swapExactTokensForTokens(
            _amountIn,
            0, // Set to 0 to allow any amount of output token
            uniswapV2Path,
            address(this),
            block.timestamp + 600
        );

        // Get the amount of output token received
        uint256 amountOut = amountsOut[amountsOut.length - 1];

        // Approve the Uniswap V3 Router to spend the received token
        IERC20(_tokenOut).approve(address(uniswapV3Router), amountOut);

        IUniswapV3Router.ExactInputSingleParams memory params = IUniswapV3Router
            .ExactInputSingleParams({
                tokenIn: _tokenOut,
                tokenOut: _tokenIn,
                fee: 3000,     // 500, 3000, 10000
                recipient: address(this),
                deadline: block.timestamp + 600, // Extend the deadline for Uniswap V3
                amountIn: amountOut,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // Perform the swap on Uniswap V3
        uniswapV3Router.exactInputSingle(params);

        if(IERC20(_tokenIn).balanceOf(address(this)) <= initialBalance){
                console2.log("Sorry, there is no profit.");
        }

        // Check if the profit is greater than or equal to the minimum profit desired
        uint256 profit = IERC20(_tokenIn).balanceOf(address(this)) - initialBalance;
        require(profit >= _minProfit, "Minimum profit is not met.");

        // Revert if there is no profit
        require(profit > 0, "No profit obtained.");
    }



    function performArbitrageFromUniswapV2ToSushiswap(
            address _tokenIn,           // Input token (WETH)
            address _tokenOut,          // Output token to be traded
            uint256 _amountIn,          // Amount of input token to be traded
            uint256 _minProfit         // Minimum profit desired
        ) external onlyOwner {
            uint256 initialBalance = IERC20(_tokenIn).balanceOf(address(this));

            // Approve the Uniswap V2 Router to spend the input token (WETH)
            IERC20(_tokenIn).approve(address(uniswapV2Router), _amountIn);
            
            // Create a path array for Uniswap V2 with WETH as input and the desired token as output
            address[] memory uniswapV2Path = new address[](2);
            uniswapV2Path[0] = _tokenIn;
            uniswapV2Path[1] = _tokenOut;
            
            // Perform the swap on Uniswap V2
            uint256[] memory amountsOut = uniswapV2Router.swapExactTokensForTokens(
                _amountIn,
                0, // Set to 0 to allow any amount of output token
                uniswapV2Path,
                address(this),
                block.timestamp + 600
            );
            
            // Get the amount of output token received
            uint256 amountOut = amountsOut[amountsOut.length - 1];

            // Approve the Sushiswap Router to spend the received token
            IERC20(_tokenOut).approve(address(sushiswapRouter), amountOut);

            // Create a path array for Sushiswap with the received token as input and WETH as output
            address[] memory sushiswapPath = new address[](2);
            sushiswapPath[0] = _tokenOut;
            sushiswapPath[1] = _tokenIn;

            // Perform the swap on Sushiswap
            sushiswapRouter.swapExactTokensForTokens(
                amountOut, // Use the received amount as input
                0, // Set to 0 to allow any amount of WETH as output
                sushiswapPath,
                address(this),
                block.timestamp + 600
            );

            if(IERC20(_tokenIn).balanceOf(address(this)) <= initialBalance){
                console2.log("Sorry, there is no profit.");
            }

            // Calculate the profit obtained after the arbitrage
            uint256 profit = IERC20(_tokenIn).balanceOf(address(this)) - initialBalance;


            // Revert if the profit condition is not met
            require(profit >= _minProfit, "Minimum profit is not met.");
        }

        function performArbitrageFromUniswapV3ToSushiswap(
            address _tokenIn,           // Input token (WETH)
            address _tokenOut,          // Output token to be traded
            uint256 _amountIn,          // Amount of input token to be traded
            uint256 _minProfit         // Minimum profit desired
        ) external onlyOwner {
            uint256 initialBalance = IERC20(_tokenIn).balanceOf(address(this));

            // Approve the Uniswap V2 Router to spend the input token (WETH)
            IERC20(_tokenIn).approve(address(uniswapV3Router), _amountIn);

            uint256 _tokenOutInitialBalance = IERC20(_tokenOut).balanceOf(address(this));
            IUniswapV3Router.ExactInputSingleParams memory params = IUniswapV3Router
                .ExactInputSingleParams({
                    tokenIn: _tokenIn,
                    tokenOut: _tokenOut,
                    fee: 3000,     // 500, 3000, 10000
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: _amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

               uniswapV3Router.exactInputSingle(params);
            
            
            // Get the amount of output token received
            uint256 amountOut =  IERC20(_tokenOut).balanceOf(address(this)) - _tokenOutInitialBalance;
            console2.log("amoutnOut: ", amountOut);

            // Approve the Sushiswap Router to spend the received token
            IERC20(_tokenOut).approve(address(sushiswapRouter), amountOut);

            // Create a path array for Sushiswap with the received token as input and WETH as output
            address[] memory sushiswapPath = new address[](2);
            sushiswapPath[0] = _tokenOut;
            sushiswapPath[1] = _tokenIn;

             // Perform the swap on Sushiswap
            sushiswapRouter.swapExactTokensForTokens(
                amountOut, // Use the received amount as input
                0, // Set to 0 to allow any amount of WETH as output
                sushiswapPath,
                address(this),
                block.timestamp + 600
            );

            if(IERC20(_tokenIn).balanceOf(address(this)) <= initialBalance){
                console2.log("Sorry, there is no profit.");
            }

            // Calculate the profit obtained after the arbitrage
            uint256 profit = IERC20(_tokenIn).balanceOf(address(this)) - initialBalance;


            // Revert if the profit condition is not met
            require(profit >= _minProfit, "Minimum profit is not met.");
        }


    
    // Retrieve tokens from the contract
    function retrieveTokens(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(owner, _amount);
    }


}
