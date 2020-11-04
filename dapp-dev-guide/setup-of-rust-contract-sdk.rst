Setting Up the Rust Contract SDK
********************************
The SDK is the easiest way to get started with Smart Contract development. This guide will walk you through the steps to get set up.

Prerequisites 
^^^^^^^^^^^^^

Install Rust
^^^^^^^^^^^^^^^^
The recommended way to from the `official Rust guide <https://www.rust-lang.org/tools/install>`_ to install Rust is by using :code:`curl`

.. code-block::

   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


It is also possible to use brew or apt to install Rust.

Update cmake
############
Version 3.14.1 or greater is required.


Install Google protobuf compiler
################################
Linux with :code:`apt` 

.. code-block::

    sudo apt install protobuf-compiler


macOS with :code:`brew`

.. code-block::

    brew install protobuf


For more details follow the `official downloads page <https://developers.google.com/protocol-buffers/docs/downloads>`_.

SDK
^^^^^^^^^^^^^^^^

For a video walkthrough of these steps, feel free to check out this quick start video.

.. raw:: html 

   <iframe width="560" height="315" src="https://www.youtube.com/embed/P8ljeSxg4NA" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Available Packages
##################

There are three crates we publish to support Rust development of Smart Contracts. These can be found on crates.io, and are:

*  `CasperLabs Contract <https://crates.io/crates/casperlabs-contract>`_ - library that supports communication with the blockchain. That's the main library to use       when writing smart contracts. 
*  `CasperLabs Test Support <https://crates.io/crates/casperlabs-engine-test-support>`_ - in-memory virtual machine you can test your smart contracts against.
*  `CasperLabs Types <https://crates.io/crates/casperlabs-types>`_ - library with types we use across the Rust ecosystem.

API Level Documentation for Smart Contracts
###########################################

Each of the crates ships with API documentation and examples for each of the functions. Docs are located at `https://docs.rs <https://docs.rs/releases/search?query=casperlabs>`_.  The contract API documentation is specific for a given version, ex: for version 0.5.1 is located at: `https://docs.rs/casperlabs-contract/0.5.1/casperlabs_contract/contract_api/index.html`

Development Environment Setup
#############################

The best & fastest way to set up a Casper Rust Smart Contract project is to use :code:`cargo-casperlabs`.  When you use this, it will set the project up with a simple contract and a runtime environment/testing framework with a simple test. It's possible to use this configuration in your CI/CD pipeline as well. Instructions are also available on `GitHub <https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs>`_.

.. code-block::

   $ cargo install cargo-casperlabs
   $ cargo casperlabs my-project

This step will create two crates called :code:`contract` and :code:`tests` inside a new folder called :code:`my-project`. This is a complete basic smart contract that saves a value, passed as an argument, on the blockchain. The tests crate provides a runtime environment of the Casper virtual machine, and a basic test of the smart contract.

Compiling to wasm
#################

The Casper blockchain uses WebAssembly (Wasm) in its runtime environment.  Compilation targets for Wasm are available for Rust, giving developers access to all the tools in the Rust ecosystem when developing smart contracts.
Casper Contracts support Rust tooling such as :code:`clippy` for linting contracts. Feel free to use them!

The project requires a specific nightly version of Rust, and requires a Wasm target to be added to that Rust version.  The steps to follow are shown by running

.. code-block::

   cargo casperlabs --help


Set up your wasm compilation rust toolchain by doing the following

.. code-block::

   cd my-project/contract
   rustup install $(cat rust-toolchain)
   rustup target add --toolchain $(cat rust-toolchain) wasm32-unknown-unknown


Build the Contract
##################
The next step is to compile the smart contract into Wasm.

.. code-block::

   cd my-project/contract
   cargo build --release

The :code:`build` command produces a smart contract at :code:`my-project/contract/target/wasm32-unknown-unknown/release/contract.wasm`.

**NOTE: It's important to build the contract using `--release` as a debug build will produce a contract which is much larger and more expensive to execute.**

Test the Contract & verify your environment is correct
######################################################

The test crate will build the contract and test it in a CasperLabs runtime environment.  A successful test run indicates that the smart contract environment is set up correctly.

.. code-block::

   cd ../tests
   cargo test

The :code:`tests` crate has a :code:`build.rs` file: effectively a custom build script. It's executed every time before running tests and it compiles the smart contract in release mode for your convenience. In practice, that means we only need to run :code:`cargo test` in the :code:`tests` crate during the development. Go ahead and modify :code:`contract/src/main.rs`. You can change the value of `KEY` and observe how the smart contract is recompiled and the test fails.
