
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract testCalldata{
    uint public finalresult;
    uint public offsetBytes;

    function returnNegative(int a) public pure returns (int) {
         return -a;
    }
   
    function add(uint a, uint b) public pure returns (uint){
         return a + b;
    }

    function test3(uint a, address, uint b) public pure returns (uint){
        return a + b;
    }

    function test4(uint a, string calldata, uint b) public pure returns (uint){
        return a + b;
    }

    function test5(uint a, bytes calldata v, uint _start) public returns (uint){
        finalresult = uint256(internalFun1(v, _start));
        return finalresult;
    }

    function internalFun1 (bytes calldata v, uint _start) internal returns (uint16 result)
    {
         
       assembly{
           sstore(offsetBytes.slot, v.offset) 
           let offset := sub(v.offset, 30)
           result := calldataload(add(offset, _start)) 
       } 
    }
   
}



