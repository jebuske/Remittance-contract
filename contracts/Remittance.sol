pragma solidity ^0.4.18;

import "./Mortal.sol";

contract Remittance is Mortal {
  address owner;
  
  //create an exchange struct
  struct Exchange {
    address exchangeAddress;
    uint commission;
    bool active;
    uint totalCommission;
    uint balance;
    bytes32 passwordhash;
  }

  //create a mapping with all the exchanges by address
  mapping(address => Exchange) public exchangeMapping;

  //create a withdrawal struct 
  struct Withdrawal {
    address to;
    uint value;
    uint deadline;
  }

  mapping (bytes32 => Withdrawal) public withdrawals;

  //create a mapping to store all used passwords
  mapping (bytes32 => bool) usedPasswords;


  event LogSetExchange(address exchangeOwner, address exchangeAddress, uint commission, bool active);
  event LogSetWithdrawal(address to, uint value, uint deadline);
  event LogWithdrawal(uint amount, address);
  event LogTotalCommission(uint);
  event LogWithrawalOfCommission(uint commission, address to);
  
  modifier onlyOwner{
    require(msg.sender == owner);
    _;
  }

  //constructor
  function Remittance() public {
    owner == msg.sender;
  }

  //set exchange
  function setExchange(address _exchangeAddress, uint _commission, bool _active)
   public 
   returns(bool) {
    exchangeMapping[msg.sender]= Exchange({
      exchangeAddress: _exchangeAddress,
      commission: _commission,
      active: _active,
      totalCommission: 0,
      balance: 0,
      passwordhash:0
    });
    //emit event upon exchange creation
    LogSetExchange(msg.sender,_exchangeAddress, _commission,_active);
    return true;
  }

  function toggleExchangeOnOff(bool _OnOff) returns (bool success){
    exchangeMapping[msg.sender].active = _OnOff;
    return true;
  }

  function setWithdrawal(bytes32 _passwordHash, address _to, uint _deadline) payable public returns (bool) {
    require (_to!=0);
    if (exchangeMapping[msg.sender].active && !usedPasswords[_passwordHash]){
    withdrawals[_passwordHash]= Withdrawal({
      to:_to,
      value: msg.value - exchangeMapping[msg.sender].commission,
      deadline: now+_deadline
    });
    usedPasswords[_passwordHash] = true;
    LogSetWithdrawal(_to, msg.value, _deadline);
    return true;
    }
  }


  function withdraw(address _exchangeAddress, string _password) 
  public 
  returns (bool)
  {
    uint amount;
    bytes32 hashedPassword = keccak256(_password);

    require(withdrawals[hashedPassword].value>0);
    require(withdrawals[hashedPassword].to = msg.sender);
    require(withdrawals[hashedPassword].deadline >= now);

    amount = withdrawals[hashedPassword].value;
    withdrawals[hashedPassword].value = 0;
    exchangeMapping[_exchangeAddress].totalCommission += exchangeMapping[_exchangeAddress].commission;
    msg.sender.transfer(amount);
    LogWithdrawal(amount, msg.sender);
    LogTotalCommission(exchangeMapping[_exchangeAddress].totalCommission);
    return true;
  }
  

  function reclaimAfterDeadline(bytes32 _passwordHash) 
  private 
  onlyOwner 
  returns(bool)
  {
    require(withdrawals[_passwordHash].deadline<now);
    uint amount = withdrawals[_passwordHash].value;
    withdrawals[_passwordHash].value = 0;
    msg.sender.transfer(amount);
    }

  function withdrawCommission()
  returns (bool)
  {
    uint commission = exchangeMapping[msg.sender].totalCommission;
    exchangeMapping[msg.sender].totalCommission = 0;
    msg.sender.transfer(commission);
    LogWithrawalOfCommission(commission, msg.sender);
  }
}
