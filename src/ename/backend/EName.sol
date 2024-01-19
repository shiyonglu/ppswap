
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract ERC20{
    string public  name;
    string public symbol;
    uint8 public decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
    uint public _totalSupply = 1_000_000_000 ether; // one billion 

 
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint rawAmt);
    event Approval(address indexed tokenOwner, address indexed spender, uint rawAmt);
    event RenounceOwnership(address oldOwner, address newOwner); 
   
   constructor(string memory _name, string memory _symbol) {
         name = _name;
         symbol = _symbol; 
   }
    

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function _mint(address to, uint256 amount) internal{
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];

    }
    
 
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // called by the owner
    function approve(address spender, uint rawAmt) public returns (bool success) {
        
        allowed[msg.sender][spender] = rawAmt;
        emit Approval(msg.sender, spender, rawAmt);
        return true;
    }

    function transfer(address to, uint rawAmt) public returns (bool success) {
        return _transfer(msg.sender, to, rawAmt);
        
    }

    function _transfer(address from, address to, uint rawAmt) internal returns (bool success) {
        balances[from] = balances[from] - rawAmt;
        balances[to] = balances[to] + rawAmt;
        emit Transfer(from, to, rawAmt);
        return true;
    }
    
    // ERC the allowence function should be more specic +-
    function transferFrom(address from, address to, uint rawAmt) public returns (bool success) {
        allowed[from][msg.sender] = allowed[from][msg.sender] - rawAmt; // this will ensure the spender indeed has the authorization
        return _transfer(from, to, rawAmt);
    }       
}


contract EName is ERC20 {
    uint256 constant fee = 0.1 ether;
    uint256 giveaway = 1000 ether;

    address public donationAccount;
    mapping (address => string) public ename;
    mapping (string => address) public eaddress;

    constructor() ERC20("EName", "ENAME") {
        donationAccount = msg.sender;
         _mint(msg.sender, 1_000_000_000 ether);
    }

    // If you register a new name, you will lose your ename associated with this account
    // we only register lower_case name
    function register(string memory _ename) payable public {
        _ename = _toLower(_ename);

        require(msg.value >= fee, "Fee too low.");
        require(eaddress[_ename] == address(0), "EName already taken.");
        
        delete eaddress[ename[msg.sender]];
        
        ename[msg.sender] = _ename;
        eaddress[_ename] = msg.sender; 
        
        (bool success, ) = donationAccount.call{value: fee}("");
        require(success, "Donation fail. ");

        if(balanceOf(address(this)) >= giveaway ){
              _transfer(address(this), msg.sender, giveaway);
        }
    }

    function _toLower(string memory str) internal pure returns (string memory) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((bStr[i] >= 'A') && (bStr[i] <= 'Z')) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(uint8(bytes1(bStr[i])) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}

}
