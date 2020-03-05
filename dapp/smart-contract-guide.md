# Smart Contract Guide

In this tutorial we will use Rust's Smart Contract library we created at Casperlab. Casperlabs blockchain uses WebAssembly (WASM) as it's virtual machine. Thanks to the Rust's native ability to compile to WASM we can build smart contract using all the good tools and libraries Rust ecosystem gives us.

## Start a new project.
First lets create a new project.
```bash
$ cargo casperlabs my-project
```
We should endup with two crates called `contract` and `tests`. It's an out of the box implementation of a very simple smart contract that saves a value, passed as an argument, on the blockchain.

## Project structure
TODO: describe each file.

## Compile and test.
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

## Libs.
TODO: describe dependencies libs.

## Basic Smart Contract.
Casperlab's VM executes smart contract by calling it's `call` function. If the function is not there, then it's not a valid smart contract. The simples possible example we can write is just an empty `call` function.
```rust
#[no_mangle]
pub extern "C" fn call() { }
```
`#[no_mangle]` attribute prevents the compiler from changing (mangling) the function name when converting to binary format of WASM. Without it, the VM exits with the error message: `Module doesn't have export call`.

## Failing gentely.
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

## Arguments.
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

## Storage.
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