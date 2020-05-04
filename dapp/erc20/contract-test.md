# Smart Contract Tests

In this section we'll use the [CasperLabs Engine Test Support](https://crates.io/crates/casperlabs-engine-test-support) crate to test the ERC-20 smart contract against the execution environment that is equivalent to what CasperLabs uses in production.

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
Remove `tests/src/integration_tests.rs` and create two files `tests/src/lib.rs` and `tests/src/erc20.rs`.

The `tests` crate has a `build.rs` file: effectively a custom build script. It's executed every time before running tests and it compiles `contract` crate in release mode for your convenience and copies the `contract.wasm` file to `tests/wasm` directory. In practice, that means we only need to run `cargo test -p tests` during the development.

## Cargo.toml
Define a `tests` package at `tests/Cargo.toml`.
```toml
[package]
name = "tests"
version = "0.1.1"
authors = ["Maciej Zieliński <maciej@casperlabs.io>"]
edition = "2018"

[dependencies]
casperlabs-contract = "0.4.0"
casperlabs-types = "0.4.0"
casperlabs-engine-test-support = "0.5.0"

[features]
default = ["casperlabs-contract/std", "casperlabs-types/std"]
```

## Testing Context
Start with defining constants like method names, key names and account addresses we'll reuse across tests.
```rust
// tests/src/erc20.rs

const ERC20_WASM: &str = "contract.wasm";
pub const ERC20_INIT_BALANCE: u64 = 10000;

pub mod account {
    use super::PublicKey;
    pub const ALI: PublicKey = PublicKey::ed25519_from([1u8; 32]);
    pub const BOB: PublicKey = PublicKey::ed25519_from([2u8; 32]);
    pub const JOE: PublicKey = PublicKey::ed25519_from([3u8; 32]);
}

mod method {
    pub const DEPLOY: &str = "deploy";
    pub const TRANSFER: &str = "transfer";
    pub const TRANSFER_FROM: &str = "transfer_from";
    pub const APPROVE: &str = "approve";
}

mod key {
    pub const ERC20_INDIRECT: &str = "erc20_indirect";
    pub const ERC20: &str = "erc20";
    pub const TOTAL_SUPPLY: &str = "total_supply";
}
```
To clearly mark the address sending the transaction, introduce `Sender` wrapper.
```rust
// tests/src/erc20.rs

pub struct Sender(pub PublicKey);
```

We'll define `ERC20Contract` struct that has its own VM instance and implements ERC-20 methods. `ERC20Contract` struct should hold a [TestContext](https://docs.rs/casperlabs-engine-test-support/latest/casperlabs_engine_test_support/struct.TestContext.html) of its own. The `erc20` token contract hash and the `erc20_indirect` session code hash won't change after the contract is deployed, so it's handy to have it available.
```rust
// tests/src/erc20.rs

pub struct ERC20Contract {
    pub context: TestContext,
    pub token_hash: Hash,
    pub indirect_hash: Hash,
}

impl ERC20Contract {
    pub fn deployed() -> Self {
        // Init context.
        let clx_init_balance = U512::from(10_000_000_000u64);
        let mut context = TestContextBuilder::new()
            .with_account(account::ALI, clx_init_balance)
            .with_account(account::BOB, clx_init_balance)
            .with_account(account::JOE, clx_init_balance)
            .build();
        // Deploy contract.
        let code = Code::from(ERC20_WASM);
        let args = (method::DEPLOY, U512::from(ERC20_INIT_BALANCE));
        let session = SessionBuilder::new(code, args)
            .with_address(account::ALI)
            .with_authorization_keys(&[account::ALI])
            .build();
        context.run(session);
        // Read hashes.
        let token_hash = Self::contract_hash(&context, key::ERC20);
        let indirect_hash = Self::contract_hash(&context, key::ERC20_INDIRECT);
        Self {
            context,
            token_hash,
            indirect_hash,
        }
    }

    fn contract_hash(context: &TestContext, name: &str) -> Hash {
        let contract_ref: Key = context
            .query(account::ALI, &[name])
            .unwrap_or_else(|_| panic!("{} contract not found.", name))
            .into_t()
            .unwrap_or_else(|_| panic!("{} is not a type Contract.", name));
        contract_ref
            .into_hash()
            .unwrap_or_else(|| panic!("{} is not a type Hash.", name))
    }

    fn call_indirect(&mut self, sender: Sender, args: impl ArgsParser) {
        let Sender(address) = sender;
        let code = Code::Hash(self.indirect_hash);
        let session = SessionBuilder::new(code, args)
            .with_address(address)
            .with_authorization_keys(&[address])
            .build();
        self.context.run(session);
    }

    fn query_contract<T: CLTyped + FromBytes>(&self, name: String) -> Option<T> {
        match self.context.query(account::ALI, &[key::ERC20, &name]) {
            Err(_) => None,
            Ok(maybe_value) => {
                let value = maybe_value
                    .into_t()
                    .unwrap_or_else(|_| panic!("{} is not expected type.", name));
                Some(value)
            }
        }
    }
}
```
`deployed` function creates new instance of `ERC20Contract` with `ALI`, `BOB` and `JOE` having positive initial balance. The contract is deployed using `ALI` account. 

