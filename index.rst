.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

*****************************************
Welcome to Casper Network's Documentation 
******************************************

This resource gives an overview of the Casper project. Here is brief highlight of key aspects about the project.

What is Casper?
***************

Casper is an open-source blockchain network that employs the Proof-of-Stake consensus protocol. The project is built upon the Correct-by-Construction (CBC)Casper protocol—a consensus algorithm developed by early Ethereum developers.

What’s more, the Casper network is optimized for enterprise and developer adoption. Leveraging on blockchain technology, the network seeks to accelerate business operations via unique features like predictable network fees, upgradeable contracts, on-chain governance, privacy flexibility and developer-friendly languages. 

Casper also solves the scalability trilemma. By optimizing for high throughput, security and decentralization, the network accelerates enterprise and developer adoption of the technology. All this is achieved while evolving to provide leading solutions in the adoption of developer and enterprise blockchain. 

Why Casper?
***********

Casper has core features and strengths that enable developers and enterprises leap the benefits of blockchain technology. These are:

* Upgradeable Contracts

Casper allows the direct upgrading of on-chain smart contracts, eliminating the need for complex migration processes. This makes it easy for developers to correct smart contract vulnerabilities.

* Developer-Friendly Language 

Casper network’s development ecosystem is designed to support WebAssembly, rather than being written in proprietary languages like solidity. This simplifies the development path for enterprises and development teams that want to build on the Casper network.

* Predictable Network Fees 

Casper seeks to eliminate volatility and improve developer and enterprise experiences by establishing transparent, consistent, and predictable gas prices. This feature seeks to promote active and diverse network behaviour.

How Casper Works?
*****************

Casper relies on a group of validators to verify transactions and uphold the network. Unlike Proof-of-Work networks, which need to centralize validators for economies of scale, Casper network allows for geographical decentralization of validators. That’s because PoS validators have a different hardware setup, and they participate in verifying transactions based on staked tokens. 

Validators on the Casper Network receive CSPR rewards for participating in the PoS consensus mechanism. (CSPR is Casper Network’s native token)

Casper’s PoS network also supports scalability mechanisms like sharding. With sharding, Casper improves overall throughput by allowing the network to process many transactions concurrently.

Why go for Casper’s Blockchain?
*******************************

The Casper network employs the Highway Protocol. Highway has several benefits over the classic Byzantine Fault Tolerant consensus protocol. First, Highway allows networks to reach higher thresholds of finality. Second, the protocol achieves flexibility by expressing block finality in ways not possible in BFT models. 'Learn more on the Highway Protocol<https://arxiv.org/pdf/2101.02159.pdf>'_.

We present the Casper Network, a new Turing-complete smart-contract platform, backed by a Proof-of-Stake (PoS) consensus algorithm and WebAssembly (wasm). The network is a permissionless, decentralized, public blockchain. The consensus protocol is called Highway, and the complete paper is found in GitHub: https://github.com/CasperLabs/highway. The consensus protocol allows clients to use different confidence thresholds to convince themselves that a given block is *finalized*. This protocol is built on Vlad Zamfir's `correct-by-construction (CBC) Casper <https://github.com/cbc-casper/cbc-casper-paper>`_ research. 

Rust is the primary programming language for smart contracts on the Casper blockchain because of its good support for compilation to wasm. However, the platform does not make assumptions about the source language and supports libraries facilitating contract development in other programming languages having wasm as a compile target. Other essential features include an account permissions model that allows the recovery of lost keys and a permissions model to securely share state between accounts and contracts (without expensive cryptographic checks). We also provide discussions of the economics of our proof-of-stake implementation and our token policies.

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

