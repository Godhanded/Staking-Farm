//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract DitoUSD{

    string public Name = "DitoUSD";
    string public Symbol ="DUSD";
    address private Owner;
    uint256 public DtotalSupply;
    //mapp address and their balance
    mapping (address=>uint256) Dbalances;

    //initiallize variables and assign supply to owner
     constructor () 
     {
         DtotalSupply = (1000000*10**18);
         Dbalances[msg.sender] = DtotalSupply;
         Owner = msg.sender;


     }

     function mintDUSD(address _addr,uint _amount)public
     {
         uint256 amount = (_amount*10**18);
         require (msg.sender == Owner, "No Permission to use this function");
         DtotalSupply += amount;
         Dbalances[_addr]+= amount;
     }

     //can only be called by DitoFarm to pay rewards
     function reward(address _to, uint256 _amount)internal
     {
         uint256 amount = (_amount*10**18);
         Dbalances[_to] += amount;
     }

     function Dtransfer(address _addr, uint _amount )public returns(bool)
     {
         //check for sufficient balance of user
         require (Dbalances[msg.sender] >= (_amount*10**18), "Insufficient Balance");
         uint256 amount = (_amount*10**18);
         //debit sender and credit reciever
         Dbalances[ msg.sender ]-= amount ;
         Dbalances[ _addr ]+= amount ;
         return true;

     }

     function DbalanceOf(address _addr)public view returns(uint256)
     {
         //show balance of address
         return Dbalances[_addr];
     }

}