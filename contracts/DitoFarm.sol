// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./MockUSDT.sol";
import "./DitoUSD.sol";

contract DitoFarm is MockUSDT, DitoUSD 

{

  address public owner;
  //dynamic array to store people that have staked
  address [] public staker;
  //map user to amount staked
  mapping (address => uint256) public stakedToken;
  //map user stacking status
  mapping (address => bool) public hasStaked; 
  //map user to his reward
  mapping (address => uint256) public reward; 
  //map user to block time
  mapping (address => uint256) private timestamp;

  //initiallize contract owner

    constructor ()
    {
        owner = msg.sender;

    }

    function Stake(uint256 _amount)public returns(string memory)
    {
        //must have balance to stake
        require( MockUSDT.balances[msg.sender] >= (_amount*10**18), "Insufficient MUSDT");
        //call MockUSDT contract to peform transfer
         MockUSDT.transferFrom(msg.sender, address(this), _amount);
         //record users timestamp add 7 days
         timestamp[msg.sender] = block.timestamp + 7 days;
         //record staked tokens
         stakedToken[msg.sender] += _amount*10**18;
         //record rewards, 1%
         reward[msg.sender] += (_amount/100);
         
         //if havent staked before add user to staker array
         if (!hasStaked[msg.sender])
         {
             staker.push(msg.sender);
         }

         hasStaked[msg.sender]=true;  
         return "staked";      
       
    }

    function unstake()public returns(string memory)
    {
        //ensure user has a stake
        require(stakedToken[msg.sender] > 0,"you dont have a stake");
        //require that the user staking status is true
        require(hasStaked[msg.sender]==true,"you dont have a stake");
        //change staking state to false
        hasStaked[msg.sender] = false;
        //return stake
        MockUSDT.transfer( msg.sender, stakedToken[msg.sender]);

        //reset staked balance to 0
        stakedToken[msg.sender] = 0;
        return "unstaked";

    }

    function collectReward()public returns(string memory, uint256, string memory)
    {
        //ensure 7 days has elapsed since last staking day
        require(block.timestamp >= timestamp[msg.sender],"Vesting period has not ended");
        //ensure they have staking reward
        require(reward[msg.sender] >= 0,"you dont have any rewards");
        uint256 dito = reward[msg.sender];
        //reset reward to 0
        reward[msg.sender]=0;
        //transfer reward to user
        DitoUSD.reward(msg.sender,dito);
        return ("you have Claimed ", dito , "DUSD");
    }
  
}