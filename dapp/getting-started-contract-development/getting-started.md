
Getting started
===============

To support the development of smart contracts on the CasperLabs blockchain enabling developers to run smart contracts in the CasperLabs runtime environment included with our CasperLabs contract development kit as follows:

- [System (Genesis) contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/system) - to bond to the network
- [Example contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples) - ERC20 example - smart contract examples
- [Integration tests](...) - to test and debug smart contract examples


How to Use this guide
---------------------

You can use this guide to build DApps to run:

- On our network (DevNet)
- Your own network
- Your local environment

In the [CasperLabs environment](https://clarity.casperlabs.io/#/) and choose to use tools you are familiar with to build your contracts and run them in the engine in the order you desire and so observe the effects of contract execution in the [global state](https://techspec.casperlabs.io/en/latest/implementation/global-state.html) (the shared database that is the blockchain) -all from within an IDE of your choice.

## What you need to Get Started

- Linux or OSx
- Programming knowledge
  - JavaScript and/or Python
- Resources

The following set of documentation is presented in order and provides instructions on Linux and OSx for setting up the CasperLabs environment locally, setting up Nodes, and building, testing, and executing Smart contracts to address your use case including:

- CL-Smart contract template repository (Debian, Ubuntu, Mint, macOS)
- Documented Instructions -- How to build a local environment Casperlabs Smart Contract template
[- Demo -- How to build a local environment](...)
- CasperLabs DevNet tools (GraphQL)
- Useful Diagrams
- Architecture


Technical Pre-requisites
------------------------

- [Rust](https://www.rust-lang.org/tools/install)
  - Cargo RPM
  - 
-  [IDE with Rust support](https://www.rust-lang.org/tools/install)
- CasperLabs client
  - Scala
  - Python
- Binaries with executables to install CasperLabs pre-built environment
- CasperLabs Repository to build from source

Using the CasperLabs runtime environment
----------------------------------------
1. Install the CasperLabs Rust Tool Chain
1. Clone the [repository](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine)

1. Check your Pre-requisites


Selecting an IDE
------------------------------------------

Choose an IDE that has Rust support. We recommended you choose an application which enables you to more easily both write and debug your contracts.

You can find Rust recommended tools [here](https://www.rust-lang.org/tools)

1. Select a tool for your platform and install
2. Setup your environment
   1. extensions
      2. rust rust language tools
      2. rust itself

Opening the project
------------------------------------

1. Clone the repository following the [README.md](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/cargo-casperlabs/README.md) with a description of the contents and structure of how it is organized.

2. Once you clone the [repository](...) follow the [installation](...) process

<!--https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine-->

2. Check your Pre-requisites so that the following is installed and that you have the correct version of the following:
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

3. Open the CasperLabs project in your IDE, you will find the following contents in the directory structure:

- The main CasperLabs project directory contains configuration files, build and compiler tools, and source code library to build and test your contracts.
- [contracts](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/cargo-casperlabs/README.md#usage)
- [tests ](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/173539561/Test+Framework+and+Project+Scaffolding+tool) directory containing two Cargo crates:
    - one for contract
    - one for tests
      - build and compile
        - system contracts (WASM)

Note that the Contract and test code are templated as `contract.rs`
<!--Key advantage here is that we can put a-->

The `.cargo/config` file located in the contract crate to specify the build target.

### Dependencies
Note that the test crate depends on the contract crate.
<!--Some experimentation is warranted -->
You can use `build.rs file` to automate builds


Use the CasperLabs runtime environment
---------------------------------------------
The runtime environment consists of:


Writing Contracts
-----------------
CasperLabs provides capabilities to develop contracts that include but are not limited to the following types:

For example:
- Tokenization types to use for exchanging tokens
- Storing assets, catalog and tokenizing what you own ---- power to vote (stake)
- Rewards (e.g. get tokens when you purchase something)-->
  

#####Example Contracts:

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

 

Deploying and Testing contracts to the DevNet
---------------------------------------------

### Deploy

For instructions on Deploying Contracts see [CONTRACT](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md)


### Test

For instructions on Testing your Contracts
See [Execution Engine Test Framework](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)

Execution error codes
---------------------

You can find a dynamically generated list with descriptions of each error code in our Rust and source documentation respectively:

see [Short Description of Fraser's Implementation](...)
see [Enum Contract FFI Error Enum](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html)
see Source ofthe [Contract_API error ](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)

