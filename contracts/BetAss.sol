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
	uint256 constant odds_denom = 100; // what we divide odds by for the chance of a true outcome
	uint256 odds; // chance of true outcome --> odds / odds_denom
	
	// Formula to ensure equal odds weighted betting pool:
	// public_stake = ((odds_denom - odds) / odds) * owner_stake
	
	// vars for the owner information
	address payable owner; // the address of the contract creator, will be owner b/c they fully own one side of bet
	uint256 owner_stake;
	bool owner_funded; // whether the owner has staked their side of the bet.
	
	// vars for the public stakers: call public whoever takes the opposite side of the owner
	address payable public_staker;
	uint256 public_stake; // total value that the public needs to put on the opposite side of this bet
	bool public_funded; // only true when total_public_stake == curr_public_stake
	
	enum Outcome { OWNER, PUBLIC } // for the 2 possible winners of the contract
	Outcome winner;

	bool executed; // flag after the execute function has been run.
	bool paid; // flag after the winnings have been paid out

	// token that will be what this bet is denominated in
	EIP20Interface token;
	address token_address;

	constructor(
		uint256 _odds, 
		uint256 _stake, // how much the contract owner is staking on their side of the bet
		address _token_address 
	) public {
		odds = _odds;
    	// set the owner of the contract
    	owner = msg.sender;
    	owner_stake = _stake;
    	// TODO: higher precision calculation
    	public_stake = owner_stake * ((odds_denom - odds) / odds);
    	// creates an instance of the token contract to be used throughout the bet contract
    	token_address = _token_address;
    	token = EIP20Interface(_token_address);
    	// does a balance check
    	require(token.balanceOf(owner) > _stake, "Insufficient balance: can't stake more than you have");    	
	}

	/*
	Method must be called by the contract owner. The contract owner must have already given this contract
	the neccessary allowance to stake the entire bet. If successful, funded var becomes true, and now betters
	can stake on the other side of the bet. If not successful, the contract will remain in the unstaked state,
	where no other betters can enter.
	*/
	function fundContract() public returns(bool success) {
		// verifies the sender
		require(msg.sender == owner, "only the contract owner can fund this bet");
		// verifies that the contract hasn't already been funded
		require(!owner_funded, "This contract has already been owner funded");
		// verifies that contract has sufficient allowance to initiate the transfer
		checkAllowance(owner, address(this), owner_stake);
		// Initiates the transfer
		transferCoin(owner, address(this), owner_stake);
		// only reach this line if the contract has been funded
		owner_funded = true;
		return true;		
	}

	/*
	Will only succeed if stake < token allowance and public funded false.
	Makes message sender take the opposite side of the bet from owner.
	*/
	function addStake(uint256 stake) public returns(bool success) {
		// checks that the owner has funded this contract
		// TODO: might not actually need this check, but that's a design decision
		require(owner_funded, "This contract is not accepting public stakes: the owner has not funded it yet");
		// check that the contract has not yet been fully funded by the public
		require(!public_funded, "This contract has already been fully funded by another staker");
		// makes sure stake is nonzero
		require(stake == public_stake, "Must stake the full amount of the bet");
		// checks that there is sufficient alloance
		checkAllowance(msg.sender, address(this), stake);
		// initiates the transfer
		transferCoin(msg.sender, address(this), stake);
		// means we succeeded, so make msg.sender the public stakers
		public_staker = msg.sender;
		public_funded = true;
	}

	/*
	Execute the contract in the following steps:
	- Check that the contract can be executed.
	- Run the random number generator.
	- Set winner var to owner or public.
	*/
	function executeBet() public returns(bool outcome) {
		// checks that the owner is executing the contract
		require(msg.sender == owner, "Only the contract owner can execute the contract");
		// make sure that both sides of the bet are funded
		require(owner_funded, "This contract has not been funded by its owner yet");
		require(public_funded, "This contract's public betting pool has not been fully funded yet");
		// makes sure that the contract hasn't already been executed
		require(!executed, "This contract has already been executed");
		// Run the RNG, effectively executing the bet
		uint256 rand = randomInt(odds_denom);
		executed = true;
		// By definition, the owner always takes the under.
 		if (rand < odds) {
			// means the owner won
			winner = Outcome.OWNER;
		} else {
			// means the public won
			winner = Outcome.PUBLIC;
		}
		return !(rand < odds); // returns if the owner won the bet
	}

	/*
	The randomness engine of this contract. Will return a pseudo random integer
	in the range [0, max).
	*/
	function randomInt(uint256 max) internal returns (uint256 rand) {
		return uint256(keccak256(abi.encode(block.timestamp, block.difficulty)))%max;
	}

	/*	
	Once the contract has been executed, anyone can call this function to payout
	the winner of the bet.
	*/
	function payoutWinner() public returns (bool success) {
		// check that the contract has been executed
		require(executed, "Must execute the contract before payout");
		// makes sure the contract hasn't already been paid out
		require(!paid, "This contract has already paid out winners");
		// pays out depending on the winner
		uint256 payout = owner_stake + public_stake;
		if (winner == Outcome.OWNER) {
			// means the contract owner gets the full balance
			// does the transfer
			transferCoin(address(this), owner, payout);
		} else {
			// means the public staker gets the full balance
			transferCoin(address(this), public_staker, payout);
		}
		paid = true;
		return true;
	}

	/*
	Self destruct function to run after the bet has been executed and payed out.
	Needs to be run by the contract owner.
	*/
	function closeContract() public returns (bool success) {
		// checks that the call is coming from the contract owner
		require(msg.sender == owner, "Only the owner can close this contract");
		// checks that the contract has already been paid out
		require(paid, "Contract can only be closed after the bet pool has been paid out");
		selfdestruct(owner);
		return true;
	}

	// 
	// TRANSACTION HELPER FUNCTIONS
	//
	/* checks that token allowance from --> to is > min */
	function checkAllowance(address _from, address _to, uint256 min)  internal returns(bool success){
		uint256 allowed = token.allowance(_from, _to);
		require(allowed >= min, "Insufficient allowance for requested stake to be executed");
		return true;
	}

	/* Helper function for doing coin transfers. Includes an error message.*/	
	function transferCoin(address _from, address _to, uint256 amount) internal returns(bool success) {
		// if sending coin from this contract, adds an allowance
		if (_from == address(this)) {
			token.approve(_to, amount);
		}
		bool transferred = token.transferFrom(_from, _to, amount);
		require(transferred, "token transfer not successful");
		return true;
	}

	//
	// VARIABLE GET FUNCTIONS
	//

	function getOdds() public view returns(uint256 _odds) {
		return odds;
	}

	function getOwner() public view returns(address _owner) {
		return owner;
	}

	function getPublicStake() public view returns(uint256 _pub_stake) {
		return public_stake;
	}

	function getOwnerFunded() public view returns(bool _owner_funded) {
		return owner_funded;
	}

	function getPublicFunded() public view returns(bool _public_funded) {
		return public_funded;
	}

	function contractAddress() public view returns(address _contract_address) {
		return address(this);
	}

	function tokenAddress() public view returns(address _token_address) {
		return token_address;
	}

	function getWinner() public view returns(bool ownerWon) {
		if (winner == Outcome.OWNER) {
			return true;
		} else {
			return false;
		}
	}
}

