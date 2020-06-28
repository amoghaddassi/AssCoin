var Migrations = artifacts.require("Migrations.sol");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(Migrations)
};
