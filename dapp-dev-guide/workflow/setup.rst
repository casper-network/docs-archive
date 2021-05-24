Pre-requisites
==============

This section details how to setup many of the pre-requistes one needs to fulfill to interact with a Casper network.

This section covers:

1. Setting up and installing the official Rust Casper client
2. Setting up accounts on a Casper network
3. Acquiring the IP address of a peer on the official Testnet or Mainnet
4. Querying deploys to check the execution status of deploys.

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

Setting up Accounts on Testnet
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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

.. code-block:: bash

    casper-client account-address --public-key <path-to-public-key-hex>/public_key_hex


Fund your Account
^^^^^^^^^^^^^^^^^

Next, you need to fund the source account using the ``[Request tokens]`` button on the `Faucet Page <https://clarity-testnet-old.make.services/#/faucet>`_ to receive tokens.

Acquire Node IP Address
^^^^^^^^^^^^^^^^^^^^^^^

You can get an IP address of a node on the network by visiting the `Peers Page <https://testnet.cspr.live/tools/peers>`_. You will see a list of peers, and you can select the IP of any peer on the list.

**Note**: If the selected peer is blocking the port, pick a different peer and try again.

You also have the option to run your own un-bonded peer on the network. Follow the `Casper How-To Guides <https://docs.cspr.community/>`_ for the testnet or mainnet, and skip the last step, which bonds the node to the network.


Deploy Status
^^^^^^^^^^^^^

Once a Deploy has been submitted to the network, it is possible to check its execution status using ``get-deploy``.

If the ``execution_results`` in the output are null, the deploy has not been executed yet. Deploys are finalized upon execution.

**Important request fields:**

- ``id`` - <STRING OR INTEGER> JSON-RPC identifier, applied to the request and returned in the response. If not provided, a random integer will be assigned
- ``node-address`` - <HOST:PORT>Hostname or IP and port of node on which HTTP service is running [default:http://localhost:7777]

::

    casper-client get-deploy \
          --id 2 \
          --node-address http://<peer-ip-address>:7777 \
          <deploy-hash>

**Important response fields:**

- ``"result"."execution_results"`` - The results of the execution.