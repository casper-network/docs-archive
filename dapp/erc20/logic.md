# Logic

## ERC-20 Standard
Before starting, we highly recommend a careful reading of the [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#) that provides for the definition of the following methods we'll implement:

- `balance_of`
- `	transfer`
- `total_supply`
- `approve`
- `allowance`
- `transfer_from`
- `mint`

## Add new crate
One of the greatest benefits of writing smart contracts in Rust is that we can write a lot of code as a standalone library to later use for implementing smart contracts. 

Here we will implement the logic of the ERC20. To make it testable and easly usable in a smart contract, we will abstract all memory operations:

1. Generate a new `logic` crate

```
$ cargo new logic --lib
warning: compiling this new crate may not work due to invalid workspace configuration
```
Cargo reminds us to add `logic` to the current workspace, 

1. We'll modify `Cargo.toml` in the root directory:

```toml
# Cargo.toml

[workspace]

members = [
    "logic",
    "contract",
    "tests"
]
```
1. Run `logic` tests to see it work:

```bash
$ cargo test -p logic
```
1. Prepare `logic/Cargo.toml`:

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
The logic will be implemented as an `ERC20Trait` trait:
```rust
// logic/src/lib.rs

pub trait ERC20Trait<
    Amount: num_traits::Zero + Add<Output = Amount> + Sub<Output = Amount> + PartialOrd + Copy,
    Address,
>
{}
```
`Amount` and `Address` generics allows for flexibilty in types definitions on the implementation.

## Reads and Writes
1. Next, we add abstract functions which handle data saves and reads:

```rust
// logic/src/lib.rs

pub trait ERC20Trait<
    Amount: num_traits::Zero + Add<Output = Amount> + Sub<Output = Amount> + PartialOrd + Copy,
    Address,
>
{
    fn read_balance(&mut self, address: &Address) -> Option<Amount>;
    fn save_balance(&mut self, address: &Address, balance: Amount);
    fn read_total_supply(&mut self) -> Option<Amount>;
    fn save_total_supply(&mut self, total_supply: Amount);
    fn read_allowance(&mut self, owner: &Address, spender: &Address) -> Option<Amount>;
    fn save_allowance(&mut self, owner: &Address, spender: &Address, amount: Amount);
}
```

## Total Supply, Balance and Approval
1. We are now ready to define the first among the ERC20 methods including the implementation of `balance_of`, `total_supply` , and `allowance`,  all of which are read-only methods:

```rust
fn balance_of(&mut self, address: &Address) -> Amount {
    self.read_balance(address).unwrap_or_else(Amount::zero)
}

fn total_supply(&mut self) -> Amount {
    self.read_total_supply().unwrap_or_else(Amount::zero)
}

fn allowance(&mut self, owner: &Address, spender: &Address) -> Amount {
    self.read_allowance(owner, spender).unwrap_or_else(Amount::zero)
}
```

## Mint
1. Next,  we'll define what is called the `mint` method -- though not a part of ERC20 specification, it's present in almost every ERC20 implementation and responsable for incrementing the balance of tokens for the given `Address`. Addtionally, `mint`  should also update the total supply as well.

```rust
fn mint(&mut self, address: &Address, amount: Amount) {
    let address_balance = self.balance_of(address);
    let total_supply = self.total_supply();
    self.save_balance(&address, address_balance + amount);
    self.save_total_supply(total_supply + amount);
}
```

## Errors
Further implementation of `transfer` and `transfer_from` will be able to throw errors.

1. Let's define them in the separate file to be ready for later implementation:

```rust
// logic/src/errors.rs

#[derive(PartialEq, Debug)]
pub enum ERC20TransferError {
    NotEnoughBalance,
}

#[derive(PartialEq, Debug)]
pub enum ERC20TransferFromError {
    TransferError(ERC20TransferError),
    NotEnoughAllowance,
}

impl From<ERC20TransferError> for ERC20TransferFromError {
    fn from(error: ERC20TransferError) -> ERC20TransferFromError {
        ERC20TransferFromError::TransferError(error)
    }
}
```

## Transfer
1. Finally, we can implement the `transfer` method for transfering tokens from address to address. 

   If the `sender` address has enough balance, tokens should be transfered to the `recipient` address. Othewise, return the `ERC20TransferError::NotEnoughBalance` error:

```rust
fn transfer(
    &mut self,
    sender: &Address,
    recipient: &Address,
    amount: Amount,
) -> Result<(), ERC20TransferError> {
    let sender_balance = self.balance_of(sender);
    if amount > sender_balance {
        Err(ERC20TransferError::NotEnoughBalance)
    } else {
        let recipient_balance = self.balance_of(recipient);
        self.save_balance(&sender, sender_balance - amount);
        self.save_balance(&recipient, recipient_balance + amount);
        Ok(())
    }
}
```

## Approve and Transfer From
The last functions are `approve` and `transfer_from`. `approve` is used to allow other addressess to spend tokens in "my name":
```rust
fn approve(&mut self, owner: &Address, spender: &Address, amount: Amount) {
    self.save_allowance(owner, spender, amount)
}
```
`transfer_from` allows for spending approved tokens:

```rust
fn transfer_from(
    &mut self,
    spender: &Address,
    owner: &Address,
    recipient: &Address,
    amount: Amount,
) -> Result<(), ERC20TransferFromError> {
    let allowance = self.allowance(owner, spender);
    if amount > allowance {
        return Err(ERC20TransferFromError::NotEnoughAllowance);
    }
    self.transfer(owner, recipient, amount)?;
    self.approve(owner, spender, allowance - amount);
    Ok(())
}
```
Note: internaly this uses the  `transfer` function. If a transfer fails, the `ERC20TransferError` is automatialy converted to `ERC20TransferFromError`, that's to `impl From<ERC20TransferError> for ERC20TransferFromError` implmentation in `logic/src/error.rs`.

## Example Implementation
```rust
// logic/src/lib.rs

pub mod errors;

use std::ops::{Add, Sub};

pub use errors::{ERC20TransferError, ERC20TransferFromError};

pub trait ERC20Trait<
    Amount: num_traits::Zero + Add<Output = Amount> + Sub<Output = Amount> + PartialOrd + Copy,
    Address,
>
{
    fn read_balance(&mut self, address: &Address) -> Option<Amount>;
    fn save_balance(&mut self, address: &Address, balance: Amount);
    fn read_total_supply(&mut self) -> Option<Amount>;
    fn save_total_supply(&mut self, total_supply: Amount);
    fn read_allowance(&mut self, owner: &Address, spender: &Address) -> Option<Amount>;
    fn save_allowance(&mut self, owner: &Address, spender: &Address, amount: Amount);

    fn mint(&mut self, address: &Address, amount: Amount) {
        let address_balance = self.balance_of(address);
        let total_supply = self.total_supply();
        self.save_balance(&address, address_balance + amount);
        self.save_total_supply(total_supply + amount);
    }

    fn transfer(
        &mut self,
        sender: &Address,
        recipient: &Address,
        amount: Amount,
    ) -> Result<(), ERC20TransferError> {
        let sender_balance = self.balance_of(sender);
        if amount > sender_balance {
            Err(ERC20TransferError::NotEnoughBalance)
        } else {
            let recipient_balance = self.balance_of(recipient);
            self.save_balance(&sender, sender_balance - amount);
            self.save_balance(&recipient, recipient_balance + amount);
            Ok(())
        }
    }

    fn balance_of(&mut self, address: &Address) -> Amount {
        self.read_balance(address).unwrap_or_else(Amount::zero)
    }

    fn total_supply(&mut self) -> Amount {
        self.read_total_supply().unwrap_or_else(Amount::zero)
    }

    fn allowance(&mut self, owner: &Address, spender: &Address) -> Amount {
        self.read_allowance(owner, spender)
            .unwrap_or_else(Amount::zero)
    }

    fn approve(&mut self, owner: &Address, spender: &Address, amount: Amount) {
        self.save_allowance(owner, spender, amount)
    }

    fn transfer_from(
        &mut self,
        spender: &Address,
        owner: &Address,
        recipient: &Address,
        amount: Amount,
    ) -> Result<(), ERC20TransferFromError> {
        let allowance = self.allowance(owner, spender);
        if amount > allowance {
            return Err(ERC20TransferFromError::NotEnoughAllowance);
        }
        self.transfer(owner, recipient, amount)?;
        self.approve(owner, spender, allowance - amount);
        Ok(())
    }
}
```

```rust
// logic/src/error.rs

#[derive(PartialEq, Debug)]
pub enum ERC20TransferError {
    NotEnoughBalance,
}

#[derive(PartialEq, Debug)]
pub enum ERC20TransferFromError {
    TransferError(ERC20TransferError),
    NotEnoughAllowance,
}

impl From<ERC20TransferError> for ERC20TransferFromError {
    fn from(error: ERC20TransferError) -> ERC20TransferFromError {
        ERC20TransferFromError::TransferError(error)
    }
}
```
