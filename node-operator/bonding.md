Bonding
=======

It is recommended that a bonding request be sent prior to beginning the synchronization process. Bonding in Casper takes
place through the auction contract via the `add_bid.wasm` contract. The auction runs for a future era, every era. The Chainspec 
specifies the number of slots available, and the auction will  take the top N slots and create the validator set for the future era.
In the testnet, era durations are approx. 30 minutes. The entire process takes approximately 3 eras. Therefore, the time of submission
of a bid, to inclusion in the validator set is a minimum of 90 minutes.  
Bonding requests (bids) are transactions like any other. 
Because they are generic transactions, they are more resistant to censorship.

## Security and Bonding

The most secure way to send a bonding transaction is to compile the contract and send the request to the network. 
Because the transaction authorizes the bonding purse to be locked into the auction contract, it's really important
to compile the contract yourself. Here are the steps to do this:

* Visit [Github](https://github.com/CasperLabs/casper-node) and fork and clone the repository.
* Make sure that all dependencies are installed  (documented on GitHub).
* Follow the instructions to build the contracts.
* Ensure that the keys you will use for bonding are available & have been funded.
* Create the bonding transaction & deploy it.
* Query the system to verify that your bid was accepted.
* Check the status of the auction to see if you have won a slot.

## Build Add_Bid Contract
Because bonding transactions are generic transactions, it's necessary to build the contract that submits a bid. 
To build contracts, set up Rust & install all dependencies. Visit 'Setting up Rust' in the Developer Guide.

Build the contracts in release mode.

```bash
$ make setup-rs
$ make build-client-contracts
```

## Example Bonding Transaction
Note the path to files and keys. Note: the session arguments need to be encased in double quotes, with the parameter values in single quotes.
Note the required payment amount.  It must contain at least 12 zeros.  Payment amount is specified in motes.

```bash
casper-client put-deploy --chain-name <CHAIN_NAME> --node-address http://<HOST:PORT> --secret-key /etc/casper/<VALIDATOR_SECRET_KEY>.pem --session-path  $HOME/casper-node/target/wasm32-unknown-unknown/release/add_bid.wasm  --payment-amount 1000000000000  --session-arg="public_key:public_key='<VALIDATOR_PUBLIC_KEY_HEX>'" --session-arg="amount:u512='<BID-AMOUNT>'" --session-arg="delegation_rate:u64='<PERCENT_TO_KEEP_FROM_DELEGATORS>'"
```

### Contract Arguments
The add_bid contract accepts 3 arguments:
* public key: The public key in hex of the account to bond.  Note: This has to be the matching key to the validator secret key that signs the deploy.
* amount: This is the amount that is being bid. If the bid wins, this will be the validator's initial bond amount.
* delegation_rate: The percentage of rewards that the validator retains from delegators that delegate their tokens to the node.

## Check the Status of the Transaction

Since this is a deployment like any other, it's possible to perform `get-deploy` using the client.
```bash
casper-client get-deploy --node-address http://<HOST:PORT> <DEPLOY_HASH>
```
Which will return the status of execution.


## Check the Status of the bid in the Auction
If the bid wins the auction, the public key and associated bond amount (formerly bid amount) will appear in the auction contract as part of the 
validator set for a future era. To determine if the bid was accepted, query the auction contract via the rust `casper-client`

```bash
casper-client get-auction-info --node-address http://<HOST:PORT>
```
The request returns a response that looks like this:
```bash
{
  "jsonrpc": "2.0",
  "result": {
    "bids": {
      "0248..6873": {
       ...
      },
    ...
    },
    "era_id": 10,
    "state_root_hash": "42ad1966f4203dbc41ca63da3ab2e99e0da6b5155369cee7e4bbad1f9230463c",
    "validator_weights": {
      "0248..6873": "100000000000001",
       ...
    }
  },
  "id": 572773124
}
```
Note the `era_id` and the `validator_weights` sections of the response. For a given `era_id` a set of validators is defined.  To determine the current era,
ping the `/status` endpoint of a validating node in the network.  This will return the current `era_id`.  The current `era_id` will be listed in the auction
info response. If the public key associated with a bid appears in the `validator_weights` structure for an era, then the account is bonded in that era.

## If the Bid doesn't win
If your bid doesn't win a slot in the auction, it is because your bid is too low.  The resolution for this problem is to increase your bid amount.
It is possible to submit additional bids, to increase the odds of winning a slot. It is also possible to encourage token holders to delegate stake to 
you for bonding.

## Withdrawing a Bid

Once a bid is placed, it will remain in the state of the auction contract. Even if the bid does not win. The reason for this is that new slots may
become available if bonded validators leave the network, or reduce their bond amounts.  Therefore, a bid must be explicitly withdrawn in order to remove
the bid from the auction. Since tokens will be transferred out of the bid purse, it's important to compile the contract to withdraw the bid yourself, so 
there is confidence in the correctness of the contract.  

## Example Withdrawl Transaction
Note the path to files and keys. Note: the session arguments need to be encased in double quotes, with the parameter values in single quotes.
Note the required payment amount.  It must contain at least 12 zeros.  Payment amount is specified in motes.

```bash
casper-client put-deploy --chain-name <CHAIN_NAME> --node-address http://<HOST>:<PORT> --secret-key secret_key.pem --session-path  withdraw_bid.wasm  --payment-amount 100000000000  --session-arg=public_key:"public_key='<PUBLIC_KEY>'" --session-arg=amount:"u512='<AMT_TO_WITHDRAW>'"
```

### Contract Arguments
The withdraw_bid contract accepts 3 arguments:
* public key: The public key in hex of the account to withhdraw.  Note: This has to be the matching key to the validator secret key that signs the deploy,
and has to match the public key of a bid in the auction contract.
* amount: This is the amount that is being withdrawn. 
* unbond_purse (optional): The purse to which the withdrawal will be remitted. Defaults to the main purse for the account if not provided.

Then check the status of the auction contract & the balance of the unbond purse for updates.






