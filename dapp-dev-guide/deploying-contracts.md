# Deploying Contracts

Ultimately, smart contracts are meant to run on the blockchain.  Once your smart contract is complete, it's time to deploy the contract to the blockchain. 
There are a few pre-requisites to doing this:

* A Client that communicates with the network
* The private key for the account that pays for the deployment
* Token to pay for the deployment on the network in the account associated with the private key..


This section will help you get set up with each pre-requisite.

## Client
The client software communicates with the network to transmit your deployments to the network. Clients can be created for any application platform, such as JavaScript or Python. The official client for Casper is a Rust client.  


**Ensure that your client matches the version of the network you intend to deploy to.**

### Using Binaries

* **Rust**: [casperlabs-client](https://crates.io/crates/casper-client)

```bash
cargo install casper-client
```
**Ensure that your client matches the version of the network you intend to deploy to.**

### Building from Source
[Instructions](https://github.com/CasperLabs/casper-node/tree/master/client)


### Token to Pay for Deployments
Blockchains are supported by infrastructure providers called "Validators". To use the Validator infrastructure, it's necessary to acquire token to pay for deployments (transactions). In a testnet, this is possible by using a faucet.  Alternatively,  accounts can be funded in Genesis, or token can be transferred from a  Genesis account to a new account.  In a production system, token is typically acquired by visiting an exchange.

### Target Network
When sending a deploy, the client needs to know which host will receive the deployment.  The `node-address` and `chain-name` parameters provide this info.

### Private Key
Blockchains use asymmetric key encryption to secure transactions.  The  private key used to sign the deployment must be the private key of the account that is being used to pay for the transaction.  The transaction will execute in this account's context unless key delegation and the `from` parameter is being used.

## Sending a Deployment to the Testnet

The easiest way to deploy a contract is to use an existing public network.  CasperLabs provides a Testnet for this.

* Go to [CasperLabs Clarity](https://clarity.casperlabs.io) and ```Sign in``` by using either your Goolge or GitHub username.
* Select "Accounts" and click ```Create Account key```.  You will be prompted to download some files. Make sure you download the files. These are your signing keys.
* Place the key files in a location that you can access during the deployment.  You should store your keys securely.
* Go to 'Faucet' in Clarity and then select the account for the key you just saved.  Click ```Request tokens``` from the faucet to fund your account.  Under ```Recent Faucet Requests``` an entry for your account should appear, with a green check mark.

The Testnet is operated by external validators that can accept transactions. 

The default port is 7777

### Check the Client Version
There is an official Python client. 

To check the client version run:

```bash
casper-client --version
```
If you want to send your deployments to an external network, use the latest released version of the client.  If you are building the client locally, check the gitHash and ensure it matches the githash of the network.

### A Basic Deployment using the Command Line
As described above, a basic deployment must provide some essential information. Here is an example deployment using the Rust client that will work with the basic contract we created using the [Contracts SDK for Rust](writing-rust-contracts):
```bash
casper-client put-deploy --chain-name <NETWORK_NAME> --node-address http://<HOST:PORT> --secret-key /home/keys/n2-secretkey.pem --session-path /home/casper-node/target/wasm32-unknown-unknown/release/do_nothing.wasm  --payment-amount 10000000
```
If your deployment works, expect to see a success message that looks like this:
```
{"api_version":"1.0.0","deploy_hash":"8c3068850354c2788c1664ac6a275ee575c8823676b4308851b7b3e1fe4e3dcc"}
```
Note: Each deploy gets a unique hash.  This is part of the cryptographic security of blockchain technology.  No two deploys will ever return the same hash.

### Check Deploy Status
Once the network has received the deployment, it will queue up in the system before being listed in a block for execution.  Sending a transaction (deployment) to the network does not mean that the transaction processed successfully.  Therefore, it's important to check to see that the contract executed properly, and that the block was finalized. 

```bash
casperlabs-client get-deploy -chain-name <NETWORK_NAME> --node-address http://<HOST:PORT> <DEPLOY_HASH>
```
Which will return a data structure like this:
```bash
{
  "api_version": "1.0.0",
  "deploy": {
    "approvals": [
      {
        "signature": "01350549b0e0173e8612100dc954dcb021e2c3de2161050d397cba8cad5607b2e234115c0f419aeae8ce6cef1464e54b76c857923c42015277f9dd6ae920842c00",
        "signer": "016af0262f67aa93a225d9d57451023416e62aaa8391be8e1c09b8adbdef9ac19d"
      }
    ],
    "hash": "8c3068850354c2788c1664ac6a275ee575c8823676b4308851b7b3e1fe4e3dcc",
    "header": {
      "account": "016af0262f67aa93a225d9d57451023416e62aaa8391be8e1c09b8adbdef9ac19d",
      "body_hash": "03cd3112fd235f7e3e474338ec08e2a8019789e02396cc2eb63f0006ffca6925",
      "chain_name": "casper-charlie-testnet-7",
      "dependencies": [],
      "gas_price": 10,
      "timestamp": "2020-10-21T19:30:39.601Z",
      "ttl": "1h"
    },
    "payment": {
      "ModuleBytes": {
        "args": "0100000006000000616d6f756e74040000000380969808",
        "module_bytes": ""
      }
    },
    "session": {
      "ModuleBytes": {
        "args": "00000000",
        "Module_bytes":
CONTRACT BYTECODE 
 }
    }
  },
  "execution_results": [
    {
      "block_hash": "75df7506a8d150c81ddcfe8303362e22cea3b2359e845b96bccee0735b774e17",
      "result": {
        "cost": "164645",
        "effect": {
          "operations": { 
LIST OF OPERATIONS
                      },
          "transforms": { 
LIST OF TRANSFORMS
                          }
            },
            "hash-1e0c2b6c77bdfe707f9d452295b21b14196e74968886eecda16d68be4c298883": "WriteContract",
            "hash-3284d00f39e9ceefa93884b7c171a8f7f9efc5d32b2104c41a12c77667ff03c3": "Identity",
            "hash-439d5326bf89bd34d3b2c924b3af2f5e233298b473d5bd8b54fab61ccef6c003": "Identity",
            "hash-46aa3a71a3824ccaa35273b9fa840f31400a1403d95f0e4c1caa992b272d15fc": "WriteContractWasm",
            "hash-9f458c8e49b65a2e8cc1df2610d0639657f9b1010acfc94a08fd0be9962d3892": "Identity",
            "hash-d4e7fc49e390a5789da70ff25a45fdf7348b1a72fdb37369f6d46f6fea65deff": "WriteContractPackage",
            "hash-d74beacad19223c6f90953254b82e86d6499b0bb6824ed86a52e3c16491431d4": "Identity",
            "hash-ebe6e4ad78c5913a4bca6d132d99b12df143f5129de946efca77d8d2a15174da": "Identity",
            "uref-0994d1e6631ca447f5a324776175c8c98ffd8d46d964de3c67776804b61a7bdf-000": "Identity",
            "uref-83b591182be016e97ba6640d9947b8358fbc106f97466e60fae9f10fa23737ee-000": {
              "WriteCLValue": {
                "bytes": "",
                "cl_type": "Unit"
              }
            },
            "uref-8dedcbbabf23d395dd7cc4933a862eda6335f1b9029394bce6df3e05f73d2061-000": {
              "AddUInt512": "1646450"
            },
            "uref-a44cb28d40ac091da0c42f01d175ff10bae86e89457290e34ee7828ddbd32902-000": {
              "WriteCLValue": {
                "bytes": "",
                "cl_type": "Unit"
              }
            },
            "uref-c91b4bef8a426fff315aee6f05d6485ecf474296a9882f9bee8fa11e560e6c91-000": {
              "WriteCLValue": {
                "bytes": "1e0c2b6c77bdfe707f9d452295b21b14196e74968886eecda16d68be4c298883",
                "cl_type": {
                  "FixedList": [
                    "U8",
                    32
                  ]
                }
              }
            },
            "uref-e2054113bc3d57386b3152d38ee774cb58dee3c87886d102ece04d9f3be274bf-000": {
              "WriteCLValue": {
                "bytes": "07c76fa8687e8d03",
                "cl_type": "U512"
              }
            }
          }
        },
        "error_message": null
      }
    }
   
```
From this data structure we can learn a few things:
* Execution cost 164645 gas
* No errors were returned by the contract
* There were no dependencies for this deploy
* The Time to Live was 1 hour

It is also possible to check the contract's state by performing a `query-state` command using the client.

### Advanced Deployments
CasperLabs supports complex deployments.  To learn more about what is possible visit [GitHub](https://github.com/CasperLabs/casper-node/blob/master/docs/CONTRACTS%2Emd).

#### Creating, signing, and deploying contracts with multiple signatures

The `deploy` command on its own provides multiple actions strung together optimizing for the common case, with the capability to separate concerns between your key management and deploy creation. See details about generating account key pairs [here](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/KEYS.md#generating-account-keys).

Every account can associate multiple keys with it and give each a weight. Collective weight of signing keys decides whether an action of certain type can be made. In order to collect weight of different associated keys, a deploy has to be signed by corresponding private keys. The `put-deploy` command creates a deploy, signs it and deploys to the node but doesn't allow for signing with multiple keys. Therefore, we split `deploy` into separate commands:

* `make-deploy`  - creates a deploy from input parameters
* `sign-deploy`  - signs a deploy with given private key
* `send-deploy`  - sends a deploy to CasperLabs node

To make a deploy signed with multiple keys: first make the deploy with `make-deploy`, sign it with the keys calling `sign-deploy` for each key, and then send it to the node with `send-deploy`.
