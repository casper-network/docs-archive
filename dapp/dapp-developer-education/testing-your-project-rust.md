# Testing your project - Rust



Developers who want to use Rust (recommended for financial applications)
can create a crates project for your smart contracts and run your
contracts in a testing framework with the CasperLabs contract runtime
environment. This enables you to use a seamless workflow for authoring
and testing your smart contracts.

Additionally, this environment can also be used for continuous
integration, enabling Rust smart contracts to be managed using
development best practices.

We’ve simplified the process into 5 easy steps with the Cargo CasperLabs
tool for creating a Wasm smart contract and tests for use on the
CasperLabs network.

## Using the Cargo CasperLabs tool

Once installed it is used as a Cargo subcommand - A command line tool
for creating a Wasm contract and tests at your <path> for use on the
CasperLabs network.

Details are on Github
[here](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs)

Environment to help contract developers test their code. Rust Cargo has
a built in ability to install binaries it will put a folder in your path
and run commands as Cargo subcommands.


## Install

`$cargo install -f cargo-casperlabs` --path=. (to create a path when not published)

`$cargo install -f cargo-casperlabs` <--Published and crates.io-->

This will update your crates download compile and build the tool and
install it to your local binary folder.

`cd cargo casperlabs `--help`` Has brief instructions on how to use the
tool, you have to have the Wasm target available for the toolchain we
want to use.

By default this creates projects which rely on our packages being
published at crates.io To test the tool against.

Command line argument is available in the tool.

USAGE:
	Cargo casperlabs <path>
	rustup install nightly-2020-01-08
	rustup target add --toolchain nightly-2020-01-08 wasm32-unknown-unknown
	cd <path>/tests
	cargo test

FLAGS
`-h` `--help` Prints help information
`-v,` `--version` Prints written version information

OPTIONS:

ARGS:
	<path>  Path to new folder for contract and tests

### Pre-requisites
You want to have the Wasm target available to use the tool

- By default the tool creates projects which rely on our packages being
  published at Crates.io
- To Test the tool against what is not yet published

You can Use a non visible command line argument available to pass to the
path of the local EE folder `--workspace-path` -- (see source code)

`$Cargo casperlabs <folder>`

`--workspace-path/home/user/Rust/CasperLabs/execution-engine/`

`$cargo casperlabs <folder>`  
`--workspace-path /home/user/Rust/CasperLabs/execution-engine/`

Open your project and you will see you have created two new rust
projects: contract, tests

You will see 2 new projects, your project folder will look like this:
- contracts
- tests - Includes
    - Test code
    - Wasm folder which contains precompiled Wasm, our standard contracts
      provided with the tool the tests need to execute,
-   External Libraries Scratches and Consoles

Start the tests, compiling the folder:  
You will have test code and pre-compiled Wasm provided with the tool
Compiling the tests invoking the build tests

1. Add configuration Run/Debug
Configurations run on the Command:
- Cargo Command Unnamed
- 2/26/20 Templates

So the tool is compiling the tests -- invoking the build script compiler
to build the contract using the correct target Wasm 32 -- compiles the
contract, storing string provided as the single argument stored under a
key code value.

- The test runs, storing a string, to be stored as expect, high level
  test support APIs https://docs.rs/casperlabs-engine-test-support
- Wrapped test support framework, new easy to use structures - highlevel

Test contracts and the EE itself with access to elements you require The
test will
- built the contract
- executed it
- and it passed


#### Workflow for dApp developers
To run a contract you can build a contract Run the test which builds a
contract and sends from the node as a deploy and executing it as a
deploy.


To run your contract

1. Run in the project --

Running the Test itself builds the contract

Running the test takes the Contract - treating it as if it is being sent
from the node as a deploy tand executing it through the EE itself

Running the test takes the contract and runs the code to deploy so it's
running through the EE itself

Note: you can also just build the contract in contract and deploy using
-- cargo build)

### Failure and Error Reporting
Single argument to the contract stored under a special value  
-- a key code
Test -- stores a key and stores the value "hello world"

