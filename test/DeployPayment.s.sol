 
 /*
 *  1. deploy on mainnet POLYGON with simulation
 *      forge script script/DeployPayment.s.sol:DeployPaymentScript --rpc-url $POLYGON_RPC_URL 
 *  2. deploy on mainnet POLYGON with verify
 *     forge script script/DeployPayment.s.sol:DeployPaymentScript --rpc-url $POLYGON_RPC_URL --broadcast --verify src/airdrop/backend/Payment.sol:Payment --etherscan-api-key $POLYSCAN_API_KEY
 *  3. Verify ONLY
 *      forge verify-contract --verifier-url https://api.polygonscan.com/api/ <contract_address> src/payment/backend/Payment.sol:Payment --etherscan-api-key $POLYSCAN_API_KEY
 *  
 *  Succesfully deployed and verified on 1/26/2024
 *  https://polygonscan.com/address/0xc20118d2Aaa7D467EDF7131C5E2c38D087D8740E#code
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../src/payment/backend/Payment.sol";


contract DeployPaymentScript is Script {
 
    function setUp() public {}

    function run() public { // need to write code here to deploy a contract
        uint privateKey = vm.envUint("JOHN_PRIV"); // the private key of john, .bashrc , note that JOHN_PRIV needs to start with 0x..
        address john = vm.addr(privateKey);      // the wallet address of john
        console2.log("john address:", john);

        vm.startBroadcast(privateKey);     //need to tell foundry to use this private key
        // deploy a contract by john as the deployer
        Payment payment = new Payment();
        
        vm.stopBroadcast();
        console2.log("The contract is deployed at address:", address(payment));
    }
}
