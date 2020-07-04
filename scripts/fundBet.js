const AssCoin = artifacts.require("AssCoin");
const BetAss = artifacts.require("BetAss")

module.exports = function(callback) {
	async () => {
		let ba = await BetAss.deployed()
		let ass = await AssCoin.deployed()
		let bal = await ass.balanceOf.call(ba.address)
		console.log(bal.valueOf())
		console.log("test")
	}
	console.log("here")
}