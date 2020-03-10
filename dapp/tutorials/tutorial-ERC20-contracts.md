Tutorial ERC20 Contract
=======================

This tutorial describes the usage of ERC20 contract based on our [CasperLabs weekly workshops]() . It provides a step-by-step set of examples including basic and advanced features to develop, build, and test the ERC 20 contract using the CasperLabs development tools available in our development environment where you will use of the [example ERC20 Token contract](...) , deploy the contract to DevNet, and then use scripts to interact with the contract on the CL Blockchain.

Learn how to use the ERC20 example contract to:

- Work with multiple keys
- Transfer authority to keys
- Transfer amounts among keys
- Check account balances in Clarity

## Before you begin

#### What you need to know:

Prior knowledge of working with contracts it is recommended you familiarize yourself with the [Getting Started](getting-started-instructions.md) topics of this guide.

- Install the client with the latest version
- Build the contracts
- Deploy to DevNet

Note: The token contract has a default name ‘test-token’ - it’s possible to name the token something different if you want to do so.

### Pre-requisites

- Docker tag: `dev`
- Running the latest version of Ubuntu
- Software version GitHash
- CasperLabs Client latest version
- Clarity Account
- Clone the [repository](https://github.com/CasperLabs/CasperLabs.git)

| Pre-requisites                                            | Check that you have completed your setup. |
| --------------------------------------------------------- | ----------------------------------------- |
| - Keys in Clarity                                         |                                           |
| - Cloned the repository and built the contracts           |                                           |
| - Have the client installed with the most updated version |                                           |


### Set-up your environment

1. Clone the repository on your machine - the code is presently in a branch. 

```shell
git clone -b dev https://github.com/CasperLabs/CasperLabs.git 
```

2. Install the CasperLabs client using brew, apt, docker or tarball ….


3. Compile contracts

``` shell
cd CasperLabs
cd execution-engine
make setup
make build-contract-rs/erc20-smart-contract
```

4. Fund accounts on DevNet - you can also create new accounts for the test as well. Make sure that all the keys you plan on using have been funded.
5. Create 3 keys - Key1, Key2, Key3 - and fund Key1 and Key2 by using https://clarity.casperlabs.io. 
6. Export your public and private keys to make the commands easier.  Export the information for Key1

```shell
export PRIV="path_to_private_key_for_Key1
export PUB="public_key_string_from_clarity"
```

Note: If you are using the Python client, you can skip this step. Otherwise, export the location of the client.

```shell
export CL_CLIENT=casperlabs-client
```

7. Navigate to the scripts directory - there are shell scripts here that make things easier.

```shell
cd ..
cd hack/docker/scripts
```

There is a script called `erc20.sh` located in the [scripts directory](...) .

To see all the commands it supports run:

```shell
./erc20.sh
```

## Deploying an ERC20

Deploy the ERC20 smart contract & specify the motes (token) to supply

```shell
./erc20.sh deploy $PRIV [supply amount]
```

Create your initial motes (token) supply & the (token) contract in your account.

## Query the results

With GraphQL,  view the (token) contract in our account.
1. Log in and select the [GraphQL console](https://clarity.casperlabs.io.
2. Create a new tab.
3. Have the hash of the block containing your deployment (or the latest block hash) and the Base16 public key of `your_example_key1`.

Enter your query:

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

Under `namedKeys` you should see 2 names - `erc20_proxy` and `test-token`

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

Next you can check the balance in the token contract,

For example:

```shell
./erc20.sh balance $PUB $PUB
```

This will return the same number as the supply amount provided during the deploy command.

### Perform a token transfer

Next, you can perform a token transfer to key2

```
export KEY2=[public-hex-for-key2]
./erc20.sh transfer $PRIV $PUB $KEY2 [amount]
```

Check the balance at `your_example_Key2` To view the status of the transfer,

For example:

```shell
./erc20.sh balance $PUB $KEY2
```
You should see the balance of Key2 as the amount you transferred.

### Authorize second key to transfer amounts

1. Set an amount that `your_example_Key2` is authorized to transfer, authorize `your_example_Key2` to transfer some amount of token.

For example:
```shell
./erc20.sh approve $PRIV $PUB $KEY2 [amount authorized]
```


### Transfer amounts from one key to a new one

1. Verify that `your_sample_Key2` is funded with tokens from the faucet.

2. From `your_example_Key2`, transfer token to `your_example_Key3`.

```shell
export KEY3=[hex of public key for key3]
export PRIV2=[path to private key for key2]
./erc20.sh transferFrom $PRIV2 $PUB $PUB $KEY3 [some amount less than authorized amount]
```

### Verify a transfer

Verify the balance at `your_sample_Key3`,

For example:

```shell
./erc20.sh balance $PUB $KEY3
```

It is also possible to purchase more motes (token) using the native CLX token.

```shell
./erc20.sh buy $PRIV $PUB [amount to purchase]
```

Now you can check the balance and the math,

For example:

```shell
./erc20.sh balance $PUB $PUB
```

### For Help - 

[Join us on our Discord channel]( https://discord.gg/mpZ9AYD) 

