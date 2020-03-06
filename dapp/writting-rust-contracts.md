# Writing Rust Contracts on CasperLabs

## Smart Contracts
This section explains step by step how to write a new smart contract.

### Basic Smart Contract
Casperlab's VM executes smart contract by calling it's `call` function. If the function is not there, then it's not a valid smart contract. The simples possible example we can write is just an empty `call` function.
```rust
#[no_mangle]
pub extern "C" fn call() { }
```
`#[no_mangle]` attribute prevents the compiler from changing (mangling) the function name when converting to binary format of WASM. Without it, the VM exits with the error message: `Module doesn't have export call`.

### Falling gently
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
It's possible to read arguments passed to the smart contract. Passing arguments is covered later. The function we are interested in is `runtime::get_arg`. Helper function `unwrap_or_revert_with` is added to `Option` and `Result` when importing `unwrap_or_revert::UnwrapOrRevert`.
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
Saving and reading values from and to the blockchain is a manual process in CasperLabs. It requires more code to be written, but also gives much flexibility. Storage system works similar to the filesystem in a operating system. Let's say we hava a string `"Hello CasperLabs"`. If you want to save it as a file, you first go to the text editor, create a new file, paste the string in and save it under a name in some directory. Similar happens in CasperLabs. First you have to save your value to the memory using `storage::new_turef`. It returns a reference to the memory object that holds `"Hello Casperlabs"` value. You could use this reference to update the value to something else. It's like a file. Secondly you have to save the reference under a human-readable string using `runtime::put_key`. It's like giving a name to the file. Following function implements this scenario:
```rust
const KEY: &str = "special_value";

fn store(value: String) {
    // Store `value` under a new unforgeable reference.
    let value_ref = storage::new_turef(value);

    // Wrap the unforgeable reference in a value of type `Key`.
    let value_key: Key = value_ref.into();

    // Store this key under the name "special_value" in context-local storage.
    runtime::put_key(KEY, value_key);
}
```
After this function is executed, the context (Account or Smart Contract) will have the content of the `value` stored under `KEY` in its named keys space. The named keys space is a key-value storage that every context has. It's like a home directory.

### Final Smart Contract
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

## Tests
As part of the CasperLabs local environment we provide the in-memory virtual machine you can run your contract against. We design the testing framework to be used using following pattern:
1. Initialize the context.
2. Deploy or call the smart contract.
3. Query the context for changes and assert the result data with the expected values.

### TestContext
Context provides a virtual machine instance. It should be a mutable object as we will change it's internal data while making deploys. It's also important to set initial balance for the account use for deploys.
```rust
const MY_ACCOUNT: [u8; 32] = [7u8; 32];

let mut context = TestContextBuilder::new()
    .with_account(MY_ACCOUNT, U512::from(128_000_000))
    .build();
```
Account is type of `[u8; 32]`. Balance is type of `U512`.

### Run Smart Contract
Before we can deploy the contract to the context, we need to prepare the request. We call the request a `session`. Each session call should have 4 elements: 
- WASM file path.
- List of arguments.
- Account context of execution.
- List of keys, that authorises the call. See: TODO insert keys management link.
```rust
let VALUE: &str = "hello world";
let session_code = Code::from("contract.wasm");
let session_args = (VALUE,);
let session = SessionBuilder::new(session_code, session_args)
    .with_address(MY_ACCOUNT)
    .with_authorization_keys(&[MY_ACCOUNT])
    .build();
context.run(session);
```
Run function panics if the code execution fails.

### Query And Assert
The smart contract we deployed creates a new vaule `"hello world"` under the key `"special_value"`. Using the `query` function it's possible to extract this value from the blockchain.
```rust
let KEY: &str = "special_value";
let result_of_query: Result<Value, Error> = context.query(MY_ACCOUNT, &[KEY]);
let returned_value = result_of_query.expect("should be a value");
let expected_value = Value::from_t(VALUE.to_string()).expect("should construct Value");
assert_eq!(expected_value, returned_value);
```
Note that the `expected_value` is a `String` type lifted to the `Value` type. It was also possible to map `returned_value` to the `String` type. 

### Final Test
Below code comes from `tests/src/integration_tests.rs`.
```rust
#[cfg(test)]
mod tests {
    use casperlabs_engine_test_support::{Code, Error, SessionBuilder, TestContextBuilder, Value};
    use casperlabs_types::U512;

    const MY_ACCOUNT: [u8; 32] = [7u8; 32];
    // define KEY constant to match that in the contract
    const KEY: &str = "special_value";
    const VALUE: &str = "hello world";

    #[test]
    fn should_store_hello_world() {
        let mut context = TestContextBuilder::new()
            .with_account(MY_ACCOUNT, U512::from(128_000_000))
            .build();

        // The test framework checks for compiled Wasm files in '<current working dir>/wasm'.  Paths
        // relative to the current working dir (e.g. 'wasm/contract.wasm') can also be used, as can
        // absolute paths.
        let session_code = Code::from("contract.wasm");
        let session_args = (VALUE,);
        let session = SessionBuilder::new(session_code, session_args)
            .with_address(MY_ACCOUNT)
            .with_authorization_keys(&[MY_ACCOUNT])
            .build();

        let result_of_query: Result<Value, Error> = context.run(session).query(MY_ACCOUNT, &[KEY]);

        let returned_value = result_of_query.expect("should be a value");

        let expected_value = Value::from_t(VALUE.to_string()).expect("should construct Value");
        assert_eq!(expected_value, returned_value);
    }
}

fn main() {
    panic!("Execute \"cargo test\" to test the contract, not \"cargo run\".");
}
```

## Deploy To Devnet
Nothing stops you now from deploying the smart contract to the devnet network. First you need to have a account with positive balance of CLX. Go to https://clarity.casperlabs.io and prepare your account. Secondly you need commandline client to make a deploy. Go to https://pypi.org/project/casperlabs-client/ and follow the installation steps.

### Use Client To Deploy
More on contracts deployment you can find here https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md. Below command is just an example of how the deploy should look like.
```bash
$ casperlabs_client --host deploy.casperlabs.io deploy \
    --session contract.wasm \
    --session-args '[{"name": "surname", "value": {"string_value": "Nakamoto"}}]' \
    --private-key account-private.pem \
    --payment-amount 10000000

Success! Deploy 8428717f1cfc9cc5c047f503661e9c0fc2a495ead44305a807bead130cbd181f deployed
```

### Check The Deploy Status
Making a deploy is not the same as having deploy included in the block. First it goes to the mempool and then validators of the network are responsible for adding it the the block. You can use client to check the status of the deploy.
```bash
$ casperlabs_client --host deploy.casperlabs.io show-deploy \
    8428717f1cfc9cc5c047f503661e9c0fc2a495ead44305a807bead130cbd181f

deploy {
  deploy_hash: "8428717f1cfc9cc5c047f503661e9c0fc2a495ead44305a807bead130cbd181f"
...
  cost: 126165
}
status {
  state: PROCESSED
}

```

### How do I know my contract executed successfully?
You can use client's method `query-state` to see a specific named key of the account. It works the same a `query` method from the testing framework.
```bash
$ casperlabs_client --host deploy.casperlabs.io query-state \
    --block-hash "f21fc0763279ad8349b0c0fce08e1ed678412d5e234a92e3063d4d5a35ee0739" \
    --type address \
    --key "0cc94662d68bd71b03083e38094f0b0e07a1bbb485969b6e68f21f4577fe928a" \
    --path "special_value"

string_value: "Nakamoto"
```
