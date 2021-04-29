
CSPR Transfer Workflow
================

This document describes a sample workflow for transferring tokens and verifying their transfer on a Casper network as of `Release-1.0.0 <https://github.com/CasperLabs/casper-node/tree/release-1.0.0>`_ .

Requirements
~~~~~~~~~~~~~

In order to follow the steps detailed below, the following is required:

1. A compatible client
2. Two accounts (one source, one target)
3. The IP address of a node on the target

CasperLabs Client
******************

Download the client `here <https://github.com/CasperLabs/casper-node/tree/release-1.0.0/client>`_

Note: The client can print out `help` information which provides an up to date list of supported commands. You can also check the help information for each individual command.

.. code-block:: bash

    $ casper-client <command> --help

Setting up Accounts on Testnet
******************************

Accounts for the testnet can be created using the block explorer, `Clarity`.

Start by creating an account on clarity using the given link:
`Create Account <https://clarity-testnet.make.services/#/accounts>`_

Create one account for the source of the transfer and one for the target account.

Save the three files for each account:

1. ``<Account-Name>`` _secret_key.pem (PEM encoded secret key)
2. ``<Account-Name>`` _public_key.pem (PEM encoded public key)
3. ``<Account-Name>`` _public_key_hex (Hex encoded string of the public key)

and note the location where they are saved.

Note: You will need the hex-encoded string of the public key in many cases.
Obtain the string by reading the ``<Account-Name>`` _public_key_hex file.

Fund both the target and source accounts using the ``[Request tokens]`` button on the Faucet page to receive tokens.
`Faucet Page <https://clarity-testnet.make.services/#/faucet>`_

Acquire Node IP address
***********************

You can get an IP address of a node on the network by visiting the `Peers <https://clarity-testnet.make.services/#/peers>`_ page.
You will see a list of peers and select the IP of any peer on the list.

Note: If the selected peer is blocking the port pick a different peer and try again.

Transfer
~~~~~~~~

RPC requests are sent to a node's RPC endpoint ``http://<peer-ip-address>:7777/rpc`` , including transfers which are a specialized type of deploy.

The following command demonstrates how to transfer from a source account to a target account using the rust client, by sending a request to the selected node's RPC endpoint.

::

    $ casper-client transfer \
        --id 1 \
        --node-address http://<peer-ip-address>:7777/rpc \
        --amount <amount-to-transfer> \
        --secret-key <source-account-secret-key>.pem \
        --chain-name casper-test \
        --payment-amount 10000 \
        --target-account <hex-encoded-target-account-public-key>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 1,
      "jsonrpc": "2.0",
      "method": "account_put_deploy",
      "params": {
        "deploy": {
          "approvals": [
            {
              "signature": "130 chars",
              "signer": "010f50b0116f213ef65b99d1bd54483f92bf6131de2f8aceb7e3f825a838292150"
            }
          ],
          "hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
          "header": {
            "account": "010f50b0116f213ef65b99d1bd54483f92bf6131de2f8aceb7e3f825a838292150",
            "body_hash": "da35b095640a403324306c59ac6f18a446dfcc28faf753ce58b96b635587dd8e",
            "chain_name": "casper-net-1",
            "dependencies": [],
            "gas_price": 1,
            "timestamp": "2021-04-20T18:04:40.333Z",
            "ttl": "1h"
          },
          "payment": {
            "ModuleBytes": {
              "args": [
                [
                  "amount",
                  {
                    "bytes": "021027",
                    "cl_type": "U512",
                    "parsed": "10000"
                  }
                ]
              ],
              "module_bytes": ""
            }
          },
          "session": {
            "Transfer": {
              "args": [
                [
                  "amount",
                  {
                    "bytes": "0400f90295",
                    "cl_type": "U512",
                    "parsed": "2500000000"
                  }
                ],
                [
                  "target",
                  {
                    "bytes": "8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
                    "cl_type": {
                      "ByteArray": 32
                    },
                    "parsed": "8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668"
                  }
                ],
                [
                  "id",
                  {
                    "bytes": "00",
                    "cl_type": {
                      "Option": "U64"
                    },
                    "parsed": null
                  }
                ]
              ]
            }
          }
        }
      }
    }

.. code-block:: json

    {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "deploy_hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713"
      }
    }

