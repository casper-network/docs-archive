.. CasperLabs Tech Spec documentation master file, created by
   sphinx-quickstart on Fri Sep  6 21:40:51 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

========
Abstract
========

We present the design for a new Turing-complete smart contract platform, backed
by a proof-of-stake (PoS) consensus algorithm, and WebAssembly (wasm). The
intent is for this design to be implemented as a new permissionless,
decentralized, public blockchain. The consensus protocol is built on Vlad
Zamfir's
`correct-by-construction (CBC) Casper <https://github.com/cbc-casper/cbc-casper-paper>`_
work. Here, we describe a
particular protocol in the CBC Casper family which is provably safe and live
under partial synchrony without an in-protocol fault tolerance threshold. The
computation model allows for efficient detection of when contract executions
can be run in parallel and the block message format allows "merging" forks in
the chain; so the platform avoids orphaning blocks unnecessarily. Rust is
supported as the primary programming language for smart contracts because of
its good support for compilation to wasm; however, the platform itself does
not make assumptions about the source language, so libraries facilitating
contract development in other programming language having wasm as a
compile target are expected. Other features of the execution engine include:
an account permissions model allowing for lost key recovery, and
a permissions model to securely share state between accounts and/or
contracts (without the need for  expensive cryptographic checks). We also
provide discussions of the economics of our proof-of-stake implementation
and our token policies.

.. include:: disclaimer.rst


.. toctree::
   :maxdepth: 2
   :caption: Contents:

   theory/index
   implementation/index
   dapp/index

