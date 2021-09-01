// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoltTokenProxy is Context {
    using SafeMath for uint256;

    // ## EVENTS ##
    event Mint(address indexed _account, uint256 _amount);
    event Burn(address indexed _account, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    event SetAddressOfImplementation(address indexed _implementationAddress);
    event AddPerpetualAddress(address indexed _newAddress);

    // ## GLOBAL VARIABLES ##
    uint256 private initialSupply;
    uint256 private currentSupply;
    uint256 private totalMintedToday;
    address private owner;
    uint8 private numberOfDecimals;
    string private nameOfToken;
    string private symbolOfToken;
    address private implementationAddress;
    uint256 private lastTimestamp;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    mapping(address => bool) private isPerpetualAddress;

    // ## MODIFIERS ##
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner of the contract can do this"
        );
        _;
    }

    modifier onlyImplementation() {
        require(msg.sender == implementationAddress);
        _;
    }

    modifier oneTimeADay() {
        require(
            block.timestamp.sub(lastTimestamp) < 1 days,
            "this function can be called just once per day"
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
        owner = msg.sender;
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

    function getOwner() public view returns (address) {
        return owner;
    }

    function getInitialSupply() public view returns (uint256) {
        return initialSupply;
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
    function addBalance(address _to, uint256 _value) public onlyImplementation {
        balances[_to] = balances[_to].add(_value);
    }

    //SUBTRACT FUNDS
    function subBalance(address _from, uint256 _value)
        public
        onlyImplementation
    {
        balances[_from] = balances[_from].sub(_value);
    }

    //_APPROVE
    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) public onlyImplementation {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        require(
            balances[_owner] >= _amount,
            "ERC20: balance less than amount to approve"
        );
        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    // ## PUBLIC FUNCTIONS (ONLY OWNER) ##
    //ADD PERPETUAL ADDRESS
    function addPerpetualAddress(address _newAddress) public onlyOwner {
        _addPerpetualAddress(_newAddress);
    }

    //BURN
    function burn(address _account, uint256 _amount) public onlyOwner {
        _burn(_account, _amount);
    }

    //MINT (ONE TIME A DAY)
    function mint(uint256 _amount) public onlyOwner oneTimeADay {
        lastTimestamp = block.timestamp;
        _mint(_amount);
    }

    // # SET #
    function setAddressOfImplementation(address _implementationAddress)
        public
        onlyOwner
    {
        implementationAddress = _implementationAddress;

        emit SetAddressOfImplementation(_implementationAddress);
    }

    // ## PRIVATE ##
    //_ADD PERPETUAL ADDRESS
    function _addPerpetualAddress(address _newAddress) private {
        isPerpetualAddress[_newAddress] = true;

        emit AddPerpetualAddress(_newAddress);
    }

    //_BURN
    function _burn(address _account, uint256 _amount) private {
        require(_account != address(0), "ERC20: burn to the zero address");
        uint256 accountBalance = balances[_account];
        require(accountBalance >= _amount, "ERC20: burn amunt exceeds balance");
        unchecked {
            balances[_account] = accountBalance - _amount;
        }
        currentSupply = currentSupply.add(_amount);
        emit Burn(_account, _amount);
    }

    //_MINT
    function _mint(uint256 _amount) private {
        require(_msgSender() != address(0), "ERC20: mint to the zero address");
        totalMintedToday = _amount;
        currentSupply = currentSupply.add(_amount);
        balances[_msgSender()] = balances[_msgSender()].add(_amount);
        emit Mint(_msgSender(), _amount);
    }
}
