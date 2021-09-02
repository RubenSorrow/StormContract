// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Pausable.sol";
import "./PerpetualProxy.sol";
import "./BoltTokenProxy.sol";

contract Zeus is Pausable {
    using SafeMath for uint256;

    // ## EVENTS ##
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 fee);
    event TransferStorm(address indexed _from, address indexed _to, uint256 _value);
    event FeeChanged(address indexed by, uint256 oldFee, uint256 newFee);

    // ## GLOBAL VARIABLES ##
    string version = "1";
    BoltTokenProxy private myProxy;
    uint256 private fee;

    // ## MODFIERS ##
    modifier onlyOwnerOrPerpetuals() {
        require(
            _msgSender() == myProxy.owner() ||
                myProxy.isTheAddressAPerpetual(_msgSender()),
            "The sender must be either the owner of the proxy or a perpetual contract"
        );
        _;
    }

    // ## CONSTRUCTOR ##
    constructor(address _addressOfTokenProxy, uint256 _fee) {
        myProxy = BoltTokenProxy(_addressOfTokenProxy);
        fee = _fee;
    }

    // ## PUBLIC FUNCTIONS ##
    //TRANSFER WITH FEE
    function transfer(address _recipient, uint256 _amount)
        public
        whenNotPaused()
        returns (bool success)
    {
        _transferFee(_msgSender(), _recipient, _amount);
        return true;
    }

    //APPROVE
    function approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) public whenNotPaused() {
        myProxy.approve(_owner, _spender, _amount);
    }

    //INCREASE ALLOWANCE
    function increaseAllowance(
        address _spender,
        uint256 _amount
    ) public whenNotPaused() returns (bool) {
        _increaseAllowance(_msgSender(),_spender, _amount);
        return true;
    }

    //DECREASE ALLOWANCE
    function decreaseAllowance(
        address _spender,
        uint256 _amount
    ) public whenNotPaused() returns (bool) {
        _decreaseAllowance(_msgSender(), _spender, _amount);
        return true;
    }
    
    //CALCULATE FEE
    function calculateFee(uint256 _amount) public view returns(uint256) {
        return _amount.mul(fee).div(10**8);
    }
    
    // # GET #
    function getVersion() public view returns (string memory) {
        return version;
    }
    
    function getFee() public view returns(uint256) {
        return fee;
    }

    // ## PUBLIC FUNCTIONS (ONLY OWNER OF PROXY) ##
    // # SET #

    // ## PUBLIC FUNCTIONS (ONLY OWNER OR PERPETUALS) ##
    //TRANSFER
    function transferStorm(
        address _recipient,
        uint256 _amount
    ) public onlyOwner() whenNotPaused() returns (bool success) {
        emit TransferStorm(_msgSender(), _recipient, _amount);
        
        _transfer(_msgSender(), _recipient, _amount);
        return true;
    }

    //TRANSFER FROM
    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public whenNotPaused() returns (bool) {

        uint256 currentAllowance = myProxy.allowance(_sender, _msgSender());
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            myProxy.approve(_sender, _msgSender(), _amount);
        }
         _transfer(_sender, _recipient, _amount);

        return true;
    }
    
    //ALLOW TO SPEND ON BEHALF OF OWNER
    function allowFromStorm(address _to,uint256 _amount) public onlyOwnerOrPerpetuals() {
        _increaseAllowance(owner(), _to, _amount);
    }

    // ## PRIVATE FUNCTIONS ##
    //_SETFEE
    function setFee(uint256 _fee) public onlyOwnerOrPerpetuals() whenNotPaused() returns(bool) {
        emit FeeChanged(_msgSender(), fee, _fee);
        
        fee = _fee;
        return true;
    }
    
    //_TRANSFER
    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        require(_sender != address(0), "ERC20: sender to the zero address");
        require(
            _recipient != address(0),
            "ERC20: receiver to the zero address"
        );
        require(
            myProxy.balanceOf(_sender) >= _amount,
            "ERC20: Transfer amount exceeds balance"
        );
        myProxy.subBalance(_sender, _amount);
        myProxy.addBalance(_recipient, _amount);

    }

    //_TRANSFER WITH FEE
    function _transferFee(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        require(_sender != address(0), "ERC20: sender to the zero address");
        require(
            _recipient != address(0),
            "ERC20: receiver to the zero address"
        );
        require(
            myProxy.balanceOf(_sender) >= _amount,
            "ERC20: Transfer amount exceeds balance"
        );
        uint256 _fee = _amount.mul(fee).div(10**8);
        if(_fee < 1) {
            _fee = 1;
        }
        emit Transfer(_sender, _recipient, _amount, _fee);

        _transfer(_sender, owner(), _fee);
        _amount = _amount.sub(_fee);
        myProxy.subBalance(_sender, _amount);
        myProxy.addBalance(_recipient, _amount);

    }

    //_INCREASE ALLOWANCE
    function _increaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) private {
        myProxy.approve(_owner, _spender, myProxy.allowance(_msgSender(), _spender) + _amount);
    }

    //_DECREASE ALLOWANCE
    function _decreaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) private {
        uint256 currentAllowance = myProxy.allowance(_owner, _spender);
        require(
            currentAllowance >= _amount,
            "ERC20: decreased allowance below zero"
        );
        myProxy.approve(_owner, _spender, currentAllowance - _amount);
    }

}