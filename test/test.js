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
    it("the admin should have 3 coins", async () => {
        const instance = await boltTokenProxy.deployed();
        const balance = await instance.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), 3000000);
    })
       it("single gas cost for 100 transactions ", async () => {
           let zeusInstance = await Zeus.deployed();
           let proxyInstance = await boltTokenProxy.deployed();
   
           const accountOne = accounts[0];
           const accountTwo = accounts[1];
   
           const amount = 6666;
           
   
           await proxyInstance.setAddressOfImplementation(zeusInstance.address);
          let summ = 0;
   
          for (let i = 0; i<450; i++) {
             let  cost =  await zeusInstance.transfer(accountOne, accountTwo, amount).catch(err => console.log(err));
             summ += await cost.receipt.gasUsed;
              
          }
          console.log("total gas cost ", summ)    
   
        
   
       })
   /*  it("multiple transaction gas cost", async () => {
        let zeusInstance = await Zeus.deployed();
        let proxyInstance = await boltTokenProxy.deployed();
        let addressArray = [];
        for (let i = 0; i < 450; i++) {
            addressArray[i] = "0xB51019588E544D2010964f76F3e5A865684f7Ab9";
        }



        const amount = 3000000;
        await proxyInstance.setAddressOfImplementation(zeusInstance.address);
        let cost = await zeusInstance.multipleTransfer(addressArray, amount, 450
        );
        console.log("Total gas cost", cost.receipt.gasUsed)

    })
 */
    //Transfer Test.
    //it("should send coins correctly", async () => {
    //    let zeusInstance = await Zeus.deployed();
    //    let proxyInstance = await boltTokenProxy.deployed();
    //    const accountOne = accounts[0];
    //    const accountTwo = accounts[1];


    //    let balanceSender = await proxyInstance.balanceOf(accountOne);
    //    let balanceReceiver = await proxyInstance.balanceOf(accountTwo);

    //    const amount = 1000000;
    //    let accountOneStartingBalance = balanceSender.toNumber();
    //    let accountTwoStartingBalance = balanceReceiver.toNumber();
    //    await proxyInstance.setAddressOfImplementation(zeusInstance.address);
    //    await zeusInstance.transfer(accountOne, accountTwo, amount).catch(err => console.log(err))


    //    balanceSender = await proxyInstance.balanceOf(accountOne);
    //    balanceReceiver = await proxyInstance.balanceOf(accountTwo);

    //    let accountOneEndingBalance = balanceSender.toNumber();
    //    let accountTwoEndingBalance = balanceReceiver.toNumber();

    //    assert.equal(
    //        accountOneEndingBalance,
    //        accountOneStartingBalance - amount,
    //        "Amount wasn't correctly taken from the account"
    //    )

    //    assert.equal(
    //        accountTwoEndingBalance,
    //        accountTwoStartingBalance + amount,
    //        "Amount wasn't correctly given to the account"
    //    )
    //})

    ////Transfer With Fee Test.
    //it("should send coins correctly", async () => {
    //    let zeusInstance = await Zeus.deployed();
    //    let proxyInstance = await boltTokenProxy.deployed();
    //    const accountOne = accounts[0];
    //    const accountTwo = accounts[1];


    //    let balanceSender = await proxyInstance.balanceOf(accountOne);
    //    let balanceReceiver = await proxyInstance.balanceOf(accountTwo);

    //    const amount = 1000000;
    //    let accountOneStartingBalance = balanceSender.toNumber();
    //    let accountTwoStartingBalance = balanceReceiver.toNumber();
    //    await proxyInstance.setAddressOfImplementation(zeusInstance.address);
    //    await zeusInstance.transferWithFee(accountOne, accountTwo, amount).catch(err => console.log(err))

    //    balanceSender = await proxyInstance.balanceOf(accountOne);
    //    balanceReceiver = await proxyInstance.balanceOf(accountTwo);

    //    let accountOneEndingBalance = balanceSender.toNumber();
    //    let accountTwoEndingBalance = balanceReceiver.toNumber();

    //    assert.equal(
    //        accountOneEndingBalance,
    //        accountOneStartingBalance - amount,
    //        "Amount wasn't correctly taken from the account 1"
    //    )

    //    assert.equal(
    //        accountTwoEndingBalance,
    //        accountTwoStartingBalance + amount - amount / 1000,
    //        "Amount wasn't correctly given to the account 2"
    //    )
    //})

    ////Approve Test.
    //it("should approve 1 coin", async () => {
    //    let zeusInstance = await Zeus.deployed();
    //    let proxyInstance = await boltTokenProxy.deployed();

    //    const accountOne = accounts[0];
    //    const accountTwo = accounts[1];

    //    const amount = 1000000;

    //    await proxyInstance.setAddressOfImplementation(zeusInstance.address);
    //    await zeusInstance.approve(accountOne, accountTwo, amount).catch(err => console.log(err));


    //    let allowance = await proxyInstance.allowance(accountOne, accountTwo);

    //    assert.equal(
    //        amount,
    //        allowance,
    //        "Allowance and amount not equal"
    //    )

    //})

    ////Decerase Allowance Test.
    //it("should decrease allowance (acc.1 -> acc.2) of 1000", async () => {
    //    let zeusInstance = await Zeus.deployed();
    //    let proxyInstance = await boltTokenProxy.deployed();

    //    const accountOne = accounts[0];
    //    const accountTwo = accounts[1];

    //    const amount = 1000;

    //    await proxyInstance.setAddressOfImplementation(zeusInstance.address);
    //    await zeusInstance.decreaseAllowance(accountOne, accountTwo, amount).catch(err => console.log(err));

    //    let allowance = await proxyInstance.allowance(accountOne, accountTwo);

    //    assert.equal(
    //        999000,
    //        allowance,
    //        "Allowance and amount not equal"
    //    )

    //})
    //
    ////Increase Allowance Test.
    //it("should increase allowance (acc.1 -> acc.2) of 1000", async () => {
    //    let zeusInstance = await Zeus.deployed();
    //    let proxyInstance = await boltTokenProxy.deployed();

    //    const accountOne = accounts[0];
    //    const accountTwo = accounts[1];

    //    const amount = 1000;

    //    await proxyInstance.setAddressOfImplementation(zeusInstance.address);
    //    await zeusInstance.increaseAllowance(accountOne, accountTwo, amount).catch(err => console.log(err));

    //    let allowance = await proxyInstance.allowance(accountOne, accountTwo);

    //    assert.equal(
    //        1000000,
    //        allowance,
    //        "Allowance and amount not equal"
    //    )

    //})
    //
})//