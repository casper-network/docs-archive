### Getting Started with the DSL

Since the DSL uses macros, it works like templates in the smart contract, so it's necessary to tell the Rust compiler where the macros are located for each smart contract.
The aim of this guide is to describe how to configure the smart contract to use the DSL.

#### Pre-Requisites - Set up the Rust SDK
Please use the Rust SDK to [create your smart contract project](/dapp-dev-guide/setup-of-rust-contract-sdk.md#setting-up-the-rust-contract-sdk) before setting up the DSL.


#### Getting the Macros

The macros are located on [GitHub](https://github.com/CasperLabs/casperlabs_contract_macro).
The macros are also shipped as a crate on crates.io

To import the macros, include the following line in the `Cargo.toml` file in the `/contract` folder for your smart contract.  The entry needs to appear in the
`[dependencies]` section.  This example points directly to Github:

```
`contract_macro = { git = "https://github.com/CasperLabs/casperlabs_contract_macro", branch = "in_progress", package = "contract_macro"} `

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
