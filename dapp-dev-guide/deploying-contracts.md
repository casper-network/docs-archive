# Deploying Contracts

Ultimately, smart contracts should be run on the blockchain.  Once your smart contract is complete, it's time to deploy your contract to a blockchain.  Deploying a contract has a few pre-requisites:

## CasperLabs Client
The client software communicates with the network to transmit your deployments to the network.  Clients exist for a variety of development platforms such as Python and Javascript.  The official client is the [Python Client](https://github.com/CasperLabs/client-py) It is also possible to create a client to meet specific needs as well.

It's possible to use pre-built binaries or build from source. Both provide the casperLabs-client.

**Ensure that your client matches the version of the network you intend to deploy to.**

### Using Binaries

* **Python**: [casperlabs-client](https://github.com/CasperLabs/client-py)

### Building from Source
[Instructions](https://github.com/CasperLabs/client-py/blob/master/README.md)

Make sure you have pre-requisites installed and you can build the casperlabs-client from source. If you build from source, you will need to add the build directories to your PATH.

Or, you can run the client commands from the root directory of the repo, using explicit paths to the binaries.

### Token to Pay for Deployments
Blockchains are supported by infrastructure providers called "Validators". To use the Validator infrastructure, it's necessary to acquire token to pay for deployments (transactions).

### Target Network
When sending a deploy, the client needs to know which host will receive the deployment.  The host parameter is either a DNS name or IP address of the host.

### Private Key
Blockchains use private key encryption to sign transactions.  The  private key used to sign the deployment must be the private key of the account that is being used to pay for the transaction.

### Advanced Deployments
CasperLabs supports complex deployments.  To learn more about what is possible visit [GitHub](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS%2Emd).

## Sending a Deployment to the Testnet

The easiest way to deploy a contract is to use an existing public network.  CasperLabs provides a Testnet for this.

* Go to [CasperLabs Clarity](https://clarity.casperlabs.io) and ```Sign in``` by using either your Goolge or GitHub username.
* Select "Accounts" and click ```Create Account key```.  You will be prompted to download some files. Make sure you download the files. These are your signing keys.
* Place the key files in a location that you can access during the deployment.  You should store your keys securely.
* Go to 'Faucet' in Clarity and then select the account for the key you just saved.  Click ```Request tokens``` from the faucet to fund your account.  Under ```Recent Faucet Requests``` an entry for your account should appear, with a green check mark.


The Testnet is operated by external validators that can accept transactions at the following endpoints:

* deploy.casperlabs.io
* 18.219.70.138
* 62.171.172.72
* 52.88.90.57
* 116.203.69.88
* 35.158.200.94

The default port is 40401

### Check the Client Version
There is an official Python client. 

To check the client version run:

```bash
pip show casperlabs_client
```
If you want to send your deployments to an external network, use the latest [released](https://pypi.org/project/casperlabs-client/) version of the client.  If you are working off of dev, build the client locally and check the gitHash.

### A Basic Deployment using the Command Line
As described above, a basic deployment must provide some essential information. Here is an example deployment using the Python client that will work with the basic contract we created using the [Contracts SDK for Rust](writing-rust-contracts):
```bash
casperlabs_client --host deploy.casperlabs.io deploy \
    --session contract.wasm \
    --session-args '[{"name": "surname", "value": {"string_value": "Nakamoto"}}]' \
    --private-key account-private.pem \
    --payment-amount 10000000
```
If your deployment works, expect to see a success message that looks like this:
```
Success! Deploy 8428717f1cfc9cc5c047f503661e9c0fc2a495ead44305a807bead130cbd181f deployed
```

Note: Each deploy gets a unique hash.  This is part of the cryptographic security of blockchain technology.  No two deploys will ever return the same hash.

### Check the Deploy Status
The process of sending a deployment is separate from the processing of the contract by the system. Deployments queue up in the system before being added to a block.  Therefore, it's important to check the status of the deployment.  For example, if an incorrect key is used to sign the deployment, it's possible that the deploy does not process on the network, in spite of a successful deploy message. Deploy statuses can also be checked in the [Clarity Explorer](https://clarity.casperlabs.io/#/search) and also by the client.

```bash
casperlabs_client --host deploy.casperlabs.io show-deploy \
    8428717f1cfc9cc5c047f503661e9c0fc2a495ead44305a807bead130cbd181f

deploy {
  deploy_hash: "8428717f1cfc9cc5c047f503661e9c0fc2a495ead44305a807bead130cbd181f"
...
  cost: 126165
}
status {
  state: PROCESSED
}

```

### Check the Contract Executed Successfully
You can use the client's method `query-state` to see a specific named key of the account. It works the same as the `query` method from the testing framework.
```bash
casperlabs_client --host deploy.casperlabs.io query-state \
    --block-hash "f21fc0763279ad8349b0c0fce08e1ed678412d5e234a92e3063d4d5a35ee0739" \
    --type address \
    --key "0cc94662d68bd71b03083e38094f0b0e07a1bbb485969b6e68f21f4577fe928a" \
    --path "special_value"

string_value: "Nakamoto"
```
