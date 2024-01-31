// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract AuthorizedHelloworld {
    address owner;

    constructor(address initialOwner){
        owner = initialOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function greeting() onlyOwner public view returns (string memory message) {
        return "hello";
    }

}

