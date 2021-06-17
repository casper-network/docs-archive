Prerequisites
==============

This section explains how to fulfill the prerequisites needed to interact with a Casper Network.

This section covers:

1. Installing the official Casper command-line client
2. Setting up an account on a Casper Network
3. Acquiring the IP address of a peer on the official Testnet or Mainnet

The Casper command-line client
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can find the client on `crates.io <https://crates.io/crates/casper-client>`_.

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

Setting up an Account
^^^^^^^^^^^^^^^^^^^^^

The process of creating an `Account <https://docs.casperlabs.io/en/latest/implementation/accounts.html>`_ can be divided into two steps:

1. Cryptographic key generation for the ``Account``
2. Funding the ``Account``

The Casper blockchain uses an on-chain ``Account`` based model, uniquely identified by an ``AccountHash`` derived from a specific ``PublicKey``.

By default, a transactional interaction with the blockchain takes the form of a ``Deploy`` cryptographically signed by the key-pair corresponding to the ``PublicKey`` used to create the account.

Accounts can be created using the Casper command-line client. Alternatively, some Casper networks such as the official Testnet and Mainnet provide a browser-based block explorer that allows ``Account`` creation.

A cryptographic key-pair will be created when using either the Casper command-line client or a block explorer to create an ``Account`` on the blockchain. This process generates three files for each ``Account``:

1. A PEM encoded secret key
2. A PEM encoded public key
3. A hex-encoded string representation of the public key

We recommend saving these files securely.

The command-line client provides a command that will give you the account hash for a given public key.

.. code-block:: bash

    casper-client account-address --public-key <path-to-public-key-hex>/public_key_hex

Option 1: Key generation using the Casper client
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This option describes how you can use the Casper command-line client to set up your accounts.

Execute the following command to generate your keys:

.. code-block:: bash

    casper-client keygen .

The above command will create three files in the current working directory:

1. ``secret_key.pem`` - PEM encoded secret key
2. ``public_key.pem`` - PEM encoded public key
3. ``public_key_hex`` - Hex encoded string of the public key

**Note**: SAVE your keys to a safe place, preferably offline.

Once the keys for the account have been generated, the accounts can be funded to finish the process of creating an account.

**Note**: Responses from the node contain ``AccountHashes`` instead of the direct hex-encoded public key. For traceability, it is important to generate the account hash and store this value locally. The account hash is a ``Blake2B`` hash of the public hex key.

Option 2: Key generation using a Block Explorer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This option is also available on networks that have a block explorer.

For instance, on the official Testnet network the `CSPR.live <https://testnet.cspr.live/>`_ block explorer is available, and the following instructions assume you are using it.

Start by creating an account using the `Create Account <https://clarity-testnet-old.make.services/#/accounts>`_ link. You will be asked to provide a unique name for your account; this is for your convenience and is not stored on chain.

You will be prompted to save three files for your new account; carefully choose where you store them. We recommend storing your keys in a secure manner.

1. ``<Account-Name>_secret_key.pem`` - PEM encoded secret key
2. ``<Account-Name>_public_key.pem`` - PEM encoded public key
3. ``<Account-Name>_public_key_hex`` - Hex encoded string of the public key


Fund your Account
~~~~~~~~~~~~~~~~~

Once the cryptographic key-pair for the ``Account`` has been generated, the ``Account`` must be funded so it can be created on chain.

In Testnet, you can fund the ``Account`` by using ``[Request tokens]`` button on the `Faucet Page <https://clarity-testnet-old.make.services/#/faucet>`_ to receive tokens.

In Mainnet, a pre-existing ``Account`` will have to transfer CSPR tokens to finalize the process of setting up an account.

In Mainnet, CSPR tokens transferred to the ``AccountHash`` corresponding to your ``PublicKey`` will automatically create your ``Account`` (if it does not already exist). Currently, this is the only way an ``Account`` can be created.

Acquire Node Address from network peers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Clients can interact with a node on the blockchain via requests sent to that node's JSON-RPC endpoint, ``http://<node-ip-address>:7777`` by default.

The node address is the IP of the ``peer``.

Both the official testnet and Mainnet provide block explorers that provide a list of IP addresses of nodes on their respective networks.

You can get the ``node-ip-address`` of a node on the network by visiting the following block explorers:

- `Peers <https://testnet.cspr.live/tools/peers>`_ on Testnet
- `Peers <https://cspr.live/tools/peers>`_ on Mainnet

You will see a list of peers, and you can select the IP of any peer on the list.

**Note**: If the selected peer is unresponsive, pick a different peer and try again.
