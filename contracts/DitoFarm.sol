// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IMUSDT
{
   function balanceOf(address _owner) external view returns (uint256 balance);
   function transfer(address _to, uint256 _value) external returns (bool success);
   function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    
}

interface IDUSD
{
     function reward(address _to, uint256 _amount)external ;
}

contract DitoFarm

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
  address private MockUSDT;
  address private DUSD;

  //initiallize contract owner

    constructor (address _mockaddr, address _Dusd)
    {
        owner = msg.sender;
        MockUSDT = _mockaddr;
        DUSD = _Dusd;
    }

    function Stake(uint256 _amount)public returns(string memory)
    {
        //must have balance to stake
        require( IMUSDT(MockUSDT).balanceOf(msg.sender) >= (_amount*10**18), "Insufficient MUSDT");
        //call MockUSDT contract to peform transfer
         IMUSDT(MockUSDT).transferFrom(msg.sender, address(this), _amount);
         //record users timestamp add 7 days
         timestamp[msg.sender] = block.timestamp + 7 days;
         //record staked tokens
         stakedToken[msg.sender] += _amount*10**18;
         //record rewards, 1%
         reward[msg.sender] += _amount*10**16;
         
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
        IMUSDT(MockUSDT).transfer( msg.sender, ((stakedToken[msg.sender])/10**18));

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
        IDUSD(DUSD).reward(msg.sender,dito);
        return ("you have Claimed ", dito , "DUSD");
    }
  
}
