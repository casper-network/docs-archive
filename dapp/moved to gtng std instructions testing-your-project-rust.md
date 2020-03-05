Testing your project - Rust
===========================

Developers who want to use Rust (recommended for financial applications) can create a crates project for your smart contracts and run your contracts in a testing framework with the CasperLabs contract runtime environment. This enables you to use a seamless workflow for authoring and testing your smart contracts.

Additionally, this environment can also be used for continuous
integration, enabling Rust smart contracts to be managed using
development best practices.

We’ve simplified the process into 5 easy steps with the Cargo CasperLabs tool for creating a Wasm smart contract and tests for use on the CasperLabs network.

## Using the Cargo CasperLabs tool

Once installed it is used as a Cargo subcommand - A command line tool for creating a Wasm contract and tests at your <path> for use on the CasperLabs network.

Details are on Github [here](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs)




## 1. Install

`$cargo install -f cargo-casperlabs` --path=. (to create a path when not published)

`$cargo install -f cargo-casperlabs` <--Published and crates.io-->

This will update your crates, download, compile and build the tool and
install it to your local binary folder.

`cd cargo casperlabs `--help`` Has brief instructions on how to use the
tool, you have to have the Wasm target available for the toolchain we
want to use.

By default this creates projects which rely on our packages being
published at crates.io To test the tool against.

Command line argument is available in the tool.

## USAGE

```shell
	Cargo casperlabs <path>
	rustup install nightly-2020-01-08
	rustup target add --toolchain nightly-2020-01-08 wasm32-unknown-unknown
	cd <path>/tests
	cargo test
```

### FLAGS

`-h` `--help` Prints help information
`-v,` `--version` Prints written version information

## OPTIONS

### ARGS:	<path>  Path to new folder for contract and tests


## Pre-requisites

Make sure you have the Wasm target available to use the tool. By default the tool creates projects which rely on our packages being
  published at Crates.io

To Test the tool against what is not yet published, you can Use a non visible command line argument available to pass to the
path of the local EE folder `--workspace-path` -- (see source code)

Navigate to your CasperLabs folder
```shell
    `$Cargo casperlabs <folder>`
    `--workspace-path/home/user/Rust/CasperLabs/execution-engine/`
```

##### Step 2: Open the <my_project> and you will see two new rust projects:

Your project folder will look like this:
- contracts
- tests - Includes
    - Test code
    - Wasm folder which contains precompiled Wasm, our standard contracts
      provided with the tool the tests need to execute,
-   External Libraries Scratches and Consoles

#####Step 3. Start the tests, compiling the folder:

You will have test code and pre-compiled Wasm provided with the tool compiling the tests invoking the `build tests`

You will be adding the configuration `Run/Debug`

Configurations run on the Command:
- Cargo Command Unnamed
- Templates

The tool is compiling the tests -- invoking the build script compiler
to build the contract using the correct target

Wasm 32 -- compiles the contract, storing string provided as the single argument stored under a key code value.

The test runs, storing a string, to be stored as expected. This is a wrapped test support framework, with new highlevel easy to use structures.

For more detail, see the test support API reference documentation for [Casperlabs Engine Test Support](https://docs.rs/casperlabs-engine-test-support)


Test contracts and the EE itself with access to elements you require

The test will:
- build the contract
- executed it
- and show it passed


#### Workflow for dApp developers
To run a contract you can build a contract Run the test which builds a
contract and sends from the node as a deploy and executing it as a
deploy.

Running the test takes the contract and runs the code treating it as if it is being sent from the node as a deploy and executing it through the Execution Engine itself.

Note: you can also just build the contract in contract and deploy using
`-- cargo build`)

##### Step 4. Failure and Error Reporting

Single argument to the contract stored under a special value  
`-- a key code`
Test `-- stores` a `key and stores the value

 For example:

 `"hello world"`

