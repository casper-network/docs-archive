
Setting up a Network
====================

It's possible to create a new network or join an existing network.  This page will outline the basics for creating a new network.

The Chain Specification
-----------------------

The Casper node software creates a genesis block from the following inputs:


* chainspec.toml
* accounts.csv

Chainspec.toml
^^^^^^^^^^^^^^

A version of the chainspec is downloaded with by a post install script that ships with the debian packages. This pulls
the file from http://genesis.casperlabs.io/casper-delta/chainspec.toml.

The production version of the file from which this is based on can be found at ``casper-node/resources/production/chainspec.toml``
in the code base.  To create a custom network, this file can be updated as desired. Any changes to this file will result in a different genesis hash.
Refer to the file itself for detailed documentation on each of the variables in the file.

Accounts.csv
^^^^^^^^^^^^

This file contains the genesis validator set information, starting accounts and associated balances and bond amounts. The file is comma-delimited.
Information in the file is organized as:

* publickey,balance,bond

If an account is not bonded at genesis, specify a ``0`` for the bond amount.  

Similar to the chainspec, this is pulled from http://genesis.casperlabs.io/casper-delta/account.csv.
