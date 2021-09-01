// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./PerpetualProxy.sol";

contract Zeus is Context {
    using SafeMath for uint256;

    address private perpetualProxyAddress;
    string version = "1";
    BoltTokenProxy private myProxy;
    PerpetualProxy private perpetualProxy;


    constructor(address _addressOfTokenProxy) {
        myProxy = BoltTokenProxy(_addressOfTokenProxy);
    }

    function setPerpetualProxyAddress(address _newAddress) public onlyOwnerOfProxy {
        perpetualProxyAddress = _newAddress;
        perpetualProxy = PerpetualProxy(perpetualProxyAddress);
    }

    function getPerpetualProxyAddress() public view returns(address) {
        return perpetualProxyAddress;
    }

    function getVersion() external view returns (string memory) {
        return version;
    }

    function transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public onlyOwnerOfProxy returns (bool success) {
        _transfer(_sender, _recipient, _amount);
        return true;
    }

    function transferWithFee(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public returns (bool success) {
        _transferWithFee(_sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public onlyOwnerOfProxy returns (bool success) {
        _transfer(_sender, _recipient, _amount);

        uint256 currentAllowance = myProxy.allowance(_sender, _msgSender());
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            myProxy._approve(_sender, _msgSender(), _amount);
        }

        return true;
    }

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
        myProxy.subtractFunds(_sender, _amount);
        myProxy.addFunds(_recipient, _amount);

        emit Transfer(_sender, _recipient, _amount);
    }

    function multipleTransfer(
        address[] memory _array,
        uint256 _amount,
        uint256 _n
    ) public returns (bool) {
        _multipleTransfer(_array, _amount, _n);
        return true;
    }

    function _multipleTransfer(
        address[] memory _array,
        uint256 _amount,
        uint256 _n
    ) private {
        for (uint256 i = 0; i < _n; i++) {
            myProxy.subtractFunds(_msgSender(), _amount / _n);
            myProxy.addFunds(_array[i], _amount / _n);
        }
    }

    function _transferWithFee(
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

        uint256 fee = _amount.div(1000);
        _transfer(_sender, 0x498611b36e097b5e19003ac6DA315ab0af7512Bf, fee);
        _amount = _amount.sub(fee);
        myProxy.subtractFunds(_sender, _amount);
        myProxy.addFunds(_recipient, _amount);

        emit TransferWithFee(_sender, _recipient, _amount, fee);
    }

    function approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) public {
        myProxy._approve(_owner, _spender, _amount);
    }

    function increaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) public returns (bool) {
        require(
            myProxy.balanceOf(_owner) > _amount,
            "ERC20: sender does not have enough money"
        );
        _increaseAllowance(_owner, _spender, _amount);
        return true;
    }

    function _increaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 currentAllowance = myProxy.allowance(_owner, _spender);
        myProxy._approve(_owner, _spender, currentAllowance + _amount);
    }

    function decreaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) public returns (bool) {
        require(_amount >= 0, "ERC20: sender does not have enough money");
        _decreaseAllowance(_owner, _spender, _amount);
        return true;
    }

    function _decreaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        uint256 currentAllowance = myProxy.allowance(_owner, _spender);
        require(
            currentAllowance >= _amount,
            "ERC20: decreased allowance below zero"
        );
        myProxy._approve(_owner, _spender, currentAllowance - _amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferWithFee(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fee
    );

    modifier onlyOwnerOrPerpetuals() {
        require(
            _msgSender() == myProxy.getOwner() || myProxy.isTheAddressAPerpetual(_msgSender()),
            "The sender must be either the owner of the proxy or a perpetual contract"
        );
        _;
    }

    modifier onlyOwnerOfProxy() {
        require(
            _msgSender() == myProxy.getOwner(),
            "The sender must be the owner of the proxy"
        );
        _;
    }
}
