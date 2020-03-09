## CasperLabs dApp development toolkit

To get you started with developing dApps, CasperLabs has released a contract development kit leveraging our CasperLabs Rust development toolchain and ecosystem. This kit will work with any IDE that integrates with Rust development.

You will be able to run smart contracts in a CasperLabs runtime environment (Execution Engine (EE)) using IDE you choose to build your contracts and run them in the runtime environment in the order you desire and so observe the effects of contract execution in the [global state](https://github.com/CasperLabs/techspec/blob/master/implementation/global-state.rst) (the shared database that is the blockchain). 

The kit includes: 

- [Example contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples) - smart contract examples for the CasperLabs contract library with tutorials for you to easily follow our standard and more advanced contracts (e.g. ERC20, Vesting, Tic Tac Toe) contracts.
- [Integration tests](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/test) -  The Cargo CasperLabs tool provides also provides for testing and debugging smart contracts in our runtime environment (Execution Engine) so that you can run a contract locally and see it's effects.

### Supported Platforms

- Unix
- Mac OS
- Windows

## Libraries

We support building smart contracts with Rust and AssemblyScript libraries.

## Rust

[Rust Library](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs/src) includes Rust source code found on our GitHub.

[Rustdocs](https://docs.rs/releases/search?query=casperlabs) are part of the Rust development environment enhancements. We also present Rustdocs with our Rust contracts library available in our Rust Crates repository where you can find the here recommended documentation to develop your projects.

[Casperlabs Contract API](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/) - Rust library for writing smart contracts

[Casperlabs Types](https://docs.rs/casperlabs-types/0.2.0/casperlabs_types/) - Types allow for the creation of Wasm contracts and tests for use on the CasperLabs Platform

[Cargo Test Engine](https://docs.rs/casperlabs-engine-test-support/) - Test library to support testing of Wasm smart contracts for use on the CasperLabs Platform

[Cargo CasperLabs](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs) Developers who want to use Rust (recommended for financial applications) can use this tool that provides a command line interface to create a crates project for your smart contracts and run them in our testing framework in our runtime environment. This enables you to have a seamless workflow for authoring and testing your smart contracts, as well as implementing continuous integration so that Rust smart contracts can be managed with recommended development best practices.

Build Cargo Casperlabs from source for developing dApps with CasperLabs Rust libraries. CasperLabs Cargo bundles all common actions into a single command with no boilerplate required, helps you create your project, setup your build environment, build and test your code, and perform continuous integration according to recommended best practices. 

## GraphQL 

Write and execute your smart contract on our platform and read data from the network using CasperLabs' GraphQL APIs:

* CasperLabs GraphQL API reference documentation and schema is accessed via the console, and from every node, and public interface for our [DevNet](http://devnet-graphql.casperlabs.io:40403/graphql)
* You can access our GraphQL Console on our [Clarity self-service portal](https://clarity.casperlabs.io/#/)

Note: If you are not familiar with GraphQL you can find a set of resources like tutorials at the [Graphql website](https://graphql.org/)

Our GraphQL supports retrieving the child relationships given a block hash provided in the following query.

Example query:

```query
query {block(blockHashBase16Prefix: "a3016e93f101da2781eae0696064df8c1ca770058b1d1eae261cfd4034f47547") {
blockHash
parents {
   children {
     blockHash
     }
   }
  }
}
```

[GIT Repository](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0) All our code is open source on GitHub. README.md docs are included with the of a repository describing what a feature is for, what it includes (e.g. source code and libraries,  and how is it used for developing dApps).

## What you need to know

We recommend familiarizing yourself with the following resources:

- Familiarize yourself with CasperLabs Basics covered in the documentation of our [GitHub repository](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/docs)
- You have an account at [clarity.casperlabs.io](https://clarity.casperlabs.io/#/) with motes added to this account, instructions are provided in the /docs folder in the [CONTRACTS.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#step-3-create-an-account-at-claritycasperlabsio) documentation for Deploying Contracts
- Demo: [Using the Contracts Kit Workshop](https://casperlabs.atlassian.net/wiki/spaces/REL/pages/279707738/Using+the+Contracts+Kit+Workshop) 
- Demo: [Stored Contracts -Using the Contracts Kit Workshop](https://casperlabs.atlassian.net/wiki/spaces/REL/pages/294584327/Stored+Contracts+-Using+the+Contracts+Kit+Workshop)
- [rust-lang.org](https://www.rust-lang.org/) -  Rust
- AssemblyScript - if you choose to work with AssemblyScript familarize yourself with AssemblyScript and our implementation [here](...)
- WASM - WebAssembly is the language your contracts are compiled to, see detailed information about Wasm [here](https://webassembly.org/)