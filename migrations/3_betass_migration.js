var BetAss = artifacts.require("./BetAss.sol");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(BetAss,
  				5,
  				1,
  				'0xbcC48a41B0ee00C6C196324D87B182C935E017a3')
};