.. raw:: html

    </details>

Note: We will use the returned `deploy_hash` to query information about the transfer deploy.


Get-Deploy
~~~~~~~~~~

We will now use the deploy hash to get more information about the status of the deploy.


::

    $ casper-client get-deploy \
          --id 2 \
          --node-address http://<peer-ip-address>:7777/rpc \
          <deploy-hash>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
    "id": 2,
    "jsonrpc": "2.0",
    "method": "info_get_deploy",
    "params": {
    "deploy_hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713"
    }
    }

.. code-block:: json

    {
      "id": 2,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "deploy": {
          "approvals": [
            {
              "signature": "130 chars",
              "signer": "010f50b0116f213ef65b99d1bd54483f92bf6131de2f8aceb7e3f825a838292150"
            }
          ],
          "hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
          "header": {
            "account": "010f50b0116f213ef65b99d1bd54483f92bf6131de2f8aceb7e3f825a838292150",
            "body_hash": "da35b095640a403324306c59ac6f18a446dfcc28faf753ce58b96b635587dd8e",
            "chain_name": "casper-net-1",
            "dependencies": [],
            "gas_price": 1,
            "timestamp": "2021-04-20T18:04:40.333Z",
            "ttl": "1h"
          },
          "payment": {
            "ModuleBytes": {
              "args": [
                [
                  "amount",
                  {
                    "bytes": "021027",
                    "cl_type": "U512",
                    "parsed": "10000"
                  }
                ]
              ],
              "module_bytes": ""
            }
          },
          "session": {
            "Transfer": {
              "args": [
                [
                  "amount",
                  {
                    "bytes": "0400f90295",
                    "cl_type": "U512",
                    "parsed": "2500000000"
                  }
                ],
                [
                  "target",
                  {
                    "bytes": "8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
                    "cl_type": {
                      "ByteArray": 32
                    },
                    "parsed": "8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668"
                  }
                ],
                [
                  "id",
                  {
                    "bytes": "00",
                    "cl_type": {
                      "Option": "U64"
                    },
                    "parsed": null
                  }
                ]
              ]
            }
          }
        },
        "execution_results": [
          {
            "block_hash": "7c7e9b0f087bba5ce6fc4bd067b57f69ea3c8109157a3ad7f6d98b8da77d97f9",
            "result": {
              "Success": {
                "cost": "10000",
                "effect": {
                  "operations": [
                    {
                      "key": "hash-d13610d5930fdab36fc25838bc8b4b77fdb4859755dd628c2d30e2a6dfc86a8c",
                      "kind": "Read"
                    },
                    {
                      "key": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
                      "kind": "Read"
                    },
                    {
                      "key": "balance-39b6cc617efddbcc5e989c9eb73ddb5d825bb1070309e7429c029826074e038a",
                      "kind": "Read"
                    },
                    {
                      "key": "balance-9e90f4bbd8f581816e305eb7ea2250ca84c96e43e8735e6aca133e7563c6f527",
                      "kind": "Write"
                    },
                    {
                      "key": "deploy-ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
                      "kind": "Write"
                    },
                    {
                      "key": "balance-34ec8bcae2675d16bad7e8ba10fada1e50dacf3935ce3b12c25a5bf000fefc76",
                      "kind": "Write"
                    },
                    {
                      "key": "transfer-8d81f4a1411d9481aed9c68cd700c39d870757b0236987bb6b7c2a7d72049c0e",
                      "kind": "Write"
                    },
                    {
                      "key": "hash-1e13f06cb64bcbf46348dc53c35444da5afc956cfd764cbc3399dc71692e0bd8",
                      "kind": "Read"
                    },
                    {
                      "key": "balance-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e",
                      "kind": "Write"
                    }
                  ],
                  "transforms": [
                    {
                      "key": "balance-39b6cc617efddbcc5e989c9eb73ddb5d825bb1070309e7429c029826074e038a",
                      "transform": "Identity"
                    },
                    {
                      "key": "deploy-ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
                      "transform": {
                        "WriteDeployInfo": {
                          "deploy_hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
                          "from": "account-hash-b0049301811f23aab30260da66927f96bfae7b99a66eb2727da23bf1427a38f5",
                          "gas": "10000",
                          "source": "uref-9e90f4bbd8f581816e305eb7ea2250ca84c96e43e8735e6aca133e7563c6f527-007",
                          "transfers": [
                            "transfer-8d81f4a1411d9481aed9c68cd700c39d870757b0236987bb6b7c2a7d72049c0e"
                          ]
                        }
                      }
                    },
                    {
                      "key": "hash-1e13f06cb64bcbf46348dc53c35444da5afc956cfd764cbc3399dc71692e0bd8",
                      "transform": "Identity"
                    },
                    {
                      "key": "transfer-8d81f4a1411d9481aed9c68cd700c39d870757b0236987bb6b7c2a7d72049c0e",
                      "transform": {
                        "WriteTransfer": {
                          "amount": "2500000000",
                          "deploy_hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
                          "from": "account-hash-b0049301811f23aab30260da66927f96bfae7b99a66eb2727da23bf1427a38f5",
                          "gas": "0",
                          "id": null,
                          "source": "uref-9e90f4bbd8f581816e305eb7ea2250ca84c96e43e8735e6aca133e7563c6f527-007",
                          "target": "uref-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e-004",
                          "to": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668"
                        }
                      }
                    },
                    {
                      "key": "balance-34ec8bcae2675d16bad7e8ba10fada1e50dacf3935ce3b12c25a5bf000fefc76",
                      "transform": {
                        "AddUInt512": "10000"
                      }
                    },
                    {
                      "key": "hash-d13610d5930fdab36fc25838bc8b4b77fdb4859755dd628c2d30e2a6dfc86a8c",
                      "transform": "Identity"
                    },
                    {
                      "key": "balance-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e",
                      "transform": {
                        "AddUInt512": "2500000000"
                      }
                    },
                    {
                      "key": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
                      "transform": "Identity"
                    },
                    {
                      "key": "balance-9e90f4bbd8f581816e305eb7ea2250ca84c96e43e8735e6aca133e7563c6f527",
                      "transform": {
                        "WriteCLValue": {
                          "bytes": "0ee0bff9d5085bc138938d44c64d31",
                          "cl_type": "U512",
                          "parsed": "999999999999999999999994999980000"
                        }
                      }
                    }
                  ]
                },
                "transfers": [
                  "transfer-8d81f4a1411d9481aed9c68cd700c39d870757b0236987bb6b7c2a7d72049c0e"
                ]
              }
            }
          }
        ]
      }
    }

