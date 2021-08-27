// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BoltTokenProxy.sol";
    
    contract bolt is Context {
        using SafeMath for uint;
        
        string version = "2";
        BoltTokenProxy  private myProxy;
        
        constructor(address _addressOfTokenProxy)  {
            myProxy = BoltTokenProxy(_addressOfTokenProxy);    
        }

        function getVersion() external view returns(string memory) {
            return version;
        }
        
        function transfer(address _to, uint256 _value) public returns (bool success) {
            address msgSender = _msgSender();
            emit Transfer(msgSender, _to, _value);
            myProxy.subtractFunds(msgSender, _value); 
            myProxy.addFunds(_to, _value);

            return true;
        }

        function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
            emit Transfer(_from, _to, _value);
            myProxy.subtractFunds(_from, _value);
            myProxy.addFunds(_to, _value);

            return true;
        }

        function approve(address _owner, address _spender, uint256 _amount) public {
            emit Approval(_owner, _spender, _amount);
            myProxy._approve(_owner, _spender, _amount);
        }

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }