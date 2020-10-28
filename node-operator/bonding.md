Bonding
=======

Unlike other networks, Casper requires that a bonding request be sent prior to beginning the synchronization process. Bonding in Casper takes
place through the auction contract. The node needs to be part of the validator set before it catches up to the current era (presently). In the Charlie testnet, era durations are approx. 30 minutes. Bonding requests (bids) are transactions like any other. Because they are generic transactions, they are more resistant to censorship.


## Build Add_Bid Contract
Because bonding transactions are generic transactions, it's necessary to build the contract that submits a bid. 

Steps:

* Visit [Github](https://github.com/CasperLabs/casper-node) and fork and clone the repository.
* Follow the instructions to build the contracts.
* Ensure that the keys you will use for bonding are available & have been funded.
* Create the bonding transaction & deploy it.
* Query the system to verify that your bid was accepted.
* Check the status of the auction to see if you have won a slot.

## Example Bonding Transaction

```bash
casper-client put-deploy --chain-name <CHAIN_NAME> --node-address http://<HOST:PORT> --secret-key /home/keys/<VALIDATOR_SECRET_KEY>.pem --session-path  $HOME/casper-node/target/wasm32-unknown-unknown/release/add_bid.wasm  --payment-amount 10000000  --session-arg=public_key:public_key=<VALIDATOR_PUBLIC_KEY_HEX> --session-arg=amount:u512=<BID-AMOUNT> --session-arg=delegation_rate:u64=<PERCENT_TO_KEEP_FROM_DELEGATORS>
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






