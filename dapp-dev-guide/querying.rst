
Querying the Network
====================

The Casper node supports queries for users and developers to gain insights about transactions sent to the network. When sending a query it is important to note that the request will be routed to a single node in the network.  

This document will outline the query features of the rust ``casper-client``

Helpful Info
^^^^^^^^^^^^

The structure of Global state and the Blockchain Design can be found `here <https://docs.casperlabs.io/en/latest/implementation/index.html>`_. Being familiar with this will help understanding how to query data from the network.

Responses from the node are returned as JSON. To make the output readable, it's recommended to have JQuery installed on the system.

.. code-block:: bash

   sudo apt-get install -y libjs-jquery

Installing the client
---------------------

The client is available as a rust crate. You can also build from `source <https://github.com/CasperLabs/casper-node/tree/master/client>`_

.. code-block:: bash

   cargo install casper-client

Help
----

To see the list of commands available ask for ``help``

.. code-block:: bash

   casper-client --help

To see a list of options for a given command, append ``--help`` 
For example:

.. code-block:: bash

   casper-client query-state --help

Query Commands Available
------------------------

There are several types of data that can be requested from a node. 


* Balance info.
* Block info.
* Deploy info.
* Contract info / Global state info

Setting up a Query
------------------

Pre-Requisite: Obtain the Global State Hash
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The state of the system transitions with each block that is created. Therefore, it's important to first obtain the latest global state hash.

.. code-block:: bash

   casper-client get-state-root-hash --node-address http://NODE:PORT | jq -r

Which will return something that looks like this:

.. code-block:: bash

   {
     "jsonrpc": "2.0",
     "result": {
       "api_version": "1.0.0",
       "state_root_hash": "d9044b240d612d9a57461a87bd61bcd1c6cc8ea4d4f4e68ec7875f61502c4468"
     },
     "id": -6565689384115820052
   }

Getting the Balance of a Purse
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Step 1: Obtain the Purse
~~~~~~~~~~~~~~~~~~~~~~~~

Casper uses the notion of purses, which can exist within accounts.  In order to obtain a balance, we first need to get the purse we want. To do this, we provide the public key of the account and the global state hash and query the system for the purses associated with the account. 

.. code-block:: bash

   casper-client query-state --node-address http://NODE:PORT -k <PUBLIC_KEY_AS_HEX> -s STATE_ROOT_HASH | jq -r

Submitting this query returns something like this:

.. code-block:: bash

   {
     "jsonrpc": "2.0",
     "result": {
       "api_version": "1.0.0",
       "merkle_proof": <LARGE MERKLE PROOF>,
     "stored_value": {
         "Account": {
           "account_hash": "account-hash-0790b3283de2756c4baef02cdb81ddee6e4dddc007c41ed63c4d59f2dff270ff",
           "action_thresholds": {
             "deployment": 1,
             "key_management": 1
           },
           "associated_keys": {
             "account-hash-0790b3283de2756c4baef02cdb81ddee6e4dddc007c41ed63c4d59f2dff270ff": 1
           },
           "main_purse": "uref-79658d9daeceb2a140fe38f4368349ff296665911dba3cbf2bf359b19f233a35-007",
           "named_keys": {}
         }
       }
     },
     "id": 4629249493325064079
   }

Step 2: Request the balance at the Purse
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now that we have a purse, we can call ``get-balance`` and retrieve the token balance in the purse.

.. code-block:: bash

   casper-client get-balance --node-address http://NODE:PORT -p <uref-<HEX STRING>-<THREE DIGIT INTEGER> -s STATE_ROOT_HASH | jq -r

Here is an example request:

.. code-block:: bash

   casper-client get-balance --node-address http://localhost:7777 -p uref-cc5f988b415f1c0813bf93510acdcb25e8f3c750479599ca89a4b25b32a91414-007 -s b16697514e88019410e6cc1df7d66cb5279ff5cd1f45206bfefaddc7069c38c0 | jq -r

And the associated response:

.. code-block:: bash

   casper-client get-balance --node-address http://localhost:7777  --purse-uref uref-79658d9daeceb2a140fe38f4368349ff296665911dba3cbf2bf359b19f233a35-007 -s d9044b240d612d9a57461a87bd61bcd1c6cc8ea4d4f4e68ec7875f61502c4468
   {
     "jsonrpc": "2.0",
     "result": {
       "api_version": "1.0.0",
       "balance_value": "6000000000",
       "merkle_proof": <MERKLE PROOF>,
        },
     "id": -6819892948223785654
   }

Note: The balance returned is in motes (the unit that makes up the Casper token). 

Getting Block Information
-------------------------

It is possible to obtain detailed block information from the system.  To do this, obtain the hash of the block of interest and send this query to a node in the network: As an Example:

.. code-block:: bash

   casper-client get-block  --node-address http://localhost:7777 -b f598c1b2852acebc299c200751dae20565b3891fa0d656f537959a68c47a1ef5 |jq -r

Returns this information about the block:

