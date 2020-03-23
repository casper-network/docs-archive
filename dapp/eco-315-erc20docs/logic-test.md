Logic Tests
===========
Included is a guided step-by-step set of examples we can follow to test the [ERC20 logic](logic.html).

Test Module
-----------
1. Add a new crate file for tests at `logic/src/tests.rs` and include this module at the top of `logic/src/lib.rs` by adding the  `tests` module for use when testing:

```rust
#[cfg(test)]
mod tests;
```
1. Write a simple test to verify that it works:

```rust
// logic/src/tests.rs

#[test]
fn my_test() {
    assert_eq!(1, 1);
}
```
1. Run the example:

```bash
$ cargo test -p logic

running 1 test
test tests::my_test ... ok
```

Test Token Implementation
-------------------------
Testing traits requires implementing it first. 

1. Let's create a test token implemention:

```rust
use std::collections::HashMap;

type Amount = u64;
type Address = u8;
type AddressPair = (Address, Address);

struct Token {
    total_supply_count: Amount,
    balances: HashMap<Address, Amount>,
    allowance: HashMap<AddressPair, Amount>,
}

impl Token {
    fn new() -> Token {
        Token {
            total_supply_count: 0,
            balances: HashMap::new(),
            allowance: HashMap::new(),
        }
    }
}
```
`Token` struct can store all the data ERC20 requires so that it's possible to implement `ERC20Trait` on top of it.

```rust
impl ERC20Trait<Amount, Address> for Token {
    fn read_balance(&mut self, address: &Address) -> Option<Amount> {
        self.balances.get(address).cloned()
    }

    fn save_balance(&mut self, address: &Address, balance: Amount) {
        self.balances.insert(*address, balance);
    }

    fn read_total_supply(&mut self) -> Option<Amount> {
        Some(self.total_supply_count)
    }

    fn save_total_supply(&mut self, new_total_supply: Amount) {
        self.total_supply_count = new_total_supply;
    }

    fn read_allowance(&mut self, owner: &Address, spender: &Address) -> Option<Amount> {
        self.allowance.get(&(*owner, *spender)).cloned()
    }

    fn save_allowance(&mut self, owner: &Address, spender: &Address, amount: Amount) {
        self.allowance.insert((*owner, *spender), amount);
    }
}
```

Unit Tests
----------
All ERC20 operations are account-based -- it's recommended to have a few accounts defined in advance:
```rust
const ADDRESS_1: Address = 1;
const ADDRESS_2: Address = 2;
const ADDRESS_3: Address = 3;
```
The testing `transfer` function should look like this:
```rust
#[test]
fn test_transfer() {
    let mut token = Token::new();
    token.mint(&ADDRESS_1, 10);
    let transfer_result = token.transfer(&ADDRESS_1, &ADDRESS_2, 3);
    assert!(transfer_result.is_ok());
    assert_eq!(token.balance_of(&ADDRESS_1), 7);
    assert_eq!(token.balance_of(&ADDRESS_2), 3);
    assert_eq!(token.total_supply(), 10);
}
```
For further information, you can read about additional tests located in the [CasperLabs/erc20](https://github.com/CasperLabs/erc20) repository on Github.

TODO: Give a link to existing file.