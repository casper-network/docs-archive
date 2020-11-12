
Setting up a Network
====================

It's possible to create a new network or join an existing network.  This page will outline the basics for creating a new network.

The Chain Specification
-----------------------

The Casper node software creates a genesis block from the following inputs:


* chainspec.toml
* accounts.csv
* compiled system contracts

Chainspec.toml
^^^^^^^^^^^^^^

A version of the chainspec ships with the debian packages. The production version of the file can be found at ``casper-node/resources/production/chainspec.toml``
in the code base.  To create a custom network, this file can be updated as desired. Any changes to this file will result in a different genesis hash.
Refer to the file itself for detailed documentation on each of the variables in the file.

Accounts.csv
^^^^^^^^^^^^

This file contains the genesis validator set information, starting accounts and associated balances and bond amounts. The file is comma-delimited.
Information in the file is organized as:


* publickey,balance,bond

If an account is not bonded at genesis, specify a ``0`` for the bond amount.  

Compiled System Contracts
^^^^^^^^^^^^^^^^^^^^^^^^^

In order to function properly, 4 key system contracts are required. The path to these system contracts are specified in ``chainspec.toml``.
Wasm compilation is non-deterministic, so these compiled contracts must be distributed to all nodes in the network. The 4 contracts are:


* mint_install.wasm
* pos_install.wasm
* standard_payment.wasm
* auction_install.wasm
