.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

******************************
Welcome to the Casper Network
******************************

This article provides an overview of the Casper project.

What is Casper?
***************

Casper is a new Turing-complete smart-contracting platform, backed by a Proof-of-Stake (PoS) consensus algorithm and WebAssembly (WASM). The network is a permissionless, decentralized, public blockchain.

The network's consensus protocol is called `Highway <https://arxiv.org/pdf/2101.02159.pdf>`_, and it has several benefits over classic Byzantine Fault Tolerant (BFT) consensus protocols. First, Highway allows networks to reach higher thresholds of *finality*, meaning that more blocks are finalized, and validators agree to add them to the blockchain. Second, the protocol achieves flexibility by expressing block finality in ways not possible in BFT models. This protocol is built on Vlad Zamfir's `correct-by-construction (CBC) Casper <https://github.com/cbc-casper/cbc-casper-paper>`_ research.

Additionally, the Casper Network is optimized for enterprise and developer adoption. While leveraging blockchain technology, the network seeks to accelerate business operations via unique features like predictable network fees, upgradeable contracts, on-chain governance, privacy flexibility, and developer-friendly languages. 

Casper also solves the scalability trilemma. Notably, the network is optimized for security, decentralization, and high throughput. All this is achieved while evolving to provide leading solutions for open-source projects and enterprises.

Why choose Casper?
******************

Casper has core features and strengths that enable developers and enterprises to reap the benefits of blockchain technology. 

Upgradeable Contracts
~~~~~~~~~~~~~~~~~~~~~

Casper allows the direct upgrading of on-chain smart contracts, eliminating the need for complex migration processes and making it easy for developers to correct smart contract vulnerabilities.

Developer-Friendly Language
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Casper Network's development ecosystem is designed to support WebAssembly, rather than being written in proprietary languages like Solidity. This feature simplifies the development path for enterprises and development teams that want to build on the Casper Network.

.. admonition:: Note 
  
  Rust is the primary programming language for smart contracts on the Casper blockchain because of its good support for compilation to WASM. However, the platform does not make assumptions about the source language and supports libraries facilitating contract development in other programming languages having WASM as a compile target. 

Account Management
~~~~~~~~~~~~~~~~~~

Other essential features include an account permissions model that allows the recovery of lost keys and a permissions model to securely share state between accounts and contracts (without expensive cryptographic checks).

Predictable Network Fees
~~~~~~~~~~~~~~~~~~~~~~~~

Casper seeks to eliminate volatility and improve developer and enterprise experiences by establishing transparent, consistent, and predictable gas prices. This feature seeks to promote active and diverse network behavior.

How does Casper work?
*********************

Casper relies on a group of validators to verify transactions and uphold the network. Unlike Proof-of-Work networks, which need to centralize validators for economies of scale, Casper allows for the geographical decentralization of validators. Casper validators verify transactions based on staked tokens and receive CSPR rewards for participating in the PoS consensus mechanism. CSPR is the native token on the Casper Network.


Where can I learn more?
***********************
Follow the links below to learn more about the Casper Network.

================================================================  ========================================================================
`How To's <workflow/index.html>`_                                 Guides for interacting with the Casper Network
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

   workflow/index
   dapp-dev-guide/index
   node-operator/index
   implementation/index
   economics/index
   staking/index
   glossary/index
   faq/index

