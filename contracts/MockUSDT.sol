//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

interface IERC20
{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    //function allowance(address _owner, address _spender) external view returns (uint256 remaining);

}

//import "hardhat/console.sol";

contract MockUSDT is IERC20
{ 
//state variables
 string private _name;
 string private _symbol;
 address private owner;
 uint256 public _totalSupply;
 uint8 private _decimals;
 uint256 public buyPrice;
//map address to balance
 mapping (address=>uint256) private balances;
 mapping (address=>mapping(address=>uint256))private allowance;

//evm record
 event Trans(address indexed _from, address indexed _to, uint256 _amount );
 event Approv(address indexed _from, address indexed _to, uint256 _amount);
     //initialize contract supply, owner, name and symbol
     constructor()
     {
         _name = "MockUSDT";
         _symbol ="MUSDT";
         _decimals = 18;
         _totalSupply = 1000*10**18;
         balances[msg.sender] = _totalSupply;
         owner = msg.sender;  
         buyPrice = 2000;

     }

     function name()public override  view returns(string memory) 
     {
         return _name;

     }

     function symbol()public override view returns(string memory)
     {
         return _symbol;
     }

     function decimals()public override view returns(uint8)
     {
         return _decimals;
     }


     function totalSupply()public override view returns(uint256)
     {
         return _totalSupply;
     }

     function transfer(address _to, uint256 _value)public override returns(bool)
     {
         //sender must have sufficient balance
         require (balances[msg.sender] >= (_value*10**18),"Insufficient balance");
         uint256 amount = (_value*10**18);
       //debit sender credit reciever
         balances[msg.sender] -= amount ;
         balances[_to]+= amount;
         emit Trans (msg.sender, _to, amount);
         return true;
     }

     function approve(address _spender, uint256 _value)public override returns(bool)
     {
         //allow a spender spend from your balance
         uint amount = (_value*10**18);
         allowance[msg.sender][_spender]+= amount;
         //evm log
         emit Approv(msg.sender,_spender, amount);
         return true;
     }

     function transferFrom(address _from, address _to, uint256 _value)public override returns(bool)
     {
         //ensure sufficient balance of owner and spender is allowed to spend inputed amount
         require(balanceOf(_from)>= (_value*10**18), "insufficient balance");
         require((_value*10**18)<= allowance[_from][msg.sender],"amount not allowed,use the aprove function to approve an address and spending amount");
         //debit spender allowance and owner balance, credit reciever
         balances[_from] -= _value*10**18;
         allowance[_from][msg.sender] -=_value*10**18;
         balances[_to] += _value*10**18;
         //evm log
         emit Trans(_from, _to, (_value*10**18));
         return true;

     }

     function balanceOf(address _owner) public override view returns(uint256)
     {
        // consol.log("This address has ", balances[_addr]);
         return balances[_owner];
     }
     function mintMUSDT(uint256 _amount)public returns(bool)
     {
         //ensure only owner of contract can use this function
         require(msg.sender ==  owner, "You are not authorized to use this function");
         uint256 amount = _amount*10**18;
         //increment supply
         _totalSupply += amount;
         //mint tokens to owners address
         balances[msg.sender]+= amount*10**18; 
         return true;
     }
      
      function buyMUSDT()public payable returns(string memory)
      {
          //return "send eth to recieve MUSDT, 1 eth costs 2000Musdt";
          uint256 bought;
          balances[msg.sender] += bought = ((msg.value)*buyPrice);
          _totalSupply += bought;
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
