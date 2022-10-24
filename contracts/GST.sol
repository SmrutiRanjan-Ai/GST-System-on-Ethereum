// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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
    uint timestamp;
}

event Transfer(
        address indexed _from,
        address indexed _to,
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
    uint timestamp;
    uint receiptCode;
    uint256 amount;
    bool cash;
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
mapping (address => invoice[]) invoice_address_list;
mapping (address => payment[]) payment_credit_map;
mapping (address => payment[]) payment_debit_map;


uint private account_counter;
uint private invoice_counter;
uint private product_counter;
uint private payment_counter;
address[] trader_list;

enum product_type { PRODUCT, SERVICE }
enum gst_category { IGST, CGST_SGST }
enum qty_types { PIECE, LITRE }

function transfer(address _to, uint256 _value, bool cash_type) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        uint ts = block.timestamp;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        payment_counter+=1;
        payment memory receipt = payment({timestamp: ts, receiptCode:payment_counter, amount:_value, cash: cash_type});
        payment_credit_map[_to].push(receipt);
        payment_debit_map[msg.sender].push(receipt);
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

function validateInvoice() private pure returns (bool){
   
       return true;
}

function paymentData() public view returns (payment[] memory, payment[] memory){

  return (payment_credit_map[msg.sender], payment_debit_map[msg.sender]);

}

function createInvoice(address buyer, item[] memory items ) public returns (uint, bool){
    
    invoice memory inv;
    inv = invoice(address_code[buyer],buyer,address_code[msg.sender], msg.sender,0,0,0,0);
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
        total_gst+=((price*rate*qty)/100);
    }

    inv.total_gst = total_gst;
    inv.total = total;
    
    if (validateInvoice()){
        if(transfer(buyer, inv.total_gst, false)){
        invoice_counter+=1;
        inv.invoice_code=invoice_counter;
        code_invoice[inv.invoice_code]=inv;
        invoice_address_list[msg.sender].push(inv);
        
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

function payAmount(address user, uint amount) public returns (bool){
    if (transfer(user, amount,true)){
    return true;
    }
    else{
        return false;
    }

}

function createInvoicePlain(address buyer, uint total_gst, uint total ) public returns (uint, bool){
    
    invoice memory inv;
    uint ts = block.timestamp;
    inv = invoice(address_code[buyer],buyer,address_code[msg.sender], msg.sender,0,total_gst,total, ts);

    if (validateInvoice()){
        if(transfer(buyer, inv.total_gst,false)){
        invoice_counter+=1;
        inv.invoice_code=invoice_counter;
        code_invoice[inv.invoice_code]=inv;
        invoice_address_list[msg.sender].push(inv);
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

function queryInv() public view returns (invoice[] memory){
  return invoice_address_list[msg.sender];
}

function addTrader() public returns (uint){
    account_counter+=1;
    address_code[msg.sender]=account_counter;
    code_address[account_counter]=msg.sender;
    trader_list.push(msg.sender);
    return account_counter;
}

function invoiceCode(uint256 code) public view returns (invoice memory){
    
    return code_invoice[code];
}

function checkTrader() public view returns (bool){
  for (uint i; i < trader_list.length; i++) {
        if (trader_list[i] == msg.sender) {
            
            return true;
        }
  }
  return false;
}


function checkBalance(address user) public view returns (uint){
    return balanceOf[user];

}

function selfBalance() public view returns (uint){
    return balanceOf[msg.sender];

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

