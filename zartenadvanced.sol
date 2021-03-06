pragma solidity ^0.4.0;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
   
}

contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract ZartenToken is ERC20Interface, Owned{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => bool) public frozenAccount;
    
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    constructor() public {
        symbol = "ZAR";
        name = "Zarten Token";
        decimals = 18;
        _totalSupply = 100000000 * 10**uint256(decimals);
        balances[owner] = _totalSupply;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function transfer(address to, uint256 tokens) public returns (bool success) {

        // ??????????????????????????? 
        require(!frozenAccount[owner]);
        require(!frozenAccount[to]);

        // ?????????????????????????????????
        require(to != address(0));

        // ???????????????????????????????????????
        require(balances[owner] >= tokens);

        // ???????????????????????????
        require(balances[to] + tokens >= balances[to]);



        // ???????????????????????????
        balances[owner] -= tokens;

        // ???????????????????????????
        balances[to] += tokens;



        // ?????????????????????
        emit Transfer(owner, to, tokens);
        return true;

    }
    
    function approve(address spender, uint256 tokens) public returns (bool success) {
        allowed[owner][spender] = tokens;
        emit Approval(owner, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // ??????????????????????????? 
        require(!frozenAccount[from]);
        require(!frozenAccount[to]);
        
        // ????????????????????????
        require(to != address(0) && from != address(0));

        // ???????????????????????????????????????
        require(balances[from] >= tokens);

        // ??????????????????????????????????????????
        require(allowed[from][owner] <= tokens);

        // ???????????????????????????
        require(balances[to] + tokens >= balances[to]);

        balances[from] -= tokens;
        allowed[from][owner] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }
    
    //????????????
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] += mintedAmount;
        _totalSupply += mintedAmount;
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }
    
    //?????????????????????
    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balances[owner] >= _value);
        balances[owner] -= _value;
        _totalSupply -= _value;
        emit Burn(owner, _value);
        return true;
    }
    
    
    //?????????????????? 
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][owner]);
        balances[_from] -= _value;
        allowed[_from][owner] -= _value;
        _totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
    
    //?????????????????? 
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    
    //???????????? 
    function AirDrop(address[] memory _recipients, uint _values) onlyOwner public returns (bool) {
        require(_recipients.length > 0);

        for(uint j = 0; j < _recipients.length; j++){
            emit Transfer(owner, _recipients[j], _values);
        }

        return true;
    }
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    //???????????? ??? 
    function buy() payable public {
        uint amount = msg.value / buyPrice;
        emit Transfer(address(this), owner, amount);
    }
    //???????????? ??? 
    function sell(uint256 amount) public {
        require(address(this).balance >= amount * sellPrice);
        emit Transfer(owner, address(this), amount);
        owner.transfer(amount * sellPrice);
    }

}