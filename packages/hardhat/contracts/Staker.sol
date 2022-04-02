// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }
mapping ( address => uint256 ) public balances;
uint256 public constant threshold = 1 ether;
event Stake(address indexed staker, uint stakeAmount);
uint256 public deadline = block.timestamp + 72 hours;
bool openForWithdraw;
bool completed;

modifier isAtDeadline {
  require(timeLeft() == 0, "Deadline has not yet been reached.");
  _;
}

modifier notCompleted() {
    completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
function stake () public payable {
  require (block.timestamp < deadline, "Staking after the deadline is not allowed.");
  // require (msg.value > 0, "Your stake cannot be zero");
  balances[msg.sender] += msg.value;
  emit Stake(msg.sender, balances[msg.sender]);

}

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

function execute () 
  public
  isAtDeadline
  notCompleted
  {
      completed = false;
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
      completed = true;
      require(completed, "staking process has not ended.");
    }
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // Add a `withdraw()` function to let users withdraw their balance
function withdraw()
  public
  isAtDeadline
  notCompleted
  {
    completed = false;
    if(address(this).balance < threshold){
      openForWithdraw = true;
    }
    require(openForWithdraw, "Withdrawal denied. threshold has been reached");
    require(balances[msg.sender]> 0);
    (bool sent,) = payable(msg.sender).call{value: balances[msg.sender]}("");
    balances[msg.sender] = 0;
    require(sent, "Failed to withdraw from balance");
    openForWithdraw = false;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

function timeLeft()
  public
  view
  returns(uint256)
  {
    return deadline > block.timestamp ? deadline - block.timestamp : 0;
  }

  // Add the `receive()` special function that receives eth and calls stake()
 receive() external payable {
   stake();
 }

}
