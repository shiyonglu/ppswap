 
 /*
 *  1. deploy on mainnet POLYGON with simulation
 *      forge script script/DeployAirdrop.s.sol:DeployAirdropScript --rpc-url $POLYGON_RPC_URL 
 *  2. deploy on mainnet POLYGON
 *     forge script script/DeployAirdrop.s.sol:DeployAirdropScript --rpc-url $POLYGON_RPC_URL --broadcast --verify src/airdrop/backend/Airdrop.sol:Airdrop --etherscan-api-key $POLYSCAN_API_KEY
 *  3. Verify: 
 *      forge verify-contract --verifier-url https://api.polygonscan.com/api/ <contract_address> src/airdrop/backend/Airdrop.sol:Airdrop --etherscan-api-key $POLYSCAN_API_KEY
 * 
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../src/airdrop/backend/Airdrop.sol";


contract DeployAirdropScript is Script {
    address private constant donationAccount = 0xeccad5a26B2604b9878F3420B23b97f77a169043;
 
    function setUp() public {}

    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john
        console2.log("john address:", john);

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        // deploy a contract by john as the deployer
        Airdrop airdrop = new Airdrop(donationAccount);
        
        vm.stopBroadcast();
        console2.log("Arbitrage contract deployed at address:", address(airdrop));
    }
}
