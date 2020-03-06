# Getting Started

This three step process includes examples designed for you to become familiar with how to use the CasperLabs development tool kit as follows:

- Install and setup your dApp development environment to work with the CasperLabs platform

- Create a new smart contract project

- Use the runtime environment to build and test contracts

## Pre-requisites

We recommend the following set-up:

[rustup](https://rustup.rs/), with Rust Cargo package manager

An IDE with Rust integration in order for you to most easily write and debug your contracts. See the [Rust website](https://www.rust-lang.org/tools) for further information.

## Instructions

Starting with the cargo-casperlabs package manager, you will see how to use this tool to develop, test, debug, and deploy contracts locally or on the CasperLabs Devnet.

**Step 1 - install the cargo-casperlabs Rust toolchain**

**From your command line**

`cargo install cargo-casperlabs`

For more details, see [Cargo-Casperlabs Crate](https://crates.io/crates/cargo-casperlabs)

**From source**

Clone [CasperLabs latest branch](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0), navigate to the  `cargo-casperlabs` directory, and install cargo-casperlabs 

```shell
CasperLabs/execution-engine/cargo-casperlabs
cargo install cargo-casperlabs --path=.
```

With the built in ability to install binaries, cargo-casperlabs  will put a folder in your path so you can run commands as Cargo subcommands,  a command line tool that provides an environment to help contract developers compile, build, and test code - creating a Wasm contract and tests to deploy on the CasperLabs network. 

Note: If you get stuck, check that the Pre-requisites are installed and that you have the correct versions.

For detailed instructions refer to the [README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs#usage) of the Cargo CasperLabs repository . 

**Step 2 Create your project** 

Once the casperlabs-cargo crate is installed, create your project, e.g. `example_project` containing an example contract with a separate test crate:

```none
cargo casperlabs example_project
```

Navigate to your project directory, cargo casperLabs installation created your project,  e.g. `example_project`, with  `contracts` and `tests` crates projects in top level directory folders:

```shell
cd example_project/
ls example_project
```

```shell
example_project`/
├── `contract` - 
└── `tests` - full test environment with the entire structure and stub so you can model that structure to create a full testing framework for your contract: 
```

When you run the casperlabs cargo tool, you will see the two separate projects folders: contracts and tests.  For more detail about the directory structure, see the [cargo-casperlabs](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs#usage) repository.

**The contract project** is a library project that is more standalone and would still build if it is moved to a different location.  `contract.rs` source code file,  like a stub with basic contract code, provides a structure for you to build your contract.

The contract project also contains the [Contract API](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/) and [type system](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/) with a complete set of documentation on [CasperLabs Rust docs](https://docs.rs/releases/search?query=casperlabs).

published to the Rust Package Registry rust.docs reference documentation repository where you can find functions, e.g.  for managing the accounts, and runtime features

**the "tests" project** is a binary project that has a custom build script included (`build.rs`) which expects the corresponding contract project to be right next to it. So, it is recommended you open each of your contract projects in a separate instance of your IDE.  

With the tests you can provide break points and work with variables operating the same as it normally would when developing any software. 

Once your  `example_project` is setup you will see the project directory containing the templates, configuration files, compiling and build tools, and libraries you will need to create, build, test, deploy, and debug your contracts: 

**Dependencies**

Note: that the tests crate depends on the contract crate

**Step 3 - Use the runtime environment to build and test contracts**

Casperlabs contracts are built and compiled to Wasm to deploy to our DevNet. Build the contract ensuring the correct version of Rust is installed along with the Wasm target navigate to the `contract` directory of your project,  install the rust tool chain, create the build target for your contract. 

```
rustup install $(cat rust-toolchain)
rustup target add --toolchain=$(cat rust-toolchain) wasm32-unknown-unknown
```

**build and compile your project**

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

The contract is compiled and the wasm built to the `contract/ release directory: example_project/contract/target/wasm32-unknown-unknown/release/contract.wasm`.

You can run your contract against our casperlabs execution-engine (EE) a virtual machine our blockchain provides. This runtime environment  allows you to run a contract the same as running it on our block chain without the overhead of having to run it on a separate node.

You can run it within any test infrastructure, like a CLI, or your IDE and observe the effects of your contract.  

For Example: 

**Compile and test contracts from the CLI**

You will see how all the dependencies are being compiled to run the execution engine locally where it will run your contract and your tests:

navigate to your tests folder and run the test with the cargo command:

```shell
cd example_project/tests
cargo test
```

**Compile and test contracts from within your IDE**

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

The tests project will auto-build the contract, but not vice-versa.

You can use `cargo-casperlabs --help` including brief instructions.