5 steps to Start Building dApps
=====================================

The following is a step-by-step process covering basic and advanced features to develop, build, and test contracts using the CasperLabs development tools available in our development envrironment.   

As DApp developers you may build from the ground up to go against the CasperLabs current `dev` or make modifications on your side, build locally, or just use what you build with the CasperLabs binaries we produce.   


Pre-requisites
--------------

Perform the install process with instructions provided [here](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/INSTALL.md) for one of the following:

- [CasperLabs  binaries](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#using-binaries-recommended) (Recommended) are provided so that you can develop and build your contracts to deploy to the CasperLabs Network or network of your choice

- [Building from source](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#building-from-source) you can develop and build your contracts for:
  - deploying to the CasperLabs Network or network of your choice
  - customization, versioning, optimization of compiling process
  - making your code visible on the blockchain for full transparency


Installing the CasperLabs toolchain
-----------------------------------

Check your Pre-requisites have been installed working through the instructions for packages in this list:
-  [rustup](https://rustup.rs/) - the installer for the Rust programming language that includes a command line tool for managing Rust versions and associated tools including Rust cargo and the rust package manager.

- Clients (Scala and/or Python) - Clients include a language specific library to interact with a node via our gRPC API, and a command line interface script (CLI)
  
  [Casperlabs client](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/INSTALL.md) (debian and rpm) nstallation instructions
  
  [Casperlabs client](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/INSTALL.md) (Scala)
  
  [Casperlabs client](https://pypi.org/project/casperlabs-client/) (Python Package and Instructions)
  
-  [SBT](https://www.scala-sbt.org/index.html) - this is an interactive Scala build tool where you can define your tasks in Scala and run them in parallel from sbt's interactive shell.

-  [Cargo CasperLabs](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs) -- Cargo CasperLabs provides a build tool for Rust. Rust Cargo has a built in ability to install binaries it will put a folder in your path and run commands as Cargo subcommands. CasperLabs Cargo bundles all common actions into a single command with no boilerplate required and provides an environment to help you test your code, and perform continuous integration according to recommended best practices.

Selecting an IDE
----------------

Choose an IDE  with Rust integration. We recommended you choose an application which enables you to more easily both write and debug your contracts. You can find Rust recommended tools on their website [here](https://www.rust-lang.org/tools).

- Select and install the Rust recommended IDE for your operating system.
- Open your IDE and setup your environment with Rust required extension plugins including:
   - rust language integration
   - rust language support (rls)

Opening the execution-engine project
--------------------------------------------
Navigate to the directory where you will find the:
  - system (Genesis) contracts - to bond to the network
  - example contracts - smart contract templates
    - ERC20 -
    - Vesting -
    - Tic Tac toe -
  - Tests - to test and debug smart contract examples

Open the CasperLabs project in your chosen IDE, you will find the configuration files, build and compiler tools, and source code library to build and test your contracts. 

* The main CasperLabs project directory contains two Cargo crates project folders, [contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts) and [tests](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/test) 

* Templated Contracts and test code
`contract.rs` source code file located in the contract directory
`.cargo/config` this configuration is file located in the contract crate and specifies the build target.
`build.rs`  You can use this build file to automate builds

### Dependencies
Note that the test crate depends on the contract crate.

Step 2: Opening the project
---------------------------

* Clone the [repository](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine) (if you have not already).

* Once you clone the repository, follow the installation process for CasperLabs Cargo [here](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation).


Note: If you get stuck, check that the Pre-requisites are installed and that you have the correct versions:

   - Java VM - must be installed to use the kit
   - WASM - WebAssembly is the language your contracts are compiled to, see detailed information about Wasm [here](https://webassembly.org/)
   - Python - Python client
   - Scala - Scala client
   - JavaScript


#### Directory Structure

 Having followed the Cargo CasperLabs Installation (https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) you should have created a project <my_project>.

  Upon opening your <my_project> in your IDE you will see the project directory with a contract project folder and tests project folder which containing the templates, configurations, tools, and libraries you will need to create, build, test, deploy, and debug your contracts, as presented here:

```
my_project/
├── contract
│   ├── .cargo
│   │   └── config
│   ├── Cargo.toml
│   ├── rust-toolchain
│   └── src
│       └── lib.rs
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


Use the CasperLabs runtime environment
---------------------------------------------

Developers who want to use Rust (recommended for financial applications) can create a crates project for your smart contracts and run your contracts in a testing framework with the CasperLabs contract runtime environment. This enables you to use a seamless workflow for authoring and testing your smart contracts.

Additionally, this environment can also be used for continuous
integration, enabling Rust smart contracts to be managed using
development best practices.

This process has been simplified with the Cargo CasperLabs tool for creating a Wasm smart contract and tests for use on the CasperLabs network.

- From terminal within your project:

  Follow the instructions  provided with the Cargo CasperLabs [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage), 

  Start with installing [rustup](https://rustup.rs/), which installs Rust tools including Cargo. This allows you to install cargo-casperlabs. Crates will be installed, or crates that may have been installed previously will be updated.

- You can also [install from the lastest `dev` branch](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation) by cloning the repository and installing cargo-casperlabs in the cargo-casperlabs directory.

- CasperLabs Cargo to create your project folder, e.g. <"my_project">, this will generate your project directory with contracts and test crates projects,  see [Directory Structure](#directory-structure) in Step 2 above.

Writing Contracts
-----------------
You can build contracts from scratch or use our [example smart contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples) with instructions and directories containing example smart contracts definitions and companion contracts.

For example:

- ERC20

- Tokens -- distributing tokens

- Payment processing

- Receiving payments

- Vesting Contracts

- Games
  - Tic Tac Toe

  In the Execution Engine directory of the repo you have cloned, you can [build](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples#building) all contracts or specific contracts:

##### Building the Contract

In your my_project/contract folder, you will install Rust and add the Wasm target. You will run the commands provided in the Casperabs Cargo [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#building-the-contract) from within the root directory of the`contract` project, and then build the contracts with the commands of the Cargo Casperlabs tool. The contract.wasm will be built  im the `release` directory

For Example:

Building a specific contract, you will see it in the root of your contract directory
```
cargo build --target wasm32-unknown-unknown --release -p hello-name-define -p hello-name-call
```

```
my_project/
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

For instructions on Deploying Contracts see [DEVNET.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code)

More advanced functions are covered in [CONTRACT.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md) the /docs folder.

### Using the Testing Framework

In your <my_project> you will find the Tests project with tests to build, deploy, and debug your contracts:

Details are on GitHub [here](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs)

### Testing your project - Rust

Once installed it Cargo CasperLabs tool may be used as a Cargo subcommand - A command line tool for creating a Wasm contract and tests at your <path>  to deploy on the CasperLabs network. This tool provides an environment to help contract developers test their code. Rust Cargo has a built in ability to install binaries it will put a folder in your path
and run commands as Cargo subcommands.

For detailed instructions see [Testing the Contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#testing-the-contract) in the Cargo CasperLabs repository.

##### Install

`$cargo install -f cargo-casperlabs` --path=. (to create a path when not published)

`$cargo install -f cargo-casperlabs` <-- works with Test docs that have been published at crates.io-->

This will update your crates, download, compile and build the tool and
install it to your local binary folder.

`cd cargo casperlabs `--help`` Has brief instructions on how to use the
tool, you have to have the Wasm target available for the toolchain we
want to use.

By default this creates projects which rely on our packages being
published at crates.io To test the tool against.

Using the Command line argument available in the tool,  you will see the output:

##### USAGE

```shell
	Cargo casperlabs <path>
	rustup install nightly-2020-01-08
	rustup target add --toolchain nightly-2020-01-08 wasm32-unknown-unknown
	cd <path>/tests
	cargo test
```

**FLAGS**

`-h` `--help` Prints help information
`-v,` `--version` Prints written version information

**OPTIONS**

ARGS:	<path>  Path to new folder for contract and tests



## Pre-requisites for Testing

Make sure you have the Wasm target available to use the tool. By default the tool creates projects which rely on our packages being published at [Crates.io]()

Navigate to your CasperLabs folder
```shell
    `$Cargo casperlabs <folder>`
    `--workspace-path/home/user/Rust/CasperLabs/execution-engine/`
```

Note: To Test the tool against what is not yet published, you can use a non visible command line argument available to pass to the path of the local EE folder `--workspace-path` -- (see source code)

##### Step 1: Once installed, open the <my_project> and you will see two new rust projects:

Your project folder will look like this:

```shell
my_project/
├── contract (can be extended, see project directory above in step 1.
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

##### Step 2: Start the tests, compiling the folder:
You will have test code and pre-compiled Wasm provided with the tool compiling the tests invoking the `build.rs`

You can do this by adding it with the configuration `Run/Debug`

Configurations run on the Command:
- Cargo Command Unnamed
- Templates

The tool compiles the tests, invoking the build script compiler
to build the contract using the correct target.

Wasm 32 -- compiles the contract, storing string provided as the single argument stored under a key code value.

- The test runs, storing a string, to be stored as expected. This is a wrapped test support framework, with new highlevel easy to use structures.

For more detail, see the test support API reference documentation for [Casperlabs Engine Test Support](https://docs.rs/casperlabs-engine-test-support)


Test contracts in the Execution Engine (EE) itself with access to elements you require:

The test will:
- build the contract
- executed it
- and show it passed


#### Testing workflow
To run a contract you can build a contract Run the test which builds a
contract and sends from the node as a deploy and executing it as a
deploy.

Running the test takes the contract and runs the code treating it as if it is being sent from the node as a deploy and executing it through the Execution Engine itself.

Note: you can also just build the contract in contract and deploy using
`-- cargo build`)

#### Failure and Error Reporting

Single argument to the contract stored under a special value  
`-- a key code`
Test `-- stores` a `key and stores the value

 For example:

 `"hello world"`

Execution error codes
---------------------

You can find a dynamically generated list with descriptions of each error code in our Rust and source documentation respectively

Error Types include:
- [system contract errors](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/types/src/system_contract_errors)
- [pos and mint errors](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/types/src/api_error.rs)
- [smart contract errors](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html) a.k.a. [Contract API FFI Errors](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)
  - You can also refer to the source of the [Contract_API errors](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)



