/*
Implements a betting interface for simple wagers:

Bet {
	owner -- creator of the contract that defines its parameters.
	constructor (odds, stake, side) {
		- creates the bet defined by odds and stake.
		- places the message sender to the desired side.
		- sets the owner to message sender.
	}
	addStake(stake) {
		- makes sure contract capacity can still accept stake.
		- message sender stakes on the opposite side of the bet from contract owner.
	}
	execute() {
		- Checks that sender is bet creator (only they can execute)
		- Checks that the contract can be execute (when both sides of the bet are fully subscribed).
		- Runs the random mechanism resolving the bet.
		- Awards the winner the pool of coin.
	}
}
*/

pragma solidity ^0.6.9;

import "./EIP20Interface.sol";

contract BetAss {
	uint256 constant odds_denom = 10000; // what we divide odds by for the chance of a true outcome
	address owner; // the address of the contract creator, will be owner b/c they fully own one side of bet
	uint256 odds; // chance of true outcome --> odds / odds_denom
	// Formula to ensure equal odds weighted betting pool:
	// (1 - odds/odds_denom) * true_stake = (odds/odds_denom) * false_stake
	uint256 true_stake;
	uint256 false_stake;
	uint256 owner_stake; // redundant, but useful to have around
	bool owner_side;
	bool funded; // whether the owner has staked their side of the bet.
	// token that will be what this bet is denominated in
	EIP20Interface token;
	address token_address;
	constructor(
		uint256 _odds, 
		uint256 _stake, // how much the contract owner is staking on their side of the bet
		bool _side, // what side of the bet the contract owner is on.
		address _token_address 
	) public {
    	// set the owner of the contract
    	owner = msg.sender;
    	odds = _odds;
    	owner_stake = _stake;
    	owner_side = _side;
    	// creates an instance of the token contract to be used throughout the bet contract
    	token_address = _token_address;
    	token = EIP20Interface(_token_address);
    	// does a balance check
    	require(token.balanceOf(owner) > _stake, "Insufficient balance: can't stake more than you have");
    	// TODO: deducts the stake from the owner
    	
    	// TODO: sets the contract bet parameters
    	
    	
	}

	/*
	Method must be called by the contract owner. The contract owner must have already given this contract
	the neccessary allowance to stake the entire bet. If successful, funded var becomes true, and now betters
	can stake on the other side of the bet. If not successful, the contract will remain in the unstaked state,
	where no other betters can enter.
	*/
	function fundContract() public returns(bool success) {
		require(msg.sender == owner, "only the contract owner can fund this bet");
		bool transfered = token.transferFrom(owner, address(this), owner_stake);
		require (transfered, "funding was not successful, please make sure contract has the neccessary allowance for this token");
		funded = transfered;
		return transfered;		
	}

	/* Returns the odds of this contract */
	function getOdds() public view returns(uint256 curr_odds) {
		return odds;
	}

	function getOwner() public view returns(address curr_owner) {
		return owner;
	}

	function contractAddress() public view returns(address contract_address) {
		return address(this);
	}

	function tokenAddress() public view returns(address curr_token_address) {
		return token_address;
	}
}

