// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BoltTokenProxy.sol";
    
    contract bolt is IERC20, Context {
        using SafeMath for uint;
               
        BoltTokenProxy  private myProxy;
        string private tokenName;
        string private tokenSymbol;
        uint8  private tokenDecimals;
        uint256 private tokenTotalSupply;
        
        mapping(address=>mapping(address=>uint))allowed;
        
        constructor(address _addressOfTokenProxy)  {
            myProxy = BoltTokenProxy(_addressOfTokenProxy);    
        }
        
        function transfer(address _to, uint256 _value) public override returns (bool success) {
            emit Transfer(_msgSender(), _to, _value);
            
             myProxy.balances[_msgSender()] = myProxy.balances[_msgSender()].sub(_value);
             myProxy.balances[_to] = myProxy.balances[_to].add(_value);
            return true;
        }

        function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
             myProxy.balance[_from] = myProxy.balance[_from].sub(_value);
             myProxy.balance[_to]   = myProxy.balance[_to].add(_value);
            emit Transfer(_from, _to, _value);
            return true;
        }

        function approve(address _spender, uint256 _value) public override returns (bool) {
            return true;
        }

         function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
             return 90;
        }
    }