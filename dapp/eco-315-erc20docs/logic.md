Logic
=====

Here we present the organization of the functional components we implement with the ERC20 standard including examples on how the contract logic is set up and interacts following these methods:

- `balance_of`
- `transfer`
- `total_supply`
- `approve`
- `allowance`
- `transfer_from`
- `mint`

**ERC-20 Standard**
The [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#) provides for the definition of the above mentioned methods we'll be implementing in the following steps:


Add a new crate
-------------
One of the main benefits of developing smart contracts in Rust is having the capability to write a lot of code which then can serve as a library for implementing smart contracts.

Here we will implement the logic of the ERC20 abstracting memory operations to render it fitting and testable for a smart contract as follows:

1. First, generate a new `logic` crate

```bash
$ cargo new logic --lib
warning: compiling this new crate may not work due to invalid workspace configuration
```
Note that Cargo provides us a reminder to add `logic` to the current workspace,

1. We'll modify `Cargo.toml` configuration file in the root directory adding the "logic" crate to the workspace:

```toml
# Cargo.toml

[workspace]

members = [
    "logic",
    "contract",
    "tests"
]
```
1. Now, we can run `logic` tests and to see how it works:

```bash
$ cargo test -p logic
```
1. Next, we prepare the configuration, `logic/Cargo.toml`:

```toml
# logic/Cargo.toml

[package]
name = "logic"
version = "0.1.0"
authors = ["Author <author@casperlabs.io>"]
edition = "2018"

[lib]
name = "logic"
doctest = false
bench = false

[dependencies]
num-traits = { version = "0.2.10", default-features = false }
```

ERC20Trait
----------

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

Reads and Writes
----------------

1. Next, we'll add abstract functions for handling data saves and reads:

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

Total Supply, Balance and Approval
----------------------------------

1. Now that we have completed our setup, we will define the first among the ERC20 methods -- `balance_of`, `total_supply` , and `allowance` (all read-only methods):

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

Mint
----

1. Next, we'll define the `mint` method -- though not a part of ERC20 specification, it's present in almost every one of our ERC20 implementations for incrementing the balance of tokens for a given `Address`. Additionally, `mint` also updates the total as well.

```rust
fn mint(&mut self, address: &Address, amount: Amount) {
    let address_balance = self.balance_of(address);
    let total_supply = self.total_supply();
    self.save_balance(&address, address_balance + amount);
    self.save_total_supply(total_supply + amount);
}
```

Errors
------
Implementation of `transfer` and `transfer_from` will be able to throw errors.

1. Here, we'll define these errors in a separate file. We can then use this further on in our implementation(s):

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

Transfer
--------

1. Finally, we can implement the `transfer` method for transferring tokens from one address to another.

For example, if a `sender` address has enough balance, tokens may be transfered to a `recipient` address. Otherwise, a `ERC20TransferError::NotEnoughBalance` error is returned:

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

Approve and Transfer From
-------------------------

 The `approve` function is used to allow other addresses to spend tokens in "my name":

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
Note: internally this uses the  `transfer` function. However, if a transfer fails, the `ERC20TransferError` is automatically converted to `ERC20TransferFromError`; to `impl From<ERC20TransferError> for ERC20TransferFromError` implementation in `logic/src/error.rs`.


Example of Complete CasperLabs ERC20
---------------------------------------------------------

This example is a complete implementation of our ERC20 logic including all the methods covered in the previous steps, e.g. balances, allocating allowances, and transferring funds, etc. followed by the associated error logic.

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
