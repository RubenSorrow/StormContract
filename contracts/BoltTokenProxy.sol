// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoltTokenProxy is Context {
    uint256 private initialSupply;
    uint256 private currentSupply;
    address private owner;
    uint8 private numberOfDecimals;
    string private nameOfToken;
    string private symbolOfToken;
    address private implementationAddress;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowance;
    
    constructor(uint256 _initialSupply, uint256 _currenSupply, string memory _name, string memory _symbol, uint8 _numberOfDecimals) {
        initialSupply = _initialSupply;
        currentSupply = _currenSupply;
        owner = msg.sender;
        nameOfToken = _name;
        symbolOfToken = _symbol;
        numberOfDecimals = _numberOfDecimals;
    }

    modifier onlyImplementation() {
        require(_msgSender() == implementationAddress);
        _;
    }

   //function setBalance(address _address, uint256 _amount) public onlyImplementation() {
   //    balances[_address] = _amount;
   //}

    function getAddressOfImplementation() external view returns(address){
        return implementationAddress;
    }

    function setAddressOfImplementation(address _implementationAddress) public onlyImplementation() {
        require(_msgSender() == owner, "Only the owner of the contract can set the address of the implementation");
        implementationAddress = _implementationAddress;
    }

    function totalSupply() external view returns(uint256) {
        return currentSupply;
    }

    function getInitialSupply() external view returns(uint256) {
        return initialSupply;
    }

    function getOwner() external view returns(address) {
        return owner;
    }

    function name() external view returns(string memory) {
        return nameOfToken;
    }

    function symbol() external view returns(string memory) {
        return symbolOfToken;
    }    

    function decimals() external view returns(uint8) {
        return numberOfDecimals;
    }

    function balanceOf(address user) external view returns(uint256) {
        return balances[user];
    }

    function getNumberOfDecimals() external view returns(uint8) {
        return numberOfDecimals;
    }
}