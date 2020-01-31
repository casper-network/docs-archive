Contract Examples
=================

Access our repository of contract examples [here](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/contracts/examples)


bonding-call
------------

[**bonding-call example**](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/contracts/examples/bonding-call/src/lib.rs)

```rust
#![no_std]

use contract_ffi::{
    contract_api::{account, runtime, system, Error},
    unwrap_or_revert::UnwrapOrRevert,
    value::U512,
};

const BOND_METHOD_NAME: &str = "bond";

enum Arg {
    BondAmount = 0,
}

// Bonding contract.
//
// Accepts bonding amount (of type `U512`) as first argument.
// Issues bonding request to the PoS contract.
#[no_mangle]
pub extern "C" fn call() {
    let pos_pointer = system::get_proof_of_stake();
    let source_purse = account::get_main_purse();
    let bonding_purse = system::create_purse();
    let bond_amount: U512 = runtime::get_arg(Arg::BondAmount as u32)
        .unwrap_or_revert_with(Error::MissingArgument)
        .unwrap_or_revert_with(Error::InvalidArgument);

    system::transfer_from_purse_to_purse(source_purse, bonding_purse, bond_amount)
        .unwrap_or_revert();

    runtime::call_contract(pos_pointer, (BOND_METHOD_NAME, bond_amount, bonding_purse))
}
```


Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

#### Rust Crates
[bonding-call](https://docs.rs/casperlabs-contract-ffi/0.21.0/casperlabs_contract_ffi/all.html) 


counter-call
------------

>[**counter-call contract example**](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/contracts/examples/bonding-call/src/lib.rs)

```rust
#![no_std]

use contract_ffi::{
    contract_api::{runtime, Error},
    unwrap_or_revert::UnwrapOrRevert,
};

const COUNTER_KEY: &str = "counter";
const GET_METHOD: &str = "get";
const INC_METHOD: &str = "inc";

#[no_mangle]
pub extern "C" fn call() {
    let counter_uref = runtime::get_key(COUNTER_KEY).unwrap_or_revert_with(Error::GetKey);
    let contract_ref = counter_uref
        .to_contract_ref()
        .unwrap_or_revert_with(Error::UnexpectedKeyVariant);

    {
        let args = (INC_METHOD,);
        runtime::call_contract::<_, ()>(contract_ref.clone(), args);
    }

    let _result: i32 = {
        let args = (GET_METHOD,);
        runtime::call_contract(contract_ref, args)
    };
}
```


Call Counter
------------

Implementation of smart contract, that increments previously deployed counter.

### Call Counter Build

Build the `wasm` file using `make` in the `execution-engine` directory.
```
$ make build-contract/counter-call
```

### Call Counter Deploy

Deploy the counter smart contract.
```
$ casperlabs-client --host $HOST deploy \
    --private-key $PRIVATE_KEY_PATH \
    --payment-amount 10000000 \
    --session $COUNTER_CALL_WASM
```

### Call Counter Check counter's value

Query global state to check counter's value.

```
$ casperlabs-client --host $HOST query-state \
    --block-hash $BLOCK_HASH \
    --type address \
    --key $PUBLIC_KEY \
    --path "counter/count"
```

### counter call Rust Crates
[counter-call](https://docs.rs/casperlabs-contract-ffi/0.21.0/casperlabs_contract_ffi/all.html) 


counter define
--------------

### counter-define contract example

> [**counter define contract example**](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/contracts/examples/counter-define/src/lib.rs)

```rust
#![no_std]

extern crate alloc;

use alloc::{collections::BTreeMap, string::String};

use contract_ffi::{
    contract_api::{runtime, storage, Error as ApiError, TURef},
    key::Key,
    unwrap_or_revert::UnwrapOrRevert,
    value::CLValue,
};

const COUNT_KEY: &str = "count";
const COUNTER_EXT: &str = "counter_ext";
const COUNTER_KEY: &str = "counter";
const GET_METHOD: &str = "get";
const INC_METHOD: &str = "inc";

enum Arg {
    MethodName = 0,
}

#[repr(u16)]
enum Error {
    UnknownMethodName = 0,
}

impl Into<ApiError> for Error {
    fn into(self) -> ApiError {
        ApiError::User(self as u16)
    }
}

#[no_mangle]
pub extern "C" fn counter_ext() {
    let turef: TURef<i32> = runtime::get_key(COUNT_KEY)
        .unwrap_or_revert()
        .to_turef()
        .unwrap_or_revert_with(ApiError::UnexpectedKeyVariant);

    let method_name: String = runtime::get_arg(Arg::MethodName as u32)
        .unwrap_or_revert_with(ApiError::MissingArgument)
        .unwrap_or_revert_with(ApiError::InvalidArgument);

    match method_name.as_str() {
        INC_METHOD => storage::add(turef, 1),
        GET_METHOD => {
            let result = storage::read(turef)
                .unwrap_or_revert_with(ApiError::Read)
                .unwrap_or_revert_with(ApiError::ValueNotFound);
            let return_value = CLValue::from_t(result).unwrap_or_revert();
            runtime::ret(return_value);
        }
        _ => runtime::revert(Error::UnknownMethodName),
    }
}

#[no_mangle]
pub extern "C" fn call() {
    let counter_local_key = storage::new_turef(0); //initialize counter

    //create map of references for stored contract
    let mut counter_urefs: BTreeMap<String, Key> = BTreeMap::new();
    let key_name = String::from(COUNT_KEY);
    counter_urefs.insert(key_name, counter_local_key.into());

    let pointer = storage::store_function_at_hash(COUNTER_EXT, counter_urefs);
    runtime::put_key(COUNTER_KEY, pointer.into());
}

```

### counter define deploy counter

Implementation of URef-based counter.

The deployement of this session code, creates new named key `counter`, that points to the deployed smart contract. The `counter` smart contract will have one named key called `count`, that points to the actual integer value, that is the counter.

The `counter` smart contract exposes two methods:
- `inc`, that increments the `count` value by one;
- `get`, that returns the value of `count`.



### counter define Build

Build the `wasm` file using `make` in the `execution-engine` directory.

`$ make build-contract/counter-define`


### counter define deploy


### deploy the counter smart contract.


> **counter define deploy example**

```shell
$ casperlabs-client --host $HOST deploy \
    --private-key $PRIVATE_KEY_PATH \
    --payment-amount 10000000 \
    --session $COUNTER_DEFINE_WASM
```


### counter define check  counter's value

Query global state to check counter's value.
**conter define check counter's value example**

```shell
$ casperlabs-client --host $HOST query-state \`
    `--block-hash $BLOCK_HASH \`
    `--type address \`
    `--key $PUBLIC_KEY \`
    `--path "counter/count"`
```



















<!--## erc20-logic contract example-->

<!--## erc20-smart-contract contract example-->

<!--## hello-name-call contract example-->

<!--## hello-name-define contract example-->

<!--## mailing-list-call contract example-->

<!--## mailing-list-define contract example-->
```
