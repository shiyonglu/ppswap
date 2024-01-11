// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract Helloworld {
    address owner;

    constructor(address initialOwner){
        owner = initialOwner;
    }

    function greeting() public returns (string memory message) {
        return "hello";
    }

}
