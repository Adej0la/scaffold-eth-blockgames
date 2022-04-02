pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

uint256 public constant tokensPerEth = 100;
  // ToDo: create a payable buyTokens() function:
function buyTokens() public payable {
 uint tokenAmount =  msg.value * tokensPerEth;
 yourToken.transfer(msg.sender, tokenAmount);
 emit BuyTokens(msg.sender, msg.value, tokenAmount);
}
  // ToDo: create a withdraw() function that lets the owner withdraw ETH
function withdraw() public onlyOwner{
  uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has not balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
}

  // ToDo: create a sellTokens() function:
function sellTokens(uint256 tokenAmountToSell) public {
    require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

    uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    require(ownerETHBalance >= amountOfETHToTransfer, "Vendor has not enough funds to accept the sell request");

    (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, "Failed to transfer tokens from user to vendor");


    (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
    require(sent, "Failed to send ETH to the user");

    emit SellTokens(msg.sender, tokenAmountToSell, amountOfETHToTransfer);
  }
}
