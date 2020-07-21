## Getting Started with the DSL

Since the DSL uses macros, it works like templates in the smart contract, so it's necessary to tell the Rust compiler where the macros are located for each smart contract.
The aim of this guide is to describe how to configure the smart contract to use the DSL.

### About the DSL


With the release of Node 0.20, each contract can have multiple entry points. 

* The `constructor_macro` creates the code that sets up the contract in the runtime and locates the contract in the runtime when execution begins (this is the deploy function that creates the entry point & stores the deploy hash stored under some function name in the runtime).  Think of the function templated by the constructor macro as your ```main``` function, while the contract macro sets up the function definitions within the calls.
* The `contract_macro` generates the code for the headers for each of the entry points that use it.
* The `casperlabs_method` creates an entry point for any function in your contract. 




#### Pre-Requisites - Set up the Rust SDK
Please use the Rust SDK to [create your smart contract project](/dapp-dev-guide/setup-of-rust-contract-sdk.md#setting-up-the-rust-contract-sdk) before setting up the DSL.


#### Getting the Macros

The macros are located on [GitHub](https://github.com/CasperLabs/casperlabs_contract_macro).
The macros are also shipped as a crate on crates.io

###### Using Github[Recommended]
To import the macros, include the following line in the `Cargo.toml` file in the `/contract` folder for your smart contract.  The entry needs to appear in the
`[dependencies]` section.  This example points directly to Github:

```
contract_macro = { git = "https://github.com/CasperLabs/casperlabs_contract_macro", branch = "in_progress", package = "contract_macro"}

```

This example uses a local path for the macros:
```
contract_macro = { path = "../../casperlabs-node/smart_contracts/contract_macro" }
```
###### Using Crates.io
You can alternatively use a crate available on crates.io as 
```
contract_macro = { package = "casperlabs_contract_macro", version = "0.1.0" }

```

#### Using the DSL
To use the DSL, simply add the following line to the `use` section of the contract.  This section is similar to `include` 

```
use contract_macro::{casperlabs_constructor, casperlabs_contract, casperlabs_method};
```
This line can go after the last `use` line in the blank contract created by `cargo-casperlabs`

Remember, if you are using the crates.io package, you may have to use the package as `casperlabs_contract_macro`. This depends entirely on how you import the package in your `Cargo.toml` file

##### Example Simple Counter Contract

The following contract creates a counter in storage. Each time the contract is invoked, the counter is incremented by 1.

```
extern crate alloc;
use alloc::{collections::BTreeSet, string::String};

// import casperlabs contract api
use contract::{
	contract_api::{runtime, storage},
	unwrap_or_revert::UnwrapOrRevert,
};
// import the contract macros
use contract_macro::{casperlabs_constructor, casperlabs_contract, casperlabs_method};
use std::convert::TryInto;

// import casperlabs types
use types::{
	bytesrepr::{FromBytes, ToBytes},
	contracts::{EntryPoint, EntryPointAccess, EntryPointType, EntryPoints},
	runtime_args, CLType, CLTyped, Group, Key, Parameter, RuntimeArgs, URef,
};

const KEY: &str = "special_value";

// macro to set up the contract
#[casperlabs_contract]
mod tutorial {
	use super::*;

// constructor macro that sets up the methods, values and keys required for the contract.
	#[casperlabs_constructor]
	fn init_counter(initial_value: u64) {
    	let value_ref: URef = storage::new_uref(initial_value);
    	let value_key: Key = value_ref.into();
    	runtime::put_key(KEY, value_key);
	}

// method macro that sets up required elements for each method in the contract.  
	#[casperlabs_method]
	fn update_counter() {
    	let old_value: u64 = key(KEY).unwrap();
    	let new_value = old_value + 1;
    	set_key(KEY, new_value);
	}

// method macro that sets up required elements for each method in the contract.  
	#[casperlabs_method]
	fn get_counter_value() -> u64 {
    	key(KEY).unwrap()
	}

	fn key<T: FromBytes + CLTyped>(name: &str) -> Option<T> {
    	match runtime::get_key(name) {
        	None => None,
        	Some(maybe_key) => {
            	let key = maybe_key.try_into().unwrap_or_revert();
            	let value = storage::read(key).unwrap_or_revert().unwrap_or_revert();
            	Some(value)
        	}
    	}
	}

	fn set_key<T: ToBytes + CLTyped>(name: &str, value: T) {
    	match runtime::get_key(name) {
        	Some(key) => {
            	let key_ref = key.try_into().unwrap_or_revert();
            	storage::write(key_ref, value);
        	}
        	None => {
            	let key = storage::new_uref(value).into();
            	runtime::put_key(name, key);
        	}
    	}
	}
}
```

##### Checkout the expansion
Once you've marked the appropriate functions with the respective macros, you may want to see what the finalized contract looks like. When the rust compiler sees each of the macros, it 'expands' the code and adds additional lines of code for each of the macros. The resultant expanded code is then finally compiled to the wasm which can then be deployed to the runtime.

To see what the expanded code looks you need the `cargo expand` tool, run the following command to install it.
```
cargo install cargo-expand

```

Go to `contract` and run the command:
```
cargo expand

```
You should see the following output:
```
#![feature(prelude_import)]
#[prelude_import]
use std::prelude::v1::*;
#[macro_use]
extern crate std;
extern crate alloc;
use alloc::{collections::BTreeSet, string::String};
use contract::{
    contract_api::{runtime, storage},
    unwrap_or_revert::UnwrapOrRevert,
};
use casperlabs_contract_macro::{casperlabs_constructor, casperlabs_contract, casperlabs_method};
use std::convert::TryInto;
use types::{
    CLValue,
    bytesrepr::{FromBytes, ToBytes},
    contracts::{EntryPoint, EntryPointAccess, EntryPointType, EntryPoints},
    runtime_args, CLType, CLTyped, Group, Key, Parameter, RuntimeArgs, URef,
};
const KEY: &str = "special_value";
fn __deploy(initial_value: u64) {
    let (contract_package_hash, _) = storage::create_contract_package_at_hash();
    let _constructor_access_uref: URef = storage::create_contract_user_group(
        contract_package_hash,
        "constructor",
        1,
        BTreeSet::new(),
    )
    .unwrap_or_revert()
    .pop()
    .unwrap_or_revert();
    let constructor_group = Group::new("constructor");
    let mut entry_points = EntryPoints::new();
    entry_points.add_entry_point(EntryPoint::new(
        String::from("init_counter"),
        <[_]>::into_vec(box [Parameter::new("initial_value", CLType::U64)]),
        CLType::Unit,
        EntryPointAccess::Groups(<[_]>::into_vec(box [constructor_group])),
        EntryPointType::Contract,
    ));
    entry_points.add_entry_point(EntryPoint::new(
        String::from("update_counter"),
        ::alloc::vec::Vec::new(),
        CLType::Unit,
        EntryPointAccess::Public,
        EntryPointType::Contract,
    ));
    entry_points.add_entry_point(EntryPoint::new(
        String::from("get_counter_value"),
        ::alloc::vec::Vec::new(),
        CLType::Unit,
        EntryPointAccess::Public,
        EntryPointType::Contract,
    ));
    let (contract_hash, _) =
        storage::add_contract_version(contract_package_hash, entry_points, Default::default());
    runtime::put_key("tutorial", contract_hash.into());
    let contract_hash_pack = storage::new_uref(contract_hash);
    runtime::put_key("tutorial_hash", contract_hash_pack.into());
    runtime::call_contract::<()>(contract_hash, "init_counter", {
        let mut named_args = RuntimeArgs::new();
        named_args.insert("initial_value", initial_value);
        named_args
    });
}
#[no_mangle]
fn call() {
    let initial_value: u64 = runtime::get_named_arg("initial_value");
    __deploy(initial_value)
}
fn __init_counter(initial_value: u64) {
    let value_ref: URef = storage::new_uref(initial_value);
    let value_key: Key = value_ref.into();
    runtime::put_key(KEY, value_key);
}
#[no_mangle]
fn init_counter() {
    let initial_value: u64 = runtime::get_named_arg("initial_value");
    __init_counter(initial_value)
}
fn __update_counter() {
    let old_value: u64 = key(KEY).unwrap();
    let new_value = old_value + 1;
    set_key(KEY, new_value);
}
#[no_mangle]
fn update_counter() {
    __update_counter();
}
fn __get_counter_value() -> u64 {
    key(KEY).unwrap()
}
#[no_mangle]
fn get_counter_value() {
    let val: u64 = __get_counter_value();
    ret(val)
}
fn key<T: FromBytes + CLTyped>(name: &str) -> Option<T> {
    match runtime::get_key(name) {
        None => None,
        Some(maybe_key) => {
            let key = maybe_key.try_into().unwrap_or_revert();
            let value = storage::read(key).unwrap_or_revert().unwrap_or_revert();
            Some(value)
        }
    }
}
fn set_key<T: ToBytes + CLTyped>(name: &str, value: T) {
    match runtime::get_key(name) {
        Some(key) => {
            let key_ref = key.try_into().unwrap_or_revert();
            storage::write(key_ref, value);
        }
        None => {
            let key = storage::new_uref(value).into();
            runtime::put_key(name, key);
        }
    }
}
fn ret<T: CLTyped + ToBytes>(value: T) {
    runtime::ret(CLValue::from_t(value).unwrap_or_revert())
}
```

##### Testing the sample contract:

You can use the following test to check whether or not your tutorial contract is working as it uses the DSL:
```
#[cfg(test)]
mod tests {
    use test_support::{Code, SessionBuilder, TestContextBuilder};
    use types::{account::AccountHash, runtime_args, RuntimeArgs, U512};

    const MY_ACCOUNT: AccountHash = AccountHash::new([7u8; 32]);
    const KEY: &str = "special_value";
    const CONTRACT: &str = "tutorial";

    #[test]
    fn should_initialize_to_zero() {
        let mut context = TestContextBuilder::new()
            .with_account(MY_ACCOUNT, U512::from(128_000_000))
            .build();
        let session_code = Code::from("contract.wasm");
        let session_args = runtime_args! {
            "initial_value" => 0u64
        };
        let session = SessionBuilder::new(session_code, session_args)
            .with_address(MY_ACCOUNT)
            .with_authorization_keys(&[MY_ACCOUNT])
            .with_block_time(0)
            .build();
        context.run(session);
        let check: u64 = match context.query(MY_ACCOUNT, &[CONTRACT, KEY]) {
            Err(_) => panic!("Error"),
            Ok(maybe_value) => maybe_value
                .into_t()
                .unwrap_or_else(|_| panic!("{} is not expected type.", KEY)),
        };
        assert_eq!(0, check);
    }
}
```

