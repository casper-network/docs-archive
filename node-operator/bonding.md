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
Note the required payment amount.  It must contain at least 10 zeros.  Payment amount is specified in motes.

```bash
casper-client put-deploy --chain-name <CHAIN_NAME> --node-address http://<HOST:PORT> --secret-key /etc/casper/<VALIDATOR_SECRET_KEY>.pem --session-path  $HOME/casper-node/target/wasm32-unknown-unknown/release/add_bid.wasm  --payment-amount 10000000000  --session-arg="public_key:public_key='<VALIDATOR_PUBLIC_KEY_HEX>'" --session-arg="amount:u512='<BID-AMOUNT>'" --session-arg="delegation_rate:u64='<PERCENT_TO_KEEP_FROM_DELEGATORS>'"
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
      "1117189c666f81c5160cd610ee383dc9b2d0361f004934754d39752eedc64957": {
        "bonding_purse": "uref-8329c2fc97d914618157c0f1fd41c38702a4852a0159b487eebdd5677123f035-007",
        "delegation_rate": 10,
        "funds_locked": null,
        "staked_amount": "100001111"
      },
      "3f774a58f4d40bd9b6cce7e306e53646913860ef2a111d00f0fe7794010c4012": {
        "bonding_purse": "uref-3ff1a0232d73c37dd1d11da0db1442472c400f190b81a9a81edc28a88717526c-007",
        "delegation_rate": 0,
        "funds_locked": 15,
        "staked_amount": "10000000"
      },
      "524a5f3567d7b5ea17ca518c9d0320fb4a75a28a5eab58d06c755c388f20a19f": {
        "bonding_purse": "uref-f472df50830c2aba6f74c1d491ba22a9cde357aa4ab478834abab2959052ba70-007",
        "delegation_rate": 0,
        "funds_locked": 15,
        "staked_amount": "10000000"
      },
      "5f3d612fa94222b01f851d1d465bd8a7f86c0bc40d81b3d20ec3197e67d02718": {
        "bonding_purse": "uref-8a5524f6a9a17d3e414009d0ec262546c446d07b6bfb6972a0040c4845caec1e-007",
        "delegation_rate": 10,
        "funds_locked": null,
        "staked_amount": "100000"
      },
      "86d42bacf67a4b6c5042edba6bc736769171ca3320f7b0040ab9265aca13bbee": {
        "bonding_purse": "uref-9f7ce53d6b144ec3cde3cafd36139b1d39159f59072e2abd87733a61a5fd6d5c-007",
        "delegation_rate": 10,
        "funds_locked": null,
        "staked_amount": "100000"
      },
      "8b15761be0c527117c79b87ca013b014a4628f01e382902a139529406723d86b": {
        "bonding_purse": "uref-9e0495811818350dc1f5c6b77a850e78faf91e0352611eb60bf5a471323a0161-007",
        "delegation_rate": 0,
        "funds_locked": 15,
        "staked_amount": "10000000"
      },
      "a4707d761e69f5838d77c2edcf378e9c51a82048fdafff389bba60aeff58210e": {
        "bonding_purse": "uref-4c8136ba59ae9b25a5287bae9a679634b16b0305f400aa3fbdd22e6fbda8806b-007",
        "delegation_rate": 10,
        "funds_locked": null,
        "staked_amount": "5318008"
      },
      "aaa7deb9ec99d6bed089fc938cac4a77bc9539f53556af057f9351a1d3c81de9": {
        "bonding_purse": "uref-3719c7c75525c2bd7f021b9560cdac1056912d444fb94c16c1420b891f0d7597-007",
        "delegation_rate": 10,
        "funds_locked": null,
        "staked_amount": "1000005"
      },
      "d62fc9b894218bfbe8eebcc4a28a1fc4cb3a5c6120bb0027207ba8214439929e": {
        "bonding_purse": "uref-9393594d011ac65378993f23b25c8bed109734a5e08223b8ac63c953c4b5a84a-007",
        "delegation_rate": 0,
        "funds_locked": 15,
        "staked_amount": "10000000"
      }
    },
    "block_height": 65,
    "era_validators": {
      "4": {
        "3f774a58f4d40bd9b6cce7e306e53646913860ef2a111d00f0fe7794010c4012": "10000000",
        "524a5f3567d7b5ea17ca518c9d0320fb4a75a28a5eab58d06c755c388f20a19f": "10000000",
        "8b15761be0c527117c79b87ca013b014a4628f01e382902a139529406723d86b": "10000000",
        "aaa7deb9ec99d6bed089fc938cac4a77bc9539f53556af057f9351a1d3c81de9": "1000005",
        "d62fc9b894218bfbe8eebcc4a28a1fc4cb3a5c6120bb0027207ba8214439929e": "10000000"
      },
      "5": {
        "3f774a58f4d40bd9b6cce7e306e53646913860ef2a111d00f0fe7794010c4012": "10000000",
        "524a5f3567d7b5ea17ca518c9d0320fb4a75a28a5eab58d06c755c388f20a19f": "10000000",
        "5f3d612fa94222b01f851d1d465bd8a7f86c0bc40d81b3d20ec3197e67d02718": "100000",
        "86d42bacf67a4b6c5042edba6bc736769171ca3320f7b0040ab9265aca13bbee": "100000",
        "8b15761be0c527117c79b87ca013b014a4628f01e382902a139529406723d86b": "10000000",
        "aaa7deb9ec99d6bed089fc938cac4a77bc9539f53556af057f9351a1d3c81de9": "1000005",
        "d62fc9b894218bfbe8eebcc4a28a1fc4cb3a5c6120bb0027207ba8214439929e": "10000000"
      },
      "6": {
        "3f774a58f4d40bd9b6cce7e306e53646913860ef2a111d00f0fe7794010c4012": "10000000",
        "524a5f3567d7b5ea17ca518c9d0320fb4a75a28a5eab58d06c755c388f20a19f": "10000000",
        "5f3d612fa94222b01f851d1d465bd8a7f86c0bc40d81b3d20ec3197e67d02718": "100000",
        "86d42bacf67a4b6c5042edba6bc736769171ca3320f7b0040ab9265aca13bbee": "100000",
        "8b15761be0c527117c79b87ca013b014a4628f01e382902a139529406723d86b": "10000000",
        "aaa7deb9ec99d6bed089fc938cac4a77bc9539f53556af057f9351a1d3c81de9": "1000005",
        "d62fc9b894218bfbe8eebcc4a28a1fc4cb3a5c6120bb0027207ba8214439929e": "10000000"
      },
      "7": {
        "1117189c666f81c5160cd610ee383dc9b2d0361f004934754d39752eedc64957": "100001111",
        "3f774a58f4d40bd9b6cce7e306e53646913860ef2a111d00f0fe7794010c4012": "10000000",
        "524a5f3567d7b5ea17ca518c9d0320fb4a75a28a5eab58d06c755c388f20a19f": "10000000",
        "5f3d612fa94222b01f851d1d465bd8a7f86c0bc40d81b3d20ec3197e67d02718": "100000",
        "86d42bacf67a4b6c5042edba6bc736769171ca3320f7b0040ab9265aca13bbee": "100000",
        "8b15761be0c527117c79b87ca013b014a4628f01e382902a139529406723d86b": "10000000",
        "a4707d761e69f5838d77c2edcf378e9c51a82048fdafff389bba60aeff58210e": "5318008",
        "aaa7deb9ec99d6bed089fc938cac4a77bc9539f53556af057f9351a1d3c81de9": "1000005",
        "d62fc9b894218bfbe8eebcc4a28a1fc4cb3a5c6120bb0027207ba8214439929e": "10000000"
      }
    },
    "state_root_hash": "98fd03288616408cd66619496ae4e265ba3b69dbc342a5ad71a113a7a48cf88d"
  },
  "id": -1845994568083720043
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
Follow the steps in [Unbonding](https://docs.casperlabs.io/en/latest/node-operator/unbonding.html) to withdraw a bid.
