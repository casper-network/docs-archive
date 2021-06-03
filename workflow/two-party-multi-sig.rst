Two Party Multi-Signature Deploys
=================================

`Accounts <https://docs.casperlabs.io/en/latest/implementation/accounts.html>`_ on a Casper network can associate other ``Accounts`` to allow or require a multiple signature scheme for ``Deploys``.

This workflow describes how a trivial two-party multi-signature scheme for ``  can be enforced for an ``Account`` on a Casper network using a smart contract.

This workflow assumes:

1. You meet the `prerequisites <setup.html>`_
2. Are using the Casper command line client
3. Have a Main Account (**MA**) ``PublicKey`` hex and an Associated Account (**AA**) ``PublicKey`` hex
4. Have a valid ``node-address``.
5. Have previously deployed a smart contract to a Casper network (Refer: `Deploying Contracts <https://docs.casperlabs.io/en/latest/dapp-dev-guide/deploying-contracts.html>`_)


Configuring the Main Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**CAUTION**: Incorrect configurations of the ``Account`` could render it defunct and unusable. It is highly recommended to first execute any changes to an ``Account`` in a test environment like, Testnet, before performing them in live environment like, Mainnet.

Each ``Account`` has an ``associated_keys`` field which is a list containing the ``AccountHash`` and its weight for every associated ``Account``. ``Accounts`` can be associated by adding the ``AccountHash`` to the ``associated_keys`` field.

``Accounts`` on a Casper network assign weights to keys associated with the ``Account``. This weight must be greater than or equal to a set value for a single key to either sign a ``Deploy`` or edit the state of the ``Account``. This set value is labelled as the ``action_threshold`` for the ``Account``.

Each ``Account`` within a Casper Network has has two action thresholds that manage the permissions to send ``Deploys`` or manage the account. Each threshold defines the minimum weight that a single key or a combination of keys must have to either:

1. Send a deploy to the network; determined by the ``deployment`` threshold
2. Edit the ``associated keys`` and the ``action thresholds``; determined by the ``key_management`` threshold

To enforce multi-signature (multi-sig) feature for an ``Account`` on a Casper network, we require that the *main key* and *associated key*'s combined weight is greater than or equal to the ``deployment`` threshold. We can do this by having each key's weight equal to half of the ``deployment`` threshold.


Contract Description
^^^^^^^^^^^^^^^^^^^^

You can run session code that will execute within the context of your main account. Below is the code that will be compiled to WASM and then sent to the network as part of a deploy.

**Note**: This contract example will set up a specific account configuration and is not a general-purpose contract.

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


The contract will execute **2 crucial steps** to enforce the multi-sig scheme for your main account:

1. Add the associated key to the ``Account`` by adding the ``AccountHash`` of the **AA**  to
2. Raise the ``action threshold`` for ``deployment`` to ``2``, such that the weight required to send a ``Deploy`` is split equally between the Main and Associated ``Account``

The action thresholds for deploys cannot be greater than the action threshold for ``key management``. Therefore we need to raise the ``key management`` threshold to raise the ``deployment`` threshold. By default, action thresholds are set to ``1``.

Contract Execution
^^^^^^^^^^^^^^^^^^

The state of the ``Account`` can be altered by sending a ``Deploy`` which executes WASM that will associate the ``AccountHash`` of the **AA**.

For the purposes of this guide, a smart contract has been written and is stored in its `Github Repository <https://github.com/casper-ecosystem/two-party-multi-sig>`_. The repository contains a ``Makefile`` with the build commands necessary to compile the contract to generate the necessary WASM.

.. code-block:: bash

    git clone https://github.com/casper-ecosystem/two-party-multi-sig
    cd two-party-multi-sig


To build the contract, run the following command:

.. code-block:: bash

  make build-contract

The compiled WASM will be saved on this path:

::

    target/wasm32-unknown-unknown/release/contract.wasm


The Casper command line client can be used to send the complied WASM to the network for execution.


.. code-block:: bash

    casper-client put-deploy \
    --node-address http://<peer-ip-address>:7777/rpc \
    --secret-key <secret-key-MA>.pem \
    --chain-name casper-test \
    --payment-amount 250000000000 \
    --session-path <path-to-contract-wasm> \
    --session-arg "deployment-account:account_hash='account-hash-<hash-AA>'"


1. ``node-address`` - An IP address of a node on the network
2. ``secret-key`` - The file name containing the secret key of the Main Account
3. ``chain-name`` - The chain-name to the network where you wish to send the deploy (this example uses the Testnet)
4. ``payment-amount`` - The cost of the deploy
5. ``session-path`` - The path to the contract WASM
6. ``session-arg`` - The contract takes the account hash of the Associated account as an argument labeled ``deployment-account``. You can pass this argument using the ``--session-arg`` flag in the command line client


**Important response fields:**

- ``"result"."deploy_hash"`` - the address of the executed deploy, needed to look up additional information about the transfer

**Note**: Save the returned ``deploy_hash`` from the output to query information about execution status.

Confirming Execution and Account Status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The state of information like the ``Account`` configuration on a Casper blockchain is stored in a `Merkle Tree <https://docs.casperlabs.io/en/latest/glossary/M.html#merkle-tree>`_ and is a snapshot of the blockchain's `Global State <https://docs.casperlabs.io/en/latest/implementation/global-state.html>`_. The representation of ``Global State`` for a given ``Block`` can be computed by executing the ``Deploys`` (including ``Transfers``) within the ``Block`` and its ancestors. The root node of the Merkle Tree identifying a particular state is called the ``state-root-hash`` and is stored in every executed ``Block``.

To check that our account was configured correctly we need the ``state-root-hash`` corresponding to the block that contains our deploy.
To obtain the ``state-root-hash``, we must:

1. Confirm the execution status of the deploy and obtain the hash of the block containing it. (Refer `Checking Deploy Status <http://127.0.0.1:8000/dapp-dev-guide/querying.html#deploy-status>`_)
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
Each key has a weight of ``1``, since the action threshold for ``deployment`` is set to ``2``, neither account is able to sign and send a deploy individually.
Thus to send the deploy from the Main account, the deploy needs to be signed by the secret keys of each account to reach the required threshold.

Details about various scenarios in which multiple associated keys can be setup is discussed in `the examples section of the Multi-Signature Tutorial <https://docs.casperlabs.io/en/latest/dapp-dev-guide/tutorials/multi-sig/examples.html>`_.

