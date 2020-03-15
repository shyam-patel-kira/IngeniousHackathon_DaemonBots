pragma solidity ^0.5.16;

import "./ConvertLib.sol";

contract SimpleValueTokens {
    // holds the current balances of all accounts
	mapping (address => uint) balances;
    
    uint public TOKEN2INRRATE = 10; 

    // Tranfer Event
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Constructor... initially every account given with 25000 tokens for trade 
    constructor() public {
        balances[tx.origin] = 25000;
    }

    // Pay coins to others...
    function PayTokens(address receiver, uint numTokens) public returns (bool) {
        // if not enough coins availble 
        if (balances[msg.sender] < numTokens) return false;
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // returns the balance of the account
    function getBalance(address account) public returns (uint) {
        return balances[account];
    }

    // Convert INR to value tokens 
	function convert2Tokens(uint currency) public view returns (uint){
        return currency / TOKEN2INRRATE ;
    }

    // Convert INR to value tokens 
	function convert2Currency(uint numTokens) public view returns (uint){
        return numTokens * TOKEN2INRRATE ;
    } 
} 