Contract Example
======================

This section covers an example smart contract used for key management.

Implementing the Smart Contract
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, download `the example contract and client <https://github.com/casper-ecosystem/keys-manager>`_ for key management.

.. code-block:: bash

	$ git clone https://github.com/casper-ecosystem/keys-manager

The smart contract above can help you manage your account. You can add keys and remove keys from your account, define weights for each key, and set thresholds for key management and network deployments. 

You could also refer to this smart contract as the `account code`. Note that once you deploy this smart contract, you cannot change it. As a result, you can rely on its behavior and state as if it were a binding agreement.

The account code execution starts in ``main.rs``, where the ``call`` function calls the ``execute`` function.  This code is similar to a script that executes and implements your account behavior. Remember that when you send a contract (WASM file) to the network, the contract execution engine will invoke the ``call`` function.
You will find the details of the ``execute`` function in ``lib.rs``, which defines the smart contract behavior and its functions.

========================  ============= 
  Function                Description    
========================  ============= 
execute                   Read arguments and set key weights and action thresholds.
set_key_weight            Set a weight for a specific key.
add_or_update_key         Add or update a key, given the key and the weight.
add_key                   Add a specific key.
remove_key_if_exists      Remove a key if it exists.
set_threshold             Set the threshold for key management and deployments, give the permission level and associated weight.
========================  ============= 

You will find a construct to handle the contract arguments in ``api.rs``.
Also, possible errors can arise and are defined in ``errors.rs``. You will see that ``lib.rs`` uses both of these libraries:

.. code-block:: rust

	use errors::Error;
	use api::Api;

In the next section, you will build and prepare the smart contract for deployment.

Building the Smart Contract
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before building the smart contract for this tutorial, you need to install the `Rust Contract SDK <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_. Make sure you have the `development environment set up <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html#development-environment-setup>`_ before proceeding.

Navigate to the ``keys-manager/contract`` folder and set up the WASM compilation Rust toolchain, which will give you access to all the tools needed for developing smart contracts. 

.. code-block:: bash

	$ cd keys-manager/contract
	$ rustup install $(cat rust-toolchain)
	$ rustup target add --toolchain $(cat rust-toolchain) wasm32-unknown-unknown

Notice that the ``contract`` folder contains a ``Cargo.toml`` file, which defines a smart contract called ``keys-manager``. The ``cargo build`` command will invoke this file to generate the corresponding WASM file.

Next, compile the smart contract and create the WASM file using this command:

.. code-block:: bash

	$ cargo build --release

If the command were successful, you would find a ``keys-manager.wasm`` file in the following directory structure:

.. image:: ../../assets/tutorials/multisig/keys-manager-wasm.png
  :width: 350
  :alt: The contract directory structure contains a keys-manager-wasm file.

| 

Next, we will review the sample client that invokes this contract to setup the account and perform key management.
