Introduction
============

Welcome to the CasperLabs project, implemented as a new permissionless, decentralized, public blockchain. Our open source Turing-complete smart contract platform is backed by a proof-of-stake (PoS) consensus algorithm, and WebAssembly (Wasm). Our particular consensus protocol in the CBC Casper family, built on Vlad Zamfir’s correct-by-construction (CBC) Casper work, is provably safe and live under partial synchrony without an in-protocol fault tolerance threshold.

Read our [Tech Spec](https://techspec.casperlabs.io/en/latest/) to Learn more about what we're building so you can become a contributor.

## Purpose of this guide

This guide highlights the set of our core documentation prioritized for you to get started with our platform so that you can install our environment locally, create and test smart contracts with our smart contracts library and test and use our libraries to build your own applications.

## Who is this guide for
This documentation is intended for members of our Community who build distributed applications (dApps), smart contracts using our CasperLabs features.

## How this guide is organized

This documentation is accessed here and located on our GitHub repository, the single source of truth for all Smart Contract Developer documentation. The topics on the index include present and future documentation initiatives in our roadmap and are organized so that you will be able to:

- Understand what CasperLabs is building and how you can build your applications
- Learn how to build and operate applications on the platform
- Learn how to set up the CasperLabs environment locally
- Learn how to create and test Smart Contracts with our Libraries
- Work with our Contracts API to access our Rust resources

## Background
The motivation for our roadmap is inspired by feedback we are receiving from your recommendations. We hope you continue to provide your feedback as you embark on this journey with us -- we look forward to building a decentralized future together.

Getting started with dApp Development
=====================================

This guide supports the development of smart contracts on the CasperLabs blockchain AssemblyScript contracts and a Rust contract development kit that includes a runtime environment, documentation, and test framework. Our Contracts Development Kit leverages the existing Rust development toolchains and ecosystem, and will work with any IDE that supports Rust development. The kit includes:

- [System (Genesis) contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/system) - to bond to the network
- [Example contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples) - smart contract examples (e.g., ERC20, Vesting, etc.)
- [Integration tests](...) - to test and debug smart contract examples

You will be able to run smart contracts in the [CasperLabs environment](https://clarity.casperlabs.io/#/) and choose to use tools you are familiar with to build your contracts and run them in the runtime environment in the order you desire and so observe the effects of contract execution in the [global state](https://techspec.casperlabs.io/en/latest/implementation/global-state.html) (the shared database that is the blockchain) -all from within an IDE of your choice.

You will be able to build, debug, deploy contracts using our CasperLabs environment and an IDE of your choice for the following scenarios:

- the CasperLabs Network
- a network of your choice
- locally

#### Cargo CasperLabs

Developers who want to use Rust (recommended for financial applications) can create a crates project for their smart contracts and run their contracts in a testing framework with the CasperLabs contract runtime environment. 

This enables developers to use a seamless workflow for authoring and testing their smart contracts. This environment can also be used for continuous integration, enabling Rust smart contracts to be managed using development best practices. 

#### Supported Operating Systems

- Unix
- Mac OS
- Windows
- Docker

## Libraries
We support building smart contracts with the following libraries.

- [Rust](...) A Rust library and Rustdocs
- [Assemblyscript](https://github.com/AssemblyScript/assemblyscript) Typescript  Library
  - [Truffle](...)

##Rustdocs

As part of the Rust development environment enhancements, we also present Rustdocs for the contracts library. The Rustdocs are available at:
- [Casperlabs Contract API](https://docs.rs/casperlabs-contract/0.2.0/casperlabs_contract/)
- [Casperlabs Types/](https://docs.rs/casperlabs-types/0.2.0/casperlabs_types/)
- [Cargo Test Engine](https://docs.rs/casperlabs-engine-test-support/)

##Smart Contracts in Assembly Script

For developers that would prefer to use a scripting type language, the W3C foundation has implemented [AssemblyScript](https://docs.assemblyscript.org/) for WebAssembly. We have created a contracts library that enables developers to create smart contracts for WebAssembly using AssemblyScript.

AssemblyScript is often conflated with TypeScript, and while these 2 languages are both scripting languages, there are several differences which are documented and contract developers should be aware of these differences.

To access the AssemblyScript contract library — you can search [here] (https://www.npmjs.com/search?q=casperlabs) or install it as follows:

`npm i @casperlabs/contract`

###GraphQL 

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

The GraphQL interface is available on every node, and public interface for [DevNet](http://devnet-graphql.casperlabs.io:40403/graphql)

## What you need to know

- Linux or OSx
- Programming knowledge
  - JavaScript and/or Python
  - Rust and/or Assembly Script

## Building contracts

Contracts are written in supported languages and compiled to Wasm for deployment from a node processed through our execution engine. Learn more about [how contracts are built and how they work with the platform](https://github.com/CasperLabs/CasperLabs/tree/release-v0.12/execution-engine/contracts/examples)

CasperLabs provides capabilities to develop contracts that include but are not limited to the following types:

- Tokenization types to use for exchanging tokens
- Storing assets catalog and tokenizing what you own
- Power to vote (stake)
- Rewards (e.g. get tokens when you purchase something)

[GIT Repository](https://github.com/CasperLabs/CasperLabs/tree/master)
All our code is open source on GitHub.

 README.md docs of a repo describe what a feature is for, what's in it, and how is it used for DApp developers

#### Coding Standards

[Coding Standards and Review](https://github.com/CasperLabs/CasperLabs/blob/dev/CONTRIBUTING.md)-- recommendations on coding standards, and how to review and publish your code

#### Getting Help

[Getting Help](https://github.com/CasperLabs/CasperLabs/tree/dev#getting-help) - Find us on Discord and Telegram.

#### Feedback

[Your feedback is welcome](...) If you have feedback or suggestions for improvement, please share with us.

Note: For documentation feedback please file issues on our docs repo or submit a pull request with your edits.





