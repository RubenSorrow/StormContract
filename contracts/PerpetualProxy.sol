// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//Check veloce delle ownership
//Mintare una quantita', fare addFund, controllare che quanto ha l'admin sia giusta, controllare che 
//la percentuale mintata sia giusta 
//Controllo del withdraw 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BoltTokenProxy.sol";

contract PerpetualProxy is Ownable {
    using SafeMath for uint256;

    uint256 private antiDumpingPercentage;
    uint256 private percentageOfInterest;
    address private beneficiary;
    address private addressOfLogicImplementation;
    address private addressOfBoltTokenProxy;

    BoltTokenProxy boltTokenProxy;

    constructor(
        uint256 _percentageOfInterest,
        uint256 _antiDumpingPercentage,
        address _beneficiary,
        address _addressOfBoltTokenProxy
    ) {
        antiDumpingPercentage = _antiDumpingPercentage;
        percentageOfInterest = _percentageOfInterest;
        beneficiary = _beneficiary;
        addressOfBoltTokenProxy = _addressOfBoltTokenProxy;
        boltTokenProxy = BoltTokenProxy(addressOfBoltTokenProxy);
    }

    function getaddressOfBoltTokenProxy() public view returns(address) {
        return addressOfBoltTokenProxy;
    }

    function setaddressOfBoltTokenProxy(address _newAddress) public onlyOwner {
        addressOfBoltTokenProxy = _newAddress;
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

    function changeBeneficiary(address _newBeneficiary) public onlyBeneficiary(_msgSender()) {
        beneficiary = _newBeneficiary;
    }

    function getAntiDumpingPercentage() public view returns(uint256) {
        return antiDumpingPercentage;
    }

    function setAntiDumpingPercentage(uint256 _antiDumpingPercentage) public onlyOwner {
        antiDumpingPercentage = _antiDumpingPercentage;
    }

    function getReserve() public view returns (uint256) {
        return boltTokenProxy.balanceOf(address(this));
    }

    function getPercentageOfInterest() public view returns (uint256) {
        return percentageOfInterest;
    }

    function setPercentageOfinterest(uint256 _percentageOfInterest) public onlyLogicContract {
        percentageOfInterest = _percentageOfInterest;
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