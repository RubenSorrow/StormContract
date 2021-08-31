// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@opengsn/contracts/src/BaseRelayRecipient.sol";
import "./BoltTokenProxy.sol";

contract Zeus is BaseRelayRecipient {
    using SafeMath for uint256;

    string version = "1";
    BoltTokenProxy private myProxy;

    constructor(address _addressOfTokenProxy, address _forwarder) {
        myProxy = BoltTokenProxy(_addressOfTokenProxy);
        trustedForwarder = _forwarder;
    }

    function _msgSender()
        internal
        view
        override(BaseRelayRecipient)
        returns (address payable)
    {
        return BaseRelayRecipient._msgSender();
    }

    function _msgData()
        internal
        view
        override(BaseRelayRecipient)
        returns (bytes memory ret)
    {
        return BaseRelayRecipient._msgData();
    }

    string public override versionRecipient = "2.2.0";

    function getVersion() external view returns (string memory) {
        return version;
    }

    function transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public returns (bool success) {
        _transfer(_sender, _recipient, _amount);
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

    modifier onlyOwnerOfProxy() {
        require(
            _msgSender() == myProxy.getOwner(),
            "The sender must be the owner of the proxy"
        );
        _;
    }
}
