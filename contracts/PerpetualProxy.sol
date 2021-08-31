// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PerpetualProxy is Ownable {
    using SafeMath for uint256;

    uint256 private reserve;
    uint256 private antiDumpingPercentage;
    uint256 private percentageOfInterest;
    address private beneficiary;
    address private addressOfLogicImplementation;

    constructor(
        uint256 _initialReserve,
        uint8 _percentageOfInterest,
        uint256 _antiDumpingPercentage,
        address _beneficiary,
        address _addressOfLogicImplementation
    ) {
        antiDumpingPercentage = _antiDumpingPercentage;
        reserve = _initialReserve;
        percentageOfInterest = _percentageOfInterest;
        beneficiary = _beneficiary;
        addressOfLogicImplementation = _addressOfLogicImplementation;
    }

    function getAddressOfLogicImplementation() public view returns(address) {
        return addressOfLogicImplementation;
    }

    function setAddressOfLogicImplementation(address _newAddress) public onlyOwner {
        addressOfLogicImplementation = _newAddress;
    }

    function getBeneficiary() public view returns(address) {
        return beneficiary;
    }

    function changeBeneficiary(address _newBeneficiary) public onlyBeneficiary(_newBeneficiary) {
        beneficiary = _newBeneficiary;
    }

    function getAntiDumpingPercentage() public view returns(uint256) {
        return antiDumpingPercentage;
    }

    function setAntiDumpingPercentage(uint256 _antiDumpingPercentage) public onlyOwner {
        antiDumpingPercentage = _antiDumpingPercentage;
    }

    function getReserve() public view returns (uint256) {
        return reserve;
    }

    function getPercentageOfInterest() public view returns (uint256) {
        return percentageOfInterest;
    }

    function setPercentageOfinterest(uint256 _percentageOfInterest) public onlyLogicContract {
        percentageOfInterest = _percentageOfInterest;
    }

    function addReserve(uint256 _amount) public view onlyLogicContract {
        reserve.add(_amount);   
    }

    function subReserve(uint256 _amount) public view onlyLogicContract {
        reserve.sub(_amount);
    }

    modifier onlyBeneficiary(address _beneficiary) {
        require(beneficiary == _beneficiary);
        _;
    }

    modifier onlyLogicContract() {
        require(_msgSender() == addressOfLogicImplementation);
        _;
    }
}