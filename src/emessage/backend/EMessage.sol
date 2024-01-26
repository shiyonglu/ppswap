// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EMessage {
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


    function sendEMessage(address _receiver, string memory _content, uint256 _maticAmount) payable external {
        require(_maticAmount == msg.value, "MATIC amount does not match");
    
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
        (bool success, ) = _receiver.call{value: _maticAmount}("");
        require(success);
    }

    function getOutgoingMessageCount(address _user) external view returns (uint256) {
             return outgoingMessageIds[_user].length;
    }

    function getIncomingMessageCount(address _user) external view returns (uint256) {
             return incomingMessageIds[_user].length;
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
}
