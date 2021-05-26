Two Party Multi-Signature Deploys
=================================

This guide details how you can configure an account to have a two-party multi-signature scheme for sending deploys.

Requirements
^^^^^^^^^^^^

To follow the steps in this document, you will need:

1. The Casper command line client
2. Two separate accounts
    - A **main account** (MA), the account you own and manage
    - An **associated account** (AA), the account which can sign deploys alongside your account in a multi-signature deploy. This account could be any third party with whom you wish to sign deploys, e.g., the Casper Association
3. A node RPC endpoint from the Casper network
4. A contract to alter your account structure


Visit the `Pre-requisites <setup.html>`_ section to complete the first three requirements.


Example Contract
^^^^^^^^^^^^^^^^

Retrieve the contract `from this link <https://github.com/casper-ecosystem/two-party-multi-sig>`_ and open the ``two-party-multi-sig`` directory. You will find a ``Makefile`` that contains the build commands necessary to compile the contract to WASM.

.. code-block:: bash
  
  cd two-party-multi-sig
  git clone https://github.com/casper-ecosystem/two-party-multi-sig  

 To build the contract, run the following command:

.. code-block:: bash

  make build-contract

The compiled WASM will be saved on this path: ``target/wasm32-unknown-unknown/release/contract.wasm``.


Configuring the Main Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Action Thresholds
~~~~~~~~~~~~~~~~~

Each account within a Casper Network has action thresholds that manage permissions to deploy and manage the account. These action thresholds are named ``deployment`` and ``key_management`` respectively. Each threshold defines the minimum weight that one or a combination of keys must have to either:

1. Send a deploy to the network
2. Manage the account to edit the state of the keys within the account

To use the multi-signature (multi-sig) feature in Casper, we require that the *main key* and *associated key*'s combined weight is greater than or equal to the deployment threshold. We can do this by having each key's weight equal to half of the deployment threshold.

Contract Description
~~~~~~~~~~~~~~~~~~~~~

We can run a simple session contract that will execute within the context of our main account. Below is the contract body that will be compiled to WASM and then sent to the network as part of a deploy.

**Important Note**: This contract example will set up a particular account configuration and is not a general-purpose contract.

.. code-block:: rust

    #![no_main]
    use casper_contract::{
        contract_api::{account, runtime},
        unwrap_or_revert::UnwrapOrRevert,
    };
    use casper_types::account::{AccountHash, ActionType, Weight};

    const ASSOCIATED_ACCOUNT: &str = "deployment-account";

    #[no_mangle]
    pub extern "C" fn call() {
        // Account hash for the account to be associated.
        let deployment_account: AccountHash = runtime::get_named_arg(ASSOCIATED_ACCOUNT);

        // Add the CA key to half the deployment threshold (i.e 1)
        account::add_associated_key(deployment_account, Weight::new(1)).unwrap_or_revert();

        // Deployment threshold <= Key management threshold.
        // Therefore update the key management threshold value.
        account::set_action_threshold(ActionType::KeyManagement, Weight::new(2)).unwrap_or_revert();

        // Set the deployment threshold to 2 enforcing multisig to send deploys.
        account::set_action_threshold(ActionType::Deployment, Weight::new(2)).unwrap_or_revert();
    }


The contract will execute **2 crucial steps** to enforce the multi-sig feature for your main account:

1. Add the associated key to the account with a weight ``1``
2. Raise the ``action threshold`` for ``deployment`` to ``2``, such that the deploy weight is split equally between the main and associated account

The action thresholds for deploys cannot be greater than the action threshold for ``key management``. Therefore we need to raise the ``key management`` threshold to raise the ``deployment`` threshold. By default, action thresholds are set to ``1``.

Contract Execution
~~~~~~~~~~~~~~~~~~

Here is how you can execute the WASM file that will alter the account to your specifications in one single deploy. You have the option to send the deploy to the network using the Casper command line client. There are a few fields that you need to fill in:

1. ``node-address`` - An IP address of a node on the network
2. ``secret-key`` - The file name containing the secret key of the Main Account
3. ``chain-name`` - The chain-name to the network where you wish to send the deploy (this example uses the Testnet)
4. ``payment-amount`` - The cost of the deploy
5. ``session-path`` - The path to the contract WASM
6. ``session-arg`` - The contract takes the account hash of the Associated account as an argument labeled ``deployment-account``. You can pass this argument using the ``--session-arg`` flag in the command line client

.. code-block:: bash

    casper-client put-deploy \
    --node-address http://<peer-ip-address>:7777/rpc \
    --secret-key <secret-key-MA>.pem \
    --chain-name casper-test \
    --payment-amount 250000000000 \
    --session-path <path-to-contract-wasm> \
    --session-arg "deployment-account:account_hash='account-hash-<hash-AA>'"


**Important response fields:**

- ``"result"."deploy_hash"`` - the address of the executed deploy, needed to look up additional information about the transfer

**Note**: Save the returned ``deploy_hash`` from the output to query information about execution status.

Confirming Execution and Account Status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To check that our account was configured correctly we need the state root hash corresponding to the block that contains our deploy.
To obtain the hash, we must:

1. Confirm the execution status of the deploy and obtain the hash of the block containing it. (Refer `Checking Deploy Status <https://docs.casperlabs.io/en/latest/dapp-dev-guide/workflow/transfer-workflow.html#deploy-status>`_)
2. Query the block containing the deploy to obtain the corresponding ``state_root_hash`` (Refer `Getting Block Information <https://docs.casperlabs.io/en/latest/dapp-dev-guide/querying.html#getting-block-information>`_)

We will use the ``state_root_hash`` and the ``hex-encoded-public-key`` of the Main account to query the network for the account and check its configuration.

.. code-block:: bash

    casper-client query-state \
    --node-address http://<peer-ip-address>:7777/rpc \
    --state-root-hash <state-root-hash-from-block> \
    --key <hex-encoded-public-key-MA>

**Example Output**

.. code-block:: json

    {
      "id": 1126043166167626077,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "merkle_proof": "2226 chars",
        "stored_value": {
          "Account": {
            "account_hash": "account-hash-dc88a1819381c5ebbc3432e5c1d94df18cdcd7253b85259eeebe0ec8661bb84a",
            "action_thresholds": {
              "deployment": 2,
              "key_management": 2
            },
            "associated_keys": [
              {
                "account_hash": "account-hash-12dee9fe535bfd8fd335fce1ba1f972f26bb60029a303b310d85419357d18f51",
                "weight": 1
              },
              {
                "account_hash": "account-hash-dc88a1819381c5ebbc3432e5c1d94df18cdcd7253b85259eeebe0ec8661bb84a",
                "weight": 1
              }
            ],
            "main_purse": "uref-74b20e9722d3f087f9dc431e9f0fcc6a803c256e005fa45b64a101512001cb78-007",
            "named_keys": []
          }
        }
      }
    }


In the above example, we can see two keys listed within the ``associated-keys`` section; these are the account hashes for the Associated Account and the Main Account, respectively.
Each of the keys weights ``1``. Since the action threshold for ``deployment`` is set to ``2``, neither account is able to sign and send a deploy individually.
Thus to send the deploy from the Main account, the deploy needs to be signed by the secret keys of each account to reach the required threshold.

Details about various scenarios in which multiple associated keys can be setup is discussed in `the examples section of the Multi-Signature Tutorial <https://docs.casperlabs.io/en/latest/dapp-dev-guide/tutorials/multi-sig/examples.html>`_.

