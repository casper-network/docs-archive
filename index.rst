.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

******************************
Welcome to the Casper Network
******************************

This resource gives an overview of the Casper project. Here is brief highlight of key aspects of the project.

What is Casper?
***************

Casper is a new Turing-complete smart-contract platform, backed by a Proof-of-Stake (PoS) consensus algorithm and WebAssembly (wasm). The network is a permissionless, decentralized, public blockchain.

The Casper Network’s consensus protocol is called `Highway <https://github.com/CasperLabs/highway>`_. The consensus protocol allows clients to use different confidence thresholds to convince themselves that a given block is *finalized*. This protocol is built on Vlad Zamfir's `correct-by-construction (CBC) Casper <https://github.com/cbc-casper/cbc-casper-paper>`_ research.

To add, the Casper Network is optimized for enterprise and developer adoption. While leveraging blockchain technology, the network seeks to accelerate business operations via unique features like predictable network fees, upgradeable contracts, on-chain governance, privacy flexibility, and developer-friendly languages. 

Casper also solves the scalability trilemma. Notably, the network is optimized for security, decentralization, and high throughput. All this is achieved while evolving to provide leading solutions in developer and enterprise blockchain.

Why Casper?
***********

Casper has core features and strengths that enable developers and enterprises to leap the benefits of blockchain technology. 

Upgradeable Contracts
~~~~~~~~~~~~~~~~~~~~~

Casper allows the direct upgrading of on-chain smart contracts, eliminating the need for complex migration processes and making it easy for developers to correct smart contract vulnerabilities.

Developer-Friendly Language
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Casper Network’s development ecosystem is designed to support WebAssembly, rather than being written in proprietary languages like Solidity. This feature simplifies the development path for enterprises and development teams that want to build on the Casper Network

.. admonition:: Note 
  
  Rust is the primary programming language for smart contracts on the Casper blockchain because of its good support for compilation to wasm. However, the platform does not make assumptions about the source language and supports libraries facilitating contract development in other programming languages having wasm as a compile target. 
  
  Other essential features include an account permissions model that allows the recovery of lost keys and a permissions model to securely share state between accounts and contracts (without expensive cryptographic checks). The Casper Network resource also provides discussions of the economics of proof-of-stake implementation and the network’s token policies.

Predictable Network Fees
~~~~~~~~~~~~~~~~~~~~~~~~ 

Casper seeks to eliminate volatility and improve developer and enterprise experiences by establishing transparent, consistent, and predictable gas prices. This feature seeks to promote active and diverse network behaviour.

How Casper Works?
*****************

Casper relies on a group of validators to verify transactions and uphold the network. Unlike Proof-of-Work networks, which need to centralize validators for economies of scale, the Casper Network allows for geographical decentralization of validators. That’s because PoS validators have a different hardware setup, and they participate in verifying transactions based on staked tokens. 

Validators on the Casper Network receive CSPR rewards for participating in the PoS consensus mechanism. (CSPR is Casper Network’s native token).

Casper’s PoS network also supports scalability mechanisms like sharding. With sharding, Casper improves overall throughput by allowing the network to process many transactions concurrently.

Why go for Casper’s Blockchain?
*******************************

The Casper Network employs the Highway Protocol. Highway has several benefits over the classic Byzantine Fault Tolerant consensus protocol. First, Highway allows networks to reach higher thresholds of finality. Second, the protocol achieves flexibility by expressing block finality in ways not possible in BFT models. This feature is made possible by the `Highway Protocol <https://arxiv.org/pdf/2101.02159.pdf>`_. 


Important Sections
******************
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

