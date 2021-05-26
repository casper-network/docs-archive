Prerequisites
==============

This section details how to setup many of the prerequistes one needs to fulfill to interact with a Casper network.

This section covers:

1. Setting up and installing the official Rust Casper client
2. Setting up accounts on a Casper network
3. Acquiring the IP address of a peer on the official Testnet or Mainnet

The Rust Casper Client
^^^^^^^^^^^^^^^^^^^^^^

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

Setting up Accounts
^^^^^^^^^^^^^^^^^^^^

Accounts can be created using the Casper command line client. However, some Casper networks like the official Testnet and Mainnet feature a block explorer that allow you to create an account online.

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

Once the keys for the account have been generated, the accounts can be funded to finish the process of creating an account.

**Important Note**: Responses from the node contain ``AccountHashes`` instead of the direct hex encoded public key. For traceability, it is important to generate the account hash and store this value locally. The account hash is a ``Blake2B`` hash of the public hex key.

Option 2: Account setup using the Block Explorer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This option is **only** available for networks that have a Block explorer like the official Testnet and Mainnet.

Start by creating an account on Clarity using the `Create Account <https://clarity-testnet-old.make.services/#/accounts>`_ link.

Save these three files for each account and note the location where they are downloaded. We recommend moving your keys to a safe location, preferrably offline.

1. ``<Account-Name>_secret_key.pem`` - PEM encoded secret key
2. ``<Account-Name>_public_key.pem`` - PEM encoded public key
3. ``<Account-Name>_public_key_hex`` - Hex encoded string of the public key

**Note**: You need the `<Account-Name>_public_key_hex` in order to verify your account balance when querying the blockchain later.


Account Hashes and Public Keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To follow the steps you will require the ``AccountHash`` and the ``hex-encoded-public-key`` for each individual account. The rust client provides a command that will provide the account hash for a given public key.

.. code-block:: bash

    casper-client account-address --public-key <path-to-public-key-hex>/public_key_hex


Fund your Account on Testnet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can fund the account setup on testnet by using ``[Request tokens]`` button on the `Faucet Page <https://clarity-testnet-old.make.services/#/faucet>`_ to receive tokens.

In Mainnet, a pre-existing account will have to transfer CSPR tokens to finalize the process of setting up an account.

An account that is setup on Mainnet or Testnet must have a minimum balance of at least 2.5 CSPR to send deploys to interact with the network.


Acquire Node IP Address
^^^^^^^^^^^^^^^^^^^^^^^

You can get an IP address of a node on the network by visiting the:

- `Testnet Peers <https://testnet.cspr.live/tools/peers>`_  for peers on Testnet
- `Mainnet Peers <https://cspr.live/tools/peers>`_ for peers on Mainnet

You will see a list of peers, and you can select the IP of any peer on the list.

**Note**: If the selected peer is blocking the port, pick a different peer and try again.

You also have the option to run your own un-bonded peer on the network. Follow the `Casper How-To Guides <https://docs.cspr.community/>`_ for the testnet or mainnet, and skip the last step, which bonds the node to the network.
