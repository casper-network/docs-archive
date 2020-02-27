# CasperLabs Stack languages


## WebAssembly (Wasm)

We use [WebAssembly](https://webassembly.org/)(Wasm)  as our Virtual Machine (VM). It enables developers to write smart contracts in all the languages that compile to the Wasm bytecode, see [Multiple programming languages and WebAssembly](https://casperlabs.atlassian.net/wiki/spaces/~868180632/pages/142704644/Product+Positioning+for+DApp+Developers+Smart+Contracts )


WebAssembly will be one the dominant technology of the near feature and great tool in everyday development. In general it enables you to write smart contracts in one of the languages you might know, see:

  - https://github.com/appcypher/awesome-wasm-langs
  - https://github.com/mbasso/awesome-wasm

Wasm is Highly supported by the development community. It will grow with useful features and cost-effective optimizations.

Our smart contracts are intended to run only with our Execution Engine (EE), so the way Wasm is set up -- having function imports are capabilities you take from the environment your Wasm is executing in that Wasm in and of itself does not do natively -- You would import from JS so you could interact with your DOM.

There is a standard being worked on for Wasm as a systems bite code language, Standard imports for READING and Writing files. So CasperLabs has a set of function imports specific to our system. Reading and writing from a contracts local state, getting block time stamp with IO style operations specific to the CasperLabs enviroment it is running in.

Wasm also supports architecture you can apply to make it more flexible.

For Example:

[CasperLabs Tic Tac Toe smart contract](#contract-example-tic-tac-toe.md) -- compiles to native binary (e.g. or to our blockchain and compiles to WASM to run on our blockchain.

 Precisely different Input output natively on machine reading STDN and writing to console.

Whereas if it is compiled to Wasm for the CL Blockchain, reading from deploy arguments writing to the contract local state--

So, all the core logic is the same. Recognizing Wasm binary isn't portable only insofar as io isn't portable, but you can isolate core logic that is io independent from the IO, so you can specify compilation targets.

# CasperLabs Clients

## [Scala Client](...)


## [Python Client](https://pypi.org/project/casperlabs-client/)


## Contract Development Languages Rust and AssemblyScript libraries)

Writing contracts in Rust and AssemblyScript makes it easier to get started with smart contract development because you can create a CI/CD pipeline with tests to verify that your contract is working properly.

## [Rust](https://www.rust-lang.org/)

Developers who want to use Rust (recommended for financial applications)
can create a crates project for their smart contracts and run their
contracts in a testing framework with the CasperLabs contract runtime
environment.

This enables developers to use a seamless workflow for authoring and
testing their smart contracts. This environment can also be used for
continuous integration, enabling Rust smart contracts to be managed
using development best practices.

CasperLabs provides Rust libraries and the Rust building tool - Cargo.
Note: Rust applications run on X86- simply use a different compiler to run on X86.

All our crates are published on crates.io now. https://crates.io/search?q=casperlabs

### Cargo CasperLabs tool

We also have the cargo-casperlabs CLI tool for which the documentation is with our crates [here](https://crates.io/crates/cargo-casperlabs) or in our source [here](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)

 (those two links have equivalent information - it's the README from the crate's root).

Details are on Github and we’ve simplified the process into 5 easy
steps:


## AssemblyScript

AssemblyScript [See](https://docs.assemblyscript.org/) is a form of TypeScript you can run your smart contracts on an X86 machine. If you are working in a professional development organization, this enables you to use CI/CD and verify the behavior of your code using a [testing framework](...).

AssemblyScript is a new compiler targeting WebAssembly while utilizing TypeScript's syntax and node's vibrant ecosystem. Instead of requiring complex toolchains to set up, you can simply npm install it - or run it in a browser.

