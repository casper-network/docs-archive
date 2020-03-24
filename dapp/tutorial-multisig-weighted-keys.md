# Multi-Signature Deployments

The following provides step-by-step examples to guide us through using and managing CasperLabs' flexible multi-signature functionality within smart contracts so that deploys can be sent for signature using the CasperLabs client. Demonstrate the capability of CasperLabs weighted keys with the following objectives:

- To manage the `threshold` feature within an account
- To understand how keys with sufficient weight can sign a deploy to meet a threshold
- To send a deploy for signature using the CasperLabs client:
  - Sending the deploy via email to someone for signature
  - Sending the deploy once it has the second signature

Before beginning, we highly recommended you review our documentation about [multi-signature-deployments](https://github.com/CasperLabs/casperlabs-multisign-example).


## About weighted keys

Key weights work with thresholds.  Any number of authorized keys can be used in combination to sign a deployment to meet a deploy threshold.

The key_management threshold must be equal or greater to the deployment_threshold.  This is a safety measure which prevents the account from being locked out. 

If the keys signing a deployment lack the sufficient weight to meet the threshold, the deployment fails to run on the node.  Users do not get an error message about this.  Rather, they observe that the transaction never appears in a block.


## Preparation

We will setup our environment with the following:

1. Create keys in [clarity.casperlabs.io](http://clarity.casperlabs.io/)
2. Clone the CasperLabs repository and build contracts
```bash
``git clone -b dev https://github.com/CasperLabs/CasperLabs.git
```
3. Install the CasperLabs client using brew, apt, docker or tarball ….

```basj
cd casperlabs client install
```

3. Build the contracts

```bash
``cd execution-engine make setup make build-contracts
```


- Update the deployment thresholds to 2 using a deployment
- View the weights
- Create a transfer deployment, sign it and send it to someone.
- Other signatory signs the deploy & sends it via the client.
- Observe that a single signer cannot complete the deployment (transfer)


9. View the default weights for the key.

Let’s look at the weight of Key1 - go to [clarity.casperlabs.io](http://clarity.casperlabs.io/) and look at GraphQL

  Let’s get the latest block:

```shell
1 2 3 4 5 ``query {  dagSlice(depth: 1) {      blockHash  } }
```

2. Now - let’s open a new  tab in GraphQL and lets examine the account associated with Key1 : Use Graph QL to see the keys associated with the contract.  Obtain your Hex key and **replace** it in keyBase16 - and the latest block hash in ‘blockHashBase16Prefix’ and then run this graphQL query.

```shell
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 ``query {  globalState(    blockHashBase16Prefix: "The latest block hash"    StateQueries: [      {        keyType: Address        keyBase16: "Your Hex Key"        pathSegments: []      }    ]  ) {    value {      __typename      ... on Account {        pubKey        associatedKeys {          pubKey          weight        }        actionThreshold {          deploymentThreshold          keyManagementThreshold        }      }    }  } }
```

You should see a result that looks like this:

```shell
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 ``{  "data": {    "globalState": [      {        "value": {          "__typename": "Account",          "pubKey": "3eaaf54978990c040150bf3b98e0128a3aab24d1bb1b484956678673531387fe",          "associatedKeys": [            {              "pubKey": "3eaaf54978990c040150bf3b98e0128a3aab24d1bb1b484956678673531387fe",              "weight": 1            }          ],          "actionThreshold": {            "deploymentThreshold": 1,            "keyManagementThreshold": 1          }        }      }    ]  } }
```

6. To prevent being locked out of the account, you must add a key that has more weight than the key management threshold (which must be increased prior to increasing the deployment threshold)

```shell
1 2 3 4 5 6 7 ``export NEW_KEY_HEX=[hex value of the new key to add] export KEYWT=5 export KARGS="[\    {\"name\": \"method\", \"value\": {\"string_value\": \"set_key_weight\"}}, \    {\"name\": \"target-account\", \"value\": {\"bytes_value\": \"${NEW_KEY_HEX}\"}}, \    {\"name\": \"weight\", \"value\": {\"bytes_value\": \"${KEYWT}\"}} \ ]"
```

```shell
1 ``casperlabs-client --host deploy.casperlabs.io deploy --session [path to session file] --session-args "${KARGS}" --payment-amount 10000000 --private-key [path to private key]
```

(the path for the contract under CasperLabs is `execution-engine/target/wasm32-unknown-unknown/release/keys_manager.wasm`)

7. First, we will update the thresholds for the account of Key1 to 3 using a deployment, run the deployment, and confirm the updated threshold.

NOTE: As a safety measure which prevents the account from being locked out, the key_management threshold must be equal or greater to the deployment_threshold.

```shell
``export KEYTH="set_key_management_threshold" export KTHRESH=3 export KTARGS="[\    {\"name\": \"method\", \"value\": {\"string_value\": \"${KEYTH}\"}}, \    {\"name\": \"weight\", \"value\": {\"bytes_value\": \"${KTHRESH}\"}} \ ]"
```

Run the deployment:

```shell
1 ``casperlabs-client --host deploy.casperlabs.io deploy --session [path to wasm file keys_manager.wasm] --session-args "${KTARGS}" --payment-amount 10000000 --private-key [path to your private key1] 
```

To Confirm the deploy worked, check the values in GraphQL - you should see a new key management threshold.

8. Now update the deployment thresholds for the account.  This will authorize only key2 to perform the token transfer.

```bash
``export DEPTH=set_deployment_threshold export DTHRESH=2 export DTARGS="[\    {\"name\": \"method\", \"value\": {\"string_value\": \"${DEPTH}\"}}, \    {\"name\": \"weight\", \"value\": {\"bytes_value\": \"${DTHRESH}\"}} \ ]"
```

The we'll repeat the GraphQL queries with the latest block hash.

```bash
``casperlabs-client --host deploy.casperlabs.io deploy --session [path to wasm file keys_manager.wasm] --session-args "${DTARGS}" --payment-amount 10000000 --from "public key1" --private-key [path to your private key2] 
```

Upon completing this deployment, Key1 will not be authorized to sign a token transfer.

9. Next, we'll export our arguments for the token transfer

```bash
``export TO_HEX="base16-of-key3" export AMOUNT="56" export TXARGS="[\    {\"name\": \"target-account\", \"value\": {\"bytes_value\": \"${TO_HEX}\"}}, \    {\"name\": \"amount\", \"value\": {\"long_value\": \"${AMOUNT}\"}} \ ]"
```

1. Now we can create the deployment, sign it with Key 1 and send it for a second signature.

```bash
1 ``casperlabs-client make-deploy --session [path to wasm file transfer_to_account.wasm] --session-args "${TXARGS}" --payment-amount 10000000 --from [base16 public key for (key1)] -o transfer_test.deploy
```

Then we'll send this file via a mechanism (scp, email) to someone else, or input it into the process for signing the deployment. This deploy is signed with 1 key. It will need another key (assuming both keys have a weight of 1) in order to process against the account.

```bash
``casperlabs-client sign-deploy -i [path to transfer_test.deploy] --public-key [path to public key 1] --private-key [path to private key 1] -o signed_transfer_test.deploy
```

To send the deployment to the second party to sign, you can send the deploy by whatever mechanism you prefer.

```bash
``casperlabs-client sign-deploy -i [path to signed_transfer_test.deploy] --public-key [path to public key 2] --private-key [path to private key 2] -o ready_transfer_test.deploy 
```

Now the deployment could be sent by party 2 if they wish. 

```
``casperlabs-client --host deploy.casperlabs.io send-deploy -i ready_transfer_test.deploy
```

We can Observe  that the  token transfer succeeds and token lands in the account3 balance.

## Outcome:

To unwind the change to the thresholds, we can just repeat the process and reset the weights back to the defaults.

Additionally, we can also attempt to remove the associated key, after we have reduced the deployment thresholds and key management thresholds.

## Errors

How to see errors.

For Example: Authorization Error

No block is created, because the deploy is not authorized, observable on the server logs.

Note: dApp developers should check we don't send a deploy until the requisite key weights are in place.