.. raw:: html

    </details>

Note there is two field in this response that interests us:

1. ``"result"."execution_results"[0]."transfers[0]"``
2. ``"result"."execution_results"[0]."block_hash"``

The first is the address of the executed transfer that the source account initiated. We will use it to look up additional information about the transfer.
The second contains the block hash of the block that included our transfer. We will require the `state_root_hash` of this block to lookup information about the accounts and their balances.

Note: Transfer addresses use a ``transfer-`` string prefix.

Get-Block
~~~~~~~~~~

We will use the ``block_hash`` to query and retrieve the block that contains our deploy for its ``state_root_hash``

::

    $ casper-client get-block \
          --id 3 \
          --node-address http://<peer-ip-address>:7777/rpc \
          --block-identifier <block-hash> \

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 3,
      "jsonrpc": "2.0",
      "method": "chain_get_block",
      "params": {
        "block_identifier": {
          "Hash": "7c7e9b0f087bba5ce6fc4bd067b57f69ea3c8109157a3ad7f6d98b8da77d97f9"
        }
      }
    }

.. code-block:: json

    {
      "id": 3,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "block": {
          "body": {
            "deploy_hashes": [],
            "proposer": "012c6775c0e9e09f93b9450f1c5348c5f6b97895b0f52bb438f781f96ba2675a94",
            "transfer_hashes": [
              "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713"
            ]
          },
          "hash": "7c7e9b0f087bba5ce6fc4bd067b57f69ea3c8109157a3ad7f6d98b8da77d97f9",
          "header": {
            "accumulated_seed": "50b8ac019b7300cd1fdeec050310e61b900e9238aa879929745900a91bd0fc4f",
            "body_hash": "224076b19c04279ae9b97f620801d5ff40ba64f431fe0d5089ef7cb84fdff45a",
            "era_end": null,
            "era_id": 0,
            "height": 8,
            "parent_hash": "416f339c4c2ff299c64a4b3271c5ef2ac2297bb40a477ceacce1483451a4db16",
            "protocol_version": "1.0.0",
            "random_bit": true,
            "state_root_hash": "cfdbf775b6671de3787cfb1f62f0c5319605a7c1711d6ece4660b37e57e81aa3",
            "timestamp": "2021-04-20T18:04:42.368Z"
          },
          "proofs": [
            {
              "public_key": "010f50b0116f213ef65b99d1bd54483f92bf6131de2f8aceb7e3f825a838292150",
              "signature": "130 chars"
            },
            {
              "public_key": "012c6775c0e9e09f93b9450f1c5348c5f6b97895b0f52bb438f781f96ba2675a94",
              "signature": "130 chars"
            },
            {
              "public_key": "018d5da83f22c9b65cdfdf9f9fdf9f7c98aa2b8c7bcf14bf855177bbb9c1ac7f0a",
              "signature": "130 chars"
            },
            {
              "public_key": "01b9088b92c8a8d592f6ec8c3e8153d7c55fc0c38b5999a214e37e73a2edd6fe0f",
              "signature": "130 chars"
            },
            {
              "public_key": "01b9e3484d96d5693e6c5fe789e7b28972aa392b054a76d175f079692967f604de",
              "signature": "130 chars"
            }
          ]
        }
      }
    }

