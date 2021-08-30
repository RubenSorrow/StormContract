const Migrations = artifacts.require("Migrations");
const proxyContract = artifacts.require('../contracts/BoltTokenProxy');
const zeusContract = artifacts.require('../contracts/Zeus');
const zeusContractV2 = artifacts.require('../contracts/ZeusV2');

module.exports = async function (deployer) {
  deployer.deploy(Migrations);
  await deployer.deploy(proxyContract, 3050000000000, 3050000000000, "Bolts", "BOLT", 6).then(async () => {
    await deployer.deploy(zeusContract, proxyContract.address, '0xcaBC8D973E438EFCFaf7DA28b6B69eA77B6990D2');
  })
};
