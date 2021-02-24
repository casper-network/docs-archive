.. role:: raw-html-m2r(raw)
   :format: htm


The Staking Transaction
--------------------

The most secure way to send a transaction is to compile the contract and send the request to the network. 
Because the transaction authorizes the token to be locked into the auction contract, it is really important to compile the contract yourself. Here are the steps to do this:

* Visit `Github <https://github.com/CasperLabs/casper-node>`_ and fork and clone the repository.
* Make sure that all dependencies are installed (documented on GitHub).
* Follow the instructions to build the contracts.
* Create the transaction and deploy it.
* Check the status of the auction to determine if the bid was accepted.

Building the Delegation Contract
--------------------------------

Clone the `casper-node <https://github.com/CasperLabs/casper-node>`_ repository and build the contracts.
To build contracts, set up Rust and install all dependencies. Visit `Setting up Rust <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_ in the Developer Guide.

Make sure you build the contracts in release mode.

Example Delegation Transaction
---------------------------

This example shows how to stake your tokens with a specific validator. You need to update the command with the delegation arguments for your scenario.

.. code-block:: bash

   $ casper-client put-deploy --chain-name delta-10 --node-address http://localhost:7777 -k $HOME/secret_key.pem --session-path  $HOME/casper-node/target/wasm32-      unknown-unknown/release/delegate.wasm  --payment-amount 1000000000  --session-arg "validator:public_key=’VALIDATOR_PUBLIC_KEY_HEX'" --session-arg="amount:u512='AMOUNT'" --session-arg "delegator:public_key='DELEGATOR_PUBLIC_KEY_HEX'"


Delegation Arguments
^^^^^^^^^^^^^^^^^^

The delegate contract accepts 3 arguments:

* **delegator public key**: The public key (in hex) of the account to delegate.  Note: This has to be the matching key to the secret key that signs the deployment.
* **amount**: This is the amount that is being delegated. 
* **validator public key**: The public key (in hex) of the validator that the stake will be delegated to.

Checking Transaction Status
---------------------------

Since this is a deployment like any other, it is possible to perform ``get-deploy`` using the ``casper-client`` to verify the status of the transaction.

.. code-block:: bash

   casper-client get-deploy --node-address http://<HOST:PORT> <DEPLOY_HASH>

The above command will return the status of execution.

Checking Validator and Delegation Status
----------------------------------------

If the bid wins the auction, the public key and associated bond amount (formerly bid amount) will appear in the auction contract as part of the validator set for a future era. To determine if the bid was accepted, query the auction contract via the Rust ``casper-client``:

.. code-block:: bash

   casper-client get-auction-info --node-address http://<HOST:PORT>

The request returns a response that looks like this:

.. code-block:: bash

   "bid": {
          "bonding_purse": "uref-5bbf1fe90097a59904f71005fd8f0beeabd0598a559617ec1dac75900b8e726a-007",
          "delegation_rate": 10,
          "delegators": [
            {
              "delegator": {
                "bonding_purse": "uref-a2a5252edc708f285da3b6b3339b574782e84dcb42042d6c79ad1c4e5fe4bea0-007",
                "delegatee": "01fe61249c459693809bf4f789dd38bc3b7772aa4ffaf642cc6993f4a1004df6c1",
                "reward": "12438241539249672248738838620",
                "staked_amount": "103388952342890156882919933495"
              },
              "public_key": "013e5817d5f88032c759f11eceb570772399a1c279cb5260c06b3e210c27523381"
            }
          ],
          "reward": "11496247653359332605909974274",
          "staked_amount": "73062616210419139229561465618"
        },
        "public_key": "01fe61249c459693809bf4f789dd38bc3b7772aa4ffaf642cc6993f4a1004df6c1"
      },
      {

If your public key and associated amount appear in the ``bid`` data structure, this means that the delegation request has been processed successfully. This does **not** mean the associated validator is part of the validator set. Confirm 
that the validator that you have selected is part of the ``era_validators`` structure, described below. 


.. code-block:: bash

   "era_validators": [
      {
        "era_id": 608,
        "validator_weights": [
          {
            "public_key": "01fe61249c459693809bf4f789dd38bc3b7772aa4ffaf642cc6993f4a1004df6c1",
            "weight": "297466251800051194565831025745"
          },
          {
            "public_key": "0103a5ebf9f685b0960de2dae045846a432868ba7f0dd5f3f57a7fb85a51d6cd39",
            "weight": "243120176614787190607411148495"
          },
          {
            "public_key": "0105463b5afdb735960f85b7cb93aa1d6cf629b882946846b9bc1a7bd39a9441b4",
            "weight": "271934137216396824082469617541"
          },

  
What if my Validator is not in the Era Validators?
----------------------

If you observe your delegation request in the ``bid`` structure but do not see the associated validator key in
``era_validators``, then the validator you selected is not part of the current validator set. In this event, 
your tokens are not earning rewards unless you undelegate, wait through the unbonding period, and re-delegate
to another validator.

Un-delegating
-------------

To unbond (un-delegate) tokens in Casper, a specific transaction is required. The command below shows you how to unbond. You need to update the command with the un-delegation arguments for your scenario. 

.. code-block:: bash

   $ casper-client put-deploy --chain-name delta-10 --node-address http://localhost:7777 -k $HOME/secret_key.pem --session-path  $HOME/casper-node/target/wasm32-      unknown-unknown/release/undelegate.wasm  --payment-amount 1000000000  --session-arg "validator:public_key=’VALIDATOR_PUBLIC_KEY_HEX'" --session-arg="amount:u512='AMOUNT'" --session-arg "delegator:public_key='DELEGATOR_PUBLIC_KEY_HEX'"
   
   
Un-delegation Arguments
^^^^^^^^^^^^^^^^^^

The un-delegate contract accepts 3 arguments:

* **delegator public key**: The public key (in hex) of the account to un-delegate.  Note: This has to be the matching key to the secret key that signs the deployment.
* **amount**: This is the amount that is being un-delegated. 
* **validator public key**: The public key (in hex) of the validator to which the stake is delegated.   
