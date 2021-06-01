.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

************************
Casper Documentation
************************

We present the Casper Network, a new Turing-complete smart-contract platform, backed by a Proof-of-Stake (PoS) consensus algorithm and WebAssembly (wasm). The network is a permissionless, decentralized, public blockchain. The consensus protocol is called Highway, and the complete paper is found in GitHub: https://github.com/CasperLabs/highway. The consensus protocol allows clients to use different confidence thresholds to convince themselves that a given block is *finalized*. This protocol is built on Vlad Zamfir's `correct-by-construction (CBC) Casper <https://github.com/cbc-casper/cbc-casper-paper>`_ research. 

Rust is the primary programming language for smart contracts on the Casper blockchain because of its good support for compilation to wasm. However, the platform does not make assumptions about the source language and supports libraries facilitating contract development in other programming languages having wasm as a compile target. Other essential features include an account permissions model that allows the recovery of lost keys and a permissions model to securely share state between accounts and contracts (without expensive cryptographic checks). We also provide discussions of the economics of our proof-of-stake implementation and our token policies.

================================================================  ========================================================================  
`Developers <dapp-dev-guide/index.html>`_                         Get started with smart contract development on the Casper blockchain in AssemblyScript or Rust 
`Node Operators <node-operator/index.html>`_                      Run node infrastructure on the Casper Network
`Design <implementation/index.html>`_                             Understand the architecture of the Casper Network, including network communication, execution semantics, account management, block structure, global state, serialization, unforgeable references, and tokens 
`Economics <economics/index.html>`_                               Conceptualize Casper's economic activity by understanding consensus, runtime, ecosystem, and the macroeconomy
`Staking Guide <staking/index.html>`_                             Participate in the protocol by staking CSPR tokens with a validator in the Casper Network 
`Glossary <glossary/index.html>`_                                 Explore key definitions in the context of the Casper Network  
`FAQ <faq/index.html>`_                                           Find answers regarding the Casper Network, CasperLabs, and the CSPR token sale  
`Changelog <changelog.html>`_                                     Review past technical releases and changelogs for the Casper Network 
================================================================  ========================================================================
   


.. include:: disclaimer.rst

.. toctree::
   :hidden:
   :maxdepth: 3
   :titlesonly:

   dapp-dev-guide/index
   node-operator/index
   implementation/index
   economics/index
   staking/index
   glossary/index
   faq/index
