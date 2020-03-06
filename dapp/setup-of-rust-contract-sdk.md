# Setting up the Rust Contract SDK

To get you started with developing dApps, CasperLabs has released a contract development kit that leverages the Rust development toolchain and ecosystem, this kit will work with any IDE that supports Rust.      

You will be able to run smart contracts in a CasperLabs runtime environment (Execution Engine (EE)) using IDE you choose and run them in the runtime environment in the order you desire and so observe the effects of contract execution in the [global state](https://github.com/CasperLabs/techspec/blob/master/implementation/global-state.rst) (the shared database that is the blockchain). 

This guide will walk you through the steps to get set up.


## Install Rust
Install Rust using the `curl`
```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
For more details follow official Rust guide. https://www.rust-lang.org/tools/install

## Available Packages
There are three crates we publish to support Rust development of Smart Contracts. These can found on crates.io, they are:
* [CasperLabs Contract](https://crates.io/crates/casperlabs-contract) - library that supports communication with the blockchain. That's the main library to use when writing smart contracts.
* [CasperLabs Test Support](https://crates.io/crates/casperlabs-engine-test-support) - in-memory virtual machine you can test your smart contracts agains.
* [CasperLabs Types](https://crates.io/crates/casperlabs-types) - library with types we use across the Rust ecosystem.


## Cargo CasperLabs
The best way to set up a CasperLabs Rust Smart Contract project is to use `cargo-casperlabs`.  When you use the crate, it will set the project up with a runtime environment and testing framework. It's possible to use this configuration in your CI/CD pipeline as well. Instructions are also available on [Github.](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)
```bash
$ cargo install cargo-casperlabs
```


## Developing Smart Contracts
In this tutorial we will use cargo-casperlabs. The CasperLabs blockchain uses WebAssembly (WASM) in its' runtime environment.  Compilation targets for WASM are available for Rust, giving developers access to all the tools in the Rust ecosystem when developing smart contracts.

## Create a new project

```bash
$ cargo casperlabs my-project
```
This step will install two crates called `contract` and `tests`. This is a complete basic smart contract that saves a value, passed as an argument, on the blockchain. The tests crate provides a runtime environment of the CasperLabs virtual machine, and a basic test of the smart contract.

## Configure Rust for Compilation to Wasm

    $ cargo install wasm-pack

## Compile
The next step is to compile the smart contract into WASM. 
```bash
$ cd contract
$ cargo build --release
```
`build` command produces a smart contract at `contract/target/wasm32-unknown-unknown/release/contract.wasm`. 

## Test the Contract
The test crate will run the contract and tests in a CasperLabs runtime environment.  A successful test run indicates that the smart contract environment is set up correctly.

```bash
$ cd ../tests
$ cargo test
```
`tests` crate has `build.rs` file. It's executed every time before running tests and it compiles smart contract for your convenience. In practice, that means we only need to run `cargo test` in `tests` crate during the developement. Go ahead and modify `contract/src/lib.rs`. You can change the value of `KEY` and observe how smart contract compiles and test fails.

