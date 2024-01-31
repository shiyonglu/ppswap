// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Import OpenZeppelin's ERC20 interface and SafeERC20 library
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Payment {
    using SafeERC20 for IERC20; // Use SafeERC20 for safe 
    

    // the sender can send totalAmount to n receivers, each gets totalAmount/n
    function sendTokens(address erc20TokenAddress, address[] memory users, uint256 totalAmount) public  {
        uint256 numOfUsers = users.length;
        require(numOfUsers > 0, "No users provided");
        require(totalAmount > 0, "Amount must be greater than zero");
        uint256 amount = totalAmount / numOfUsers;

          // Transfer tokens to the contract using safeTransferFrom
        IERC20(erc20TokenAddress).safeTransferFrom(msg.sender, address(this), totalAmount);

        // Distribute tokens to users
        for (uint256 i = 0; i < numOfUsers; i++) {
            address user = users[i];
            require(user != address(0), "Invalid user address");

            // Update user balances
            IERC20(erc20TokenAddress).safeTransfer(user, amount);
        }
    }
}
