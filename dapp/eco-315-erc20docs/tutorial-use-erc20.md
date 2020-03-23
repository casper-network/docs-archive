Tutorial- Using the ERC20 Contract
==================================

The following provides a guided step-by-step process with a set of examples for using basic and advanced features of the CasperLabs eco system to work with the ERC 20 contract including but not limited to:

- Accessing the example ERC20 Token contract
- Deploying the contract to Devnet
- Using scripts to interact with the contract on the CL Blockchain
- Checking account balances in Clarity

## Before you begin

Prior knowledge of working with contracts is highly recommended. For more details see  [Writing Rust Contracts on CasperLabs] (`<../writing-rust-contracts.html>`) topics of this guide.

TODO: rename link above and link appropriately

Note: The token contract has a default name `test-token` -- it’s possible to name the token something different if you want to do so.

### Pre-requisites

- Docker tag: `dev`
- Running the latest version of Ubuntu
- Software version GitHash
- CasperLabs Client latest version Install and build the contracts
- Clarity Account
- Clone of [CasperLabs repository](https://github.com/CasperLabs/CasperLabs.git) to your machine



Check your pre-requisites

| Pre-requisites                                            | Check that you have completed your setup.                    |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| - Keys in Clarity                                         | https://clarity.casperlabs.io/#/accounts                     |
| - You have cloned the repository and built the contracts  | ```make build-contract-rs/erc20-smart-contract               |
| - Have the client installed with the most updated version | Install the CasperLabs client using brew, apt, docker or tarball …. |

1. Compile contracts

``` shell
cd CasperLabs
cd execution-engine
make setup
make build-contract-rs/erc20-smart-contract
```

1. Fund accounts on Devnet - you can also create new accounts for the test as well. 

   To make it easier, we recommend first funding all keys you plan on using.

1. Create 3 keys - Key1, Key2, Key3 - and fund Key1 and Key2 by using https://clarity.casperlabs.io.   

1. Export your public and private keys to make working with commands easier

For example: Export the information for Key1

```shell
export PRIV="path_to_private_key_for_Key1
export PUB="public_key_string_from_clarity"
```

1. Export the location of the client

```shell
export CL_CLIENT=casperlabs-client
```

Note: If you are using the Python client, you can skip the above step. 

1. Navigate to the [scripts directory](..) and get shell scripts we have created: 

```shell
cd ..
cd hack/docker/scripts
```

1. Locate the `erc20.sh` script 
2. To see all the commands it supports run:

```shell
./erc20.sh
```

## Deploying an ERC20

Deploy the ERC20 smart contract & specify the tokens (motes) to supply

```shell
./erc20.sh deploy $PRIV [supply amount]
```

Create your initial token (motes) supply & the token contract in your account.

## Query the results (GraphQL)

With GraphQL,  you can view the token contract in the account.
1. Log in and select the [GraphQL console](https://clarity.casperlabs.io).
2. Create a new tab by selecting the add new tab icon - this will open a new query
3. Have the hash of the block containing your deployment (or the latest block hash) and the Base16 public key of `your_example_key1`.
4. Enter the query:

```shell
query {
  globalState(
    blockHashBase16Prefix: "LATEST BLOCK HASH"
    StateQueries: [
      {
        keyType: Address
        keyBase16: "PUBLIC KEY FOR KEY1"
        pathSegments: []
      }
    ]
  ) {
    value {
      __typename
      ... on Account {
        pubKey
        associatedKeys {
          pubKey
          weight
        }
        actionThreshold {
          deploymentThreshold
          keyManagementThreshold
        }
        namedKeys{
          name
        }
      }
    }
  }
}
```

Under `namedKeys` you should see 2 names:  `erc20_proxy` and `test-token`

```shell
{
  "data": {
    "globalState": [
      {
        "value": {
          "__typename": "Account",
          "pubKey": "877c399eab63c7d439d04e176811894c9f4ed3f43376ad8aa8b49c3b373749a7",
          "associatedKeys": [
            {
              "pubKey": "877c399eab63c7d439d04e176811894c9f4ed3f43376ad8aa8b49c3b373749a7",
              "weight": 1
            }
          ],
          "actionThreshold": {
            "deploymentThreshold": 1,
            "keyManagementThreshold": 1
          },
          "namedKeys": [
            {
              "name": "erc20_proxy"
            },
            {
              "name": "mint"
            },
            {
              "name": "pos"
            },
            {
              "name": "test_token"
            }
          ]
        }
      }
    ]
  }
}
```

### Check the balance

1. Next, you can check the balance in the token contract:

```shell
./erc20.sh balance $PUB $PUB
```

This will return the same number as the supply amount provided with the deploy command.

### Perform a token transfer

1. Then, you can perform a token transfer to key2:

```shell
export KEY2=[public-hex-for-key2]
./erc20.sh transfer $PRIV $PUB $KEY2 [amount]
```

1. To view the status of the transfe, check the balance at `your_example_Key2` :

```shell
./erc20.sh balance $PUB $KEY2
```
You should see the balance of Key2 as the amount you transferred.

TODO: show this balance of Key2

### Authorize another key to transfer amounts

1. Set an amount that `your_example_Key2` is authorized to transfer, authorize `your_example_Key2` to transfer some amount of token:

```shell
./erc20.sh approve $PRIV $PUB $KEY2 [amount authorized]
```

1. Verify that `your_sample_Key2` is funded with tokens from the faucet.


### Transfer amounts from one key to a new one

1. From `your_example_Key2`, transfer token to `your_example_Key3`:


```shell
export KEY3=[hex of public key for key3]
export PRIV2=[path to private key for key2]
./erc20.sh transferFrom $PRIV2 $PUB $PUB $KEY3 [some amount less than authorized amount]
```

### Verify a transfer

1. Verify the balance at `your_sample_Key3`:

```shell
./erc20.sh balance $PUB $KEY3
```

1. Purchase more token (motes), if need be. You can use the native CLX token:

```shell
./erc20.sh buy $PRIV $PUB [amount to purchase]
```

2. Now you can check the balance and the math

```shell
./erc20.sh balance $PUB $PUB
```

### For Help - 

[Join us on our Discord channel]( https://discord.gg/mpZ9AYD) 

