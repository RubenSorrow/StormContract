const Zeus = artifacts.require("../build/contracts/Zeus");

contract("Zeus", account => {
    it("Should let me see the name of the coins", () => {
        Zeus.deployed()
        .then(instance => instance.name.call())
        .then(nameOfTheCoins => {
            Assert.equal(
                nameOfTheCoins,
                "Bolts",
                "Name incorrect"
            )
        })
    })
})