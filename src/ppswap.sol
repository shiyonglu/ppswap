/*
The PPSwap smart contract is designed to facilitate decentralized trading of any ERC20 token on the Ethereum blockchain. 
Utilizing OpenZeppelin's ERC20 and SafeERC20 libraries, it allows users to create offers specifying the sale terms of any 
ERC20 token they own, set their desired price in Ether, and define the maximum quantity available for sale. Other participants 
can accept these offers by sending the corresponding Ether amount, executing trades directly through the contract, which securely 
handles the token transfers with proper approvals. This flexible trading mechanism is further enhanced by detailed event logging 
for transparency and offers robust security features like reentrancy guards to ensure safe and reliable transactions.

Hint: can we implement a bonding curve for PPS price: https://medium.com/coinmonks/token-bonding-curves-explained-7a9332198e0e
*/


// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PPSwap is ERC20 {
    using SafeERC20 for IERC20;

    uint256 public constant INITIAL_SUPPLY = 1e27; // 1 billion tokens, assuming 18 decimals
    uint256 public lastOfferID = 0; 
    uint256 public ppsPrice = 0.0001 ether;      // how much ether for 1 unit of PPS (10***18)
    address payable public trustAccount; 
    address public contractOwner;

    enum OfferStatus { Created, Filled, Cancelled }

    struct Offer {
        IERC20 token;
        uint256 price;
        uint256 maxBuy;
        address payable maker;
        OfferStatus status;
    }

    mapping(uint256 => Offer) public offers;

    event MakeOffer(uint256 indexed offerID, address indexed token, uint256 price, uint256 maxBuy);
    event CancelOffer(uint256 indexed offerID);
    event AcceptOffer(uint256 indexed offerID, uint256 tokenAmt, uint256 ethAmt);
    event BuyPPS(uint256 ETHAmt, uint256 PPSAmt);
    event SellPPS(uint256 PPSAmt, uint256 ETHAmt);
    event Withdraw(uint256 amount);
    event Deposit(uint256 amount);

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can call this function.");
        _;
    }

    constructor(address payable _trustAccount) ERC20("PPSwapTesting1", "PPS") {
        _mint(_trustAccount, INITIAL_SUPPLY);
        contractOwner = msg.sender;
        trustAccount = _trustAccount;
    }

    function makeOffer(address _token, uint256 price, uint256 maxBuy) external returns (uint256) {
        lastOfferID += 1;
        offers[lastOfferID] = Offer({
            token: IERC20(_token),
            price: price,
            maxBuy: maxBuy,
            maker: payable(msg.sender),
            status: OfferStatus.Created
        });
        IERC20(_token).approve(address(this), maxBuy);
        emit MakeOffer(lastOfferID, _token, price, maxBuy);
        return lastOfferID;
    }

    function cancelOffer(uint256 offerID) external {
        require(offers[offerID].maker == msg.sender, "Only the offer maker can cancel this offer.");
        offers[offerID].status = OfferStatus.Cancelled;
        emit CancelOffer(offerID);
    }

    function acceptOffer(uint256 offerID) external payable {
        Offer storage offer = offers[offerID];
        require(offer.status == OfferStatus.Created, "This order has been either cancelled or filled.");
        
        uint256 tokenAmt = msg.value * 1e18 / offer.price; // Calculate the amount of token to be bought based on ETH sent
        require(tokenAmt <= offer.maxBuy, "The amount you buy exceeds the buy limit.");
        
        offer.token.safeTransferFrom(offer.maker, msg.sender, tokenAmt);
        offer.maker.transfer(msg.value);
        offer.status = OfferStatus.Filled;
        emit AcceptOffer(offerID, tokenAmt, msg.value);
    }

    function buyPPS() public payable {
        uint256 rawPPSAmt = msg.value * 1e18 / ppsPrice;
        _transfer(address(this), msg.sender, rawPPSAmt);
        emit BuyPPS(msg.value, rawPPSAmt);
    }

    function sellPPS(uint256 amtPPS) public {
        uint256 amtETH = ppsPrice * amtPPS / 1e18;
        _transfer(msg.sender, address(this), amtPPS);
        (bool success, ) = msg.sender.call{value: amtETH}("");
        require(success, "Failed to send Ether");
        emit SellPPS(amtPPS, amtETH);
    }
}
