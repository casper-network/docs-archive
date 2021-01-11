Examples with multi-signature
=============================

This section walks you through scenarios where accounts have multiple associated keys for signing transactions at various thresholds.

In the image below, the `nctl tool <https://github.com/CasperLabs/casper-node/blob/master/utils/nctl/README.md>`_ set up a local Casper network to display the structure of the faucet account.

.. image:: ../../assets/tutorials/multisig/account_example.png

| 

1) One key signing all transactions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, only one key can sign transactions in the name of this account. The key is "account-hash-a1…" under the associated_keys. If you sign the transaction using "account-hash-a1…", the signed transaction will have a weight equal to 1. For deployments or key management, the weight required is also 1. Therefore, the associated key meets the deployment and key management thresholds and can perform both actions.

.. code-block:: sh

   {
       "api_version": "1.0.0",
       "merkle_proof": "01000…..11",
       "stored_value": {
          "Account": {
             "account_hash": "account-hash-a1…",
                "action_thresholds": {
                   "deployment": 1,
                   "key_management": 1
             },
             "associated_keys": [
                {
                   "account_hash": "account-hash-a1…",
                   "weight": 1
                }
             ],
             "main_purse": "uref-1234…",
             "named_keys": []
          }
       }
   }


2) Special keys for deployments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, you have two keys. One key can only perform deployments, and the second key can perform key management and deployments.  The key with account hash a1 can deploy and make account changes, but the second key with account hash b2 can only deploy and cannot make any account changes.
    
.. code-block:: sh

 {
    "api_version": "1.0.0",
    "merkle_proof": "01000…..11",
    "stored_value": {
        "Account": {
            "account_hash": "account-hash-a1…",
            "action_thresholds": {
                "deployment": 1,
                "key_management": 2
            },
            "associated_keys": [
                {
                    "account_hash": "account-hash-a1…",
                    "weight": 2
                },
                {
                    "account_hash": "account-hash-b2…",
                    "weight": 1
                }
            ],
            "main_purse": "uref-1234…",
            "named_keys": []
        }
    }
 }




3) Multiple keys signing a transaction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some transactions require multiple associated keys. In this example, the two associated keys have weight 1. To make changes to the account, you need to use both keys to sign the transaction. However, for deployment, each key can sign separately.

.. code-block:: sh

 {
   "api_version": "1.0.0",
   "merkle_proof": "01000…..11",
   "stored_value": {
      "Account": {
         "account_hash": "account-hash-a1…",
         "action_thresholds": {
            "deployment": 1,
            "key_management": 2
         },
         "associated_keys": [
            {
               "account_hash": "account-hash-a1…",
               "weight": 1
            },
            {
               "account_hash": "account-hash-b2…",
               "weight": 1
            }
         ],
         "main_purse": "uref-1234…",
         "named_keys": []
      }
   }
 }

4) Two out of three accounts signing a transaction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, two out of three associated keys need to sign a transaction. 
Consider a transaction where you have one key in your browser, one key on your mobile phone, and one key in your safe. To do a transaction, first, you sign it with your browser extension (for example, Metamask). Afterward, a notification appears on your mobile phone requesting you to approve the transaction. With these two keys, you can complete the transaction.
However, what if you lose the two keys on your browser and phone? 
Also, what if someone finds your browser and phone? They can perform deployments, but they cannot change the account details.
In this setup, you can use the safe key to remove the lost keys from the account because the safe key's weight is 3.

.. code-block:: sh

 {
   "api_version": "1.0.0",
   "merkle_proof": "01000…..11",
   "stored_value": {
      "Account": {
         "account_hash": "account-hash-a1…",
         "action_thresholds": {
            "deployment": 2,
            "key_management": 3
         },
         "associated_keys": [
            {
               "account_hash": "account-hash-a1…",  //browser
               "weight": 1
            },
            {
               "account_hash": "account-hash-b2…",  //mobile
               "weight": 1
            },
            {
               "account_hash": "account-hash-c3…",  //safe
               "weight": 3
            }
         ],
         "main_purse": "uref-1234…",
         "named_keys": []
      }
   }
 }

