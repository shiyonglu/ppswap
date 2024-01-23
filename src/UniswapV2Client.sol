
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";


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

contract UniswapV2Interaction {
    address public owner;
    IUniswapV2Router public uniswapRouter;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    constructor(address _routerAddress) {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router(_routerAddress);
    }

    // Swap tokens using Uniswap V2
    function swapTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] memory _path
    ) external onlyOwner {
        // Approve the router to spend the tokenIn
        IERC20(_tokenIn).approve(address(uniswapRouter), _amountIn);
        
        // Perform the swap
        uniswapRouter.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            _path,
            address(this),
            block.timestamp + 600
        );
    }
    
    // Retrieve tokens from the contract
    function retrieveTokens(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(owner, _amount);
    }
}
