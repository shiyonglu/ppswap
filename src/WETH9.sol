// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH9 is ERC20 {
    // Event to notify ether deposit
    event Deposit(address indexed account, uint256 amount);
    // Event to notify ether withdrawal
    event Withdraw(address indexed account, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH") {}

    // Allows users to deposit Ether and mint WETH
    function deposit() public payable {
        // Mint WETH to the sender's account based on the ether sent
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    // Allows users to withdraw Ether by burning WETH
    function withdraw(uint256 amount) external {
        // Burn WETH tokens from the sender's account
        _burn(msg.sender, amount);
        // Transfer Ether back to the sender
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // Fallback function to handle direct ether transfers to the contract
    receive() external payable {
        deposit();
    }
}