.. raw:: html

    </details>


Note there is one field in this response that interests us:

``"result"."block"."header"."state_root_hash"``

This contains the root hash of the global state trie for this block. We will use this to look up various values, like the source and destination account and their balances.

Query (Source Account)
~~~~~~~~~~~~~~~~~~~~~~~

Using the global state hash of the block containing our transfer deployment and the public key of the target account, we will query for information about the ``Source`` account.

::

    $ casper-client query-state \
      --id 4 \
      --node-address http://<peer-ip-address>:7777/rpc \
      --state-root-hash <state-root-hash> \
      --key <hex-encoded-source-account-public-key>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 4,
      "jsonrpc": "2.0",
      "method": "state_get_item",
      "params": {
        "key": "account-hash-b0049301811f23aab30260da66927f96bfae7b99a66eb2727da23bf1427a38f5",
        "path": [],
        "state_root_hash": "cfdbf775b6671de3787cfb1f62f0c5319605a7c1711d6ece4660b37e57e81aa3"
      }
    }

.. code-block:: json

    {
      "id": 4,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "merkle_proof": "2228 chars",
        "stored_value": {
          "Account": {
            "account_hash": "account-hash-b0049301811f23aab30260da66927f96bfae7b99a66eb2727da23bf1427a38f5",
            "action_thresholds": {
              "deployment": 1,
              "key_management": 1
            },
            "associated_keys": [
              {
                "account_hash": "account-hash-b0049301811f23aab30260da66927f96bfae7b99a66eb2727da23bf1427a38f5",
                "weight": 1
              }
            ],
            "main_purse": "uref-9e90f4bbd8f581816e305eb7ea2250ca84c96e43e8735e6aca133e7563c6f527-007",
            "named_keys": []
          }
        }
      }
    }

.. raw:: html

    </details>


Note there is one field in this response that interests us:

``"result"."stored_value"."Account"."main_purse"``

This value is the address of the main purse containing the sender’s tokens. This purse is the source of the tokens transferred in this example.

Query (Target Account)
~~~~~~~~~~~~~~~~~~~~~~

We will repeat the above step to query information about the target account.

::

    $ casper-client query-state \
          --id 5 \
          --state-root-hash <state-root-hash> \
          --key <hex-encoded-target-account-public-key>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 5,
      "jsonrpc": "2.0",
      "method": "state_get_item",
      "params": {
        "key": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
        "path": [],
        "state_root_hash": "cfdbf775b6671de3787cfb1f62f0c5319605a7c1711d6ece4660b37e57e81aa3"
      }
    }

.. code-block:: json

    {
      "id": 5,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "merkle_proof": "2228 chars",
        "stored_value": {
          "Account": {
            "account_hash": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
            "action_thresholds": {
              "deployment": 1,
              "key_management": 1
            },
            "associated_keys": [
              {
                "account_hash": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668",
                "weight": 1
              }
            ],
            "main_purse": "uref-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e-007",
            "named_keys": []
          }
        }
      }
    }

