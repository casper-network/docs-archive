# Smart Contract

In this section we will use [logic](logic) crate to finally implement ERC20 Smart Contract. Make sure you know the basics from [Writing Rust Contracts on CasperLabs](../writing-rust-contracts) tutorial.

ERC20 will have two contracts:
* `erc20` contract that handles ERC20 implementation,
* `proxy` contract that should be called by the account. It calls `erc20` on behalf of the account, so `erc20` has its own context. 

The `contract` crate will include:
* `errors.rs` - errors definition,
* `input_parser.rs` - parsing arguments,
* `env.rs` - interacting with blockchain's storage,
* `erc20.rs` - implementation of `ERC20Trait`,
* `contracts.rs` - smart contracts.

## Context
It's important to understand how execution contract works. Let's compare it to Ethereum to see the difference.

In Ethereum account object is just an public key with the balance. In CasperLabs account has its own key-value storage and account-only functions like the [associated keys](../../implementation/accounts.html#associated-keys-and-weights) management.

In Ethereum when contract is called, it executes in its own context. The contract knows only the account's address which invoked it. In Solidity accessible by `msg.caller`. 

In CasperLabs when contract is called, it executes in the context of calling account, so it uses account's storage.

Additionaly in CasperLabs the contract has its own key-value storage, but only when called by other contract. Imagine a chain of calls: `Account` calls `Contract A`, then `Contract A` calls `Contract B`. `Contract A` is executed in the context of `Account`. `Contract B` is executed in the context of itself.

## Cargo.toml
Start with package definition at `contract/Cargo.toml`.
```toml
[package]
name = "contract"
version = "0.1.1"
authors = ["Maciej Zielinski <maciej@casperlabs.io>"]
edition = "2018"

[lib]
crate-type = ["cdylib"]
doctest = false
test = false
bench = false

[dependencies]
casperlabs-contract = "0.4.0"
casperlabs-types = "0.4.0"
logic = { path = "../logic", default-features = false }

[features]
default = ["casperlabs-contract/std", "casperlabs-types/std"]
```

## Errors
We start the implementation with defining the error codes as `Error` enum. It's important to provide `From<Error>` trait implementation for `ApiError`, so it is easier to revert with [runtime::revert](https://docs.rs/casperlabs-contract/latest/casperlabs_contract/contract_api/runtime/fn.revert.html).
```rust
// contract/src/error.rs

use casperlabs_types::ApiError;

#[repr(u16)]
pub enum Error {
    UnknownApiCommand = 1,                      // 65537
    UnknownDeployCommand = 2,                   // 65538
    UnknownProxyCommand = 3,                    // 65539
    MissingArgument0 = 16,                      // 65552
    MissingArgument1 = 17,                      // 65553
    MissingArgument2 = 18,                      // 65554
    MissingArgument3 = 19,                      // 65555
    MissingArgument4 = 20,                      // 65556
    MissingArgument5 = 21,                      // 65557
    InvalidArgument0 = 22,                      // 65558
    InvalidArgument1 = 23,                      // 65559
    InvalidArgument2 = 24,                      // 65560
    InvalidArgument3 = 25,                      // 65561
    InvalidArgument4 = 26,                      // 65562
    InvalidArgument5 = 27,                      // 65563
    UnsupportedNumberOfArguments = 28           // 65564
}

impl From<Error> for ApiError {
    fn from(error: Error) -> ApiError {
        ApiError::User(error as u16)
    }
}

impl Error {
    pub fn missing_argument(i: u32) -> Error {
        match i {
            0 => Error::MissingArgument0,
            1 => Error::MissingArgument1,
            2 => Error::MissingArgument2,
            3 => Error::MissingArgument3,
            4 => Error::MissingArgument4,
            5 => Error::MissingArgument5,
            _ => Error::UnsupportedNumberOfArguments,
        }
    }

    pub fn invalid_argument(i: u32) -> Error {
        match i {
            0 => Error::InvalidArgument0,
            1 => Error::InvalidArgument1,
            2 => Error::InvalidArgument2,
            3 => Error::InvalidArgument3,
            4 => Error::InvalidArgument4,
            5 => Error::InvalidArgument5,
            _ => Error::UnsupportedNumberOfArguments,
        }
    }
}
```
Take a look at the complete error list in [error.rs](https://github.com/CasperLabs/erc20/blob/master/logic/src/tests.rs) file.

## Input
You already know that in CasperLabs arguments should be handled manually as presented in [Writing Rust Contracts on CasperLabs](../writing-rust-contracts). It's possible to come up with different strategies for arguments parsing that suit our needs. In this very example we'll follow 2 simple rules:
1. Calls addressed to `erc20` contract has first argument a type of `String`, that is the name of function we want to call.
2. Calls addressed to `proxy` contract has first argument a type of `Tuple(String, Hash)`, where `Hash` is the address of `erc20` token and `String` is method name. The `proxy` should call `erc20` contract at `Hash` using `String` as a function name and pass other arguments intact.

Having those rules allows us to build universal (for `erc20` and `proxy`) argument handler. It's a good practice to separate argument parser from the rest of the code.

```rust
// contract/src/input_parser.rs

use casperlabs_contract::{contract_api::runtime, unwrap_or_revert::UnwrapOrRevert};
use casperlabs_types::{
    account::PublicKey,
    bytesrepr::{Error as ApiError, FromBytes},
    CLTyped, ContractRef, U512,
};

use crate::error::Error;

pub const DEPLOY: &str = "deploy";
pub const INIT_ERC20: &str = "init_erc20";
pub const BALANCE_OF: &str = "balance_of";
pub const TOTAL_SUPPLY: &str = "total_supply";
pub const TRANSFER: &str = "transfer";
pub const TRANSFER_FROM: &str = "transfer_from";
pub const APPROVE: &str = "approve";
pub const ALLOWANCE: &str = "allowance";

pub enum Input {
    Deploy(U512),
    InitErc20(U512),
    Transfer(PublicKey, U512),
    TransferFrom(PublicKey, PublicKey, U512),
    Approve(PublicKey, U512),
    BalanceOf(PublicKey),
    Allowance(PublicKey, PublicKey),
    TotalSupply,
}

pub fn from_args() -> Input {
    let method: String = method_name();
    match method.as_str() {
        DEPLOY => Input::Deploy(get_arg(1)),
        INIT_ERC20 => Input::InitErc20(get_arg(1)),
        TRANSFER => Input::Transfer(get_arg(1), get_arg(2)),
        TRANSFER_FROM => Input::TransferFrom(get_arg(1), get_arg(2), get_arg(3)),
        APPROVE => Input::Approve(get_arg(1), get_arg(2)),
        BALANCE_OF => Input::BalanceOf(get_arg(1)),
        ALLOWANCE => Input::Allowance(get_arg(1), get_arg(2)),
        TOTAL_SUPPLY => Input::TotalSupply,
        _ => runtime::revert(Error::UnknownApiCommand),
    }
}

pub fn destination_contract() -> ContractRef {
    let (_, hash): (String, [u8; 32]) = get_arg(0);
    ContractRef::Hash(hash)
}

fn get_arg<T: CLTyped + FromBytes>(i: u32) -> T {
    runtime::get_arg(i)
        .unwrap_or_revert_with(Error::missing_argument(i))
        .unwrap_or_revert_with(Error::invalid_argument(i))
}

fn method_name() -> String {
    let maybe_argument: Result<String, ApiError> =
        runtime::get_arg(0).unwrap_or_revert_with(Error::missing_argument(0));
    match maybe_argument {
        Ok(method) => method,
        Err(_) => {
            let (method, _): (String, [u8; 32]) = get_arg(0);
            method
        }
    }
}
```
The idea is to convert arguments into `Input` enum and use `input_parser::from_args()` in contracts.

## Implement ERC20Trait
We already implemented `ERC20Trait` once in [Logic Tests](logic-test.html#test-token-implemetation). Now we'll do it again, using blockchain as a state storage this time.
```rust
// src/contract/erc20.rs

use std::string::{String, ToString};

use casperlabs_types::{account::PublicKey, U512};

use crate::env;
use logic::ERC20Trait;

pub const TOTAL_SUPPLY_KEY: &str = "total_supply";

pub struct ERC20Token;

impl ERC20Trait<U512, PublicKey> for ERC20Token {
    fn read_balance(&mut self, address: &PublicKey) -> Option<U512> {
        let name = balance_key(address);
        env::key(&name)
    }

    fn save_balance(&mut self, address: &PublicKey, balance: U512) {
        let name = balance_key(address);
        env::set_key(&name, balance);
    }

    fn read_total_supply(&mut self) -> Option<U512> {
        env::key(TOTAL_SUPPLY_KEY)
    }

    fn save_total_supply(&mut self, total_supply: U512) {
        env::set_key(TOTAL_SUPPLY_KEY, total_supply);
    }

    fn read_allowance(&mut self, owner: &PublicKey, spender: &PublicKey) -> Option<U512> {
        let name = allowance_key(owner, spender);
        env::key(&name)
    }

    fn save_allowance(&mut self, owner: &PublicKey, spender: &PublicKey, amount: U512) {
        let name = allowance_key(owner, spender);
        env::set_key(&name, amount);
    }
}

fn balance_key(public_key: &PublicKey) -> String {
    public_key.to_string()
}

fn allowance_key(owner: &PublicKey, spender: &PublicKey) -> String {
    format!("{}{}", owner, spender)
}
```
It uses `env::key` as a getter and `env::set_key` as setter. Let's define them.
```rust
// contract/src/env.rs

use std::convert::TryInto;

use crate::{
    error::Error,
    input_parser,
};
use casperlabs_contract::{
    contract_api::{runtime, storage},
    unwrap_or_revert::UnwrapOrRevert,
};
use casperlabs_types::{
    bytesrepr::{FromBytes, ToBytes},
    CLTyped, Key, U512,
};


pub fn key<T: FromBytes + CLTyped>(name: &str) -> Option<T> {
    match runtime::get_key(name) {
        None => None,
        Some(maybe_key) => {
            let key = maybe_key
                .try_into()
                .unwrap_or_revert_with(Error::UnexpectedType);
            let value = storage::read(key)
                .unwrap_or_revert_with(Error::MissingKey)
                .unwrap_or_revert_with(Error::UnexpectedType);
            Some(value)
        }
    }
}

pub fn set_key<T: ToBytes + CLTyped>(name: &str, value: T) {
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
```

## Proxy Contract
The first smart contract we'll write is the `proxy` contract. It will be executed in the context of the account, that sends the transaction. Its goal is to call `erc20` contract and pass arguments further.
```rust
// contract/src/contracts.rs

#[no_mangle]
pub extern "C" fn erc20_proxy() {
    let token = input_parser::destination_contract();
    match input_parser::from_args() {
        Input::Transfer(recipient, amount) => {
            let args = (input_parser::TRANSFER, recipient, amount);
            runtime::call_contract::<_, ()>(token, args);
        }
        Input::TransferFrom(owner, recipient, amount) => {
            let args = (input_parser::TRANSFER_FROM, owner, recipient, amount);
            runtime::call_contract::<_, ()>(token, args);
        }
        Input::Approve(spender, amount) => {
            let args = (input_parser::APPROVE, spender, amount);
            runtime::call_contract::<_, ()>(token, args);
        }
        _ => runtime::revert(Error::UnknownProxyCommand),
    }
}
```
[call_contract](https://docs.rs/casperlabs-contract/latest/casperlabs_contract/contract_api/runtime/fn.call_contract.html) is the key function here. It allows to call another contract.

## ERC20 Contract
Next contract we'll define is `erc20`. When called, the function `erc20` is invoked. At first, contract checks if it's already initialized. `env` functions are defined below. If not it's not initialized, it calls `init_erc20` function that mints tokens for the caller and marks contract as initialized. From now on, the `handle_erc20` function is always invoked.
```rust
// contract/src/contract.rs

let ERC20_CONTRACT_NAME: &str = "erc20";

#[no_mangle]
pub extern "C" fn erc20() {
    if env::is_initialized(env::ERC20_CONTRACT_NAME) {
        handle_erc20().unwrap_or_revert();
    } else {
        init_erc20();
        env::mark_as_initialized(env::ERC20_CONTRACT_NAME);
    }
}

pub fn init_erc20() {
    if let Input::InitErc20(amount) = input_parser::from_args() {
        let mut token = erc20::ERC20Token;
        token.mint(&runtime::get_caller(), amount);
    } else {
        runtime::revert(Error::UnknownErc20ConstructorCommand);
    }
}

pub fn handle_erc20() -> Result<(), Error> {
    let mut token = erc20::ERC20Token;
    match input_parser::from_args() {
        Input::Transfer(recipient, amount) => token
            .transfer(&runtime::get_caller(), &recipient, amount)
            .map_err(Error::from),
        Input::Approve(spender, amount) => {
            token.approve(&runtime::get_caller(), &spender, amount);
            Ok(())
        }
        Input::TransferFrom(owner, recipient, amount) => token
            .transfer_from(&runtime::get_caller(), &owner, &recipient, amount)
            .map_err(Error::from),
        Input::BalanceOf(address) => {
            runtime::ret(CLValue::from_t(token.balance_of(&address)).unwrap_or_revert())
        }
        Input::Allowance(owner, spender) => {
            runtime::ret(CLValue::from_t(token.allowance(&owner, &spender)).unwrap_or_revert())
        }
        Input::TotalSupply => {
            runtime::ret(CLValue::from_t(token.total_supply()).unwrap_or_revert())
        }
        _ => Err(Error::UnknownErc20CallCommand),
    }
}
```
New `env` methods are `env::is_initialized` and `env::mark_as_initialized`.
```rust
// contract/src/env.rs

pub fn is_initialized(name: &str) -> bool {
    key::<bool>(name).is_some()
}

pub fn mark_as_initialized(name: &str) {
    set_key(name, true);
}
``` 
[ret](https://docs.rs/casperlabs-contract/latest/casperlabs_contract/contract_api/runtime/fn.ret.html) function returns the given value to the host (other contract that invoked the `call_contract`) and terminates the currently running module.

## Call Function
Above contract won't do much if they are not deployed. It's not enought to define them. We'll use [store_function_at_hash](https://docs.rs/casperlabs-contract/latest/casperlabs_contract/contract_api/storage/fn.store_function_at_hash.html) to save them on the blockchain. Below's `call` function will be called right after the WASM file is included in the block.
```rust
// contract/src/contracts.rs

#[no_mangle]
pub extern "C" fn call() {
    match input_parser::from_args() {
        Input::Deploy(initial_balance) => {
            env::deploy_token(initial_balance);
            env::deploy_proxy();
        }
        _ => runtime::revert(Error::UnknownDeployCommand),
    }
}
```
It expects two arguments: `"deploy"` as a method name, and `initial_balance` as the number of tokens initially minted for the calling account.

Let's take a look at `env::deploy_token` and `env::deploy_proxy`. `deploy_token` stores the `erc20` contract and gets `token_ref` as the return. Then it calls `erc20` contract to initilized it. At the end it saves the contract's hash under `erc2` as one of the named key the account. `call` is running in the context of the account that executed the transaction. `deploy_proxy` does the same, but without initialization step as it doesn't need it. 

```rust
// contract/src/env.rs

use crate::input_parser;

pub const ERC20_CONTRACT_NAME: &str = "erc20";
pub const ERC20_PROXY_CONTRACT_NAME: &str = "erc20_proxy";

pub fn deploy_token(initial_balance: U512) {
    let token_ref = storage::store_function_at_hash(ERC20_CONTRACT_NAME, Default::default());
    runtime::call_contract::<_, ()>(token_ref.clone(), (input_parser::INIT_ERC20, initial_balance));
    let contract_key: Key = token_ref.into();
    let token: Key = storage::new_uref(contract_key).into();
    runtime::put_key(ERC20_CONTRACT_NAME, token);
}

pub fn deploy_proxy() {
    let proxy_ref = storage::store_function_at_hash(ERC20_PROXY_CONTRACT_NAME, Default::default());
    let contract_key: Key = proxy_ref.into();
    let proxy: Key = storage::new_uref(contract_key).into();
    runtime::put_key(ERC20_PROXY_CONTRACT_NAME, proxy);
}
```

