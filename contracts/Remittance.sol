pragma solidity ^0.4.18;

contract Remittance {
  address owner;
  
  //create an exchange struct
  struct Exchange {
    address exchangeAddress;
    uint commission;
    bool active;
    uint totalCommission;
  }

  mapping(bytes32 => Exchange) public exchangeMapping;

  //create a withdrawal struct 
  struct Withdrawal {
    address to;
    uint value;
    uint deadline;
  }

  mapping (bytes32 => Withdrawal) public withdrawals;

  event LogSetExchange(address,uint commission, bool active);
  event LogSetWithdrawal(address to, uint value, uint deadline);
  event LogWithdrawal(uint amount, address);
  event LogTotalCommission(uint);
  
  
  //constructor
  function Remittance(){
    owner == msg.sender;
  }

  //set exchange
  function setExchange(bytes32 _passwordHashExchange, uint _commission, bool _active) public returns(bool) {
    var exchange = exchangeMapping(_passwordHashExchange);
    exchange.exchangeAddress = msg.sender;
    exchange.commission = _commission;
    exchange.active = _active;
    exchange.totalCommission = 0;
    LogSetExchange(exchange.exchangeAddress,_commission,_active);
    return true;
  }

  function setWithdrawal(bytes32 _passwordHashExchange, bytes32 _passwordHashWithdrawer, address _to, uint _value, uint _deadline) public returns (bool) {
    if (exchangeMapping[_passwordHashExchange].active == true && msg.sender==exchangeMapping[_passwordHashExchange].exchangeAddress){
    var withdrawal = withdrawals(_passwordHashWithdrawer);
    withdrawal.to = _to;
    withdrawal.value = _value - exchangeMapping[_passwordHashExchange].commission;
    withdrawal.deadline = now+_deadline;
    LogSetWithdrawal(_to, withdrawal.value, withdrawal.deadline);
    return true;
    }
  }

  function withdraw(bytes32 _passwordHashExchange, bytes32 _passwordHash) returns (bool){
    uint amount;
    require(withdrawals[_passwordHash].value>0);
    if (withdrawals[_passwordHash].deadline >= now && withdrawals[_passwordHash].to == msg.sender){
    amount = withdrawals[_passwordHash].value;
    withdrawals[_passwordHash].value = 0;
    msg.sender.transfer(amount);
    LogWithdrawal(amount, msg.sender);
    exchangeMapping[_passwordHashExchange].totalCommission += exchangeMapping[_passwordHashExchange].commission;
    LogTotalCommission(exchangeMapping[_passwordHashExchange].totalCommission);
    return true;
    }
  }
}