.. code-block:: bash

   {
     "api_version": "1.0.0",
     "block": {
       "body": null,
       "hash": "f598c1b2852acebc299c200751dae20565b3891fa0d656f537959a68c47a1ef5",
       "header": {
         "accumulated_seed": "da4dd0e151f20e503d51cf7af35a0e45532563547b7053de956261bde23f1b48",
         "body_hash": "0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8",
         "deploy_hashes": [],
         "era_end": null,
         "era_id": 151,
         "global_state_hash": "95da44e0e6f380034176386bc60cc77e07d7ccc07267588ca0a08fd3aa60466b",
         "height": 1694,
         "parent_hash": "10947da39448da222974d097119b4f20679b9f33fe922c20dc2e0241d9d9b06e",
         "proposer": "016af0262f67aa93a225d9d57451023416e62aaa8391be8e1c09b8adbdef9ac19d",
         "random_bit": true,
         "timestamp": "2020-10-19T21:37:47.008Z"
       },
       "proofs": [
         "01ade71b9975b8f11ea6caf5c268b1ab09952969a5a70f2fcc557768053aaf8271e87c7e07190655bc0fbde595e50a4581262a37f304874a0d79357062a9567805"
       ]
     }
   }

Deploy Status
-------------

Once a transaction (deploy) has been submitted to the network, it is possible to check its execution status using ``get-deploy``.

If the ``execution_results`` in the output are null, the transaction hasn't run yet. Transactions are finalized upon execution.

**Important request fields:**

- ``id`` - <STRING OR INTEGER> JSON-RPC identifier, applied to the request and returned in the response. If not provided, a random integer will be assigned
- ``node-address`` - <HOST:PORT>Hostname or IP and port of node on which HTTP service is running [default:http://localhost:7777]

::

    casper-client get-deploy \
          --id 2 \
          --node-address http://<peer-ip-address>:7777 \
          <deploy-hash>










Querying the State for the Address of a contract
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``query-state`` command is a generic query against global state. Earlier we queried global state for the account's main purse. Here we query the state of a contract. We can do so by including the contract address rather than the account public key in the ``query-state`` command.

Here we query to get the address of an ERC20 contract from Global State.

Step 1: Get the Latest Global State Hash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We need to obtain the global state hash after our contract has been deployed to the network.

.. code-block:: bash

   casper-client get-state-root-hash --node-address http://NODE:PORT | jq -r

Step 2: Query State
~~~~~~~~~~~~~~~~~~~

Now take the global state hash from Step 1 and include it here, along with the account public key that created the contract.

.. code-block:: bash

   casper-client query-state --node-address http://NODE:PORT -k <PUBLIC KEY IN  HEX> -s <STATE_ROOT_HASH>

Example Result
~~~~~~~~~~~~~~

If there is a contract stored in an account, it will appear under ``named-keys``. 

.. code-block:: bash

   casper-client query-state --node-address http://localhost:7777 -k 016af0262f67aa93a225d9d57451023416e62aaa8391be8e1c09b8adbdef9ac19d -s 0c3aaf547a55dd500c6c9bbd42bae45e97218f70a45fee6bf8ab04a89ccb9adb |jq -r
   {
     "api_version": "1.0.0",
     "stored_value": {
       "Account": {
         "account_hash": "804af75bc8161e1ec4189e7d4441eb1bf1047ff6fc13b1d71026f34c5f96f937",
         "action_thresholds": {
           "deployment": 1,
           "key_management": 1
         },
         "associated_keys": [
           {
             "account_hash": "804af75bc8161e1ec4189e7d4441eb1bf1047ff6fc13b1d71026f34c5f96f937",
             "weight": 1
           }
         ],
         "main_purse": "uref-439d5326bf89bd34d3b2c924b3af2f5e233298b473d5bd8b54fab61ccef6c003-007",
         "named_keys": {
           "ERC20": "hash-d527103687bfe3188caf02f1e487bfb8f60bfc01068921f7db24db72a313cedb",
           "ERC20_hash": "uref-80d9d36d628535f0bc45ae4d28b0228f9e07f250c3e85a85176dba3fc76371ce-007",

         }
       }
     }
   }

Step 3: Query the contract State
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now that we have the hash of the contract, we can query the contract's internal state. To do this, we pass in the contract's hash and the global state hash.  If we look at the ERC20 contract, we see that there is a token name specified as ``_name``.  We can query for the value stored here.

.. code-block:: bash

   casper-client query-state --node-address http://localhost:7777 -k hash-d527103687bfe3188caf02f1e487bfb8f60bfc01068921f7db24db72a313cedb -s 0c3aaf547a55dd500c6c9bbd42bae45e97218f70a45fee6bf8ab04a89ccb9adb -q _name | jq -r

And we should see something like this:

.. code-block:: bash

   {
     "api_version": "1.0.0",
     "stored_value": {
       "CLValue": {
         "bytes": "0b000000e280984d65646861e28099",
         "cl_type": "String"
       }
     }
   }

Note: This result is returned as bytes. These bytes need to be deserialized into a the correct CLType.  This can be done in the contract or in the dApp.
Refer to `casper-types <https://docs.rs/casperlabs-types/0.6.1/casperlabs_types/bytesrepr/index.html>`_ for the API's to do this.
