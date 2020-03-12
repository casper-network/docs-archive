# ERC20 Logic

## ERC-20 Standard
ERC20 standard is defined in [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#). Read it carefully as it defines methods we'll implement:
* balance_of
* transfer
* total_supply
* approve
* allowance
* transfer_from
* mint

## Add new crate
One of the greates benefits of writing smart contract in Rust is that we can write a lot of code as standalone library and use it later to implement smart contracts. In this section we will implement the logic of ERC20. To make it testable and easly usable later in smart contract we will abstract all memory operations.

Generate a new `logic` crate.
```
$ cargo new logic --lib
warning: compiling this new crate may not work due to invalid workspace configuration
```
Cargo reminds us to add `logic` to the current workspace, so let's modify `Cargo.toml` in the root directory.
```toml
# Cargo.toml

[workspace]

members = [
    "logic",
    "contract",
    "tests"
]
```
Run `logic` tests to see it works.
```bash
$ cargo test -p logic
```
Prepare `logic/Cargo.toml`.
```toml
# logic/Cargo.toml

[package]
name = "logic"
version = "0.1.0"
authors = ["Maciej Zielinski <maciej@casperlabs.io>"]
edition = "2018"

[lib]
name = "logic"
doctest = false
bench = false

[dependencies]
num-traits = { version = "0.2.10", default-features = false }
```

## ERC20Trait
The logic will be implemented as an `ERC20Trait` trait.
```rust
# logic/src/lib.rs

pub trait ERC20Trait<
    Amount: num_traits::Zero + Add<Output = Amount> + Sub<Output = Amount> + PartialOrd + Copy,
    Address,
>
{}
```
`Amount` and `Address` generics allows for flexibilty in types definitions on the implementation step. 
