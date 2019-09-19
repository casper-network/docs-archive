.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Abstract
========

In 2019, CasperLabs introduces a blockchain platform that it believes
incorporates all the features required for mainstream adoption outlined in the
detailed sections of this technical specification.

1. **Consensus Method**: CasperLabs strives to be the first to deploy an
   implementation of the Correct-by-Construction  Casper \(CBC Casper\) Proof-of-Stake consensus
   protocol as described here_ by Vlad Zamfir, Ethereum Foundation Researcher
   and Lead CBC-Casper Architect for CasperLabs.
2. **Throughput**: By implementing a consensus protocol that reserves its
   computation capacity for actual computational work, rather than PoW math
   problems, and through other network on protocol design decisions, CasperLabs'
   blockchain can achieve significantly higher throughput.
3. **Concurrent Execution**: CasperLabs' execution engine is multi-threaded and
   allows for multiple dApps \(Smart Contracts\) to be executed concurrently. On
   the consensus protocol level, multiple validators are also allowed to propose
   blocks concurrently.
4. **Side Chains**: CasperLabs enables customization and free-market innovation
   through side chains, whereby chains can exist in the network with entirely
   unique parameters and configuration. For example, the fee model for a child
   chain may be unique to its published specialization \(e.g. a "storage
   chain"\), or a it may provide ultra-low-latency and fast block finality for
   specialized dApps such as distributed exchanges.
5. **Open to All Programming Languages**: Rather than introducing a new,
   proprietary, and obscure programming language for the development of dApps,
   CasperLabs' execution engine is based on WebAssembly \(Wasm\), the open
   standard put forward by the W3C. Wasm is a binary instruction format that is
   designed as a target for compilation of high-level languages like C, C++,
   Rust and many others. In fact, community projects to develop compilation
   targets for Wasm in almost *all* high-level languages are underway or
   encouraged. This open approach allows any software engineer to start
   developing on CasperLabs' blockchain immediately.
6. **Fully Decentralized**: CasperLabs believes in full decentralization on all
   levels, specifically: \(1\) *the operation of the blockchain network shall be
   open to anyone*. No master-nodes shall be sold: in fact, master-nodes don't
   exist in the network. No special roles shall be delegated. Equal opportunity
   shall exist for all that wish to operate network nodes. \(2\) *development of
   the software shall be open source and community driven*. While CasperLabs is
   excited to initially take a leading role in the development of the blockchain
   software, it expects the community to take over the lead after the initial
   launch of the network and encourages community participation in the software
   development at all times. \(3\) *governance of the network shall be community
   driven*. CasperLabs believes that decentralized networks should be governed
   by their community of stakeholders, not by centralized entities or
   disproportionally by one category of stakeholders. Governance principles will
   be put forth to ensure this.



.. toctree::
   :maxdepth: 2
   :caption: Contents:

   theory/index
   implementation/index


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

.. _here: https://github.com/cbc-casper/cbc-casper-paper
