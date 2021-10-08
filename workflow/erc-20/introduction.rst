Using the ERC-20 Contract
===========================

The Ethereum Request for Comment (ERC-20) standard defines a set of rules that dictate the total supply of tokens, how the tokens are transferred, how transactions are approved, and how token data is accessed. These ERC-20 tokens are blockchain-based assets that have value and can be transferred or recorded. 

This guide introduces you to the steps involved in using an ERC-20 contract to transfer tokens between user accounts on the `cspr.live <https://cspr.live/>`_ website. To execute these ERC-20 transactions, you will need some CSPR token balance. To understand the implementation of an ERC-20 contract, you can see the `ERC-20 Tutorial <https://docs.casperlabs.io/en/latest/dapp-dev-guide/tutorials/erc20/index.html>`_.

The following accounts are created to demonstrate the use of an ERC-20 contract:

* `User A <https://integration.cspr.live/account/01f2dfc09a94ef7bce440f93a1bb6f17fdac0c913549927d452e7e91a376e9d20d>`_
* `User B <https://integration.cspr.live/account/015d4e20b5f7f687be80aed6e20960898b02c7549cc49ddf583224ecd894eca375>`_
* `User C <https://integration.cspr.live/account/0101fe69ae2012358e5ce8e8b39661d45d225251c4f19ebb7fc74b057637e65aa4>`_
* `User D <https://integration.cspr.live/account/0171bd7bac58780ce950007de575a472bcb30457e7b68427a6ed466568d71db1d6>`_

Prerequisites
--------------

* You meet the `prerequisites <https://docs.casperlabs.io/en/latest/workflow/setup.html>`_
* You are using the Casper command-line client
* You have a valid ``node-address``
* You have previously deployed a smart contract to a Casper network

.. toctree::
   :hidden:
   
   setup
   query
   transfers
   approvals
   final-balance
