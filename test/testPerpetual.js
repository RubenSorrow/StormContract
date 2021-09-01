/**
 * @author Nick
 * To test:
 *  1) sudo truffle dev 
 *  2) migrate --reset
 *  3) test
 */

const zeusContract = artifacts.require("../build/contracts/Zeus");
const boltTokenProxy = artifacts.require("../build/contracts/BoltTokenProxy");
const perpetualProxy = artifacts.require("../build/contacts/PerpetualProxy");
const perpetualLogic = artifacts.require("../build/contacts/PerpetualLogic");

contract("PerpetualProxy", accounts => {

    it("The perpetual contract should be registered in the array of perpetual addresses", async () => {
        const instanceOfBoltTokenProxy = await boltTokenProxy.deployed();
        const instanceOfZeusContract = await zeusContract.deployed();
        const instanceOfPerpetualProxy = await perpetualProxy.deployed();
        const instanceOfPerpetualLogic = await perpetualLogic.deployed();

        await instanceOfBoltTokenProxy.addPerpetualAddress(instanceOfPerpetualProxy.address, {
            from: accounts[0]
        })
        const checkIfTheAddressIsAPerpetual = await instanceOfBoltTokenProxy.isTheAddressAPerpetual(instanceOfPerpetualProxy.address);
        assert.equal(
            checkIfTheAddressIsAPerpetual,
            true,
            "This isn't the address of a perpetual"
        )
    })

    it("Should let me see that the reserve of the first perpetual is 7625000000", async () => {
        const instanceOfBoltTokenProxy = await boltTokenProxy.deployed();
        const instanceOfZeusContract = await zeusContract.deployed();
        const instanceOfPerpetualProxy = await perpetualProxy.deployed();
        const instanceOfPerpetualLogic = await perpetualLogic.deployed();

        await instanceOfBoltTokenProxy.setAddressOfImplementation(instanceOfZeusContract.address ,{
            from: accounts[0]
        });
        
        await instanceOfPerpetualProxy.setAddressOfLogicImplementation(instanceOfPerpetualLogic.address, {
            from: accounts[0]
        });
        await instanceOfBoltTokenProxy.addPerpetualAddress(instanceOfPerpetualLogic.address, {
            from: accounts[0]
        });
        await instanceOfPerpetualLogic.addFunds({
            from: accounts[0]
        })
        assert.equal(
            7625000000,
            await instanceOfPerpetualProxy.getReserve(),
            "The reserve of the owner is not 7625000000"
        );
    })

    /*
        Test 1: Check the ownership of the perpetual contract, the owner must be Storm (the account that deploys the contract)
        but the beneficiary must be another account
    */
    it("The address of the logic of the perpetual is correct", async () => {
        const instanceOfPerpetualProxy = await perpetualProxy.deployed();
        const instanceOfPerpetualLogic = await perpetualLogic.deployed();

        await instanceOfPerpetualProxy.setAddressOfLogicImplementation(instanceOfPerpetualLogic.address);
        const addressOfLogicImplementation = await instanceOfPerpetualProxy.getAddressOfLogicImplementation();
        assert.equal(
            addressOfLogicImplementation,
            instanceOfPerpetualLogic.address,
            "The implementation address is not correct"
        );
    })

    it("Should set the correct beneficiary of the contract", async () => {
        const instanceOfPerpetualProxy = await perpetualProxy.deployed();
        const instanceOfPerpetualLogic = await perpetualLogic.deployed();
        assert.equal(
            await instanceOfPerpetualProxy.getBeneficiary(),
            accounts[0],
            "The beneficiary should be the one specified when the contract was deployed"
        )
        await instanceOfPerpetualProxy.setAddressOfLogicImplementation(instanceOfPerpetualLogic.address);
        await instanceOfPerpetualProxy.changeBeneficiary(accounts[1], {
            from: accounts[0]
        });
        //Check if the beneficiary has changed
        assert.equal(
            await instanceOfPerpetualProxy.getBeneficiary(),
            accounts[1],
            "The beneficiary is not correct"
        )
        //Check if the beneficiary hasn't changed
        assert.notEqual(
            await instanceOfPerpetualProxy.getBeneficiary(),
            accounts[0],
            "The address of the beneficiary didn't change"
        )
    })
})