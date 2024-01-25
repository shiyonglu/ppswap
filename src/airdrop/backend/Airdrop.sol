// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Import OpenZeppelin's ERC20 interface and SafeERC20 library
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IEName{
    function ename(address account) external returns (string memory);
    function donationAccount() external returns (address);
}

contract Airdrop {
    address donationAccount;
    uint256 feePerRecipient = 0.1 ether;

    address public constant ENAME_ADDRESS = 0xBAA5c79d9a4C9E60a19D1C7884E2b400A6D8211A; // on polygon

    using SafeERC20 for IERC20; // Use SafeERC20 for safe 
    
    
    constructor(address _donationAccount){
        donationAccount = _donationAccount;

    }

     // Mapping to track token balances for each user and token
    mapping(address => mapping(address => uint256)) public userTokenBalances;


    // Function for the sponsor to send ERC20 tokens to the contract
    function sponsorSendTokens(address erc20TokenAddress, address[] memory users, uint256 amount) public payable {
        uint256 numOfUsers = users.length;
        require(numOfUsers > 0, "No users provided");
        require(amount > 0, "Amount must be greater than zero");
        uint256 totalAmount = amount * numOfUsers;
        uint256 totalFee = feePerRecipient * numOfUsers;

        IEName enameContract = IEName(ENAME_ADDRESS);
        string memory myename = enameContract.ename(msg.sender);
     
        // check whether sufficient fee has been sent
        if(isEmptyString(myename))      // if NOT ename member
            require(msg.value >= totalFee, "Not sufficient fee sent.");
        else // ename member gets 50% discount
            require(msg.value >= totalFee >> 1, "Not sufficient fee sent.");


        // Ensure that the sender has approved the contract to transfer the tokens
        IERC20 erc20Token = IERC20(erc20TokenAddress);
        uint256 allowance = erc20Token.allowance(msg.sender, address(this));
        require(allowance >= totalAmount, "Insufficient allowance");

        // Transfer tokens to the contract using safeTransferFrom
        erc20Token.safeTransferFrom(msg.sender, address(this), totalAmount);

        // Distribute tokens to users
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            require(user != address(0), "Invalid user address");

            // Update user balances
            erc20Token.safeTransfer(user, amount);
        }
    }

    function isEmptyString(string memory inputstr) public pure returns (bool){
        return keccak256(abi.encode(inputstr)) == keccak256(abi.encode(""));
    }
}
