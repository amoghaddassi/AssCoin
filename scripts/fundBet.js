/*
TODO: make this JS file work.
Will fully fund a deployed bet contract.
*/
// define the bet contract
let ba = await BetAss.deployed()
// define the token contract
let ass = await AssCoin.deployed()
// approve 100 token allowance for the contract
ass.approve(ba.address, 100, {from: accounts[0]})
// funds the contract
ba.fundContract()
process.exit()