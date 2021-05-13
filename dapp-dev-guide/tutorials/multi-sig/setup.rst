Multi-Signature Setup
=====================

This document describes a workflow wherein an account can be configured to require multisig to send deploys to a Casper network.

Requirements
^^^^^^^^^^^^

To follow the steps in this document, you will need:

1. A compatible client or SDK such as the `JavaScript SDK <https://www.npmjs.com/package/casper-client-sdk>`_, `Java SDK <https://github.com/cnorburn/casper-java-sdk>`_, or GoLang SDK (location forthcoming)
2. Two separate accounts
    - Main account (MA), the account you own and will manage
    - An Associated account (AA), the account which will sign deploys alongside your account in multsig, this account could be any third party with whom you wish to sign deploys. E.g the Casper association.
3. A node RPC endpoint
4. A contract to alter your account structure. <TODO-Link-Contract-Here>

The Rust Casper Client
^^^^^^^^^^^^^^^^^^^^^^

In this document, we will use the Rust Casper client to transfer tokens. You can find the client on `crates.io <https://crates.io/crates/casper-client>`_.

Run the commands below to install the Casper client on most flavors of Linux and macOS. You will need the nightly version of the compiler.

.. code-block:: bash

  rustup toolchain install nightly
  cargo +nightly install casper-client

The Casper client can print out `help` information, which provides an up-to-date list of supported commands.

.. code-block:: bash

    casper-client --help

**Important**: For each command, you can use `help` to get the up-to-date arguments and descriptions:

.. code-block:: bash

    casper-client <command> --help

Setting up Accounts on Testnet
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We recommended following the steps in this document by using the `Casper testnet <https://docs.cspr.community/docs/testnet.html>`_.

Accounts for the testnet can be created using the Rust Casper client or `the Block Explorer <https://clarity-testnet-old.make.services/#/>`_.

You need to create one account for the source of the transfer and one for the target account.

Option 1: Account setup using the Casper client
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This option describes how you can use the Rust Casper client to set up your accounts.

Execute the following command to generate your keys:

.. code-block:: bash

    casper-client keygen .

The above command will create three files in the current working directory:

1. ``secret_key.pem`` - PEM encoded secret key
2. ``public_key.pem`` - PEM encoded public key
3. ``public_key_hex`` - Hex encoded string of the public key

**Important Note**: SAVE your keys to a safe place, preferably offline.

Next, go to `the Block Explorer <https://clarity-testnet-old.make.services/#/>`_ to upload your public key. Log in using your Github or Google account.

**Important Note**: Do NOT, EVER, upload your secret key.

Now you are ready to fund your account and `request tokens <#fund-your-account>`_.

**Important Note**: Responses from the node contain ``AccountHashes`` instead of the direct hex encoded public key. For traceability, it is important to generate the account hash and store this value locally. The account hash is a ``Blake2B`` hash of the public hex key.

Option 2: Account setup using the Block Explorer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start by creating an account on Clarity using the `Create Account <https://clarity-testnet-old.make.services/#/accounts>`_ link.

Save these three files for each account and note the location where they are downloaded. We recommend moving your keys to a safe location, preferrably offline.

1. ``<Account-Name>_secret_key.pem`` - PEM encoded secret key
2. ``<Account-Name>_public_key.pem`` - PEM encoded public key
3. ``<Account-Name>_public_key_hex`` - Hex encoded string of the public key

**Note**: You need the `<Account-Name>_public_key_hex` in order to verify your account balance when querying the blockchain later.


Account Hashes and Public Keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To follow the steps you will require the ``AccountHash`` and the ``hex-encoded-public-key`` for each individual account. The rust client provides a command that will provide the account hash for a given public key.

::

    casper-client account-address --public-key <path-to-public-key-hex>/public_key_hex


Fund your Main Account
^^^^^^^^^^^^^^^^^^^^^^

Next, you need to fund the Main account using the ``[Request tokens]`` button on the `Faucet Page <https://clarity-testnet-old.make.services/#/faucet>`_ to receive tokens.

Acquire Node IP Address
^^^^^^^^^^^^^^^^^^^^^^^

