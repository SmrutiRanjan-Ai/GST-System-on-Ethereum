
const toastLiveExample = document.getElementById('liveToast')

const displayBalance = async (account,contract) => {
    add = await contract.methods.selfBalance().call({from: account});
    $("#accountnum").html(account);
    $("#accountbalance").html(add);
    displayLedger(account,contract);
    displayInvoice(account,contract);

  };

  const alertPlaceholder = document.getElementById('liveAlertPlaceholder')

  const alert = (message, type) => {
    const wrapper = document.createElement('div')
    wrapper.innerHTML = [
      `<div class="alert alert-${type} alert-dismissible" role="alert">`,
      `   <div>${message}</div>`,
      '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
      '</div>'
    ].join('')
  
    alertPlaceholder.append(wrapper)
  }

  const displayLedger = async (account,contract) =>{

    const paymentData = await contract.methods.paymentData().call({ from: account});
    const creditArray = paymentData[0];
    const debitArray = paymentData[1];
    


    
    var html = '';
    for (var i = 0; i < creditArray.length; i++) {
        // add opening <tr> tag to the string:
        html += '<tr><th scope="row">'+(i+1)+'</th>';
        html += '<td>' + creditArray[i].receiptCode + '</td>';
        
            html += '<td>' + creditArray[i].timestamp + '</td>';
            html += '<td>' + creditArray[i].amount + '</td>';
            if (creditArray[i].cash){
            html += '<td>Cash</td>';}
            else{
              html += '<td>GST Credit</td>';
            }
            

            
        }
        // add closing </tr> tag to the string:
        html += '</tr>';

    
    //append created html to the table body:
    $('#credit').append(html);

    var html = '';
    for (var i = 0; i < debitArray.length; i++) {
        // add opening <tr> tag to the string:
        html += '<tr><th scope="row">'+(i+1)+'</th>';
        html += '<td>' + debitArray[i].receiptCode + '</td>';
        
            html += '<td>' + debitArray[i].timestamp + '</td>';
            html += '<td>' + debitArray[i].amount + '</td>';
            if (debitArray[i].cash){
            html += '<td>Cash</td>';}
            else{
              html += '<td>GST Debit</td>';
            }
            

            
        }
        // add closing </tr> tag to the string:
        html += '</tr>';
        console.log(html);
    
    //append created html to the table body:
    $('#debit').append(html);
  }

  const displayInvoice = async (account,contract) => {

   

    add = await contract.methods.queryInv().call({from: account});
   

    var html = '';
    for (var i = 0; i < add.length; i++) {
        // add opening <tr> tag to the string:
        html += '<tr><th scope="row">'+(i+1)+'</th>';
        
            html += '<td>' + add[i][1] + '</td>';
            html += '<td>' + add[i][3] + '</td>';
            html += '<td>' + add[i][4] + '</td>';
            html += '<td>' + add[i][5] + '</td>';
            html += '<td>' + add[i][6] + '</td>';
            html += '<td>' + add[i][7] + '</td>';

            
        }
        // add closing </tr> tag to the string:
        html += '</tr>';
    
    //append created html to the table body:
    $('#body').append(html);
    

  }
  
  const updateGreeting = (greeting, contract, accounts) => {
    let input;
    $("#input").on("change", (e) => {
      input = e.target.value;
    });
    $("#form").on("submit", async (e) => {
      e.preventDefault();
      await contract.methods
        .updateGreeting(input)
        .send({ from: accounts[0], gas: 40000 });
      displayGreeting(greeting, contract);
    });
  };

  const createInvoice = (contract, account) => {
    let buyer;
    let totalgst;
    let total;
    let payint;
    let payAddress;
    let start;
    let end;
    $("#startTimestamp").on("change", (e) => {
      start = e.target.value;
    });
    $("#endTimestamp").on("change", (e) => {
      end = e.target.value;
    });

    $("#createReturn").on("click", async (e) => {

      const paymentData = await contract.methods.paymentData().call({ from: account});
      const creditArray = paymentData[0];
      let credit = 0;
      let cash = 0;
      let gst=0;
      

      add = await contract.methods.queryInv().call({from: account});
      for (var i = 0; i < add.length; i++) {
        gst+=add[i][5];
      }


      for (let i=0; i<creditArray.length;i++ ){
        if(creditArray[i].timestamp>start && creditArray[i].timestamp<end && creditArray[i].cash!=true){
          credit+=creditArray[i].amount;

        }
        

      }

      for (let i=0; i<creditArray.length;i++ ){
        if(creditArray[i].timestamp>start && creditArray[i].timestamp<end && creditArray[i].cash==true){
          cash+=parseInt(creditArray[i].amount);

        }
        

      }

      $("#total1").html(gst);
      $("#total2").html(credit);
      $("#total3").html(cash);
      console.log(gst,credit,cash);

    });



    $("#register").on("click", async (e) => {

      const status = await contract.methods.addTrader().send({ from: account, gas: 2000000 });
      console.log(status);

    });
    $("#payint").on("change", (e) => {
        payint = e.target.value;
    });
    $("#paybuyer").on("change", (e) => {
        payAddress = e.target.value;
    });

    $("#pay").on("click", async (e) => {

        const status = await contract.methods.payAmount(payAddress,payint).send({ from: account, gas: 2000000 });
        let options = {
          filter: {
              value: []    //Only get events where transfer value was 1000 or 1337
          },
          fromBlock: "latest",                  //Number || "earliest" || "pending" || "latest"
          toBlock: 'latest'
      };
      
        const result = await contract.getPastEvents('Transfer', options);
        delete result[0]['raw'];
        alert(JSON.stringify(result[0],null, '<br>'),'success');
        
       if (result){
       console.log(result);}
  
      });



    $("#totalgst").on("change", (e) => {
        totalgst = e.target.value;
    });
    $("#total").on("change", (e) => {
        total = e.target.value;
      });
      $("#buyer").on("change", (e) => {
        buyer = e.target.value;
      });
    $("#sep").on("click", async (e) => {
      e.preventDefault();
      console.log(totalgst,total);
      const status = await contract.methods.createInvoicePlain(buyer,totalgst,total).send({ from: account, gas: 2000000 });
      console.log(status);
      let options = {
        filter: {
            value: []    //Only get events where transfer value was 1000 or 1337
        },
        fromBlock: "latest",                  //Number || "earliest" || "pending" || "latest"
        toBlock: 'latest'
    };
    
    const result = await contract.getPastEvents('Transfer', options);
        delete result[0]['raw'];
        alert(JSON.stringify(result[0],null, '<br>'),'success');
      displayBalance(account,contract);
      displayInvoice(account,contract);
    });
  };
  
  async function greetingApp() {
    const web3 = await getWeb3();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    account = accounts[0];
    const contract = await getContract(web3);
    
  
    displayBalance(account,contract);
    createInvoice(contract, account);
  }
  
  greetingApp();