ERC20 Tutorial Overview
=======================

The following includes a set of topics with step-by-step examples to guide you through basic and
advanced features for implementing the CasperLabs ERC20. Following the preparation and logic
you will be able to create and manage tokens by smart contract, and test contracts using the
CasperLabs development framework, before deploying and running erc20 contracts to devnet.

We highly recommended reviewing `Writing Rust Contracts on CasperLabs <../writing-rust-contracts.html>`_ in this guide, prior to beginning this tutorial.

Though most smart contract developers are familiar with the ERC20, we highly recommend taking the
opportunity to carefully read through the following:

Etherium `ERC-20 Token Standard <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#>`_
(Ethereum Request For Comments and 20). This standard provides guidelines for the definition of
methods we'll be implementing with ERC20.

Note: Completed code is found on our Github `CasperLabs/erc20 <https://github.com/CasperLabs/erc20>`_.


.. toctree::
   :maxdepth: 2

   erc20-intro
   prepare
   logic
   logic-test
   tutorial-use-erc20
