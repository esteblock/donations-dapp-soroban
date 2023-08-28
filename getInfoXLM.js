import StellarSdk from "stellar-sdk";

const args = process.argv;
const address = args[2]

const horizonUrl="http://stellar:8000";

var server = new StellarSdk.Server(horizonUrl, {allowHttp: true});

server.loadAccount(address)
  .then(account => {
    // Find the XLM balance
    const xlmBalance = account.balances.find(balance => balance.asset_type === 'native');

    console.log(`Address: ${address} | XLM balance: ${xlmBalance.balance}`);
  })
  .catch(error => {
    console.error('Error loading account:', error);
  });
