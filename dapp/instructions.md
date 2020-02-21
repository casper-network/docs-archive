Getting started instructions
============================

### Pre-requisites 

- Using our [CasperLabs  binaries](https://github.com/CasperLabs/CasperLabs/releases) you can build your contracts to deploy to the CasperLabs Network or network of your choice

- [Building from source](https://github.com/CasperLabs/CasperLabs/tree/dev/comm#build-from-the-source) you can build your contracts for:
  - deploying to the CasperLabs Network or network of your choice
  - customization, versioning, optimization of compiling process
  - making your code visible on the blockchain for full transparency

## Instructions
- Install [rustup](https://rustup.rs/)
- Install the [Casperlabs client]() (`WASM`, `Python`)
- [Cargo CasperLabs](https://crates.io/) -- "Cargo is the build tool for Rust. It bundles all common actions into a single command. No boilerplate required."
- [SBT](https://www.scala-sbt.org/index.html)
  "The interactive Scala build tool where you can define your tasks in Scala and run them in parallel from sbt's interactive shell.



Using the CasperLabs runtime environment
----------------------------------------

Step 1 - Install Cargo CasperLabs

`cargo install cargo-casperlabs`

Step 2 - Create your project "my_project"

`cargo casperlabs my_project`

Step 3 - Set up your Rust environment for building

```shell
cd my_project/contract
rustup install $(cat rust-toolchain)
rustup target add --toolchain=$(cat rust-toolchain) wasm32-unknown-unknown
```

Step 4 - Build your project 

`cargo build --release`

Step 5 - A test framework is set up for you so you can Run tests by:

```
cd my_project/tests
cargo test
```





1. Install the CasperLabs Rust Tool Chain
2. Clone the [repository](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine)
3. Check your Pre-requisites
4. Navigate to the directory where you will find:
  - system (Genesis) contracts - to bond to the network
  - Example contracts - smart contract examples
    - ERC20 example,
    - Vesting,
    - Tic Tac toe
  - Integration tests - to test and debug smart contract examples


Selecting an IDE
----------------

Choose an IDE that has Rust support. We recommended you choose an application which enables you to more easily both write and debug your contracts. You can find Rust recommended tools [here](https://www.rust-lang.org/tools)

1. Select a tool for your platform and install
1. Setup your environment with extensions as need with:
   1. rust
   1. rust language tools


Opening the project
-------------------

1. Clone the repository following the [README.md](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/cargo-casperlabs/README.md) with a description of the contents and structure of how it is organized.

1. Once you clone the [repository](...) follow the [installation](...) process.

<!--https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine-->

1. Check your Pre-requisites so that the following is installed and that you have the correct version of the following:
   - Java VM
   - Rustup
     - Rust
     - Cargo
     - rust tool chain
   - WASM
   - Python
   - Scala
   - JavaScript
   - Assembly Script

1. Open the CasperLabs project in your IDE, you will find the following contents in the directory structure:

    - The main CasperLabs project directory contains configuration files, build and compiler tools, and source code library to build and test your contracts.
    - [contracts](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/cargo-casperlabs/README.md#usage)
    - [tests ](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/173539561/Test+Framework+and+Project+Scaffolding+tool) directory containing two Cargo crates:
        - one for contract
        - one for tests
          - build and compile
            - system contracts (WASM)

Note that the Contract and test code are templated as `contract.rs`
<!--Key advantage here is that we can put a-->
and the `.cargo/config` file located in the contract crate specifies the build target.

### Dependencies

Note that the test crate depends on the contract crate.
<!--Some experimentation is warranted -->
You can use `build.rs file` to automate builds


Use the CasperLabs runtime environment
---------------------------------------------
The runtime environment consists of:


Writing Contracts
-----------------
You can build contracts from scratch or use our example smart contracts:

- ERC20
- Tokens -- distributing tokens
- Payment processing
- Receiving payments
- Vesting Contracts
<!--- Auctions -->
<!--- Voting-->
- Games
  - Tic Tac Toe
<!--- Other -- Category-->
<!--  - Specialized commerce apps-->
<!--  - Distributed versions (e.g. ride sharing)-->
<!--  - Supply chain management-->


## Using Rust

All our crates are published on [crates.io](https://crates.io/search?q=casperlabs)

[GITHub Source](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/contract-ffi/src/lib.rs)

- [Types](https://docs.rs/casperlabs-types)
- Casperlabs [Contract API](https://docs.rs/casperlabs-contract)
- Casperlabs [Test Support](https://docs.rs/casperlabs-engine-test-support)

We also have a [cargo-casperlabs CLI tool](https://crates.io/crates/cargo-casperlabs) also accessed cargo-casperlabs CLI tool source in GIT [here](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)

These links have equivalent information - including a README.md from the crate's root.

Access the list of annotated Contract exit codes with details [here](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)


Deploying and Testing contracts to the DevNet
---------------------------------------------

### Deploy

For instructions on Deploying Contracts see [DEVNET](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code)

Also see [CONTRACT](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md)


### Test

For instructions on Testing your Contracts See [Execution Engine Test Framework](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs)

In your project you will find tests to build, deploy, and debug your contracts:

- Cargo.toml - for the purposes of
- [Cl_test_..py](...) - test the CasperLabs scala client
- [Cl_test_..py](...) - test the CasperLabs python client
- [Makefile.toml](...) - to build the contract
- [README.md](...) --
- [rust-toolchain](...) - to build and deploy your test contracts


Execution error codes
---------------------

Error Types
- [System Contract Errors](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/types/src/system_contract_errors)
- smart contract errors
- [Pos and Mint Errors](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/types/src/api_error.rs) (PoS, Mint errors,...)
- [Contract API FFI] [Errors] (...)

You can find a dynamically generated list with descriptions of each error code in our Rust and source documentation respectively [here](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)

<!--see [Short Description of Fraser's Implementation](...)-->
<!--see [Enum Contract FFI Error Enum](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html)-->
<!--see Source of the [Contract_API error ](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)-->

