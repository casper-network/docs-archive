# Getting Started

This follows the recommended process for getting started with dApp development with the CasperLabs platform features so that you can begin to develop, build, and test contracts using the CasperLabs development kit tools.

As dApp developers, you may build from the ground up to, or go against the latest CasperLabs release version, make modifications on your side, build locally, or just use what you build with the CasperLabs binaries we produce.

- Setup your dApp development environment to work with the CasperLabs platform

- Create a new smart contract project
- Use the runtime environment to build and test contracts

## Pre-requisites

[An IDE with Rust integration](https://www.rust-lang.org/tools) that enables you to most easily write and debug your contracts. See Rust recommended tools from their website [here](https://www.rust-lang.org/tools). 

[rustup](https://rustup.rs/), which installs Rust tools including rust Cargo. This allows you to install cargo-casperlabs whereby CL Crates will be installed, or crates that may have been installed previously will be updated.

[Cargo CasperLabs](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs) develop, build, debug, and deploy contracts using our CasperLabs environment and run your contracts locally and on the CasperLabs Devnet.

## Instructions

From the your terminal

Follow the instructions in the Cargo CasperLabs [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) 

Install from source clone [CasperLabs release branch](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation) and installing cargo-casperlabs cargo-casperlabs directory.

CasperLabs Cargo installation creates your project folder, e.g.  `*_project`, this will generate your project directory with contracts and test crates projects.



##### Step 1 - installation

From the command line, or terminal in your IDE you can: 

1. install 

This also installs Rust Cargo which, with a built in ability to install binaries it will put a folder in your path and run commands as Cargo subcommands. 

2. clone the CasperLabs [repository](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0) from the latest branch 

3. navigate to the `cargo-casperlabs` directory

4. install [Cargo CasperLabs ](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation) 

Now the Cargo CasperLabs tool may be used as a Cargo subcommand -  A (CLI) command line tool that provides an environment to help contract developers compile, build, and test code. You can use this for creating a Wasm contract and tests  to deploy on the CasperLabs network. 

1. Create a new smart contract project 
   1. contracts project 
   2. test project

You will find the configuration files, build and compiler tools, and source code library to build and test your contracts. 

Note: If you get stuck, check that the Pre-requisites are installed and that you have the correct versions:

##### Step 2 - opening the execution-engine project

**Directory Structure**

Having followed the [Cargo CasperLabs Installation](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) you should have created a new project,  `*_project` and 2 CargoCasperlabs projects:

- contract
- tests 

In your IDE you will see the project directory containing the templates, configuration files, compiling and build tools, and libraries you will need to create, build, test, deploy, and debug your contracts: 

```markdown
`*_project`/
├── `contract`
│   ├── .cargo
│   │   └── config
│   ├── Cargo.toml
│   ├── rust-toolchain
│   └── src
│       └── lib.rs
└── `tests`
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

##### How it works, what it does

`*_project`

Cargo crates project folders, [contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts) and [tests](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/test) 

* Contracts

  `.cargo/config` this configuration is file located in the contract crate and specifies the build target.

  `contract.rs` source code file located in the contract directory

* Tests 

  * Tests - to test and debug smart contract examples

    Templated Contracts with test code
    `build.rs`  You can use this build file to automate builds

    `Cargo.toml`

    `rust-toolchain`

    `src` folder contains 

    ​	 	`rust_integration_tests.rs `	

* wasm - system (Genesis) contracts - to bond to the network

**Dependencies**

Note that the test crate depends on the contract crate

##### Step 2 How to use the runtime environment with Casperlabs Cargo

`$cargo install -f cargo-casperlabs` --path=. (to create a path when not published)

`$cargo install -f cargo-casperlabs` -- works with Test docs that have been published at crates.io--

This will update your crates, download, compile and build the tool and install it to your local binary folder.

`cd cargo casperlabs `--help`` includes brief instructions on how to use the tool.



It is important you have to have the Wasm target available for the toolchain we want to use.

Note: By default the installation creates projects which rely on our packages being published at [crates.io](crates.io) to test the tool against.

Using the Command line argument available in the tool,  you will see the following output for usage, flags, and options:

USAGE

```shell
	Cargo casperlabs <path>
	rustup install nightly-2020-01-08
	rustup target add --toolchain nightly-2020-01-08 wasm32-unknown-unknown
	cd <path>/tests
	cargo test
```

FLAGS

`-h` `--help` Prints help information
`-v,` `--version` Prints written version information

OPTIONS

ARGS:	<path>  Path to new folder for contract and tests



##### Compile and testing a contracts



# Smart contract development guidelines

You can build contracts from scratch or use our [example smart contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples) with instructions and directories containing example smart contracts definitions and companion contracts.

In the Execution Engine directory of the repo you have cloned, you can [build](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples#building) all contracts or specific contracts:

For example:

- ERC20
- Tokens -- distributing tokens
- Payment processing
- Receiving payments
- Vesting Contracts
- Games
  - Tic Tac Toe


#### Using Rust

Developers who want to use Rust (recommended for financial applications) can create a crates project for your smart contracts and run your contracts in a testing framework with the CasperLabs contract runtime environment. This enables you to use a seamless workflow for authoring and testing your smart contracts.

Additionally, this environment can also be used for continuous integration, enabling Rust smart contracts to be managed using development best practices.

This process has been simplified with the Cargo CasperLabs tool for creating a Wasm smart contract and tests for use on the CasperLabs network.

##### Rust 101 

- [crates.io](https://crates.io/search?q=casperlabs) this is where all CasperLabs crates are published
- [GITHub Source](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/contract-ffi/src/lib.rs) - source code is available in all of our feature repositories
- [Contract API](https://docs.rs/casperlabs-contract) - smart contracts Rust library 
- [Types](https://docs.rs/casperlabs-types) - types you will used in creating Wasm contracts and tests for CasperLabs platform
- [Test Support](https://docs.rs/casperlabs-engine-test-support)- our platforms test support libraries
- [Error Codes](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings) - Access the list of annotated Contract exit codes with details

**Tools**

- [CLI Tool](https://crates.io/crates/cargo-casperlabs) cargo-casperlabs CLI tool also accessed as cargo-casperlabs CLI tool source in GIT [here](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)

  Note: These links have equivalent information - including a README.md from the  Cargo Casperlabs crate's root.

##### Example Contracts

Contracts are written in supported languages (for compiling to Wasm for deployment from a node) and processed through our execution engine (EE). 

Learn more about this in the  [README.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/execution-engine/contracts/examples/README.md)  of the contracts example directory as well as about how contracts are built and when deploying, [how they operate on the platform](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md) 

CasperLabs provides capabilities to develop contracts that include but are not limited to the following types:

- Tokenization types to use for exchanging tokens
- Storing assets catalog and tokenizing what you own
- Power to vote (stake)
- Rewards (e.g. get tokens when you purchase something)

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

##### Step 3 Deploying and Testing contracts to the DevNet

##### Deploying Contracts to Devnet

For instructions on Deploying Contracts see [DEVNET.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code)

Additionally, more advanced functions for deployments are covered in [CONTRACT.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md) in the /docs folder of the master repo you cloned your project from.

##### Using the Testing Framework

Running the test builds the contract, and takes it and runs the code treating it as if it is being sent from a node as a deploy and executing it through the Execution Engine itself.

##### Testing workflow

The test will run in 3 steps:

1. build the contract
2. execute the contract
3. show the results -- passed, or failed with an error report to help debug 

Note: you can also just build the contract in contract and deploy using `-- cargo build`

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

##### Testing your project - Rust

For detailed instructions see [Testing the Contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#testing-the-contract) in the Cargo CasperLabs repository.

1. Make sure you have the Wasm target available to use the tool. 

Note: By default the tool creates projects which relies on our packages being published at [Crates.io]()

1. Navigate to the execution-engine directory 

```shell
    `$Cargo casperlabs <folder>`
    `--workspace-path/home/user/Rust/CasperLabs/execution-engine/`
```

Note: To Test the tool against what is not yet published, you can use a non visible command line argument available to pass to the path of the local EE folder `--workspace-path` -- (see source code)

1. Open the project `*_project`

You will see two rust projects have been built, contract and tests:

```markdown
my_project/
├── **contract** (can be extended, see project directory above in step 1.
└── **tests**
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

1. Start the tests, this compiles the folder:

You will have test code and pre-compiled Wasm provided with the tool compiling, the tests invoking the `build.rs`

You can do this by adding it with the configuration `Run/Debug`

Configurations run on the Command:
- Cargo Command Unnamed
- **Templated Contract and test code includes:**
  - `contract.rs` source code file located in the contract directory
  - `.cargo/config` this configuration is file located in the contract crate and specifies the build target.
  - `* build.rs`  You can use this build file to automate builds

The tool compiles the tests, invoking the build script compiler to build the contract using the correct target.

Wasm 32 -- compiles the contract, storing as a string provided as the single argument stored under a key code value.

The test runs, storing a string, to be stored as expected. This is a wrapped test support framework, with new highlevel easy to use structures.

For more detail, see the engine test support API reference crate documentation for [Casperlabs Engine Test Support](https://docs.rs/casperlabs-engine-test-support).


Test contracts in the Execution Engine (EE) itself with access to elements you require:

## Failure and Error Reporting

Single argument to the contract is stored under a special value
`-- a key code`

Test `-- stores` a `key` and the value

 To view an example, we recommend you start with testing out our [Hello World Contract](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples/hello-name-define) and [companion](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples/hello-name-call):

 `"hello world"`

**Dependencies**

Note that the test crate depends on the contract crate.

##### Execution error codes

You can find a dynamically generated list with descriptions of each error code in our Rust and source documentation respectively

Error Types include:
- [system contract errors](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/types/src/system_contract_errors)
- [pos and mint errors](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/types/src/api_error.rs)
- [smart contract errors](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html) a.k.a. [Contract API FFI Errors and Mappings](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)
  - You can also refer to the source of the [Contract_API errors](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)



