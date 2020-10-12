# Setting Up the Rust Contract SDK
The SDK is the easiest way to get started with Smart Contract development. This guide will walk you through the steps to get set up.

## Prerequisites 

### Install Rust
The recommended way to from the [official Rust guide](https://www.rust-lang.org/tools/install) to install Rust is by using `curl`
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

It is also possible to use brew or apt to install Rust.

### Update cmake

Version 3.14.1 or greater is required.


### Install Google protobuf compiler

Linux with `apt` 

```bash
sudo apt install protobuf-compiler
```

macOS with `brew`

```bash
brew install protobuf
```

For more details follow the [official downloads page](https://developers.google.com/protocol-buffers/docs/downloads).

## CasperLabs SDK

## Available Packages
There are three crates we publish to support Rust development of Smart Contracts. These can be found on crates.io, and are:
* [CasperLabs Contract](https://crates.io/crates/casperlabs-contract) - library that supports communication with the blockchain. That's the main library to use when writing smart contracts. 
* [CasperLabs Test Support](https://crates.io/crates/casperlabs-engine-test-support) - in-memory virtual machine you can test your smart contracts against.
* [CasperLabs Types](https://crates.io/crates/casperlabs-types) - library with types we use across the Rust ecosystem.

## Technical Documentation for the Contract API
Each of the crates ships with API documentation and examples for each of the functions. Docs are located at https://docs.rs.  For example, the contract API documentation for version 0.5.1 is located at: https://docs.rs/casperlabs-contract/0.5.1/casperlabs_contract/contract_api/index.html


## Cargo CasperLabs
The best way to set up a CasperLabs Rust Smart Contract project is to use `cargo-casperlabs`.  When you use this, it will set the project up with a simple contract and a runtime environment/testing framework with a simple test. It's possible to use this configuration in your CI/CD pipeline as well. Instructions are also available on [GitHub](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs).
```bash
cargo install cargo-casperlabs
```


## Develop Smart Contracts
In this tutorial we will use `cargo-casperlabs`. The CasperLabs blockchain uses WebAssembly (Wasm) in its runtime environment.  Compilation targets for Wasm are available for Rust, giving developers access to all the tools in the Rust ecosystem when developing smart contracts.

## Create a new project

```bash
cargo casperlabs my-project
```
This step will create two crates called `contract` and `tests` inside a new folder called `my-project`. This is a complete basic smart contract that saves a value, passed as an argument, on the blockchain. The tests crate provides a runtime environment of the CasperLabs virtual machine, and a basic test of the smart contract.

## Configure Rust for Building the Contract and Test

The project requires a specific nightly version of Rust, and requires a Wasm target to be added to that Rust version.  The steps to follow are shown by running
```bash
cargo casperlabs --help
```

These steps can be performed by running
```bash
cd my-project/contract
rustup install $(cat rust-toolchain)
rustup target add --toolchain $(cat rust-toolchain) wasm32-unknown-unknown
```

## Build the Contract
The next step is to compile the smart contract into Wasm.
```bash
cd my-project/contract
cargo build --release
```
The `build` command produces a smart contract at `my-project/contract/target/wasm32-unknown-unknown/release/contract.wasm`.

**NOTE: It's important to build the contract using `--release` as a debug build will produce a contract which is much larger and more expensive to execute.**

## Test the Contract
The test crate will build the contract and test it in a CasperLabs runtime environment.  A successful test run indicates that the smart contract environment is set up correctly.

```bash
cd ../tests
cargo test
```
The `tests` crate has a `build.rs` file: effectively a custom build script. It's executed every time before running tests and it compiles the smart contract in release mode for your convenience. In practice, that means we only need to run `cargo test` in the `tests` crate during the development. Go ahead and modify `contract/src/main.rs`. You can change the value of `KEY` and observe how the smart contract is recompiled and the test fails.
