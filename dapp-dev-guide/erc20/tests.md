# Smart Contract Tests

In this section we'll use the [CasperLabs Engine Test Support](https://crates.io/crates/casperlabs-engine-test-support) crate to test the ERC-20 smart contract against the execution environment that is equivalent to what CasperLabs uses in production.  Here we will create 2 files that will set up the testing framework for the ERC20 contract.  

The following is an example of a finished test.
```rust
#[test]
fn test_erc20_transfer() {
    let amount = 10;
    let mut token = ERC20Contract::deployed();
    token.transfer(BOB, amount, Sender(ALI));
    assert_eq!(token.balance_of(ALI), ERC20_INIT_BALANCE - amount);
    assert_eq!(token.balance_of(BOB), amount);
}
```
Remove `tests/src/integration_tests.rs` and create three files:
* `tests/src/erc20.rs` - sets up testing context and creates helper functions used by unit tests 
* `tests/src/tests.rs` - contains the unit tests
* `tests/src/lib.rs` - required by rust toolchain.  Links the other 2 files together

The `tests` crate has a `build.rs` file: effectively a custom build script. It's executed every time before running tests and it compiles `contract` crate in release mode for your convenience and copies the `contract.wasm` file to `tests/wasm` directory. In practice, that means we only need to run `cargo test -p tests` during the development.

## Set up Cargo.toml
Define a `tests` package at `tests/Cargo.toml`.
```toml
[package]
name = "tests"
version = "0.1.1"
authors = ["Your Name here <your email here>"]
edition = "2020"

[dependencies]
casperlabs-contract = "0.6.1"
casperlabs-types = "0.6.1"
casperlabs-engine-test-support = "0.8.1"

[features]
default = ["casperlabs-contract/std", "casperlabs-types/std"]
```

## Create ERC20.rs Logic for Testing

### Set Up the Testing Context
Start with defining constants like method names, key names and account addresses that will be reused across tests. 
This initializes the global state with all the data and methods that the smart contract needs in order to run properly.

```rust
// tests/src/erc20.rs

pub mod account {
    use super::PublicKey;
    pub const ALI: PublicKey = PublicKey::ed25519_from([1u8; 32]);
    pub const BOB: PublicKey = PublicKey::ed25519_from([2u8; 32]);
    pub const JOE: PublicKey = PublicKey::ed25519_from([3u8; 32]);
}

pub mod token_cfg {
    use super::*;
    pub const NAME: &str = "ERC20";
    pub const SYMBOL: &str = "STX";
    pub const DECIMALS: u8 = 18;
    pub fn total_supply() -> U256 { 1_000.into() } 
}

pub struct Sender(pub AccountHash);

pub struct Token {
    context: TestContext
}
```

### Deploying the Contract
The next step is to define the `ERC20Contract` struct that has its' own VM instance and implements ERC-20 methods.
This struct should hold a `TestContext` of its own. The token contract hash and the erc20_indirect session code 
hash won’t change after the contract is deployed, so it’s handy to have it available. This code snippet builds 
the context and includes the compiled `contract.wasm` binary that is being tested. This function creates new 
instance of `ERC20Contract` with `ALI`, `BOB` and `JOE` having positive initial balance. 
The contract is deployed using the `ALI` account.


```rust
// tests/src/erc20.rs

// the contract struct
pub struct Token {
    context: TestContext
}

impl Token {

    pub fn deployed() -> Token {
    
        // Builds test context with Alice & Bob's accounts
        let mut context = TestContextBuilder::new()
            .with_account(account::ALI, U512::from(128_000_000))
            .with_account(account::BOB, U512::from(128_000_000))
            .build();
            
        // Adds compiled contract to the context with arguments specified above.
        // For this example it is 'ERC20' & 'STX'    
        let session_code = Code::from("contract.wasm");
        let session_args = runtime_args! {
            "tokenName" => token_cfg::NAME,
            "tokenSymbol" => token_cfg::SYMBOL,
            "tokenTotalSupply" => token_cfg::total_supply()
        };

        // Builds the session with the code and arguments 
        let session = SessionBuilder::new(session_code, session_args)
            .with_address(account::ALI)
            .with_authorization_keys(&[account::ALI])
            .build();
            
        //Runs the code
        context.run(session);
        Token { context }
    }
```

### Querying the System
The above step has simulated a real deploy on the network. This code snippet describes 
how to query for the hash of the contract. Contracts are deployed under the context of an account. 
Since the deployment was created under thhe context of `account::ALI`, this is what is queried here. 
The `query_contract` function uses `query` to lookup named keys. It will be used to implement `balance_of`, 
`total_supply` and `allowance` checks.

```rust
    fn contract_hash(&self) -> Hash {
        self.context
            .query(account::ALI, &[format!("{}_hash", token_cfg::NAME)])
            .unwrap_or_else(|_| panic!("{} contract not found", token_cfg::NAME))
            .into_t()
            .unwrap_or_else(|_| panic!("{} has wrong type", token_cfg::NAME))
    }

    // This function is a generic helper function that queries for a named key defined in the contract.
    fn query_contract<T: CLTyped + FromBytes>(&self, name: &str) -> Option<T> {
        match self.context.query(
            account::ALI,
            &[token_cfg::NAME, &name.to_string()],
        ) {
            Err(_) => None,
            Ok(maybe_value) => {
                let value = maybe_value
                    .into_t()
                    .unwrap_or_else(|_| panic!("{} is not expected type.", name));
                Some(value)
            }
        }
    }

    // Here we call the helper function to query on specific named keys defined in the contract.
 
    // Returns the name of the token
    pub fn name(&self) -> String {
        self.query_contract("_name").unwrap()
    }

    // Returns the token symbol
    pub fn symbol(&self) -> String {
        self.query_contract("_symbol").unwrap()
    }

    // Returns the number of decimal places for the token
    pub fn decimals(&self) -> u8 {
        self.query_contract("_decimals").unwrap()
    }
```

