const Migrations = artifacts.require("Migrations");
const proxyContract = artifacts.require('../contracts/BoltTokenProxy');
const zeusContract = artifacts.require('../contracts/Zeus');
const perpetualProxy = artifacts.require("../contracts/PerpetualProxy");
const perpetualLogic = artifacts.require("../contracts/PerpetualLogic");

module.exports = async function (deployer) {
  deployer.deploy(Migrations);
  await deployer.deploy(proxyContract, 3050000000000, 3050000000000, "Bolts", "BOLT", 6).then(async () => {
    await deployer.deploy(zeusContract, proxyContract.address).then(async () => {
      //Reserve of 0 token, interest of 0.25, antidumping of 5, no beneficiary set, no logic set
      await deployer.deploy(perpetualProxy, 0, 250000, 5, "0x6E27D0d89AD3e93cbb3938f55a7f91e34C861732").then(async () => {
        await deployer.deploy(perpetualLogic, proxyContract.address, zeusContract.address, perpetualProxy.address)
      })
    })
  })
};
