Delegation Workflow
===================

This document details a workflow where an account holder on the Casper network can delegate their tokens to validators
on a Casper network.


Requirements
^^^^^^^^^^^^

To follow the steps detailed within this document you will need:

1. A compatible client or SDK such as the `JavaScript SDK <https://www.npmjs.com/package/casper-client-sdk>`_, `Java SDK <https://github.com/cnorburn/casper-java-sdk>`_, or GoLang SDK (location forthcoming)
2. An account on a Casper network
3. A node RPC endpoint to send the delegation deploys.
4. The public key of a validator on the same network
5. The delegation contract to execute on the network
6. The undelegation contract to later undelegate if needed.


The first three requirements are covered in the `Direct Native Token Transfer section <https://docs.casperlabs.io/en/latest/dapp-dev-guide/workflow/transfer-workflow.html#requirements>`_.

In live networks such as Mainnet, a pre-existing account will have to transfer CSPR tokens to finalize the process of setting up an account.


Acquire Validator Public Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can get the public key of a validator on the network by visiting the `Validators Page <https://cspr.live/validators>`_. You will see a list of validators present on the network and their stake within the network.
You can click on any validator present on the list to see more information about the validator. Note the public key of the validator you wish to delegate to.

Each validator page will show the delegation (commission) rate, this represents the percentage of **your** reward share that the validator will retain.
Thus, a 10% rate implies that the validator will retain 10% of your reward share. As a prospective delegator, it is important to select a validating node that you can trust and offers a favorable delegation rate.
Please do your due diligence before you stake your tokens with a validator.

If you observe your delegation request in the bid structure but do not see the associated validator key in ``era_validators``, then the validator you selected is not part of the current validator set.
In this event, your tokens are not earning rewards unless you undelegate, wait through the unbonding period, and re-delegate to another validator.

Additionally, any rewards earned are re-delegated by default to the validator from the initial delegation request. Therefore at the time of undelegation you may want to un-delegate the initial amount
plus any additional rewards earned through the delegation process.

The active validator set is constantly rotating, therefore when delegating to a validator be sure to remember that the validator you selected may have been rotated out of the set.


Executing the Delegation Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We recommend first testing the following steps on our official Testnet before performing these steps in a live environment like the Casper mainnet.

Building the Delegation Contract
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Clone the `casper-node <https://github.com/CasperLabs/casper-node>`_ repository and build the contracts.
To build contracts, set up Rust and install all dependencies. Visit `Setting up Rust <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_ in the Developer Guide.

Once the contracts have been built, you will need the ``delegate.wasm`` to create a deploy that we will initiate the delegation process. The WASM can be found in the

``target/wasm32-unknown-unknown/release`` path.

Sending the Delegation Deploy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you have the ``delegate.wasm`` you can create a deploy which will execute the delegation request.

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


Executing the Undelegation request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sending the Undelegation Deploy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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


**Note**: The arguments remain the same, however in this case we deploy the ``undelegate.wasm`` instead of ``delegate``.

Asserting the undelegation
~~~~~~~~~~~~~~~~~~~~~~~~~~

We will use the Rust Casper Client to first check the execution of the undelegation deploy and then subsequently query the auction state to confirm the withdrawal of the delegated tokens.

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



We can also check the status of the Auction to confirm that our bid has been withdrawn.

::

    casper-client get-auction-info \
    --node-address http://<peer-ip-address>:7777/rpc

If the public key and the amount are absent from the ``bids`` structure then we can safely assert that we have indeed un-delegated from the validator.

**Important Note**: You can also check your account balance on the `Block Explorer <https://cspr.live/>`_ and additionally verify that the balance has increased
by the amount of tokens that were undelegated.


