var BetAss = artifacts.require("./BetAss.sol");

// AssCoin addresses:
// Dev net: 0xbcC48a41B0ee00C6C196324D87B182C935E017a3
// Ropsten: 0x6733c39bc0a4021c297d3207fd8ee057b4ec0f85

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(BetAss,
  				50,
  				1,
  				'0x6733c39bc0a4021c297d3207fd8ee057b4ec0f85')
};