 
 /*
 *  Note 1) you will need an endpoint URL to connect to a blockchain, get your MUMBAI_RPC_URL from: https://www.infura.io/
 *       2) you need to put the public key and private key of your metamask account in a file .env. like the following.
 *          Make sure to use chmod 600 to protect its security.
 *    
 *              JOHN_PRIV="0xa9b35...."
 *              JOHN_PUB="0x8229...."
 *                
 * 
 *  Command: 
 *  1.  simulate locally
 *        forge script script/DeployArbitrage.s.sol:DeployArbitrageScript
 *  2. simulate remotely 
 *        forge script script/DeployArbitrage.s.sol:DeployArbitrageScript --rpc-url $MUMBAI_RPC_URL
 *      
 *  3. deploy on testnet MUMBAI
 *     forge script script/DeployArbitrage.s.sol:DeployArbitrageScript --rpc-url $MUMBAI_RPC_URL --broadcast
 *
 *  4. deploy on mainnet POLYGON
 *     forge script script/DeployArbitrage.s.sol:DeployArbitrageScript --rpc-url $POLYGON_RPC_URL --broadcast
 * 
 *  5. deploy and verify the contract on mainnet POLYGON
 *     add the POLYSCAN_API_KEY to .env. Obtain your own POLYSCAN_API_KEY from https://polygonscan.com
 *          export POLYSCAN_API_KEY="JFKKKADQZ6TDYMPF2HEKFSTGJCI8Y3RWBC"
 * 
 *     forge script script/DeployArbitrage.s.sol:DeployArbitrageScript --rpc-url $POLYGON_RPC_URL --broadcast --verify
 *  
 *     Spent: 0.045857726120800272 MATIC to deploy on POLYGON on 1/15/2024, 
 *     Contract Address: 
 *          0x53fa78DA6aEDd264288fE63383AdB610e3804F86
 *  * MAKE SURE WRITE DOWN THE ADDRESS OF YOUR NEWLY DEPLOYED CONTRACT.
 *   
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../src/Arbitrage.sol";


contract DeployArbitrageScript is Script {
    address private immutable uniswapV2Router_ON_POLYGON = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address private immutable uniswapV3Router_ON_POLYGON = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private immutable sushiswapRouter_ON_POLYGON = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

 
    function setUp() public {}

    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john
        console2.log("john address:", john);

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        // deploy a contract by john as the deployer
        Arbitrage arbitrage = new Arbitrage();
        arbitrage.setUniswapV2Router(address(uniswapV2Router_ON_POLYGON));
        arbitrage.setUniswapV3Router(address(uniswapV3Router_ON_POLYGON));
        arbitrage.setSushiswapRouter(address(sushiswapRouter_ON_POLYGON));

        vm.stopBroadcast();
        console2.log("Arbitrage contract deployed at address:", address(arbitrage));
        console2.log("The ower of the contract is: ", arbitrage.owner());
    }
}
