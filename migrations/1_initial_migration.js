const Migrations = artifacts.require("Migrations");
const proxyContract = artifacts.require('../contracts/BoltTokenProxy');
const zeusContract = artifacts.require('../contracts/Zeus');

module.exports = async function (deployer) {
  deployer.deploy(Migrations);
  await deployer.deploy(proxyContract, 3000000000, 3000000000, "Bolts", "BOLT", 6).then(async () => {
    await deployer.deploy(zeusContract, proxyContract.address);
  })
};
