// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Check veloce delle ownership
//Mintare una quantita', fare addFund, controllare che quanto ha l'admin sia giusta, controllare che
//la percentuale mintata sia giusta
//Controllo del withdraw
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BoltTokenProxy.sol";

contract PerpetualProxy is Ownable {
    using SafeMath for uint256;

    // ## EVENTS ##
    event SetPercentageOfInterest(uint256 _percentageOfInterest);
    event SetAddressOfLogicImplementation(address indexed _newAddress);
    event SetAntiDumpingPercentage(uint256 _antiDumpingPercentage);
    event ChangeBeneficiary(address indexed _newBeneficiary);

    // ## GLOBAL VARIABLES ##
    uint256 private antiDumpingPercentage;
    uint256 private percentageOfInterest;
    address private beneficiary;
    address private addressOfLogicImplementation;
    address private addressOfBoltTokenProxy;

    BoltTokenProxy private boltTokenProxy;

    // ## MODIFIERS ##
    modifier onlyBeneficiary() {
        require(_msgSender() == beneficiary);
        _;
    }

    modifier onlyLogicContract() {
        require(_msgSender() == addressOfLogicImplementation);
        _;
    }

    // ## CONTRUCTOR ##
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

    // ## PUBLIC FUNCTIONS ##
    // # GET #
    function getaddressOfBoltTokenProxy() public view returns (address) {
        return addressOfBoltTokenProxy;
    }

    function getAddressOfLogicImplementation() public view returns (address) {
        return addressOfLogicImplementation;
    }

    function getBeneficiary() public view returns (address) {
        return beneficiary;
    }

    function getAntiDumpingPercentage() public view returns (uint256) {
        return antiDumpingPercentage;
    }

    function getReserve() public view returns (uint256) {
        return boltTokenProxy.balanceOf(address(this));
    }

    function getPercentageOfInterest() public view returns (uint256) {
        return percentageOfInterest;
    }

    // ## PUBLIC FUNCTIONS (ONLY LOGIC CONTRACT)
    // # SET #
    function setPercentageOfInterest(uint256 _percentageOfInterest)
        public
        onlyLogicContract()
        returns(bool)
    {
        emit SetPercentageOfInterest(_percentageOfInterest);
        
        percentageOfInterest = _percentageOfInterest;
        return true;
    }

    // ## PUBLIC FUNCTIONS (ONLY OWNER)
    // # SET #
    function setAddressOfLogicImplementation(address _newAddress)
        public
        onlyOwner()
        returns(bool)
    {
        emit SetAddressOfLogicImplementation(_newAddress);
        
        addressOfLogicImplementation = _newAddress;
        return true;
    }

    function setAntiDumpingPercentage(uint256 _antiDumpingPercentage)
        public
        onlyOwner()
        returns(bool)
    {
        emit SetAntiDumpingPercentage(_antiDumpingPercentage);
        
        antiDumpingPercentage = _antiDumpingPercentage;
        return true;
    }

    // ## PUBLIC FUNCTIONS (ONLY BENEFICIARY)
    // # SET #
    function changeBeneficiary(address _newBeneficiary)
        public
        onlyBeneficiary()
        returns(bool)
    {
        emit ChangeBeneficiary(_newBeneficiary);
        
        beneficiary = _newBeneficiary;
        return true;
    }
}