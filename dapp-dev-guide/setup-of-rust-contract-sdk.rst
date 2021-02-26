Getting Started
===============

The Rust contract SDK is the easiest way to get started with smart contract development. This guide will walk you through the steps to set up your development environment.

Prerequisites 
^^^^^^^^^^^^^

Install Rust
##############
The recommended way to from the `official Rust guide <https://www.rust-lang.org/tools/install>`_ to install Rust is by using :code:`curl`

.. code::

   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


It is also possible to use brew or apt to install Rust.

Update Cmake
############
Version 3.14.1 or greater is required.


Install Google protobuf compiler
################################
Linux with :code:`apt` 

.. code::

    sudo apt install protobuf-compiler


macOS with :code:`brew`

.. code::

    brew install protobuf


For more details follow the `official downloads page <https://developers.google.com/protocol-buffers/docs/downloads>`_.

Video Tutorial
^^^^^^^^^^^^^^

For a video walkthrough of these steps, feel free to check out this quick-start video.

.. raw:: html 

   <iframe width="560" height="315" src="https://www.youtube.com/embed?v=XZsc7YiJ12M&list=PL8oWxbJ-csErqfzYvbWsMUr4IvwRVenni&index=1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Available Packages
##################

There are three crates we publish to support Rust development of Smart Contracts. These can be found on crates.io, and are:

*  `Casper Contract <https://crates.io/crates/casper-contract>`_ - library that supports communication with the blockchain. That's the main library to use       when writing smart contracts. 
*  `Casper Test Support <https://crates.io/crates/casper-engine-test-support>`_ - in-memory virtual machine you can test your smart contracts against.
*  `Casper Types <https://crates.io/crates/casper-types>`_ - library with types we use across the Rust ecosystem.

API Documentation for Smart Contracts
#####################################

Each of the crates ships with API documentation and examples for each of the functions. Docs are located at `https://docs.rs <https://docs.rs/releases/search?query=casper>`_.  The contract API documentation is specific for a given version, ex: for version 0.5.1 is located at: `https://docs.rs/casper-contract/0.1.0`.

Development Environment Setup
#############################

The best and fastest way to set up a Casper Rust Smart Contract project is to use :code:`cargo-casper`.  When you use this, it will set the project up with a simple contract and a runtime environment/testing framework with a simple test. It's possible to use this configuration in your CI/CD pipeline as well. 

.. code::

   $ cargo install cargo-casper
   $ cargo casper my-project

This step will create two crates called :code:`contract` and :code:`tests` inside a new folder called :code:`my-project`. This is a complete basic smart contract that saves a value, passed as an argument, on the blockchain. The tests crate provides a runtime environment of the Casper virtual machine, and a basic test of the smart contract.

Compiling to WASM
#################

The Casper blockchain uses WebAssembly (Wasm) in its runtime environment.  Compilation targets for Wasm are available for Rust, giving developers access to all the tools in the Rust ecosystem when developing smart contracts.
Casper Contracts support Rust tooling such as :code:`clippy` for linting contracts. Feel free to use them!

The project requires a specific nightly version of Rust, and requires a Wasm target to be added to that Rust version.  The steps to follow are shown by running

.. code::

   cargo casper --help


Set up your wasm compilation rust toolchain by doing the following

.. code::

   cd my-project/contract
   rustup install $(cat rust-toolchain)
   rustup target add --toolchain $(cat rust-toolchain) wasm32-unknown-unknown


Build the Contract
##################
The next step is to compile the smart contract into Wasm.

.. code::

   cd my-project/contract
   cargo build --release

The :code:`build` command produces a smart contract at :code:`my-project/contract/target/wasm32-unknown-unknown/release/contract.wasm`.

**NOTE: It's important to build the contract using `--release` as a debug build will produce a contract which is much larger and more expensive to execute.**

Test the Contract & verify your environment is correct
######################################################

The test crate will build the contract and test it in a Casper runtime environment.  A successful test run indicates that the smart contract environment is set up correctly.

.. code::

   cd ../tests
   cargo test

The :code:`tests` crate has a :code:`build.rs` file: effectively a custom build script. It's executed every time before running tests and it compiles the smart contract in release mode for your convenience. In practice, that means we only need to run :code:`cargo test` in the :code:`tests` crate during the development. Go ahead and modify :code:`contract/src/main.rs`. You can change the value of `KEY` and observe how the smart contract is recompiled and the test fails.
