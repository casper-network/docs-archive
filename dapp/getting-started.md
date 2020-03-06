# Getting Started

This step-by-step process includes a set of examples designed for you to become familiar with how to use the CasperLabs development tool kit. 

Starting with the cargo-casperlabs package manager you will see how to use the tools so that you can start to develop, test, debug, and deploy contracts locally or on the CasperLabs Devnet with the basics to: 

- Setup your dApp development environment to work with the CasperLabs platform

- Create a new smart contract project
- Use the runtime environment to build and test contracts

## Pre-requisites

We recommend the following set-up:

An IDE with Rust integration in order for you to most easily write and debug your contracts. See recommended tools from the [Rust website](https://www.rust-lang.org/tools). 

[rustup](https://rustup.rs/), with Rust Cargo package manager

## Instructions

##### Step 1 - install the cargo-casperlabs Rust toolchain

To Install the casperlabs Crate

- Install from your terminal

  From the command line run

  `cargo install cargo-casperlabs`

For more details, see [Cargo-Casperlabs Crate](https://crates.io/crates/cargo-casperlabs)

- Install from source

Clone [CasperLabs latest branch](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0)

 navigate to the  `cargo-casperlabs` directory 

```shell
CasperLabs/execution-engine/cargo-casperlabs
```

and install [Cargo CasperLabs ](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#installation), Run

```shell
cargo install cargo-casperlabs --path=.
```

This installs Cargo which, with the built in ability to install binaries it will put a folder in your path so you can run commands as Cargo subcommands. Once installed the cargo-casperLabs tool may be used as a Cargo subcommand -  A (CLI) command line tool that provides an environment to help contract developers compile, build, and test code. You can use this for creating a Wasm contract and tests  to deploy on the CasperLabs network. 

Note: If you get stuck, check that the Pre-requisites are installed and that you have the correct versions.

For detailed instructions refer to the [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) of the Cargo CasperLabs repository . 

**Step 2**  **Create your project** 

Now that the casperlabs-cargo crate is installed, you can create your project, e.g. `example_project` containing an example contract and a separate test crate for the contract.

```none
cargo casperlabs example_project
```

Navigate to your project folder and you will see the contracts and test folder, 

```shell
cd example_project/
ls example_project
```

CasperLabs Cargo installation creates your project folder, e.g.  `example_project`, this will generate your  `contracts` and `test` crates projects top level directory folders:

```shell
example_project`/
├── `contract` - 
└── `tests` - full test environment with the entire structure and stub of a single stub so you can model that structure to create a full testing framework for your contract: 
```

```shell
example_project`/
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

Once your  `example_project` is setup you will see the project directory containing the templates, configuration files, compiling and build tools, and libraries you will need to create, build, test, deploy, and debug your contracts: 

**Dependencies**

Note: that the tests crate depends on the contract crate

**Step 3 - Building a contract**

Casperlabs contracts are built and compiled to Wasm to deploy to our DevNet.

Build the contract ensuring the correct version of Rust is installed along with the Wasm target:

1. navigate to the `contract` directory of your project

2. install the rust tool chain

   `rustup install $(cat rust-toolchain)`

3. create the build target for your contract

   `rustup target add --toolchain=$(cat rust-toolchain) wasm32-unknown-unknown`

4. now you can build an empty project and compile it

   `cargo build --release`

```shell
`example_project`/
├── `contract`
│   └── src
│   └── target
│		└── release
|		└── wasm32-unkown-unknown
|				└── release  <-- the release folder with the `contract.wasm` is generated
```

The contract will compile and the wasm be built to the contract/ release directory:  `example_project/contract/target/wasm32-unknown-unknown/release/contract.wasm`.

The contract has been built to `contract.wasm`, (you can use a different name of the contract for your project, and if you deploy this each version should be saved under a different name)

Note: We recommend against having multiple contracts in a project, i.e. each contract should have its own project.

**Step 4 - using the runtime environment** -- **execution engine** 

You can run your contract against our casperlabs execution-engine (EE) a virtual machine our blockchain provides. This is a run time environment which allows you to run a contract the same as running it on our block chain, but without any overhead of having to run it on a separate node.

You can run it within any test infrastructure, e.g. a CLI, and observe the effects of your contract.  

For Example: 

##### Compile and test contracts from the CLI

You will see how all the dependencies are being compiled to run the execution engine locally where it will run your contract and your tests, and how it will 

1. navigate to your test folder
2. run the test with the cargo command

```shell
cd example_project/tests
cargo test
```

**Compile and test contracts from within your IDE**

When you run the casperlabs cargo tool, you will see the two separate projects folders: contracts and tests.  You can view learn about the folder structure more in detail in the [cargo-casperlabs](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs#usage) repository.

- **The contract project** is a library project that is more standalone and would still build if it is moved to a different location 

 `contract.rs` source code file located in the contract directory, like a stub, with basic contract code it provides a structure for you to build your contract.

The contract project also contains the [Contract API](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/) and [type system](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/) with a complete set of documentation on [CasperLabs Rust docs](https://docs.rs/releases/search?query=casperlabs)

published to the Rust Package Registry rust.docs reference documentation repository where you can find functions, e.g.  for managing the accounts, and runtime features

- **the "tests" project** is a binary project that has a custom build script included (`build.rs`) which expects the corresponding contract project to be right next to it. So, it is recommended you open each of your contract projects in a separate instance of your IDE.  

  With the tests you can provide break points and work with variables operating the same as it normally would when developing any software. 

You can use `cargo-casperlabs --help` including brief instructions about the tool.

Note: The tests project will auto-build the contract, but not vice-versa












