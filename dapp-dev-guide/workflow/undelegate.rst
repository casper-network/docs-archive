Undelegating Tokens from a Validator
====================================

This document details a workflow where tokens delegated to a validator on a Casper network can be undelegated.

Requirements
^^^^^^^^^^^^

To follow the steps detailed within this document you will need:

1. The Casper command line client
2. An account on a Casper network
3. A node RPC endpoint to send the delegation deploys.
4. The public key of a validator on the same network
5. Have previously delegated tokens to a validator on the network
6. The undelegation wasm to execute on the network

Refer to the `Delegation Workflow <delegation.html>`_ for steps to fulfil these requirements.

Building The Undelegation WASM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In the case that the ``undelegate.wasm`` cannot be obtained from a trusted source, it is recommended to build the WASM yourself.

Clone the `casper-node <https://github.com/CasperLabs/casper-node>`_ repository and build the contracts.
To build contracts, set up Rust and install all dependencies. Visit `Setting up Rust <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_ in the Developer Guide.

Once the contracts have been built, you will need the ``undelegate.wasm`` to create a deploy that we will initiate the un-delegation process. The WASM can be found in the

``target/wasm32-unknown-unknown/release`` path.


Sending the Undelegation Deploy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once the undelegate WASM has been compilied, we can deploy the WASM in a similar manner to how we deployed the delegation request.

Below is an example using the Rust Casper client:

::

    casper-client put-deploy \
    --node-address http://<peer-ip-addres>:7777/rpc \
    --chain-name casper \
    --session-path <path-to-wasm>/undelegate.wasm \
    --payment-amount 250000000000 \
    --session-arg "validator:public_key='<hex-encoded-validator-public-key>'" \
    --session-arg "amount:u512='<amount-to-delegate>'"
    --session-arg "delegator:public_key='<hex-encoded-public-key>'" \
    --secret-key <delegator-secret-key>.pem

**Note** The delegator public key and the secret key that signs the deploy must be part of the same keypair.

**Important request fields:**

- ``id`` - <STRING OR INTEGER> Optional JSON-RPC identifier applied to the request and returned in the response. If not provided, a random integer will be assigned
- ``node-address`` - <HOST:PORT> Hostname or IP and port of node on which HTTP service is running [default:http://localhost:7777]
- ``secret-key`` - Path to secret key file
- ``chain-name`` - Name of the chain, to avoid the deploy from being accidentally or maliciously included in a different chain
  - The *chain-name* for testnet is **casper-test**
  - The *chain-name* for mainnet is **casper**
- ``session-path`` - The path to where the ``delegate.wasm`` is located
- ``session-arg`` - The arguments to the ``delegate`` execution

    - The argument ``validator`` is the public key of the validator to whom the tokens will be delegated to
    - The argument ``amount`` is the amount of tokens to be delegated
    - The argument ``delegator`` is the public key of the account delegating tokens to a validator

**Note**: There is an optional ``--ttl`` field that also specifies the duration of time for which the deploy will be valid.

Asserting the undelegation
^^^^^^^^^^^^^^^^^^^^^^^^^^

We can use the Rust Casper client to generate an RPC request to query for the auction state.
The subsequent RPC response will confirm that the undelegation request was successfully executed.


Check the status of the Auction to confirm that our bid has been withdrawn.

::

    casper-client get-auction-info \
    --node-address http://<peer-ip-address>:7777/rpc

If the public key and the amount are absent from the ``bids`` structure then we can safely assert that we have indeed un-delegated from the validator.


::

    casper-client get-deploy \
    --node-address http://<peer-ip-address>:7777/rpc \
    <undelegation-deploy-hash>

A successful undelegation deploy will contain a ``WriteWithdraw`` transform within the execution results, similar to the ``WriteBid`` transform we saw in the delegation deploy.

Below is a sample of successful execution.

::

                {
                  "key": "withdraw-093d69e49af06167265325b6ffe90d8e9e766431c1919f3351c18de0975701c1",
                  "transform": {
                    "WriteWithdraw": [
                      {
                        "amount": "1",
                        "bonding_purse": "uref-ca9247ad56a4d5be70484303133e2d6db97f7d7385772155763749af98ace0b0-007",
                        "era_of_creation": 68,
                        "unbonder_public_key": "010c7fef89bf1fc38363bd2ec20bbfb5e1152d6a9579c8847615c59c7e461ece89",
                        "validator_public_key": "0102db4e11bccb3f9d823c82b9389625d383867d00d09b343043cdbe5ca56dd1fd"
                      }
                    ]
                  }
                },


You can also check your account balance on the `Block Explorer <https://cspr.live/>`_ and additionally verify that the balance has increased
by the amount of tokens that were undelegated.

**Important Note**: After un-delegating tokens from a validator, you must wait for the unbonding period to lapse before re-delegating tokens to either the same validator or a different validator.

