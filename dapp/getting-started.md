# Getting started with dApp development

Our CasperLabs Rust contracts development kit leverages the existing Rust development toolchains and ecosystem, and will work with any IDE that supports Rust development.   

You will be able to run smart contracts in the [CasperLabs environment](https://clarity.casperlabs.io/#/) using tools you choose to build your contracts and run them in the runtime environment in the order you desire and so observe the effects of contract execution in the [global state](https://github.com/CasperLabs/techspec/blob/master/implementation/global-state.rst) (the shared database that is the blockchain). The kit includes:

- [System (Genesis) contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/system) provided so that you may bond to the network,

- [Example contracts](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/examples) - smart contract examples for the CasperLabs contract library with tutorials so you can use our standard and more advanced contracts, including but not limited to ERC20, Vesting, etc.,
- [Integration tests](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/contracts/test) -  for you to test and debug smart contracts

You may choose to build, debug, deploy contracts using our CasperLabs environment and an IDE of your choice running your contracts with the following scenarios:

* the CasperLabs Network
* a network of your choice
* locally

### Supported Operating Systems

- Unix
- Mac OS
- Windows
- Docker

## Cargo CasperLabs Tool

Developers who want to use Rust (recommended for financial applications) can use this tool with a command line interface to create a crates project for your smart contracts and run them in our testing framework in the CasperLabs contract runtime environment.

This enables you to have a seamless workflow for authoring and testing your smart contracts, as well as for continuous integration so that Rust smart contracts to be managed with development best practices.

## Libraries

We support building smart contracts with Rust and AssemblyScript libraries.

### Rust

[Rust Library](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/execution-engine/cargo-casperlabs/src) includes Rust source code found on our GitHub.

[Rustdocs](https://docs.rs/releases/search?query=casperlabs) are part of the Rust development environment enhancements. Ee also present Rustdocs with the Rust contracts library available in our Rust Crates repository where you can find the following recommended documentation to develop your projects:

- [Casperlabs Contract API](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/) - Rust library for writing smart contracts
- [Casperlabs Types](https://docs.rs/casperlabs-types/0.2.0/casperlabs_types/) - Types allow for the creation of Wasm contracts and tests for use on the CasperLabs Platform
- [Cargo Test Engine](https://docs.rs/casperlabs-engine-test-support/) - library to support testing of Wasm smart contracts for use on the CasperLabs Platform

### Assembly Script Smart Contracts

For developers that would prefer to use a scripting type language, the W3C foundation has implemented [AssemblyScript](https://docs.assemblyscript.org/) for WebAssembly. You can use the contracts library to create smart contracts for WebAssembly using AssemblyScript.

Our CasperLabs AssemblyScript contract library may be downloaded from [NPM](https://www.npmjs.com/search?q=casperlabs), or you can install it from your command line.

`npm i @casperlabs/contract`

Note: AssemblyScript is often conflated with TypeScript, and while these 2 languages are both scripting languages, there are several differences documented for contract developers to be aware of.

## GraphQL

Write and execute your smart contract on our platform and read data from the network using CasperLabs' GraphQL APIs:

* You can access our GraphQL Console on our
  [Clarity self-service portal](https://clarity.casperlabs.io/#/)
* CasperLabs GraphQL API reference documentation and schema may be accessed
  via the console and from every node, and public interface for our
  [DevNet](http://devnet-graphql.casperlabs.io:40403/graphql)
* If you are not familiar with GraphQL you can find a set of resources
  like tutorials at the [Graphql website](https://graphql.org/)

Our GraphQL supports retrieving the child relationships given a block hash.

Example query:

```
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



## Building contracts

Contracts are written in supported languages and compiled to Wasm for
deployment from a node processed through our execution engine. Learn
more by viewing the [README.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/execution-engine/contracts/examples/README.md) about how contracts are built and [how they operate on the platform](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md)

CasperLabs provides capabilities to develop contracts that include but
are not limited to the following types:

- Tokenization types to use for exchanging tokens
- Storing assets catalog and tokenizing what you own
- Power to vote (stake)
- Rewards (e.g. get tokens when you purchase something)

[GIT Repository](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0)
All our code is open source on GitHub. README.md docs are included with
the of a repository describing what a feature is for, what's in it, and
how is it used for developing dApps.

