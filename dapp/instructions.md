Getting Started
===============

The following provides a step-by-step set of examples including basic and advanced features to develop, build, and test contracts using the CasperLabs development tools available in our development envrironment for: 

- Rust
- Assembly Scrip the following set of documentation is presented in order and provides instructions on Linux and OSx for developing, building, testing, and executing Smart contracts to address your use case

Prior knowledge about Rust and/or Assembly script is assumed.

##  3 Easy Steps to start developing contracts in
Step 1 - Install the CasperLabs Rust Tool Chain
Step 2 - Clone the [repository](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine)
Step 3 -  Navigate to the directory where you will find:
  - system (Genesis) contracts - to bond to the network
  - example contracts - smart contract templates
    - ERC20 -
    - Vesting -
    - Tic Tac toe -
  - Tests - to test and debug smart contract examples


### Pre-requisites

- Using our [CasperLabs  binaries](https://github.com/CasperLabs/CasperLabs/releases) you can develop and build your contracts to deploy to the CasperLabs Network or network of your choice

- [Building from source](https://github.com/CasperLabs/CasperLabs/tree/dev/comm#build-from-the-source) you can develop and build your contracts for:
  - deploying to the CasperLabs Network or network of your choice
  - customization, versioning, optimization of compiling process
  - making your code visible on the blockchain for full transparency

## Instructions

### Installing the CasperLabs toolchain
- Install [rustup](https://rustup.rs/)
- Install the [Casperlabs client](INSTALL.md) (Scala or Python)
- [Cargo CasperLabs](https://crates.io/) -- Cargo is the build tool for Rust. It bundles all common actions into a single command. No boilerplate required.
- [SBT](https://www.scala-sbt.org/index.html) - The interactive Scala build tool where you can define your tasks in Scala and run them in parallel from sbt's interactive shell.

### Using the CasperLabs runtime environment

1. Install Cargo CasperLabs

`cargo install cargo-casperlabs`

2. Create your project "my_project"

`cargo casperlabs my_project`

3. Set up your Rust environment for building

```shell
cd my_project/contract
rustup install $(cat rust-toolchain)
rustup target add --toolchain=$(cat rust-toolchain) wasm32-unknown-unknown
```

4. Build your project 

`cargo build --release`

5. A test framework is set up for you so you can Run tests by:

```shell
cd my_project/tests
cargo test
```



Selecting an IDE
----------------

Choose an IDE that has Rust support. We recommended you choose an application which enables you to more easily both write and debug your contracts. You can find Rust recommended tools [here](https://www.rust-lang.org/tools)

1. Select a tool for your platform and install
1. Setup your environment with extensions as need with:
   1. rust
   1. rust language tools



Opening the project
-------------------

1. Clone the repository and follow the instructions of the [README.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/execution-engine/cargo-casperlabs/README.md) with a description of the contents and project structure.

1. Once you clone the repository, follow the installation process [here](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation).

1. Check your Pre-requisites are installed and that you have the correct version of the following:

   - Java VM - must be installed to use the kit
   - WASM - WebAssembly is the language your contracts are compiled to, see detailed information about Wasm [here](https://webassembly.org/)
   - Python - Python client
   - Scala - Scala client
   - JavaScript

   Rust
   - Rustup
     - Rust
     - Cargo
     - rust tool chain
   - CL Cargo - A command line tool for creating a Wasm smart contract and tests for use on the CasperLabs network.

   Assembly Script
   - ...
   - ...
   - ...

4. Open the CasperLabs project in your IDE, you will find the following contents in the directory structure as follows  [here](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/execution-engine/cargo-casperlabs/README.md#usage)

- The main CasperLabs project directory contains configuration files, build and compiler tools, and source code library to build and test your contracts:
- [contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts)
- [tests] directory containing two Cargo crates:
  
    - one for contract
    - one for tests
      - build and compile
        - system contracts (WASM)
    
    For more detail see Test Framework [here](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/173539561/Test+Framework+and+Project+Scaffolding+tool) 

**Templated Contract and test code**
`contract.rs` source code file located in the contract directory
`.cargo/config` this configuration is file located in the contract crate and specifies the build target.
`build.rs`  You can use this build file to automate builds

### Dependencies
Note that the test crate depends on the contract crate.


Use the CasperLabs runtime environment
---------------------------------------------

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

- [crates.io](https://crates.io/search?q=casperlabs) all our crates are published
- [GITHub Source](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/contract-ffi/src/lib.rs)
- [Contract API](https://docs.rs/casperlabs-contract)
- [Types](https://docs.rs/casperlabs-types)
- [Test Support](https://docs.rs/casperlabs-engine-test-support)
- [Error Codes](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)Access the list of annotated Contract exit codes with details

**Tools**
- [CLI Tool](https://crates.io/crates/cargo-casperlabs) We also have a cargo-casperlabs CLI tool also accessed as cargo-casperlabs CLI tool source in GIT [here](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)
Note: These links have equivalent information - including a README.md from the crate's root.



Deploying and Testing contracts to the DevNet
---------------------------------------------

### Deploy

For instructions on Deploying Contracts see [DEVNET](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code)

Also see [CONTRACT](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md)



### Using Testing Framework

For instructions on Testing your Contracts See [Execution Engine Test Framework](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs)

In your project you will find tests to build, deploy, and debug your contracts:

- Cargo.toml - for the purposes of
- [Cl_test_..CLI](...) - test the CasperLabs scala client
- [Cl_test_..py](...) - test the CasperLabs python client
- [Makefile.toml](...) - to build the contract
- [rust-toolchain](...) - to build and deploy your test contracts
- [README.md](...) --



Execution error codes
---------------------

You can find a dynamically generated list with descriptions of each error code in our Rust and source documentation respectively [here](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)

Error Types include:
- [system contract errors](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/types/src/system_contract_errors)
- [pos and mint errors](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/types/src/api_error.rs)
- [smart contract errors] a.k.a. [Contract API FFI Errors](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html)
  - Source of the [Contract_API error ](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)



