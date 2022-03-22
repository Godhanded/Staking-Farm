//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

//import "hardhat/console.sol";

contract MockUSDT
{ 
//state variables
 string private name;
 string private symbol;
 address private owner;
 uint256 public totalSupply;
 uint256 public buyPrice;
//map address to balance
 mapping (address=>uint256) public balances;
 mapping (address=>mapping(address=>uint256))public allowance;

//evm record
 event Trans(address _from, address _to, uint256 _amount );
 event Approv(address _from, address _to, uint256 _amount);
     //initialize contract supply, owner, name and symbol
     constructor()
     {
         name = "MockUSDT";
         symbol ="MUSDT";
         totalSupply = 1000*10**18;
         balances[msg.sender] = totalSupply;
         owner = msg.sender;  
         buyPrice = 2000;

     }

     function transfer(address _to, uint256 _amount)public returns(bool)
     {
         //sender must have sufficient balance
         require (balances[msg.sender] >= (_amount*10**18),"Insufficient balance");
         uint256 amount = (_amount*10**18);
       //debit sender credit reciever
         balances[msg.sender] -= amount ;
         balances[_to]+= amount;
         emit Trans (msg.sender, _to, _amount);
         return true;
     }

     function approve(address _spender, uint256 _amount)public returns(bool)
     {
         //allow a spender spend from your balance
         allowance[msg.sender][_spender]= _amount;
         //evm log
         emit Approv(msg.sender,_spender,_amount);
         return true;
     }
     function transferFrom(address _from, address _to, uint256 _amount)public returns(bool)
     {
         //ensure sufficient balance of owner and spender is allowed to spend inputed amount
         require(balanceOf(_from)>= (_amount*10**18), "insufficient balance");
         require(_amount<= allowance[_from][msg.sender],"amount not allowed,use the aprove function to approve an address and spending amount");
         //debit spender allowance and owner balance, credit reciever
         balances[_from] -= _amount*10**18;
         allowance[_from][msg.sender] -=_amount*10**18;
         balances[_to] += _amount*10*18;
         //evm log
         emit Trans(_from, _to, _amount);
         return true;

     }

     function balanceOf(address _addr) public view returns(uint256)
     {
        // consol.log("This address has ", balances[_addr]);
         return balances[_addr];
     }
     function mintMUSDT(uint256 _amount)public returns(bool)
     {
         //ensure only owner of contract can use this function
         require(msg.sender ==  owner, "You are not authorized to use this function");
         uint256 amount = _amount*10**18;
         //increment supply
         totalSupply += amount;
         //mint tokens to owners address
         balances[msg.sender]+= amount*10**18; 
         return true;
     }
      
      function buyMUSDT()public payable returns(string memory)
      {
          //return "send eth to recieve MUSDT, 1 eth costs 2000Musdt";
          uint256 bought;
          balances[msg.sender] += bought = ((msg.value)*buyPrice);
          totalSupply += bought;
          //add supply increment
          return "Recieved";
      }

      function modifyTokenBuyPrice(uint256 _price)public returns(string memory, uint256, string memory)
      {
          //ensure only owner can peform function
          require(msg.sender== owner," only owner can use this function");
          //change price state variable
          buyPrice = _price;
          return("Buy price has been changed to ", _price, " per Ether");
      }
}
