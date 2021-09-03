// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BoltTokenProxy.sol";
import "./Zeus.sol";
import "./PerpetualProxy.sol";
import "./Pausable.sol";

contract PerpetualLogic is Pausable {
    using SafeMath for uint256;

    // ## EVENTS ##
    event SetlogicImplementationOfZeus(address indexed _logicImplementationOfZeus);
    event FundsAdded(uint256 amount);
    event Withdrawn(address indexed by, uint256 amount);

    // ## GLOBAL VARIABLES ##
    uint256 private amountOfTokensSentDaily;
    uint256 private lastTimestamp;
    address private addressOfProxyBolt;
    address private logicImplementationOfZeus;
    address private addressOfProxyPerpetual;

    BoltTokenProxy private boltTokenProxy;
    Zeus private zeusContract;
    PerpetualProxy private perpetualProxy;

    // ## MODIFIERS ##
    modifier onlyBeneficiary() {
        require(
            perpetualProxy.getBeneficiary() == _msgSender(),
            "Only the beneficiary can call this function"
        );
        _;
    }

    // ## CONSTRUCTOR ##
    constructor(
        address _addressOfProxyBolt,
        address _logicImplementationOfZeus,
        address _addressOfperpetualProxy
    ) {
        addressOfProxyPerpetual = _addressOfperpetualProxy;
        addressOfProxyBolt = _addressOfProxyBolt;
        logicImplementationOfZeus = _logicImplementationOfZeus;
        boltTokenProxy = BoltTokenProxy(_addressOfProxyBolt);
        zeusContract = Zeus(_logicImplementationOfZeus);
        perpetualProxy = PerpetualProxy(addressOfProxyPerpetual);
    }

    // ## PUBLIC FUNCTIONS ##
    // # GET #
    function getlogicImplementationOfZeus() public view returns (address) {
        return logicImplementationOfZeus;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    // ## PUBLIC FUNCTIONS (ONLY OWNER) ##
    // # SET #
    function setlogicImplementationOfZeus(address _logicImplementationOfZeus)
        public
        onlyOwner()
        whenNotPaused()
        returns(bool)
    {
        emit SetlogicImplementationOfZeus(_logicImplementationOfZeus);
        
        logicImplementationOfZeus = _logicImplementationOfZeus;
        return true;
    }

    //ADD FUNDS
    function addFunds() public onlyOwner() whenNotPaused() returns(bool) {
        uint256 amount = _addFunds();
        
        emit FundsAdded(amount);
        
        return true;
    }

    // ## PUBLIC FUNCTIONS (ONLY BENEFICIARY)
    /*
        Everytime a withdraw is done the percentage of interest of the perpetual contract is reduced by 
        the amount: percentage of tokens transferred related to the total reserve of the perpetual.
        Example: if we withdraw 1 token and we've 10 tokens in our reserve then the percentage of interest
        decreases of 10%.
        There's a limit to daily withdraws: the limit is calculated by taking a fixed percentage (by the time 
        We're writing this comment is 5%) of the totalSupply of the tokens.
        Example: if we withdraw 1000 tokens and the totalSupply is 1 billion is okay because 1000 < 50000000
        if we withdraw 100000 tokens but the totalSupply is 1 million then It's wrong.
        Only the beneficiary of the contract itself can give out the benificiary role.
        Storm team has no direct manage of the funds locked inside the contract
    */
    function withdraw(uint256 _amount) public onlyBeneficiary() whenNotPaused() returns(bool) {
        emit Withdrawn(_msgSender(), _amount);
        
        _withdraw(_amount);
        return true;
    }

    // ## PRIVATE FUNCTIONS ##
    //Calculate the 5% of the totalSupply of bolts
    function getPercentageOfTotalSupply() private view returns (uint256) {
        uint256 totalSupply = boltTokenProxy.totalSupply();
        return
            totalSupply.div(100).mul(perpetualProxy.getAntiDumpingPercentage());
    }

    function _addFunds() private returns(uint256) {
        uint256 expectedBalanceOfPerpetual = boltTokenProxy
            .totalSupply()
            .mul(perpetualProxy.getPercentageOfInterest())
            .div(10**8);
        if (
            expectedBalanceOfPerpetual >
            boltTokenProxy.balanceOf(addressOfProxyPerpetual)
        ) {
            zeusContract.allowFromStorm(address(this), expectedBalanceOfPerpetual.sub(
                boltTokenProxy.balanceOf(addressOfProxyPerpetual)));
            zeusContract.transferFrom(
                owner(),
                addressOfProxyPerpetual,
                expectedBalanceOfPerpetual.sub(
                    boltTokenProxy.balanceOf(addressOfProxyPerpetual)
                )
            );
        }
        return expectedBalanceOfPerpetual.sub(boltTokenProxy.balanceOf(addressOfProxyPerpetual));
    }

    function _withdraw(uint256 _amount) private {
        require(perpetualProxy.getReserve() >= _amount, "Insufficient balance");
        require(
            _msgSender() != address(0),
            "ERC20: receiver of the contract can't be address(0)"
        );

        if (
            (amountOfTokensSentDaily + _amount) > getPercentageOfTotalSupply()
        ) {
            revert("Limit of daily transfer reached");
        }

        if (block.timestamp.sub(lastTimestamp) > (1 days)) {
            amountOfTokensSentDaily = 0;
            start24HTimer();
        }

        //Calculate the new percentage of interest
        if (_amount > 0) {
            uint256 percentageOfInterest = perpetualProxy
                .getPercentageOfInterest();
            uint256 lostInterest = percentageOfInterest
                .mul(_amount)
                .div(perpetualProxy.getReserve());
            perpetualProxy.setPercentageOfInterest(percentageOfInterest - lostInterest);
            //Take the amount of tokens from the sender and give it to the receiver
            amountOfTokensSentDaily.add(_amount);
            zeusContract.transferStorm(_msgSender(), _amount);
        }
    }

    function start24HTimer() private {
        lastTimestamp = getTimeStamp();
    }
}