5) Having multiple safe keys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example builds upon the previous example, where you can set up multiple safe keys. The additional safe keys can be in the bank, under your mattress, or encrypted on your computer.

.. code-block:: sh

 {
   "api_version": "1.0.0",
   "merkle_proof": "01000…..11",
   "stored_value": {
      "Account": {
         "account_hash": "account-hash-a1…",
         "action_thresholds": {
            "deployment": 2,
            "key_management": 3
         },
         "associated_keys": [
            {
               "account_hash": "account-hash-a1…",  // browser
               "weight": 1
            },
            {
               "account_hash": "account-hash-b2…",  // mobile
               "weight": 1
            },
            {
               "account_hash": "account-hash-c3…",  // safe 1
               "weight": 3
            },
            {
               "account_hash": "account-hash-d3…",  // safe 2
               "weight": 3
            },
            {
               "account_hash": "account-hash-e3…",  // safe 3
               "weight": 3
            }
         ],
         "main_purse": "uref-1234…",
         "named_keys": []
      }
   }
 }

6) Deploying as the same account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example outlines that it doesn't matter which key you use to sign. You will always deploy as the same account. You can throw away the private key of your account (although maybe not recommended), and you would still be able to execute transactions.

.. code-block:: sh

 {
   "api_version": "1.0.0",
   "merkle_proof": "01000…..11",
   "stored_value": {
      "Account": {
         "account_hash": "account-hash-00…",
         "action_thresholds": {
            "deployment": 2,
            "key_management": 3
         },
         "associated_keys": [
            {
               "account_hash": "account-hash-00…", // my account
               "weight": 0
            },
            {
               "account_hash": "account-hash-a1…", // browser
               "weight": 1
            },
            {
               "account_hash": "account-hash-b2…", // mobile
               "weight": 1
            },
            {
               "account_hash": "account-hash-c3…", // safe 1
               "weight": 3
            },
            {
               "account_hash": "account-hash-d3…", // safe 2
               "weight": 3
            },
            {
               "account_hash": "account-hash-e3…", // safe 3
               "weight": 3
            }
         ],
         "main_purse": "uref-1234…",
         "named_keys": []
      }
   }
 }


7) Blocking your account
^^^^^^^^^^^^^^^^^^^^^^^^

In this example, the user has accidentally blocked the account. The deployment threshold is 2, but the account has only one associated key with a weight set to 1. It is essential to have a sufficient number of keys to perform key management. Otherwise, account recovery will not be possible, as we do not support inactive accounts' recovery. This example will hopefully help you avoid this scenario.

.. code-block:: sh

 {
   "api_version": "1.0.0",
   "merkle_proof": "01000…..11",
   "stored_value": {
      "Account": {
         "account_hash": "account-hash-a1…",
         "action_thresholds": {
            "deployment": 2,
            "key_management": 2
         },
         "associated_keys": [
            {
               "account_hash": "account-hash-a1…",
               "weight": 1
            }
         ],
         "main_purse": "uref-1234…",
         "named_keys": []
      }
   }
 }

8) Deployments blocked temporarily
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, the user has accidentally blocked the deployments, but the associated key can change the deployment threshold from 2 to 1. The key_management threshold is 1, which enables the associated key to change the threshold of any action. [http://localhost:8000/implementation/accounts.html#key-management-actions]

.. code-block:: sh

 {
   "api_version": "1.0.0",
   "merkle_proof": "01000…..11",
   "stored_value": {
      "Account": {
         "account_hash": "account-hash-a1…",
         "action_thresholds": {
            "deployment": 2,
            "key_management": 1
         },
         "associated_keys": [
            {
               "account_hash": "account-hash-a1…",
               "weight": 1
            }
         ],
         "main_purse": "uref-1234…",
         "named_keys": []
      }
   }
 }
