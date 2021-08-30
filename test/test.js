/**
 * @author Nick
 * To test:
 *  1) sudo truffle dev --network testnet
 *  2) migrate --reset
 *  3) test
 */

const Zeus = artifacts.require("../build/contracts/Zeus");
const boltTokenProxy = artifacts.require("../build/contracts/BoltTokenProxy");

contract("BoltTokenProxy", () => {

    // it("should be 3 million coins as totalSupply", () =>
    //     boltTokenProxy.deployed()
    //         .then(instance => instance.totalSupply())
    //         .then(totalSupply => {
    //             assert.equal(
    //                 totalSupply,
    //                 3050000000,
    //                 "There wasn't 3 million coins as totalSupply"
    //             )
    //         })
    // )

    it("the admin should have 1 coins", async () =>
    {
        const instance = await boltTokenProxy.deployed();
        const balance = await instance.balanceOf("0x6E27D0d89AD3e93cbb3938f55a7f91e34C861732");
        assert.equal(balance.valueOf(), 1000000);
    })

    it("should send coins correctly", async () => {
        let zeusInstance = await Zeus.deployed();
        let proxyInstance = await boltTokenProxy.deployed();
        const accountOne = "0x6E27D0d89AD3e93cbb3938f55a7f91e34C861732";
        const accountTwo = "0xeac4c5732999dedd4f6c7a6318a7d5301ef6eb3c";

        let balanceSender = await proxyInstance.balanceOf(accountOne);
        let balanceReceiver = await proxyInstance.balanceOf(accountTwo);
        
        const amount = 1000000;
        let accountOneStartingBalance = balanceSender.toNumber();
        let accountTwoStartingBalance = balanceReceiver.toNumber();

        await zeusInstance.transfer(accountOne, accountTwo, amount, {
            from: accountOne
        })

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