### Invoking methods in the Contract
This code snippet describes a generic way to call a specific entry point in the contract. 

```rust
    fn call(&mut self, sender: Sender, method: &str, args: RuntimeArgs) {
        let Sender(address) = sender;
        let code = Code::Hash(self.contract_hash(), method.to_string());
        let session = SessionBuilder::new(code, args)
            .with_address(address)
            .with_authorization_keys(&[address])
            .build();
        self.context.run(session);
    }
```

### Invoke each of the getter methods in the Contract.

```rust
    pub fn balance_of(&self, account: AccountHash) -> U256 {
        let key = format!("_balances_{}", account);
        self.query_contract(&key).unwrap_or_default()
    }

    pub fn allowance(&self, owner: AccountHash, spender: AccountHash) -> U256 {
        let key = format!("_allowances_{}_{}", owner, spender);
        self.query_contract(&key).unwrap_or_default()
    }

    pub fn transfer(&mut self, recipient: AccountHash, amount: U256, sender: Sender) {
        self.call(sender, "transfer", runtime_args! {
            "recipient" => recipient,
            "amount" => amount
        });
    }

    pub fn approve(&mut self, spender: AccountHash, amount: U256, sender: Sender) {
        self.call(sender, "approve", runtime_args! {
            "spender" => spender,
            "amount" => amount
        });
    }
    
    pub fn transfer_from(&mut self, owner: AccountHash, recipient: AccountHash, amount: U256, sender: Sender) {
        self.call(sender, "transferFrom", runtime_args! {
            "owner" => owner,
            "recipient" => recipient,
            "amount" => amount
        });
    }
}
```

## Create tests.rs File with Units

### Unit Tests
Now that we have a testing context, we can use this context and create unit tests that test 
the contract code by invoking the functions defined in  `tests/src/erc20.rs`.
Add these functions to `tests/src/tests.rs`.

```rust
// tests/src/tests.rs

use crate::erc20::{Token, Sender, account::{ALI, BOB, JOE}, token_cfg};

#[test]
fn test_erc20_deploy() {
    let token = Token::deployed();
    assert_eq!(token.name(), token_cfg::NAME);
    assert_eq!(token.symbol(), token_cfg::SYMBOL);
    assert_eq!(token.decimals(), token_cfg::DECIMALS);
    assert_eq!(token.balance_of(ALI), token_cfg::total_supply());
    assert_eq!(token.balance_of(BOB), 0.into());
    assert_eq!(token.allowance(ALI, ALI), 0.into());
    assert_eq!(token.allowance(ALI, BOB), 0.into());
    assert_eq!(token.allowance(BOB, ALI), 0.into());
    assert_eq!(token.allowance(BOB, BOB), 0.into());
}

#[test]
fn test_erc20_transfer() {
    let amount = 10.into();
    let mut token = Token::deployed();
    token.transfer(BOB, amount, Sender(ALI));
    assert_eq!(token.balance_of(ALI), token_cfg::total_supply() - amount);
    assert_eq!(token.balance_of(BOB), amount);
}

#[test]
#[should_panic]
fn test_erc20_transfer_too_much() {
    let amount = 1.into();
    let mut token = Token::deployed();
    token.transfer(ALI, amount, Sender(BOB));
}

#[test]
fn test_erc20_approve() {
    let amount = 10.into();
    let mut token = Token::deployed();
    token.approve(BOB, amount, Sender(ALI));
    assert_eq!(token.balance_of(ALI), token_cfg::total_supply());
    assert_eq!(token.balance_of(BOB), 0.into());
    assert_eq!(token.allowance(ALI, BOB), amount);
    assert_eq!(token.allowance(BOB, ALI), 0.into());
}

#[test]
fn test_erc20_transfer_from() {
    let allowance = 10.into();
    let amount = 3.into();
    let mut token = Token::deployed();
    token.approve(BOB, allowance, Sender(ALI));
    token.transfer_from(ALI, JOE, amount, Sender(BOB));
    assert_eq!(token.balance_of(ALI), token_cfg::total_supply() - amount);
    assert_eq!(token.balance_of(BOB), 0.into());
    assert_eq!(token.balance_of(JOE), amount);
    assert_eq!(token.allowance(ALI, BOB), allowance - amount);
}

#[test]
#[should_panic]
fn test_erc20_transfer_from_too_much() {
    let amount = token_cfg::total_supply().checked_add(1.into()).unwrap();
    let mut token = Token::deployed();
    token.transfer_from(ALI, JOE, amount, Sender(BOB));
}
```

## Configure lib.rs to run everything via cargo
Within the `tests/src/lib.rs` file, add the following lines.
This tells cargo which files to use when running the tests.

```rust
#[cfg(test)]
pub mod tests;
#[cfg(test)]
pub mod erc20;
```

## Run the Tests!
Run tests to verify they work. This is run via `bash`.
```bash
$ cargo test -p tests
```
