.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Abstract
========

In 2019, CasperLabs introduces a blockchain platform that incorporates all the
features required for mainstream adoption outlined in the detailed sections of
this technical specification.

1. **Consensus Method**: CasperLabs strives to be the first to deploy an
   implementation of the Correct-by-Construction  Casper \(CBC Casper\)Proof-of-Stake consensus protocol -- described here_ by Vlad Zamfir, Ethereum Foundation Researcher and Lead CBC-Casper Architect for CasperLabs.
2. **Throughput**: Implementing a consensus protocol that reserves its
   computation capacity for actual computational work, rather than PoW math
   problems, and through other network on protocol design decisions, our
   blockchain can achieve significantly higher throughput.
   
.. please elaborate re: network on protocol design decisions

3. **Concurrent Execution**: The execution engine is multi-threaded --
   multiple dApps \(smart contracts\) can be executed concurrently. And, on the
   consensus protocol level, multiple validators can propose blocks
   concurrently. 
4. **Side Chains**:  The platform enables customization and free-market innovation
   through side chains. These side chains can exist in the network with entirely
   unique parameters and configuration. For example, the fee model for a child
   chain may be unique to its published specialization \(e.g. a "storage
   chain"\), or it may provide ultra-low-latency and fast block finality for
   specialized dApps such as distributed exchanges.
5. **Open to All Programming Languages**: Rather than introducing a new,
   proprietary and obscure programming language for the development of dApps,
   our execution engine is based on WebAssembly \(Wasm\). An open
   standard put forward by the W3C, Wasm is a binary instruction format
   designed as a target for compilation of high-level languages like C, C++,
   Rust and many others. In fact, community projects to develop compilation
   targets for Wasm in almost *all* high-level languages are underway or
   encouraged. This open approach allows any software engineer to start
   developing on CasperLabs' blockchain immediately.
6. **Fully Decentralized**: The platform is designed for full decentralization on all
   levels, specifically: \(1\) *the operation of the blockchain network shall be
   open to anyone*. No master-nodes shall be sold: in fact, master-nodes don't
   exist in the network. No special roles shall be delegated. Equal opportunity
   shall exist for all who wish to operate network nodes. \(2\) *development of
   the software shall be open source and community driven*. Moreover, while we
   are most excited to initially take a leading role in the initial development
   of the blockchain software, it is expected that the Casperlabs community will take
   over the lead after the initial launch of the network and we strongly
   encourages community participation in the software development at all times throughout.
   \(3\) *governance of the network shall be community
   driven*. CasperLabs believes that decentralized networks should be governed
   by the respective community of stakeholders; not by centralized entities or
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
