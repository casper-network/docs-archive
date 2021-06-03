Undelegating Tokens
===================

This document details a workflow where tokens delegated to a validator on a Casper network can be undelegated.

Requirements
^^^^^^^^^^^^

This workflow assumes:

1. You meet the `prerequisites <setup.html>`_
2. Are using the Casper command line client
3. The undelegation contract or WASM to execute on the network
4. A valid ``node-address``.
5. Have previously deployed a smart contract to a Casper network (Refer: `Deploying Contracts <https://docs.casperlabs.io/en/latest/dapp-dev-guide/deploying-contracts.html>`_)
6. Have previously delegated tokens to a validator


Building The Undelegation WASM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you cannot obtain the ``undelegate.wasm`` from a trusted source, you can build the WASM yourself.

Clone the `casper-node <https://github.com/CasperLabs/casper-node>`_ repository and build the contracts.
To build contracts, set up Rust and install all dependencies, visit `Setting up Rust <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_ in the Developer Guide.

Once the contracts have been built, you will need the ``undelegate.wasm`` to create a deploy that we will initiate the un-delegation process.

The WASM can be found in:

::

    target/wasm32-unknown-unknown/release


Sending the Undelegation Deploy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To initiate the undelegation process, send a deploy containing the ``undelegate.wasm`` to the network.


Below is an example using the Casper command line client:

::

    casper-client put-deploy \
    --node-address http://<peer-ip-addres>:7777/rpc \
    --chain-name casper \
    --session-path <path-to-wasm>/undelegate.wasm \
    --payment-amount 250000000000 \
    --session-arg "validator:public_key='<hex-encoded-validator-public-key>'" \
    --session-arg "amount:u512='<amount-to-delegate>'"
    --session-arg "delegator:public_key='<hex-encoded-public-key>'" \
    --secret-key <delegator-secret-key>.pem

**Note** The delegator public key and the secret key that signs the deploy must be part of the same keypair.

**Request fields:**

- ``id`` - <STRING OR INTEGER> Optional JSON-RPC identifier applied to the request and returned in the response. If not provided, a random integer will be assigned
- ``node-address`` - <HOST:PORT> Hostname or IP and port of node on which HTTP service is running [default:http://localhost:7777]
- ``secret-key`` - Path to secret key file
- ``chain-name`` - Name of the chain, to avoid the deploy from being accidentally or maliciously included in a different chain

    - The *chain-name* for testnet is **casper-test**
    - The *chain-name* for mainnet is **casper**

- ``session-path`` - The path to where the ``delegate.wasm`` is located
- ``session-arg`` - The arguments to the ``delegate`` execution

    - The argument ``validator`` is the public key of the validator from whom the tokens will be undelegated
    - The argument ``amount`` is the amount of tokens to be undelegated
    - The argument ``delegator`` is the public key of the account undelegating tokens from a validator


Asserting the undelegation
^^^^^^^^^^^^^^^^^^^^^^^^^^

We can use the Casper command line client to generate an RPC request to query for the auction state.
The subsequent RPC response will confirm that the undelegation request was successfully executed.


Check the status of the Auction to confirm that our bid has been withdrawn.

::

    casper-client get-auction-info \
    --node-address http://<peer-ip-address>:7777/rpc

**Request fields**:

- ``node-address`` - <HOST:PORT> Hostname or IP and port of node on which HTTP service is running [default:http://localhost:7777]


If the public key and the amount are absent from the ``bids`` structure then we can safely assert that we have indeed un-delegated from the validator.


If your account is on the official Testnet or Mainnet, you can use the Block explorer to look up your account balance and see the tokens have been added to your balance.

1. `Testnet explorer <https://testnet.cspr.live/>`_
2. `Mainnet explorer <https://cspr.live/>`_

**Important Note**: After un-delegating tokens from a validator, you must wait for the unbonding period to lapse before re-delegating tokens to either the same validator or a different validator.