.. raw:: html

    </details>



GetBalance (Source Purse)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Now that we have the address of the ``Source`` purse, we can get its balance.

::

    $ casper-client get-balance \
          --id 6 \
          --node-address http://<peer-ip-address>:7777/rpc \
          --state-root-hash <state-root-hash> \
          --purse-uref <source-account-purse-uref>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 7,
      "jsonrpc": "2.0",
      "method": "state_get_balance",
      "params": {
        "purse_uref": "uref-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e-007",
        "state_root_hash": "cfdbf775b6671de3787cfb1f62f0c5319605a7c1711d6ece4660b37e57e81aa3"
      }
    }

.. code-block:: json

    {
      "id": 7,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "balance_value": "5000000000",
        "merkle_proof": "2502 chars"
      }
    }

.. raw:: html

    </details>

We can now see the balance of the ``Source`` account.


GetBalance (Target Purse)
~~~~~~~~~~~~~~~~~~~~~~~~~

Similarly, now that we have the address of the target purse, we can get its balance.

::

    $ casper-client get-balance \
          --id 7 \
          --node-address http://<peer-ip-address>:7777/rpc \
          --state-root-hash <state-root-hash> \
          --purse-uref <target-account-purse-uref>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 7,
      "jsonrpc": "2.0",
      "method": "state_get_balance",
      "params": {
        "purse_uref": "uref-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e-007",
        "state_root_hash": "cfdbf775b6671de3787cfb1f62f0c5319605a7c1711d6ece4660b37e57e81aa3"
      }
    }

.. code-block:: json

    {
      "id": 7,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "balance_value": "5000000000",
        "merkle_proof": "2502 chars"
      }
    }

.. raw:: html

    </details>


Query (Transfer)
~~~~~~~~~~~~~~~~~

We will use the ``transfer-<address>`` to query for details about the transfer.

::

    $ casper-client query-state \
          --id 8 \
          --node-address http://<peer-ip-address>:7777/rpc \
          --state-root-hash <state-root-hash> \
          --key transfer-<address>

.. raw:: html

    <details>
    <summary>Sample Output</summary>

.. code-block:: json

    {
      "id": 8,
      "jsonrpc": "2.0",
      "method": "state_get_item",
      "params": {
        "key": "transfer-8d81f4a1411d9481aed9c68cd700c39d870757b0236987bb6b7c2a7d72049c0e",
        "path": [],
        "state_root_hash": "cfdbf775b6671de3787cfb1f62f0c5319605a7c1711d6ece4660b37e57e81aa3"
      }
    }

.. code-block:: json

    {
      "id": 8,
      "jsonrpc": "2.0",
      "result": {
        "api_version": "1.0.0",
        "merkle_proof": "924 chars",
        "stored_value": {
          "Transfer": {
            "amount": "2500000000",
            "deploy_hash": "ec2d477a532e00b08cfa9447b7841a645a27d34ee12ec55318263617e5740713",
            "from": "account-hash-b0049301811f23aab30260da66927f96bfae7b99a66eb2727da23bf1427a38f5",
            "gas": "0",
            "id": null,
            "source": "uref-9e90f4bbd8f581816e305eb7ea2250ca84c96e43e8735e6aca133e7563c6f527-007",
            "target": "uref-6f4026262a505d5e1b0e03b1e3b7ab74a927f8f2868120cf1463813c19acb71e-004",
            "to": "account-hash-8ae68a6902ff3c029cea32bb67ae76b25d26329219e4c9ceb676745981fd3668"
          }
        }
      }
    }

.. raw:: html

    </details>

Here we can see information about the transfer we conducted: its deploy hash, the account which executed the transfer, the source and target purses and the target account as well.
Using this we can verify our transfer executed successfully.


List RPCs
~~~~~~~~~

The above example uses RPC calls to execute and then verify the transfer. There are additional RPC calls that can be made to compose other use cases.
There is an RPC call that can be made to the endpoint which lists the RPC calls which are supported by that version of the node.

::

    $ casper-client list-rpcs

The endpoint returns an OpenRPC compliant document which describes all the RPC calls available and provides examples for the RPCs as well.
Please be sure to query this specific endpoint as it provides the up-to-date information on interacting with the RPC endpoint.