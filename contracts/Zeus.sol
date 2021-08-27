// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20.sol";
import "@openzeppelin-contracts/contracts/utils/Context.sol";
import "./BoltTokenProxy.sol";






       
    
    contract bolt  {
        using SafeMath for uint;
        
       
        BoltTokenProxy  private myProxy;
        string private tokenName;
        string private tokenSymbol;
        uint8  private tokenDecimals;
      
        
        
        uint256 private tokenTotalSupply;
        
        mapping(address => uint) balance;
        mapping(address=>mapping(address=>uint))allowed;
        
        
        constructor(address _addressOfTokenProxy)  {
            myProxy = BoltTokenProxy(_addressOfTokenProxy);

        
            
            
        }
        
       
      
        function transfer(address _to, uint256 _value) public override returns (bool success) {
            myProxy.balance[_msgsender()] = myProxy.balance[_msgsender()].sub(_value);
            myProxy.balance[_to] = myProxy.balance[_to].add(_value);
            emit Transfer(_msgsender(), _to, _value);
            return true;
        }
        function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
            myProxy.balance[_from] = myProxy.balance[_from].sub(_value);
            myProxy.balance[_to]   = myProxy.balance[_to].add(_value);
            emit Transfer(_from, _to, _value);
            return true;
            
        }
        function approve(address _spender, uint256 _value) public override returns (bool success) {
            myProxy.allowed[_msgsender()][_spender] = _value;
            emit Approval(_msgsender(), _spender, _value);
            return true;
        }
         function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
             return myProxy.allowed[_owner][_spender];
         }
    }