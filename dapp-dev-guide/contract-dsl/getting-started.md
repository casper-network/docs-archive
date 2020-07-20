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

To import the macros, include the following line in the `Cargo.toml` file in the `/contract` folder for your smart contract.  The entry needs to appear in the
`[dependencies]` section.  This example points directly to Github:

```
contract_macro = { git = "https://github.com/CasperLabs/casperlabs_contract_macro", branch = "in_progress", package = "contract_macro"}

```

This example uses a local path for the macros:
```
contract_macro = { path = "../../casperlabs-node/smart_contracts/contract_macro" }
```
#### Using the DSL
To use the DSL, simply add the following line to the `use` section of the contract.  This section is similar to `include` 

```
use contract_macro::{casperlabs_constructor, casperlabs_contract, casperlabs_method};
```
This line can go after the last `use` line in the blank contract created by `cargo-casperlabs`

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
