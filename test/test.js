/**
 * @author Nick
 * To test:
 *  1) sudo truffle dev --network testnet
 *  2) migrate --reset
 *  3) test
 */

const Zeus = artifacts.require("../build/contracts/Zeus");
const boltTokenProxy = artifacts.require("../build/contracts/BoltTokenProxy");

contract("BoltTokenProxy", account => {
    it("should be 3 million coins as totalSupply", () =>
        boltTokenProxy.deployed()
            .then(instance => instance.totalSupply())
            .then(totalSupply => {
                assert.equal(
                    totalSupply,
                    3050000000,
                    "There wasn't 3 million coins as totalSupply"
                )
            })
    )

    it("the name should be Bolts", () =>
            boltTokenProxy.deployed()
                .then(instance => instance.name())
                .then(nameOfTheToken => {
                    assert.equal(
                        nameOfTheToken, 
                        "Bolts",
                        "The name wasn't Bolt"
                    )
                })
    )
})