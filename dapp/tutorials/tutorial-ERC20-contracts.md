Tutorial ERC20 Contract
=======================

This tutorial describes the usage of ERC20 contract based on our CasperLabs weekly workshops. It provides a step-by-step set of examples including basic and advanced features to develop, build, and test the ERC 20 contract using the CasperLabs development tools available in our development environment as follows:
<!--(based on the workshop given by Medha Parlikar)-->

(learning oriented --experience) learn by doing as the journey of
learning — not a final destination

This tutorial provides you with the steps to  use of the example ERC20 Token contract, deploy the contract to DevNet, and then use scripts to interact with the contract on the CL Blockchain.

- Learn how to work with the ERC20 example contract.
- Working with multiple keys
  - Transfer authority to keys
  - Transfer amounts among keys
  - Check account balances in Clarity
- <!--Install the client - version 0.11-->
- <!--Build the contracts-->
- <!--Deploy to DevNet-->

## Before you begin

#### What you need to know:

Prior knowledge of working with contracts it is recommended you familiarize yourself with the [Getting Started](getting-started-instructions.md) topics of this guide.

Note: The token contract has a default name ‘test-token’ - it’s possible to name the token something different if you want to do so.

### Pre-requisites

- Docker tag: dev
- Software version GitHash
- CasperLabs Client (version)  <!--0.11.0 (5777274434bf8cb676c43b0a0ca28f4e015c683e)-->
- Running the latest version of Ubuntu.  
- Clarity Account
- Clone the repository  https://github.com/CasperLabs/CasperLabs.git

| **Title**             | **Description**                                           | Notes                                                        |
| --------------------- | --------------------------------------------------------- | ------------------------------------------------------------ |
| Verify pre-requisites | Check that everyone has managed to get through the setup. | Does everyone have keys in Clarity?Has everyone  cloned the repository and built the contracts?Does everyone have the client installed?  What is the version number for the Client? |
|                       |                                                           |                                                              |

### Set-up your environment

1. Clone the repository on your machine - the code is presently in a branch. 

```
git clone -b dev https://github.com/CasperLabs/CasperLabs.git 
```

2. Install the CasperLabs client using brew, apt, docker or tarball ….

3. Compile contracts

```
cd CasperLabs
cd execution-engine
make setup
make build-contract-rs/erc20-smart-contract
```

4. Fund accounts on DevNet - you can also create new accounts for the test as well. Make sure that all the keys you plan on using have been funded.
5. Create 3 keys - Key1, Key2, Key3 - and fund Key1 and Key2 by using https://clarity.casperlabs.io. 
6. Export your public and private keys to make the commands easier.  Export the information for Key1

```
export PRIV="path_to_private_key_for_Key1
export PUB="public_key_string_from_clarity"
```

Note: If you are using the Python client, you can skip this step. Otherwise, export the location of the client.

```
export CL_CLIENT=casperlabs-client
```

7. Navigate to the scripts directory - there are shell scripts here that make things easier.

```
cd ..
cd hack/docker/scripts
```

There is a script called erc20.sh in the scripts directory.  To see all the commands it supports run

```
./erc20.sh
```

## Deploying an ERC20

Deploy the ERC20 smart contract & specify the token supply

```
./erc20.sh deploy $PRIV [supply amount]
```

This step creates your initial token supply & the token contract in your account.



## Query the results

Now let’s take a look at GraphQL and confirm that we can see the token contract in our account.  From https://clarity.casperlabs.io, Log in and select the GraphQL console from the home page.  Create a new tab.  Have the hash of the block containing your deployment (or the latest block hash) and the Base16 public key of key1.  

Enter this query:

```
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

```
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

Next you can check the balance in the token contract.

```
./erc20.sh balance $PUB $PUB
```

This will return the same number as the supply amount provided during the deploy command.

### Perform a token transfer

Next we can perform a token transfer to key2

```
export KEY2=[public-hex-for-key2]
./erc20.sh transfer $PRIV $PUB $KEY2 [amount]
```

Now we will check the balance at Key2

```
./erc20.sh balance $PUB $KEY2
```

You should see the balance of Key2 as the amount you transferred.

### Authorize second key to transfer amounts

Next we will authorize Key2 to transfer some amount of token

```
./erc20.sh approve $PRIV $PUB $KEY2 [amount authorized]
```

This will set the amount that Key2 is authorized to transfer.

### Transfer amounts from one key to a new one

Next we will use Key2 to transfer token to Key3.  Make sure that Key2 is funded with tokens from the faucet.

```
export KEY3=[hex of public key for key3]
export PRIV2=[path to private key for key2]
./erc20.sh transferFrom $PRIV2 $PUB $PUB $KEY3 [some amount less than authorized amount]
```

### Verify a transfer

Then verify the balance at Key3 

```
./erc20.sh balance $PUB $KEY3
```

It is also possible to purchase more token using the native CLX token 

```
./erc20.sh buy $PRIV $PUB [amount to purchase]
```

Now check the balance, and do the math!

```
./erc20.sh balance $PUB $PUB
```



### For Help - 

[Join us on our Discord channel]( https://discord.gg/mpZ9AYD) 

