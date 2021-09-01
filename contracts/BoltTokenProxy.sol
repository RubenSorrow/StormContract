// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoltTokenProxy is Context {
    using SafeMath for uint256;
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

    address[] private addressesOfPerpetuals;

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
        _mint(_initialSupply);
        nameOfToken = _name;
        symbolOfToken = _symbol;
        numberOfDecimals = _numberOfDecimals;
    }

    function addPerpetualAddress(address _newAddress) public  {
        _addPerpetualAddress(_newAddress);
    }

    function _addPerpetualAddress(address _newAddress) private {
        addressesOfPerpetuals.push(_newAddress);
    }

    function getPerpetualAddresses() public view returns (address[] memory) {
        return addressesOfPerpetuals;
    }

    function isTheAddressAPerpetual(address _address)
        public
        view
        returns (bool)
    {
        uint256 i;
        for (i = 0; i < addressesOfPerpetuals.length; i++) {
            if (_address == addressesOfPerpetuals[i]) {
                return true;
            }
        }

        return false;
    }

    function subtractFunds(address _from, uint256 _value)
        public
        onlyImplementation
    {
        balances[_from] = balances[_from].sub(_value);
    }

    function addFunds(address _to, uint256 _value) public onlyImplementation {
        balances[_to] = balances[_to].add(_value);
    }

    function getAddressOfImplementation() public view returns (address) {
        return implementationAddress;
    }

    function setAddressOfImplementation(address _implementationAddress) public onlyOwner {
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

    function mint(uint256 _amount) public onlyOwner oneTimeADay {
        lastTimestamp = block.timestamp;
        _mint(_amount);
    }

    function _mint(uint256 _amount) internal {
        require(_msgSender() != address(0), "ERC20: mint to the zero address");
        totalMintedToday = _amount;
        currentSupply = currentSupply.add(_amount);
        balances[_msgSender()] = balances[_msgSender()].add(_amount);
        emit Mint(_msgSender(), _amount);
    }

    function burn(address _account, uint256 _amount) public onlyOwner {
        _burn(_account, _amount);
    }

    function getTotalMintedToday() public view returns (uint256) {
        return totalMintedToday;
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner of the contract can do this");
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
}
