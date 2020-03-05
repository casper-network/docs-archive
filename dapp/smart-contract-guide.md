# Smart Contract Guide

## Rust environment

### Install Rust

### Cargo CasperLabs Tool

### Available packages

## Developping Smart Contracts
In this tutorial we will use Rust's Smart Contract library we created at Casperlab. Casperlabs blockchain uses WebAssembly (WASM) as it's virtual machine. Thanks to the Rust's native ability to compile to WASM we can build smart contract using all the good tools and libraries Rust ecosystem gives us.

### Start a new project
First lets create a new project.
```bash
$ cargo casperlabs my-project
```
We should endup with two crates called `contract` and `tests`. It's an out of the box implementation of a very simple smart contract that saves a value, passed as an argument, on the blockchain.

### Project structure
TODO: describe each file.

### Compile and test
Let's compile the smart contract into WASM file. Note, that it's not necessary to set WASM as an compilation target. It's already defined in `contract/.cargo/config`.
```bash
$ cd contract
$ cargo build --release
```
`build` command produces a smart contract at `contract/target/wasm32-unknown-unknown/release/contract.wasm`. We don't need to do anything with it at the moment. Let's go into the `test` crate and run tests.
```bash
$ cd ../tests
$ cargo test
```
`tests` crate has `build.rs` file. It's executed every time before running tests and it compiles smart contract for your convenience. In practice, that means we only need to run `cargo test` in `tests` crate during the developement. Go ahead and modify `contract/src/lib.rs`. You can change the value of `KEY` and observe how smart contract compiles and test fails.

### Libs
TODO: describe dependencies libs.

### Basic Smart Contract
Casperlab's VM executes smart contract by calling it's `call` function. If the function is not there, then it's not a valid smart contract. The simples possible example we can write is just an empty `call` function.
```rust
#[no_mangle]
pub extern "C" fn call() { }
```
`#[no_mangle]` attribute prevents the compiler from changing (mangling) the function name when converting to binary format of WASM. Without it, the VM exits with the error message: `Module doesn't have export call`.

### Failing gentely
Throwing an error during the smart contract execution is a perfectly normall thing to do. This is how we do it.
```rust
use casperlabs_contract::contract_api::runtime;
use casperlabs_types::ApiError;

#[no_mangle]
pub extern "C" fn call() {
    runtime::revert(ApiError::PermissionDenied) 
}
```
Build-in error codes can be found here: https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings. You can create your own errors using `ApiError::User(<your error code>)` variant of `ApiError`.

### Arguments
It's possible to read arguments passed to the smart contract. Passing arguments is covered later. The function we are interested in is `runtime::get_arg()`. Helper function `unwrap_or_revert_with` is added to `Option` and `Result` when importing `unwrap_or_revert::UnwrapOrRevert`.
```rust
use casperlabs_contract::{
    contract_api::runtime,
    unwrap_or_revert::UnwrapOrRevert,
};

#[no_mangle]
pub extern "C" fn call() {
    let value: String = runtime::get_arg(0)
        // Unwrap the `Option`, returning an error if there was no argument supplied.
        .unwrap_or_revert_with(ApiError::MissingArgument)
        // Unwrap the `Result` containing the deserialized argument or return an error if there was
        // a deserialization error.
        .unwrap_or_revert_with(ApiError::InvalidArgument);
}
```

### Storage
Saving and reading values from and to the blockchain is a manual process at CasperLabs. It requires more code to be written, but also gives much flexibility.

Below code comes from `contract/src/lib.rs`. It reads an argument and stores it in the memory under `special_value` key.
```rust
#![cfg_attr(
    not(target_arch = "wasm32"),
    crate_type = "target arch should be wasm32"
)]

use casperlabs_contract::{
    contract_api::{runtime, storage},
    unwrap_or_revert::UnwrapOrRevert,
};
use casperlabs_types::{ApiError, Key};

const KEY: &str = "special_value";

fn store(value: String) {
    // Store `value` under a new unforgeable reference.
    let value_ref = storage::new_turef(value);

    // Wrap the unforgeable reference in a value of type `Key`.
    let value_key: Key = value_ref.into();

    // Store this key under the name "special_value" in context-local storage.
    runtime::put_key(KEY, value_key);
}

// All session code must have a `call` entrypoint.
#[no_mangle]
pub extern "C" fn call() {
    // Get the optional first argument supplied to the argument.
    let value: String = runtime::get_arg(0)
        // Unwrap the `Option`, returning an error if there was no argument supplied.
        .unwrap_or_revert_with(ApiError::MissingArgument)
        // Unwrap the `Result` containing the deserialized argument or return an error if there was
        // a deserialization error.
        .unwrap_or_revert_with(ApiError::InvalidArgument);

    store(value);
}
```

## Deploying contracts
### How to structure your deployments

You can Deploy contracts using our pre-built binaries or build from source. Both provide the casperLabs-client.

* [**Using binaries**](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#using-binaries-recommended) (recommended):

    Make sure you have rustup installed and the casperlabs package, which contains casperlabs-client.

* [**Building from source**](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#building-from-source)

    Make sure you have rustup installed and you can build the casperlabs-client from [source]() . If you build from source, you will need to add the build directories to your PATH.

    Or, you can run the client commands from the root directory of the repo, using explicit paths to the binaries.


### Features of the deployment interface

* [CasperLabs Clarity](https://clarity.casperlabs.io/#/) - you can deploy contracts from our Clarity Portal, or

* Follow the instructions in [CONTRACTS.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md) about how to deploy contracts using the CasperLabs Client 

### Deploying to DevNet

A quick start includes a simple set of instructions for getting started on the CasperLabs devnet [here](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code).

Note: More advanced users may wish to take other approaches to some of the steps listed.

### How do I know my contract deployed successfully?

**View deploys in [Clarity](https://clarity.casperlabs.io/#/deploys) -** Navigate to your account in Clarity and select the deploys tab where you can se a detailed view of your deploy with a hash, timestamp, amd result.

**Work with deploys in CL Client**- You will find a step-by-step set of instructions and examples including basic and advanced features about features you can use including but not limited to creating, sending, printing, and querying deployments in our [CONTRACTS.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#deploying-contracts).

Note: Prior knowledge about permissions and execution semantics is recommended and can be found in our Techspec [here](https://github.com/CasperLabs/techspec/blob/master/implementation/accounts.rst).


## Using GraphQL

### To debug contracts

### To learn about the network

## Execution error codes
A listing and description of each error code.
