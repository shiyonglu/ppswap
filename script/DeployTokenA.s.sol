/*
 *  Command: 
 *  1.  simulate locally
 *        forge script script/DeployTokenA.s.sol:DeployTokenAScript
 *  2. simulate remotely 
 *        forge script script/DeployTokenA.s.sol:DeployTokenAScript --rpc-url $POLYGON_RPC_URL
 * 
 *      $POLYGON_RPC_URL is obtained from https://www.alchemy.com/ (or https://www.infura.io/) and cofigured at ~/.bashrc
 * 
 *  3. deploy in real 
 *     forge script script/DeployTokenA.s.sol:DeployTokenAScript --rpc-url $POLYGON_RPC_URL --broadcast
 *     for example: forge script script/DeployTokenA.s.sol --rpc-url https://polygon-rpc.com --broadcast
 *  
 *  4. deploy and verify the contract
 *      forge script script/DeployTokenA.s.sol:DeployTokenAScript --rpc-url $POLYGON_RPC_URL --broadcast --verify src/TokenA.sol:TokenA -etherscan-api-key $POLYSCAN_API_KEY
 *   
 *  5. Just verify after deployment: 
 *     forge verify-contract --verifier-url https://api.polygonscan.com/api/ 0x4663948dad67359c767662DF8D7F79136e8361dA src/TokenA.sol:TokenA --etherscan-api-key $POLYSCAN_API_KEY
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {TokenA} from "../src/TokenA.sol";

contract DeployTokenAScript is Script {
    function setUp() public {}

    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc
        address john = vm.addr(privateKey);      // the wallet address of john
        console2.log("john address:", john);

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        // deploy a contract by john as the deployer
        TokenA token = new TokenA();

        console2.log("token deployed at address:", address(token));

        vm.stopBroadcast();

        console2.log("ERC20Mock token balance of john:", token.balanceOf(john));
    }
}
