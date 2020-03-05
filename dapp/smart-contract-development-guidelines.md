Smart Contract Development Guidelines
=====================================

As dApp developers, you may build from the ground up, or go against the latest CasperLabs release version, make modifications on your side, build locally, or just use what you build with the CasperLabs binaries we produce.

Contract authors can write their smart contracts in Rust with some degree of confidence. We have language bindings in Rust and you can view source code examples in our GIT repository. The module is supposed to be a wrapper around a separate Rust process for smart contracts execution.

CasperLabs provides capabilities to develop contracts that include but are not limited to the following types:

- Tokenization types to use for exchanging tokens
- Storing assets catalog and tokenizing what you own
- Power to vote (stake)
- Rewards (e.g. get tokens when you purchase something)

You can use this documentation to access our CLContract API endpoints, and get information about CLContract types how to build your own contracts.

Rust 101
--------

Contracts are built with Rust and compiled to [WASM](...)

- [crates.io](https://crates.io/search?q=casperlabs) this is where all CasperLabs crates are published
- [GITHub Source](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/contract-ffi/src/lib.rs) - source code is available in all of our feature repositories

- [Contract API](https://docs.rs/casperlabs-contract) - smart contracts Rust library

- [Types](https://docs.rs/casperlabs-types) - types you will used in creating Wasm contracts and tests for CasperLabs platform

- [Test Support](https://docs.rs/casperlabs-engine-test-support)- our platforms test support libraries

- [Error Codes](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings) - Access the list of annotated Contract exit codes with details

**Tools**

- [Cargo CasperLabs CLI Tool](https://crates.io/crates/cargo-casperlabs) cargo-casperlabs CLI tool
[cargo-casperlabs GIT Repository](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)


**Process of working with Rust Language**

Developers who want to use Rust (recommended for financial applications) can create a crates project for your smart contracts and run your contracts in the testing framework with the CasperLabs contract runtime environment. This enables you to use a seamless workflow for authoring and testing your smart contracts.

Additionally, this environment can also be used for continuous integration, enabling Rust smart contracts to be managed using development best practices.

This process has been simplified with the Cargo CasperLabs tool for creating a Wasm smart contract and tests for use on the CasperLabs network.

You can build contracts from scratch or use our [example smart contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples) with instructions and directories containing example smart contracts definitions and companion contracts.

In the Execution Engine directory of the repo you have cloned, you can [build](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples#building) all contracts or specific contracts:


Contracts are written in supported languages (for compiling to Wasm for deployment from a node) and processed through our execution engine (EE).

Learn more about this in the  [README.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/execution-engine/contracts/examples/README.md)  of the contracts example directory as well as about how contracts are built and when deploying, [how they operate on the platform](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md)


**Example Contract Tutorials**
- ERC20
- Vesting Contracts
- Tic Tac Toe


##### The Contract API



##### Structuring your project

<!--Video [CasperLabs - Smart contract template repository v0.0.1] (https://www.youtube.com/watch CasperLabs - Smart contract template repository v0.0.1] ch?v=P8SC_upCqAg&feature=youtu.be)-->

Directories structure is designed for developing, building, and testing  Rust contracts.

- Smart Contracts
- Tests
- System contracts
- Cargo
- Rust tool chain

##### Testing Your Project



##### Building the Contract

From within your `my_project/contract folder`, you will install Rust and add the Wasm target. You will run the commands provided in the Casperabs Cargo [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#building-the-contract) from within the root directory of the`contract` project, and then build the contracts with the commands of the Cargo Casperlabs tool. The `contract.wasm` will be built  in the `release` directory as per this example:

For Example:

Building a specific contract, you will see it in the root of your contract directory
```
cargo build --target wasm32-unknown-unknown --release -p hello-name-define -p hello-name-call
```

```markdown
the_project/
├── contract
│   ├── .cargo
│   │   └── config
│   ├── Cargo.toml
│   ├── rust-toolchain
│   └── src
│       └── lib.rs
|   └── target/
|				└── wasm32-unknown-unknown
|						└──	debug
|						└──	release <--- See
└── tests
    ├── build.rs
    ├── Cargo.toml
    ├── rust-toolchain
    ├── src
    │   └── integration_tests.rs
    └── wasm
        ├── mint_install.wasm
        ├── pos_install.wasm
        └── standard_payment.wasm
```

##### Deploying and Testing contracts to the DevNet

For instructions on Deploying Contracts see [DEVNET.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code)

Additionally, more advanced functions for deployments are covered in [CONTRACT.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md) in the /docs folder of the master repo you cloned your project from.


##### Using the Testing Framework

Running the test builds the contract, and takes it and runs the code treating it as if it is being sent from a node as a deploy and executing it through the Execution Engine itself.

##### Testing workflow

The test will run in 3 steps: build the contract, execute the contract, show the results -- passed, or failed with an error report to help debug

Note: without testing, you can also just build the contract in contract and deploy using `-- cargo build`

## Instructions

1. In your `*_project` you will find the Tests project with tests to build, deploy, and debug your contracts:

```markdown
`*_project`/
├── contract
│   ├── .cargo
│   │   └── config
│   ├── Cargo.toml
│   ├── rust-toolchain
│   └── src
│       └── lib.rs
│  └── target/
│				└── wasm32-unknown-unknown
│						└──	debug
│						└──	release <-- See
└── tests  <-- See
    ├── build.rs
    ├── Cargo.toml
    ├── rust-toolchain
    ├── src
    │   └── integration_tests.rs
    └── wasm
        ├── mint_install.wasm
        ├── pos_install.wasm
        └── standard_payment.wasm
```


1. Make sure you have the Wasm target available to use the tool.

Note: By default the tool creates projects which relies on our packages being published at [Crates.io]()

1. Navigate to the execution-engine directory

```shell
    `$Cargo casperlabs <folder>`
    `--workspace-path/home/user/Rust/CasperLabs/execution-engine/`
```

Note: To Test the tool against crates not yet published, you can use a non visible command line argument available to pass to the path of the local EE folder `--workspace-path` -- (see source code)

1. In the `*_project` will see two rust projects have been built:
    - contract/
    - tests/


1. Start the tests, this compiles the folder:

You can do this by adding it with the configuration `Run/Debug`

running the tests invokes the `build.rs` to build the contract

You will have test code and pre-compiled Wasm
Configurations run on the Command:
- Cargo Command Unnamed
- **Templated Contract and test code includes:**
  - `contract.rs` source code file located in the contract directory
  - `.cargo/config`  configuration is file located in the contract crate and specifies the build target.
  - `* build.rs`  You can use this build file to automate builds

The tool compiles the tests, invoking the build script compiler to build the contract using the correct target Wasm 32 -- compiles the contract, storing as a string provided as the single argument stored under a key code value.

For more detail, see the engine test support API reference crate documentation for [Casperlabs Engine Test Support](https://docs.rs/casperlabs-engine-test-support).


Test contracts in the Execution Engine (EE) itself with access to elements you require:


## Failure and Error Reporting

Single argument to the contract is stored under a special value
`-- a key code`

Test `-- stores` a `key` and the value




