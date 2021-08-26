Setting up the Casper Client
============================

Prerequisites
-------------
1. You have completed the **Getting Started** tutorial to set up your development environment, including tools like ``cmake`` (version 3.1.4+), ``cargo``, and ``Rust``.
2. You have completed the **NCTL** tutorial, which introduces you to the CLI tool used to set up and control local Casper networks for development.


Installing the Casper Client
----------------------------
Once you have a working Rust development environment and NCTL installed, you will need to install the **casper-client** crate (https://crates.io/crates/casper-client). This crate is a collection of CLI commands that make it simple to issue instructions to the blockchain and query state information.

**Installation instructions**

.. code-block:: sh

    $ rustup toolchain install nightly
    $ cargo +nightly-2021-06-17 install casper-client

Once you have casper-client installed, we can proceed to walk through the process of setting up NCTL, cloning the contract, and deploying it to the chain.

Before we go through the tutorial, we will give a high-level overview of this tutorial’s walkthrough and briefly summarize the relevant commands (and respective arguments).


