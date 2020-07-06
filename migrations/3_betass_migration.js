var BetAss = artifacts.require("./BetAss.sol");

// AssCoin addresses:
// Dev net: 0xbCdEF55F69C5A855A3BC6A3Fb860a3F9b1A4e963
// Ropsten: 0x6733c39bc0a4021c297d3207fd8ee057b4ec0f85

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(BetAss,
  				50,
  				1,
  				'0x6733c39bc0a4021c297d3207fd8ee057b4ec0f85')
};