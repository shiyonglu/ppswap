/*
 *  Command: 
 *  1.  simulate locally
 *        forge script script/Counter.s.sol:CounterScript 
 *  2. simulate remotely 
 *        forge script script/Counter.s.sol:CounterScript --rpc-url $GOERLI_RPC_URL
 *      $GOERLI_RPC_URL is obtained from https://www.alchemy.com/ and cofigured at ~/.bashrc  
 *  3. deploy in real 
 *     forge script script/Counter.s.sol:CounterScript --rpc-url $GOERLI_RPC_URL --broadcast
 *
 *  4. deploy and verify the contract
 *      forge script script/Counter.s.sol:CounterScript --rpc-url $GOERLI_RPC_URL --broadcast --verify
 *   
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc
        address john = vm.addr(privateKey);      // the wallet address of john
        console2.log("john address:", john);

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        // deploy a contract by john as the deployer
        ERC20Mock token = new ERC20Mock();

        console2.log("token deployed at address:", address(token));

        // call the contract by john as the msg.sender
        token.mint(john, 10 ether); // mint 10 ether to john

        vm.stopBroadcast();
        console2.log("ERC20Mock token balance of john:", token.balanceOf(john));
    }
}
