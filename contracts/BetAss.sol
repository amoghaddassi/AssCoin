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
	
	// vars for the owner information
	uint256 owner_stake;
	bool owner_funded; // whether the owner has staked their side of the bet.
	
	// vars for the public stakers: call public whoever takes the opposite side of the owner
	uint256 total_public_stake; // total value that the public needs to put on the opposite side of this bet
	mapping (address => uint256) public public_stakes; // mapping to hold the list of all public stakers
	uint256 curr_public_stake; // how much has currently been staked by the public
	bool public_funded; // only true when total_public_stake == curr_public_stake
	
	// token that will be what this bet is denominated in
	EIP20Interface token;
	address token_address;

	constructor(
		uint256 _odds, 
		uint256 _stake, // how much the contract owner is staking on their side of the bet
		address _token_address 
	) public {
    	// set the owner of the contract
    	owner = msg.sender;
    	odds = _odds;
    	owner_stake = _stake;
    	// TODO: actually calculate the public stake correctly using proportions
    	total_public_stake = _stake; 
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
		// verifies that contract has sufficient allowance to initiate the transfer
		uint256 allowed = token.allowance(owner, address(this));
		require(allowed >= owner_stake, "Insufficient allowance for contract to be funded");
		// Initiates the transfer
		bool transferred = token.transferFrom(owner, address(this), owner_stake);
		require(transferred, "funding not successful");
		// only reach this line if the contract has been funded
		owner_funded = true;
		return true;		
	}

	/*
	Will only succeed if stake < token allowance and stake < notowner_stake.
	Adds the message sender to the pool of bets taking the opposite side of the contract
	owner's bet. Payout is proportional to stake percent of total pool.
	*/
	function addStake(uint256 stake) public returns(bool success) {
		// checks that the owner has funded this contract
		// TODO: might not actually need this check, but that's a design decision
		require(owner_funded, "This contract is not accepting public stakes: the owner has not funded it yet");
		// check that the contract has not yet been fully funded by the public
		require(!public_funded, "This contract has already been fully funded by public stakers");
		// checks that there's enough room left in the public money pool
		require(stake <= total_public_stake - curr_public_stake,
				"Requested stake would oversubscribe the bet: stake less.");
		// checks that there is sufficient alloance
		uint256 allowed = token.allowance(msg.sender, address(this));
		require(allowed >= stake, "Insufficient allowance for requested stake to be executed");
		// initiates the transfer
		bool transferred = token.transferFrom(msg.sender, address(this), stake);
		require(transferred, "funding not successful");
		// means we succeeded, so add msg.sender to the public stakers
		public_stakes[msg.sender] += stake; // maps are 0 initialized, so this is fine
		curr_public_stake += stake;
		// updates the public_funded var
		if (curr_public_stake == total_public_stake) {
			public_funded = true;
		}
	}

	/*
	TODO: execute contract. Where the winner will be deceided and paid.
	*/
	function executeBet() public returns(bool outcome) {
		return false;
	}

	/*
	Returns the amount staker has staked in the public pool.
	*/
	function getStake(address staker) public view returns(uint256 _stake) {
		return public_stakes[staker];
	}

	// get functions for all main variables
	function getOdds() public view returns(uint256 _odds) {
		return odds;
	}

	function getOwner() public view returns(address _owner) {
		return owner;
	}

	function getTotalPublicStake() public view returns(uint256 _pub_stake) {
		return total_public_stake;
	}

	function getCurrentPublicStake() public view returns(uint256 _curr_pub_stake) {
		return curr_public_stake;
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
}

