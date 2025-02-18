// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./BoltTokenProxy.sol";
import "./Zeus.sol";
import "./PerpetualProxy.sol";

contract PerpetualLogic is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeMath for uint8;
    using Address for address;

    uint256 private amountOfTokensSentDaily;
    uint256 private lastTimestamp;
    bool private didSendTokenToday = false;
    address private addressOfProxyImplementationOfZeus;
    address private logicImplementationOfZeus;
    address private addressProxyImplementationOfPerpetual;

    BoltTokenProxy private boltTokenProxy;
    Zeus private zeusContract;
    PerpetualProxy private perpetualProxy;

    constructor(
        address _addressOfProxyImplementationOfZeus,
        address _logicImplementationOfZeus,
        address _addressOfperpetualProxy
    ) {
        addressProxyImplementationOfPerpetual = _addressOfperpetualProxy;
        addressOfProxyImplementationOfZeus = _addressOfProxyImplementationOfZeus;
        logicImplementationOfZeus = _logicImplementationOfZeus;
        boltTokenProxy = BoltTokenProxy(_addressOfProxyImplementationOfZeus);
        zeusContract = Zeus(_logicImplementationOfZeus);
        perpetualProxy = PerpetualProxy(addressProxyImplementationOfPerpetual);
    }


    function getlogicImplementationOfZeus() public view returns(address){
        return logicImplementationOfZeus;
    }

    function setlogicImplementationOfZeus(address _logicImplementationOfZeus) public onlyOwner {
        logicImplementationOfZeus = _logicImplementationOfZeus;
    }

    function addFunds(uint256 _amount) public onlyOwner {
        _addFunds(_amount);
    }

    function _addFunds(uint256 _amount) private {
        zeusContract.transfer(_msgSender(), address(addressProxyImplementationOfPerpetual), _amount);
    }

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
    function withdraw(uint256 _amount) public onlyBeneficiary(_msgSender()) {
        _withdraw(_amount);
    }

    function _withdraw(uint256 _amount) private {
        require(perpetualProxy.getReserve() >= _amount, "Insufficient balance");
        require(
            _msgSender() != address(0),
            "ERC20: receiver of the contract can't be address(0)"
        );
 
        if ((amountOfTokensSentDaily + _amount) > getPercentageOfTotalSupply()) {
            revert("Limit of daily transfer reached");
        }

        if (block.timestamp.sub(lastTimestamp) > (1 days)) {
            amountOfTokensSentDaily = 0;
            start24HTimer();
        }

        //Calculate the new percentage of interest
        uint256 percentageOfInterest = perpetualProxy.getPercentageOfInterest();
        uint256 newPercentageOfInterest = percentageOfInterest.mul(_amount).div(perpetualProxy.getReserve());
        perpetualProxy.setPercentageOfinterest(newPercentageOfInterest);
        
        //Take the amount of tokens from the sender and give it to the receiver
        perpetualProxy.subReserve(_amount);
        amountOfTokensSentDaily.add(_amount);
        zeusContract.transfer(address(this), _msgSender(), _amount);
    }

    function start24HTimer() private {
        lastTimestamp = getTimeStamp();
        didSendTokenToday = true;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    //Calculate the 5% of the totalSupply of bolts
    function getPercentageOfTotalSupply() private view returns(uint256) {
        uint256 totalSupply = boltTokenProxy.totalSupply();
        return totalSupply.div(100).mul(perpetualProxy.getAntiDumpingPercentage());
    }

    modifier onlyBeneficiary(address _beneficiary) {
        require(perpetualProxy.getBeneficiary() == _beneficiary);
        _;
    }
}
