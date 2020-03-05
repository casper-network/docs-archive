# Getting Started

This follows the recommended process for getting started with dApp development with the CasperLabs platform features so that you can begin to develop, build, and test contracts using the CasperLabs development kit tools to:

- Setup your dApp development environment to work with the CasperLabs platform
- Create a new smart contract project
- Use the runtime environment to build and test contracts

## Pre-requisites

An [IDE with Rust integration](https://www.rust-lang.org/tools) that enables you to most easily write and debug your contracts. See Rust recommended tools from their website [here](https://www.rust-lang.org/tools). 

[Cargo CasperLabs](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs) develop, build, debug, and deploy contracts using our CasperLabs environment and run your contracts locally or on the CasperLabs Devnet.

[rustup](https://rustup.rs/), installs Rust tools including rust Cargo. This allows you to install cargo-casperlabs whereby CL Crates will be installed. Crates that have been installed previously will be updated.

## Instructions

Install from your terminal

Follow the instructions in the Cargo CasperLabs [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) 

Install from source

Clone [CasperLabs release branch](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation) and installing cargo-casperlabs cargo-casperlabs directory.

CasperLabs Cargo installation creates your project folder, e.g.  `*_project`, this will generate your project directory with contracts and test crates projects.

##### Step 1 - installation

From the command line, or terminal in your IDE you can: 

`casperlabs-cargo install` 

This also installs Rust Cargo which, with a built in ability to install binaries it will put a folder in your path and run commands as Cargo subcommands. 

2. clone the CasperLabs [repository](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0) from the latest branch 

3. navigate to the `cargo-casperlabs` directory

4. install [Cargo CasperLabs ](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation) 

Now the Cargo CasperLabs tool may be used as a Cargo subcommand -  A (CLI) command line tool that provides an environment to help contract developers compile, build, and test code. You can use this for creating a Wasm contract and tests  to deploy on the CasperLabs network. 

1. Create a new smart contract project

Cargo CasperLabs will build the configuration files, build and compiler tools, and source code library to build and test your contracts.

Note: If you get stuck, check that the Pre-requisites are installed and that you have the correct versions:

##### Step 2 - opening the execution-engine project

**Directory Structure**

Having followed the [Cargo CasperLabs Installation](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) in your `*_project` you will see 2 CargoCasperlabs projects:

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

##### Step 3 How to use the runtime environment with Casperlabs Cargo

`$cargo install -f cargo-casperlabs` --path=. (to create a path when not published)

`$cargo install -f cargo-casperlabs` -- works with Test docs that have been published at [crates.io](https://crates.io/crates/cargo-casperlabs)

This will update your crates, download, compile and build the tool and install it to your local binary folder.

`cd cargo casperlabs`  `--help` includes brief instructions on how to use the tool.

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


example, we recommend you start with testing out our [Hello World Contract](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples/hello-name-define) and [companion](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples/hello-name-call):

 `"hello world"`


