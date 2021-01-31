Client Example
==============
This section covers an example client that invokes a smart contract for key management. In addition to the main account, the client code will add two additional accounts to perform deployments. The two deployment accounts will perform deployments but will not be able to add another account.

You will test your client using the `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_ tool on a local Casper network with five nodes.

Prerequisites
^^^^^^^^^^^^^
* You have compiled the `example contract and client <https://github.com/casper-ecosystem/keys-manager>`_ for key management.
* You have set up the `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_ tool.

Setting up the Network
^^^^^^^^^^^^^^^^^^^^^^^
You can use the `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_ tool to set up a local network for this tutorial.

Navigate to your ``casper-node`` folder and run the following commands.

.. code-block:: bash

	$ nctl-compile
	$ nctl-assets-setup
	$ nctl-start
	$ nctl-view-faucet-account

The network you created with the nctl tool has a special account called a faucet account, which holds your tokens. You will need these tokens to interact with the network. If the network is up and running, you will be able to see your faucet account details.

.. image:: ../../assets/tutorials/multisig/account_example.png
  :alt: The faucet account details as setup by nctl..

| 

Setting up the Client
^^^^^^^^^^^^^^^^^^^^^^^
Navigate back to your ``keys-manager/client/src/`` folder and open the ``utils.js`` file. Explore the set up needed for your client to communicate with the network.

This client code expects a compiled WASM file in the ``contract`` folder and a local network called ``casper-net-1`` with the following configuration.

========================  ================================================  =============
Variable                  Description                                       Value
========================  ================================================  =============
nodeUrl                   The URL of the first node in your local network.  http://localhost:40101/rpc
eventStoreUrl             The URL where events are posted.                  http://localhost:3000
wasmPath                  The path of the compiled WASM contract.           ../contract/target/wasm32-unknown-unknown/release/keys-manager.wasm
networkName               The name of your local network set up by nctl.    casper-net-1
========================  ================================================  =============

Specify your faucet account path on the following line. Replace <ENTER_YOUR_PATH> with your own path.

.. code-block:: javascript

	let baseKeyPath = "<ENTER_YOUR_PATH>/casper-node/utils/nctl/assets/net-1/faucet/";

The following line in ``utils.js`` creates a client that connects to the Casper network. This is the main-facing piece of this library.

.. code-block:: javascript

	let client = new CasperClient(nodeUrl, eventStoreUrl);

The rest of the code in this file creates functions for account management, funding the account, and issuing deployments to the local network.

**Setting up the Account using a Key Manager**

Next, open the ``keys-manager.js`` file to see how the client code implements key management.

    // 1. Set mainAccount's weight to 3.
Set the weight for the main account to 3.

    // 2. Set Keys Management Threshold to 3.
Set the key management threshold to 3. With this key, you can manage keys and, therefore, the entire account.

    // 3. Set Deploy Threshold to 2.
Set the deployment threshold to 2.

    // 4. Add first new key with weight 1.
Add a second key with weight 1. You cannot do anything with this key alone since all the action thresholds are higher than 1.

   // 5. Add second new key with weight 1.
Add a third key with weight 1. If you use this key with the second key, you can deploy, since the weights add up to 2.

    // 6. Make a transfer from mainAccount using only both accounts.
Transfer tokens from the main account??

    // 7. Remove first account.
    // 8. Remove second account.
Remove the two keys with weight 1.

In the next section, you will test your client and key management implementation.
