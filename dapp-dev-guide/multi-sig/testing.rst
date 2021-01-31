Testing your Client
===================

You will now test your client using the `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_ tool on your local Casper network with five nodes.

Prerequisites
^^^^^^^^^^^^^
* You have completed all the previous sections, and your local network is up and running using the `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_ tool.

.. code-block:: bash

    $node src/keys-manager.js


When the deployment accounts sign the transaction, they can use the faucet account to transfer tokens and perform the deployment since their combined weight is 2, which meets the deployment threshold. Here is the current account structure:

.. code-block:: bash

 {
	“api_version”: “1.0.0”,
	“merkle_proof”: “01000…..11”,
	“stored_value”: {
		“Account”: {
			“account_hash”: “account-hash-da11…”,
			“action_thresholds”: {
				“deployment”: 2,
				“key_management”: 3
			},
			“associated_keys”: [
				{
					“account_hash”: “account-hash-1…”, // faucet account
					“weight”: 3
				},
				{
					“account_hash”: “account-hash-2…”, // deploy account 1
					“weight”: 1
				},
				{
					“account_hash”: “account-hash-3…”, // deploy account 2
					“weight”: 1
				}
			],
			“main_purse”: “uref-1234…”,
			“named_keys”: []
		}
	}
 }

After the transfer, the client code removes the deployment accounts, and we are left with the following structure:

.. code-block:: sh

 {
	“api_version”: “1.0.0”,
	“merkle_proof”: “01000…..11”,
	“stored_value”: {
		“Account”: {
			“account_hash”: “account-hash-da11…”,
			“action_thresholds”: {
				“deployment”: 2,
				“key_management”: 3
			},
			“associated_keys”: [
				{
					“account_hash”: “account-hash-1…”, // faucet account
					“weight”: 3
				}
			],
			“main_purse”: “uref-1234…”,
			“named_keys”: []
		}
	}
 }

You can employ the same strategy in your own account implementation, or customize the multi-signature feature to your needs. 

We offer some additional use cases in the next section.