`call_indirect` function uses [run](https://docs.rs/casperlabs-engine-test-support/latest/casperlabs_engine_test_support/struct.TestContext.html#method.run) function to call the contract deployed under `self.indirect_hash`. It will be used to implement `transfer`, `approve` and `transfer_from` calls.

`query_contract` function uses [query](https://docs.rs/casperlabs-engine-test-support/latest/casperlabs_engine_test_support/struct.TestContext.html#method.query) to lookup named keys of the `erc20` contract stored under `self.token_hash`. It will be used to implement `balance_of`, `total_supply` and `allowance` checks.

## Transfer, Approve, Transfer From
Now it's easy to define methods that are needed to make a deploy.
```rust
// tests/src/erc20.rs

pub fn transfer(&mut self, receiver: PublicKey, amount: u64, sender: Sender) {
    self.call_indirect(
        sender,
        (
            (method::TRANSFER, self.token_hash),
            receiver,
            U512::from(amount),
        ),
    )
}

pub fn approve(&mut self, spender: PublicKey, amount: u64, sender: Sender) {
    self.call_indirect(
        sender,
        (
            (method::APPROVE, self.token_hash),
            spender,
            U512::from(amount),
        ),
    )
}

pub fn transfer_from(
    &mut self,
    owner: PublicKey,
    receiver: PublicKey,
    amount: u64,
    sender: Sender,
) {
    self.call_indirect(
        sender,
        (
            (method::TRANSFER_FROM, self.token_hash),
            owner,
            receiver,
            U512::from(amount),
        ),
    )
}
```

## Balance Of, Total Supply, Allowance
It's also easy to define reader functions. Note that, for `balance_of` and `allowance` if the record is not present, it means it's equal to zero.
```rust
// tests/src/erc20.rs

pub fn balance_of(&self, account: PublicKey) -> u64 {
    let balance: Option<U512> = self.query_contract(account.to_string());
    balance.unwrap_or_else(U512::zero).as_u64()
}

pub fn allowance(&self, owner: PublicKey, spender: PublicKey) -> u64 {
    let allowance: Option<U512> = self.query_contract(format!("{}{}", owner, spender));
    allowance.unwrap_or_else(U512::zero).as_u64()
}

pub fn total_supply(&self) -> u64 {
    let balance: Option<U512> = self.query_contract(key::TOTAL_SUPPLY.to_string());
    balance.unwrap().as_u64()
}
```

## Unit Tests
Include `tests/src/erc20.rs` in `tests/src/lib.rs` and start writing tests.
```rust
// tests/src/lib.rs

[cfg(test)]
mod erc20;

#[cfg(test)]
mod tests {
    use super::erc20;
    use erc20::{
        account::{ALI, BOB, JOE},
        ERC20Contract, Sender, ERC20_INIT_BALANCE,
    };

    #[test]
    fn test_erc20_deploy() {
        let token = ERC20Contract::deployed();
        assert_eq!(token.balance_of(ALI), ERC20_INIT_BALANCE);
        assert_eq!(token.balance_of(BOB), 0);
        assert_eq!(token.total_supply(), ERC20_INIT_BALANCE);
    }

    #[test]
    fn test_erc20_transfer() {
        let amount = 10;
        let mut token = ERC20Contract::deployed();
        token.transfer(BOB, amount, Sender(ALI));
        assert_eq!(token.balance_of(ALI), ERC20_INIT_BALANCE - amount);
        assert_eq!(token.balance_of(BOB), amount);
    }

    #[test]
    fn test_erc20_approve() {
        let amount = 10;
        let mut token = ERC20Contract::deployed();
        token.approve(BOB, amount, Sender(ALI));
        assert_eq!(token.balance_of(ALI), ERC20_INIT_BALANCE);
        assert_eq!(token.balance_of(BOB), 0);
        assert_eq!(token.allowance(ALI, BOB), amount);
        assert_eq!(token.allowance(BOB, ALI), 0);
    }

    #[test]
    fn test_erc20_transfer_from() {
        let allowance = 10;
        let amount = 3;
        let mut token = ERC20Contract::deployed();
        token.approve(BOB, allowance, Sender(ALI));
        token.transfer_from(ALI, JOE, amount, Sender(BOB));
        assert_eq!(token.balance_of(ALI), ERC20_INIT_BALANCE - amount);
        assert_eq!(token.balance_of(BOB), 0);
        assert_eq!(token.balance_of(JOE), amount);
        assert_eq!(token.allowance(ALI, BOB), allowance - amount);
    }
}
```
Run tests to verify they work.
```bash
$ cargo test -p tests
```
