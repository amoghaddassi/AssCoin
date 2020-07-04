const MetaCoin = artifacts.require("AssCoin");
const BetAss = artifacts.require("BetAss")

contract("AssCoin test", async accounts => {
	it("should put 10000 MetaCoin in the first account", async () => {
		let instance = await MetaCoin.deployed();
		let balance = await instance.balanceOf.call(accounts[0]);
		assert.equal(balance.valueOf(), 10000);
	});

	it("should send coin correctly", () => {
		let meta;

		// Get initial balances of first and second account.
		const account_one = accounts[0];
		const account_two = accounts[1];

		let account_one_starting_balance;
		let account_two_starting_balance;
		let account_one_ending_balance;
		let account_two_ending_balance;

		const amount = 10;
		return MetaCoin.deployed()
			.then(instance => {
				meta = instance;
				return meta.balanceOf.call(account_one);
			})
			.then(balance => {
				account_one_starting_balance = balance.toNumber();
				return meta.balanceOf.call(account_two);
			})
			.then(balance => {
				account_two_starting_balance = balance.toNumber();
				// https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts
				// different notation from balanceOf b/c this is a transaction that
				// changes the state of the network. This costs gas; calls don't.
				return meta.transfer(account_two, amount, {from: account_one});
			})
			.then(() => meta.balanceOf.call(account_one))
			.then(balance => {
				account_one_ending_balance = balance.toNumber();
				return meta.balanceOf.call(account_two);
			})
			.then(balance => {
				account_two_ending_balance = balance.toNumber();

				assert.equal(
					account_one_ending_balance,
					account_one_starting_balance - amount,
					"Amount wasn't correctly taken from the sender"
				);
				assert.equal(
					account_two_ending_balance,
					account_two_starting_balance + amount,
					"Amount wasn't correctly sent to the receiver"
				);
			});
	});
});

contract("BetAss test", async accounts => {
	it("should set odds to 5", async () => {
		let instance = await BetAss.deployed();
		let odds = await instance.getOdds.call();
		assert.equal(odds.valueOf(), 5);
	});

	
})