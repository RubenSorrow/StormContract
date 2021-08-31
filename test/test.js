/**
 * @author Nick
 * To test:
 *  1) sudo truffle dev --network testnet
 *  2) migrate --reset
 *  3) test
 */

const Zeus = artifacts.require("../build/contracts/Zeus");
const boltTokenProxy = artifacts.require("../build/contracts/BoltTokenProxy");

contract("BoltTokenProxy", accounts => {
//BalaceOf Test.
    it("the admin should have 1 coins", async () =>
    {
        const instance = await boltTokenProxy.deployed();
        const balance = await instance.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), 1000000);
    })
//Transfer Test.
    it("should send coins correctly", async () => {
        let zeusInstance = await Zeus.deployed();
        let proxyInstance = await boltTokenProxy.deployed();
        const accountOne = accounts[0];
        const accountTwo = accounts[1];


        let balanceSender = await proxyInstance.balanceOf(accountOne);
        let balanceReceiver = await proxyInstance.balanceOf(accountTwo);
        
        const amount = 1000000;
        let accountOneStartingBalance = balanceSender.toNumber();
        let accountTwoStartingBalance = balanceReceiver.toNumber();
        await proxyInstance.setAddressOfImplementation(zeusInstance.address);
        await zeusInstance.transfer(accountOne, accountTwo, amount).catch(err => console.log(err))
        

        balanceSender = await proxyInstance.balanceOf(accountOne);
        balanceReceiver = await proxyInstance.balanceOf(accountTwo);

        let accountOneEndingBalance = balanceSender.toNumber();
        let accountTwoEndingBalance = balanceReceiver.toNumber();

        assert.equal(
            accountOneEndingBalance,
            accountOneStartingBalance - amount,
            "Amount wasn't correctly taken from the account"
        )

        assert.equal(
            accountTwoEndingBalance,
            accountTwoStartingBalance + amount,
            "Amount wasn't correctly given to the account"
        )
    })

})