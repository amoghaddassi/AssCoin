# AssCoin

Best new altcoin in the game. Expect a market cap of 100 billion soon enough once the traders get a hold of it. Backed by ASS.

Tech specs: this is an ERC20 token. Bout as obvious as it gets.

Deployed [here](https://ropsten.etherscan.io/token/0x6733c39bc0a4021c297d3207fd8ee057b4ec0f85)

### BetAss
This contract is meant to be a token ambigous (though obviously built around the great AssCoin) bet abstraction.

These are very simple coin flip style bets. Each bet is parameterized by:

- probability of success (for the owner)
- how much the owner will stake on success.
- which token the stake will be denominated in (must be an EIP20 token).

Then a public betting pool (essentially everyone that will put up the opposite side of the bet at even money stakes) is fully determined.

The contract facilitates all of the funding, bet execution and payouts. This contract is meant to be deployed many times, one for each bet made.

The architecture for the contract is essentially an implicit state machine, with the following states and transitions: contract creation --> owner funding --> public funding --> bet execution (run RNG) --> payout --> contract self destruct.

Example deployed [here](https://ropsten.etherscan.io/token/0x93031aBF353307463e30cCC0916cc376627E8D7c). In terms of the states above, this contract has been paid out, but not self destructed. It was created with the following parameters:

- Odds: 50 / 100
- Stake: 1
- Token: AssCoin (duh) linked above.


### Prereqs
- Node.js
- Truffle
- Infura
- Ropsten ether

### Deployment
`truffle compile`: will build all the contracts.

`truffle test`: execute the test suite for the contracts.

`truffle deploy`: will deploy to a local development net specified in truffle-config.js

`truffle deploy --network ropsten`: deploys to the ropsten test net. Need ether for tx fees.

**Note**: need to fill in infura key info in truffle-config.js before last step.


