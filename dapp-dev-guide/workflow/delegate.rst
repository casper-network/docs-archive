Delegating Tokens to a Validator
================================

This document details a workflow where an account holder on the Casper network can delegate their tokens to a validator
on a Casper network.


Requirements
^^^^^^^^^^^^

To follow the steps detailed within this document you will need:

1. The Casper command line client
2. An account on a Casper network
3. A node RPC endpoint to send the delegation deploys.
4. The public key of a validator on the same network
5. The delegation contract to execute on the network

Visit the `Pre-requisites <setup.html>`_ section to complete the first three requirements.

Acquire Validator Public Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can get the public key of a validator on Mainnet by visiting the `Validators on Mainnet <https://cspr.live/validators>`_, or `Validators on Testnet <https://testnet.cspr.live/validators>`_ for validators on testnet. You will see a list of validators present on the network and their stake within the network.
You can click on any validator present on the list to see more information about the validator. Note the public key of the validator you wish to delegate to.

Each validator page will show the delegation (commission) rate, this represents the percentage of **your** reward share that the validator will retain.
Thus, a 10% rate implies that the validator will retain 10% of your reward share. As a prospective delegator, it is important to select a validating node that you can trust and offers a favorable delegation rate.
Please do your due diligence before you stake your tokens with a validator.

If you observe your delegation request in the bid structure but do not see the associated validator key in ``era_validators``, then the validator you selected is not part of the current validator set.
In this event, your tokens are not earning rewards unless you undelegate, wait through the unbonding period, and re-delegate to another validator.

Additionally, any rewards earned are re-delegated by default to the validator from the initial delegation request. Therefore at the time of undelegation you may want to un-delegate the initial amount
plus any additional rewards earned through the delegation process.

The active validator set is constantly rotating, therefore when delegating to a validator be sure to remember that the validator you selected may have been rotated out of the set.


Building The Delegation WASM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In the case that the ``delegate.wasm`` cannot be obtained from a trusted source, it is recommended to build the WASM yourself.

Clone the `casper-node <https://github.com/CasperLabs/casper-node>`_ repository and build the contracts.
To build contracts, set up Rust and install all dependencies. Visit `Setting up Rust <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_ in the Developer Guide.

Once the contracts have been built, you will need the ``delegate.wasm`` to create a deploy that we will initiate the delegation process. The WASM can be found in the

``target/wasm32-unknown-unknown/release`` path.



Executing the Delegation Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We recommend first testing the following steps on our official Testnet before performing these steps in a live environment like the Casper mainnet.

Sending the Delegation Deploy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you have the ``delegate.wasm`` from a **trusted** source you can create a deploy which will execute the delegation request.


Below is an example deployment of the delegation request:

::

    casper-client put-deploy \
    --node-address http://<peer-ip-addres>:7777/rpc \
    --chain-name casper \
    --session-path <path-to-wasm>/delegate.wasm \
    --payment-amount 250000000000 \
    --session-arg "validator:public_key='<hex-encoded-validator-public-key>'" \
    --session-arg "amount:u512='<amount-to-delegate>'" \
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

**Important response fields:**

- ``"result"."deploy_hash"`` - the address of the executed delegation request.

Save the returned `deploy_hash` from the output to query information about the delegation deploy later.
Refer to `Deploy Status <https://docs.casperlabs.io/en/latest/dapp-dev-guide/workflow/transfer-workflow.html#deploy-status>`_ section on how deploy executions can be confirmed.

Confirming the Delegation
~~~~~~~~~~~~~~~~~~~~~~~~~

Once the deploy has been executed, we can query for Auction information to confirm our delegation. We can use the Rust Casper client to create an RPC request to query the auction.

Below is an example of querying:

::

    casper-client get-auction-info \
    --node-address http://<peer-ip-address>:7777/rpc

This will return all the bids currently in the auction contract and the list of active validators for ``4`` future eras from the present era.

Below is a sample output:

::

        "bids": [
        {
          "bid": {
            "bonding_purse": "uref-a5ce7dbc5f7e02ef52048e64b2ff4693a472a1a56fe71e83b180cd33271b2ed9-007",
            "delegation_rate": 1,
            "delegators": [
              {
                "bonding_purse": "uref-ca9247ad56a4d5be70484303133e2d6db97f7d7385772155763749af98ace0b0-007",
                "delegatee": "0102db4e11bccb3f9d823c82b9389625d383867d00d09b343043cdbe5ca56dd1fd",
                "public_key": "010c7fef89bf1fc38363bd2ec20bbfb5e1152d6a9579c8847615c59c7e461ece89",
                "staked_amount": "1"
              },
              {
                "bonding_purse": "uref-38a2e9cad51b380e478c9a325578f4bbdaa0337b99b9ab9bf1dc2a114eb948b9-007",
                "delegatee": "0102db4e11bccb3f9d823c82b9389625d383867d00d09b343043cdbe5ca56dd1fd",
                "public_key": "016ebb38d613f2550e7c21ff9d99f6249b4ae5fb9e30938f6ece2d84a22a36b035",
                "staked_amount": "478473232415318176495746923"
              }
            ],
            "inactive": false,
            "staked_amount": "493754513995516852173468935"
          },
          "public_key": "0102db4e11bccb3f9d823c82b9389625d383867d00d09b343043cdbe5ca56dd1fd"
        },


If your public key and associated amount appear in the bid data structure, this means that the delegation request has been processed successfully.
This does not mean the associated validator is part of the validator set.


Checking Validator Status
~~~~~~~~~~~~~~~~~~~~~~~~~

Once we have delegated to a validator we must also check that the validator is part of the active validator set. If a validator is part of the set,
their public key will be present in the auction information. We can use the Rust casper client to create an RPC request to obtain Auction information
and assert that the selected validator is part of the set.

::

    casper-client get-auction-info \
    --node-address http://<peer-ip-address>:7777/rpc

**Important fields**:

Check the ``"auction_state"."era_validators"`` structure, the public key of the selected validator will be present for the era in which they will be an active validator.

Below is an example of the structure

::

    "block_height":105,
         "era_validators":[
            {
               "era_id":9,
               "validator_weights":[
                  {
                     "public_key":"0102db4e11bccb3f9d823c82b9389625d383867d00d09b343043cdbe5ca56dd1fd",
                     "weight":"648151805935226166098427654"
                  },
                  {
                     "public_key":"01aa67009b37a23c7ad0ca632da5da239d5db46067d4b34125f61b04611f610baf",
                     "weight":"648151805938466925128109996"
                  },
                  {
                     "public_key":"01b7afa2beeddffd13458b763d7a00259f7dc0fa45498dfed05b4d7df4b7d65e2c",
                     "weight":"648151805935226166098427656"
                  },
                  {
                     "public_key":"01ca5463dac047cbd750d97ee42dd810cf1e081ece7d83ae4fc03b25a9ecad3b6a",
                     "weight":"648151805938466925128109998"
                  },
                  {
                     "public_key":"01f4a7644695aa129eba09fb3f11d0277b2bea1a3d5bc1933bcda93fdb4ad17e55",
                     "weight":"648151805938466925128110000"
                  }
               ]
            },




In the above example we see the public keys of the active validators in Era ``9``.


