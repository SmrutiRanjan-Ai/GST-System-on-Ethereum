// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
contract GST {


uint256 _totalSupply;
address manager;

constructor(uint256 _initialSupply) {
      account_counter = 0;   // Using State variable
      invoice_counter = 0;
      product_counter = 0;
      payment_counter = 0;
      manager=msg.sender;
      balanceOf[msg.sender] = _initialSupply;
      _totalSupply = _initialSupply;
      address_code[msg.sender]=account_counter;
   }

function totalSupply(uint mintAmount) public returns (bool) {
    if (manager == msg.sender){
        balanceOf[msg.sender]+=mintAmount;
        return true;
    }
    return false;


}

struct product {
	string name;
	uint product_code;
    uint gst_rate;
	
    }

struct Set {
        uint[] values;
        mapping (uint => bool) is_in;
    }


struct trader {
    string name;
    address trader_code;
	uint gstn_code;
}

struct invoice{
    uint buyer;
    address buyer_address;
    uint seller;
    address seller_address;
    uint invoice_code;
    uint total_gst;
    uint total;
}

event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;



struct item{
    uint product_code;
    uint price;
    uint qty;
}

struct payment{
    string proof;
    uint receiptCode;
    uint trader_code;

}
mapping (uint => product) code_product;
mapping (uint => uint) account_balance;
mapping (uint => uint) account_trader;
mapping (uint => trader) code_trader;
mapping (uint => invoice) code_invoice;
mapping (uint => payment[]) payment_trader_prooflist;
mapping (uint => uint) payment_receipt_trader_code;
mapping (uint => string) payment_receipt_proof;
mapping (uint => invoice[]) invoice_trader_list;
mapping (uint => address) code_address;
mapping (uint => uint)gst_rate;
mapping (uint => product) product_list;
mapping (uint => item) inv_items;
mapping (address => uint) address_code;

uint private account_counter;
uint private invoice_counter;
uint private product_counter;
uint private payment_counter;

enum product_type { PRODUCT, SERVICE }
enum gst_category { IGST, CGST_SGST }
enum qty_types { PIECE, LITRE }

function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

function validateInvoice() private pure returns (bool){
   
       return true;
   

}

item[] it;

function createInvoice(uint seller_code, uint buyer_code, item[] memory items ) public returns (uint, bool){
    
    invoice memory inv;
    it.push(items[0]);

    inv = invoice(buyer_code,code_address[buyer_code],seller_code, msg.sender,0,0,0);

    uint total_gst =0;
    uint total =0;
    uint code;
    uint qty;
    uint price;
    uint rate;

    for(uint i=0; i<items.length;i++){
        code=items[i].product_code;
        qty=items[i].qty;
        price=items[i].price;
        rate=gst_rate[code];
        total+=(price*qty);
        total_gst+=(price*rate*qty);
    }

    inv.total_gst = total_gst;
    inv.total = total;
    
    if (validateInvoice()){
        if(transfer(code_address[buyer_code], inv.total_gst)){
        invoice_counter+=1;
        inv.invoice_code=invoice_counter;
        code_invoice[inv.invoice_code]=inv;
        invoice_trader_list[seller_code].push(inv);
        
        return (inv.invoice_code, false);
        }
        else{
            revert("Invalid value");
        }

    }
    else{
        return (0,false);
    }
}

function createInvoicebyaddress(address buyer, item[] memory items ) public returns (uint, bool){
    
    invoice memory inv;
    it.push(items[0]);

     inv = invoice(address_code[buyer],buyer,address_code[msg.sender], msg.sender,0,0,0);

    uint total_gst =0;
    uint total =0;
    uint code;
    uint qty;
    uint price;
    uint rate;

    for(uint i=0; i<items.length;i++){
        code=items[i].product_code;
        qty=items[i].qty;
        price=items[i].price;
        rate=gst_rate[code];
        total+=(price*qty);
        total_gst+=(price*rate*qty);
    }

    inv.total_gst = total_gst;
    inv.total = total;
    
    if (validateInvoice()){
        if(transfer(buyer, inv.total_gst)){
        invoice_counter+=1;
        inv.invoice_code=invoice_counter;
        code_invoice[inv.invoice_code]=inv;
        invoice_trader_list[address_code[msg.sender]].push(inv);
        
        return (inv.invoice_code, false);
        }
        else{
            revert("Invalid value");
        }

    }
    else{
        return (0,false);
    }
}

function payAmount(uint trader_code, uint amount) public returns (bool){
    if (transfer(code_address[trader_code], amount)){
    return true;
    }
    else{
        return false;
    }

}

function addTrader() public returns (uint){
    account_counter+=1;
    address_code[msg.sender]=account_counter;
    code_address[account_counter]=msg.sender;

    return account_counter;
}


function checkBalance(uint trader_code) public view returns (uint){
    return balanceOf[code_address[trader_code]];

}
function addProduct(string memory name, uint rate) public returns (uint){
    product_counter+=1;
    gst_rate[product_counter]=rate;
    product memory p;
    p=product(name,product_counter,rate);
    product_list[product_counter]=p;
    return product_counter;
}



enum state_list {
ANDHRA_PRADESH,
ARUNACHAL_PRADESH,
ASSAM,
BIHAR,
CHHATTISGARH,
GOA,
GUJARAT,
HARYANA,
HIMACHAL_PRADESH,
JAMMU_AND_KASHMIR,
JHARKHAND,
KARNATAKA,
KERALA,
MADHYA_PRADESH,
MAHARASHTRA,
MANIPUR,
MEGHALAYA,
MIZORAM,
NAGALAND,
ODISHA,
PUNJAB,
RAJASTHAN,
SIKKIM,
TAMIL_NADU,
TELANGANA,
TRIPURA,
UTTAR_PRADESH,
UTTARAKHAND,
WEST_BENGAL,
ANDAMAN_AND_NICOBAR_ISLANDS,
CHANDIGARH,
DADRA_AND_NAGAR_HAVELI,
DAMAN_AND_DIU,
DELHI,
LADAKH,
LAKSHADWEEP
}



}
