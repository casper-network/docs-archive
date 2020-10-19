# Querying

The Casper node supports queries for users and developers to gain insights about transactions sent to the network. When sending a query it is important to note that the request will be routed to a single node in the network.  

This document will outline the query features of the rust `casper-client`

### Pre-Requisites

Responses from the node are returned as JSON. To make the output readable, it's recommended to have JQuery installed on the system.

```bash
sudo apt-get install -y libjs-jquery
```


## Installing the client

The client is available as a rust crate.

```bash
cargo install casper-client
```

## Help

To see the list of commands available ask for `help`

```bash
casper-client --help
```

To see a list of options for a given command, append `--help` 
For example:

```bash
casper-client query-state --help
```

## Query Commands Available

There are several types of data that can be requested from a node. 

* Balance info.
* Block info.
* Deploy info.
* Contract info / Global state info


## Setting up a Query

### Pre-Requisite: Obtain the Global State Hash

The State of the system transitions with each block that is created. Therefore, it's important to first obtain the latest global state hash.

```bash
casper-client get-global-state-hash --node-address http://address:7777 | jq -r

```

Which will return something that looks like this:
```bash
{
  "api_version": "1.0.0",
  "global_state_hash": "b16697514e88019410e6cc1df7d66cb5279ff5cd1f45206bfefaddc7069c38c0"
}
```

### Getting the Balance of a Purse

#### Step 1: Obtain the Purse

Casper uses the notion of purses, which can exist within accounts.  In order to obtain a balance, we first need to get the purse we want. To do this, we provide the public key of the account and the global state hash and query the system for the purses associated with the account. 
```bash
casper-client query-state --node-address http://address:7777 -k <public key as hex> -g b16697514e88019410e6cc1df7d66cb5279ff5cd1f45206bfefaddc7069c38c0 | jq -r

```
Submitting this query returns something like this:

```bash
{
  "api_version": "1.0.0",
  "stored_value": {
    "Account": {
      "account_hash": "22465f462b6cb2d32dfd68ebcea919f618d0d08f0078e1625fa49ede7d1b7ab2",
      "action_thresholds": {
        "deployment": 1,
        "key_management": 1
      },
      "associated_keys": [
        {
          "account_hash": "22465f462b6cb2d32dfd68ebcea919f618d0d08f0078e1625fa49ede7d1b7ab2",
          "weight": 1
        }
      ],
      "main_purse": "uref-cc5f988b415f1c0813bf93510acdcb25e8f3c750479599ca89a4b25b32a91414-007",
      "named_keys": {}
    }
  }
}
```
#### Step 2: Request the balance at the Purse

Now that we have a purse, we can call `get-balance` and retrieve the token balance in the purse.

```bash
casper-client get-balance --node-address http://address:7777 -p <uref-<HEX STRING>-<THREE DIGIT INTEGER> -g b16697514e88019410e6cc1df7d66cb5279ff5cd1f45206bfefaddc7069c38c0 | jq -r

```
Here is an example request:
```bash
casper-client get-balance --node-address http://localhost:7777 -p uref-cc5f988b415f1c0813bf93510acdcb25e8f3c750479599ca89a4b25b32a91414-007 -g b16697514e88019410e6cc1df7d66cb5279ff5cd1f45206bfefaddc7069c38c0 | jq -r

```

And the associated response:
```bash
{
  "api_version": "1.0.0",
  "balance_value": "1000000000000000"
}
```
Note: The balance returned is in motes (the unit that makes up the Casper token). 