You can get an IP address of a node on the network by visiting the `Peers Page <https://testnet.cspr.live/tools/peers>`_. You will see a list of peers, and you can select the IP of any peer on the list.

**Note**: If the selected peer is blocking the port, pick a different peer and try again.

Example Contract
^^^^^^^^^^^^^^^^

Retrieve the contract from the link and enter the contract directory. There will be a ``Makefile`` that will contain the build commands to compile the contract to WASM.

To build the contract run:

::

    make build-contract

The compiled WASM will be saved to

::

    target/wasm32-unknown-unknown/release/contract.wasm


Configuring the Main Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Action Thresholds
~~~~~~~~~~~~~~~~~

Each account within a Casper network has action thresholds that manage permissions to deploy and manage the account.
These action thresholds are termed as ``deployment`` and ``key_management`` respectively. Each threshold defines the minimum weight
that one or a combination of one or more keys must have to either:

1. Send a deploy to the network.
2. Manage the account to edit the state of the keys within the account.

In order to achieve multi-sig we require that the combined weight of the main-key and associated key is either greater than or equal to
the ``deployment`` action-threshold.

We can do this having the weight of each key be half the ``deployment`` threshold.

Contract Description
~~~~~~~~~~~~~~~~~~~~~

We can run a simple session contract that will execute within the context our main account. Below is body of the contract that will be compiled to WASM and then sent to the network as part of a deploy.

**Important Note**: The contract example will setup a very specific account configuration and is not a general purpose contract.


::

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


In order to enforce ``multisig`` for our main account, the contract will execute **2** crucial steps:

1. Add the associated key to the account with a weight ``1``
2. Raise the ``action threshold`` for ``deployment`` to ``2`` such that the weight is split equally between both the main and associated account.

**Important Note**: The action thresholds for deploys cannot be greater than the action threshold for ``key management``. Therefore we raise the ``key management`` threshold to allow us to raise the ``deployment``
threshold; by default both thresholds are set to ``1``

Contract Execution
~~~~~~~~~~~~~~~~~~

We execute the wasm that will alter the account to our specifications in one single deploy. We can send the deploy to the network using the Casperlabs rust client.
The contract takes the account hash of the Associated as an argument labelled as ``deployment-account``. This argument can be passed using the ``--session-arg`` flag in the rust client.
An example deployment is given below:

::

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

Confirming execution and Account status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We can confirm that the contract executed successfully by using the deploy hash from the previous step.

::

    casper-client get-deploy \
    --node-addres http://<peer-ip-address>:7777/rpc \
    <deploy-hash>

**Important response fields:**

- ``"result"."execution_results"[0]."block_hash"`` - contains the block hash of the block that included our deploy. We will require the `state_root_hash` of this block to look up information about the account and confirm whether the account has been setup correctly.

We will use the block_hash to query and retrieve the block that contains our deploy. Afterward, we will retrieve the root hash of the global state trie for this block, also known as the block’s state_root_hash. We will use the state_root_hash to look up the account.

::

    casper-client get-block \
    --node-address http://<peer-ip-address>:7777/rpc \
    --block-identifer <block-hash>

**Important response fields:**

- ``"result"."block"."header"."state_root_hash"`` - contains the root hash of the global state trie for this block


We will use the ``state_root_hash`` and the ``hex-encoded-public-key`` of the Main account to query the network for the account and check its configuration.

::

    casper-client query-state \
    --node-address http://<peer-ip-address>:7777/rpc \
    --state-root-hash <state-root-hash-from-block> \
    --key <hex-encoded-public-key-MA>

**Output**

::

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


In the above example we can see that there are two keys listed within ``associated-keys``, these are the account hashes for the Associated Account, and the Main Account respectively.
Each of the keys has a weight of ``1``, since the action threshold for ``deployment`` is set to ``2``, neither account would be able to sign and send a deploy individually.
Thus to send the deploy from the Main account, the deploy would have to be signed by the secret keys of each account to reach the required threshold.

Details about various scenarios in which multiple associated keys can be setup is discusse in the examples section.

