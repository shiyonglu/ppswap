// Check other assert functions here: https://book.getfoundry.sh/reference/ds-test#asserting
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/emessage/backend/EMessage.sol";

contract EMessageTest is Test{
    EMessage emsg;

    address sender1 = makeAddr("sender1");
    address receiver1 = makeAddr("receiver1");
    address receiver2 = makeAddr("receiver2");

    
    function setUp() public {
        emsg = new EMessage();
        deal(sender1, 10000);
        deal(receiver1, 10000);
        deal(receiver2, 10000);
    }
   
    function testEMessage() public {
        vm.startPrank(sender1);
        emsg.sendEMessage{value: 1000}(receiver1, "Thank you 1", 1000);
        assertEq(receiver1.balance, 11000);

        vm.expectRevert();
        emsg.sendEMessage{value: 999}(receiver1, "Thank you 1", 1000);

        vm.expectRevert();
        emsg.sendEMessage{value: 1000}(receiver1, "Thank you 1", 999);

        emsg.sendEMessage{value: 1000}(receiver2, "Thank you 1", 1000);
        vm.stopPrank();
        
        assertEq(sender1.balance, 8000);

        assertEq(emsg.getOutgoingMessageCount(sender1), 2);
        assertEq(emsg.getIncomingMessageCount(receiver1), 1);
        assertEq(emsg.getIncomingMessageCount(receiver1), 1);  

    }


}
