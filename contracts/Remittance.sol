pragma solidity ^0.4.18;

contract Remittance {
  address owner;
  
  //create an exchange struct
  struct Exchange {
    address exchangeAddress;
    uint commission;
    bool active;
    uint totalCommission;
    uint balance;
  }

  mapping(address => Exchange) public exchangeMapping;

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
  event LogAddAmount(uint amount, address from);
  
  modifier onlyOwner{
    require(msg.sender == owner);
    _;
  }

  //constructor
  function Remittance(){
    owner == msg.sender;
  }

  //set exchange
  function setExchange(uint _commission, bool _active) public returns(bool) {
    exchangeMapping[msg.sender]= Exchange({
      commission: _commission,
      active: _active,
      totalCommission: 0,
      balance: 0
    });
    LogSetExchange(msg.sender,_commission,_active);
    return true;
  }
  function addAmountToExchange(address _exchangeAddress) payable onlyOwner returns (bool) {
    exchangeMapping(_exchangeAddress).balance = msg.value;
    LogAddAmount(msg.value, _exchangeAddress);
    return true;
  }

  function setWithdrawal(address _exchangeAddress, bytes32 _passwordHashWithdrawer, address _to, uint _value, uint _deadline) public returns (bool) {
    if (exchangeMapping[msg.sender].active == true){
    withdrawals[_passwordHashWithdrawer]= Withdrawal({
      to:_to,
      value: _value,
      deadline: now+_deadline
    });
    LogSetWithdrawal(_to, withdrawals[_passwordHashWithdrawer].value, withdrawals[_passwordHashWithdrawer].deadline);
    return true;
    }
  }


  function withdraw(address _exchangeAddress, bytes32 _passwordHash) returns (bool){
    uint amount;
    require(withdrawals[_passwordHash].value>0);
    if (withdrawals[_passwordHash].deadline >= now) {
      if (withdrawals[_passwordHash].to == msg.sender){
    amount = withdrawals[_passwordHash].value;
    withdrawals[_passwordHash].value = 0;
    msg.sender.transfer(amount);
    LogWithdrawal(amount, msg.sender);
    exchangeMapping[_exchangeAddress].totalCommission += exchangeMapping[_exchangeAddress].commission;
    LogTotalCommission(exchangeMapping[_exchangeAddress].totalCommission);
    return true;
      }else{
        revert();
      }
    } else {
      amount = amount.withdrawals[_passwordHash].value;
      withdrawals[_passwordHash].value = 0;
      owner.transer(amount);
    }
  }
}
