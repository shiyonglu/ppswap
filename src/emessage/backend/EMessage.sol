fasf
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EMessage {
    address public owner;
    uint256 public messageCount;

    struct MessageInfo {
        address sender;
        address receiver;
        string content;
        uint256 maticAmount;
        uint256 timestamp;
    }

    mapping(uint256 => MessageInfo) public messages;
    mapping(address => uint256[]) public outgoingMessageIds;
    mapping(address => uint256[]) public incomingMessageIds;

    event MessageSent(
        uint256 indexed messageId,
        address indexed sender,
        address indexed receiver,
        string content,
        uint256 maticAmount,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
        messageCount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation");
        _;
    }

    receive() external payable {
        // Allow the contract to receive MATIC.
    }

    function sendEMessage(address _receiver, string memory _content, uint256 _maticAmount) external {
        require(msg.sender != _receiver, "You cannot send a message to yourself");
        require(_receiver != address(0), "Receiver address cannot be zero address");
        require(_maticAmount > 0, "You must send MATIC along with the message");
        
        messageCount++;

        messages[messageCount] = MessageInfo({
            sender: msg.sender,
            receiver: _receiver,
            content: _content,
            maticAmount: _maticAmount,
            timestamp: block.timestamp
        });

        // Record outgoing message ID for the sender.
        outgoingMessageIds[msg.sender].push(messageCount);

        // Record incoming message ID for the receiver.
        incomingMessageIds[_receiver].push(messageCount);

        // Send MATIC directly to the receiver.
        payable(_receiver).transfer(_maticAmount);

        emit MessageSent(messageCount, msg.sender, _receiver, _content, _maticAmount, block.timestamp);
    }

    function getOutgoingMessageIds(address _user, uint256 _start, uint256 _numOfMessages) external view returns (uint256[] memory) {
        uint256[] memory userOutgoingMessages = outgoingMessageIds[_user];
        uint256 end = _start + _numOfMessages > userOutgoingMessages.length ? userOutgoingMessages.length : _start + _numOfMessages;
        uint256[] memory result = new uint256[](end - _start);

        for (uint256 i = _start; i < end; i++) {
            result[i - _start] = userOutgoingMessages[i];
        }

        return result;
    }

    function getIncomingMessageIds(address _user, uint256 _start, uint256 _numOfMessages) external view returns (uint256[] memory) {
        uint256[] memory userIncomingMessages = incomingMessageIds[_user];
        uint256 end = _start + _numOfMessages > userIncomingMessages.length ? userIncomingMessages.length : _start + _numOfMessages;
        uint256[] memory result = new uint256[](end - _start);

        for (uint256 i = _start; i < end; i++) {
            result[i - _start] = userIncomingMessages[i];
        }

        return result;
    }

    function withdrawMATIC() external onlyOwner {
        uint256 balanceToWithdraw = address(this).balance;
        require(balanceToWithdraw > 0, "No MATIC balance to withdraw");
        payable(owner).transfer(balanceToWithdraw);
    }
}
