// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {modifiers} from "./modifiers.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoltTokenProxy is Context {
    using SafeMath for uint256;
    uint256 private initialSupply;
    uint256 private currentSupply;
    address private owner;
    uint8 private numberOfDecimals;
    string private nameOfToken;
    string private symbolOfToken;
    address private implementationAddress;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(
        uint256 _initialSupply,
        uint256 _currenSupply,
        string memory _name,
        string memory _symbol,
        uint8 _numberOfDecimals
    ) {
        initialSupply = _initialSupply;
        currentSupply = _currenSupply;
        owner = msg.sender;
        nameOfToken = _name;
        symbolOfToken = _symbol;
        numberOfDecimals = _numberOfDecimals;
    }

   
    function subtractFunds(address _from, uint256 _value)
        public
        onlyImplementation(_msgSender())
    {
        balances[_from] = balances[_from].sub(_value);
    }

    function addFunds(address _to, uint256 _value) public onlyImplementation(_msgSender()) {
        balances[_to] = balances[_to].add(_value);
    }

    function getAddressOfImplementation() external view returns (address) {
        return implementationAddress;
    }

    function setAddressOfImplementation(address _implementationAddress) public {
        require(
            _msgSender() == owner,
            "Only the owner of the contract can set the address of the implementation"
        );
        implementationAddress = _implementationAddress;
    }

    function totalSupply() external view returns (uint256) {
        return currentSupply;
    }

    function getInitialSupply() external view returns (uint256) {
        return initialSupply;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function name() external view returns (string memory) {
        return nameOfToken;
    }

    function symbol() external view returns (string memory) {
        return symbolOfToken;
    }

    function decimals() external view returns (uint8) {
        return numberOfDecimals;
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getNumberOfDecimals() external view returns (uint8) {
        return numberOfDecimals;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) public onlyImplementation(_msgSender()) {
        allowances[_owner][_spender] = _amount;
    }

    function mint(address _account, uint256 _amount) public onlyAdmin(_msgSender()) {
        _mint(_account, _amount);
    }

    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: mint to the zero address");
        currentSupply = currentSupply.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        emit Mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public onlyAdmin(_msgSender()) {
        _burn(_account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: burn to the zero address");
        uint256 accountBalance = balances[_account];
        require(accountBalance >= _amount, "ERC20: burn amunt exceeds balance");
        unchecked {
            balances[_account] = accountBalance - _amount;
        }
        currentSupply = currentSupply.add(_amount);
        emit Burn(_account, _amount);
    }

    event Mint(address indexed _account, uint256 _amount);
    event Burn(address indexed _account, uint256 _amount);

    modifier onlyAdmin(address _owner) {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyImplementation(address _implementationAddress) {
        require(msg.sender == _implementationAddress);
        _;
    }
}
