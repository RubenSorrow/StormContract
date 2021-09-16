// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Address.sol";

contract BoltTokenProxy is Ownable {
    using SafeMath for uint256;
    using Address for address;

    // ## EVENTS ##
    event Mint(address indexed _account, uint256 _amount);
    event Burn(address indexed _account, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event SetAddressOfImplementation(address indexed _implementationAddress);
    event AddPerpetualAddress(address indexed _newAddress);

    // ## GLOBAL VARIABLES ##
    uint256 private currentSupply;
    uint256 private totalMintedToday;
    uint256 private lastTimestamp;
    uint8 private numberOfDecimals;
    string private nameOfToken;
    string private symbolOfToken;
    address private implementationAddress;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    mapping(address => bool) private isPerpetualAddress;

    // ## MODIFIERS ##
    modifier onlyImplementation() {
        require(_msgSender() == implementationAddress, "The sender is not a Zeus implementation");
        require(_msgSender().isContract(), "The sender is not a contract");
        _;
    }

    modifier oneTimeADay() {
        require(
            block.timestamp.sub(lastTimestamp) >= 1 days,
            "This function can be called only once per day"
        );
        _;
    }

    // ## CONSTRUCTOR ##
    constructor(
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol,
        uint8 _numberOfDecimals
    ) {
        _mint(_initialSupply);
        nameOfToken = _name;
        symbolOfToken = _symbol;
        numberOfDecimals = _numberOfDecimals;
    }

    // ## PUBLIC FUNCTIONS ##
    // # GET #
    function name() public view returns (string memory) {
        return nameOfToken;
    }

    function symbol() public view returns (string memory) {
        return symbolOfToken;
    }

    function decimals() public view returns (uint8) {
        return numberOfDecimals;
    }

    function getMintedToday() public view returns (uint256) {
        return totalMintedToday;
    }

    function totalSupply() public view returns (uint256) {
        return currentSupply;
    }

    function getNumberOfDecimals() public view returns (uint8) {
        return numberOfDecimals;
    }

    function getAddressOfImplementation() public view returns (address) {
        return implementationAddress;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function isTheAddressAPerpetual(address _address)
        public
        view
        returns (bool)
    {
        return isPerpetualAddress[_address];
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    // ## PUBLIC FUNCTIONS (ONLY IMPLEMENTATION) ##
    //ADD FUNDS
    function addBalance(address _to, uint256 _value) public onlyImplementation() {
        balances[_to] = balances[_to].add(_value);
    }

    //SUBTRACT FUNDS
    function subBalance(address _from, uint256 _value)
        public
        onlyImplementation()
    {
        balances[_from] = balances[_from].sub(_value);
    }

    //_APPROVE
    function approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) public onlyImplementation() returns(bool) {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        emit Approval(_owner, _spender, _amount);
        
        allowances[_owner][_spender] = _amount;
        return true;
    }

    // ## PUBLIC FUNCTIONS (ONLY OWNER) ##
    //ADD PERPETUAL ADDRESS
    function addPerpetualAddress(address _newAddress) public onlyOwner() returns(bool) {
        emit AddPerpetualAddress(_newAddress);
        
        _addPerpetualAddress(_newAddress);
        return true;
    }

    //BURN
    function burn(address _account, uint256 _amount) public onlyOwner() returns(bool) {
        emit Burn(_account, _amount);
        
        _burn(_account, _amount);
        return true;
    }

    //MINT (ONE TIME A DAY)
    /*function mint(uint256 _amount) public onlyOwner() oneTimeADay() returns(bool) {
        emit Mint(_msgSender(), _amount);
        
        _mint(_amount);
        return true;
    }*/
    
    function mint(uint256 _amount) public onlyOwner() returns(bool) {
        emit Mint(_msgSender(), _amount);
        
        _mint(_amount);
        return true;
    }

    // # SET #
    function setAddressOfImplementation(address _implementationAddress)
        public
        onlyOwner()
        returns(bool)
    {   
        emit SetAddressOfImplementation(_implementationAddress);
        
        implementationAddress = _implementationAddress;
        return true;
    }

    // ## PRIVATE ##
    //_ADD PERPETUAL ADDRESS
    function _addPerpetualAddress(address _newAddress) private {
        isPerpetualAddress[_newAddress] = true;
    }

    //_BURN
    function _burn(address _account, uint256 _amount) private {
        require(_account != address(0), "ERC20: burn to the zero address");
        require(balances[_account] >= _amount, "ERC20: burn amunt exceeds balance");
        unchecked {
            balances[_account] = balances[_account].sub(_amount);
        }
        currentSupply = currentSupply.sub(_amount);
    }

    //_MINT
    function _mint(uint256 _amount) private {
        require(_msgSender() != address(0), "ERC20: mint to the zero address");
        lastTimestamp = block.timestamp;
        totalMintedToday = _amount;
        currentSupply = currentSupply.add(_amount);
        balances[_msgSender()] = balances[_msgSender()].add(_amount);
    }
}
