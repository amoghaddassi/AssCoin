var AssCoin = artifacts.require("./AssCoin.sol");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(AssCoin,
  				10000,
  				0,
  				"AssCoin",
  				"ASS")
};