# AssCoin

Best new altcoin in the game. Expect a market cap of 100 billion soon enough once the traders get a hold of it. Backed by ASS.

Tech specs: this is an ERC20 token. Bout as obvious as it gets.

Deployed [here](https://ropsten.etherscan.io/token/0x6733c39bc0a4021c297d3207fd8ee057b4ec0f85)

### BetAss
This contract is meant to be a token ambigous (though obviously built around the great AssCoin) bet abstraction.

These are very simple coin flip style bets. Each bet is parameterized by:

- probability of success (for the owner)
- how much the owner will stake on success.

Then a public betting pool (essentially everyone that will put up the opposite side of the bet at even money stakes) is fully determined.

The contract facilitates all of the funding, bet execution and payouts. Still a work in progress.

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


