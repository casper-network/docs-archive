
Introduction
============

Welcome to the CasperLabs project, implemented as a new permissionless decentralized, public blockchain. Our open source Turing-complete smart contract platform is backed by a proof-of-stake (PoS) consensus algorithm, and WebAssembly (Wasm). Our particular consensus protocol in the CBC Casper family, built on Vlad Zamfir’s correct-by-construction (CBC) Casper work, is provably safe and live under partial synchrony without an in-protocol fault tolerance threshold.

<<<<<<< HEAD
Read our [Tech Spec](https://techspec.casperlabs.io/en/latest/) to learn more about what we're building and become a community contributor.  
=======
<<<<<<< HEAD
Read our [Tech Spec](https://techspec.casperlabs.io/en/latest/) to learn more about what we're building and become a community contributor.
=======
Read our [Tech Spec](https://techspec.casperlabs.io/en/latest/) to Learn more about what we're building so you can become a contributor....
>>>>>>> 24d29833036f71474525d59ab9ce1478b13bbcf4
>>>>>>> 845f1392099a60fe0027c996c20af0edaf064cd0

## Purpose of this guide

This guide is designed to support dApp developers getting started with the development of smart contracts on the CasperLabs blockchain with AssemblyScript contracts, and a Rust contract development kit that includes a runtime environment, reference documentation, and test framework.

## Who is this guide for
<<<<<<< HEAD
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
=======

This documentation is intended for members of our Community who build distributed applications (dApps), smart contracts using our CasperLabs features. You can install our environment locally, create and test Smart Contracts with our Smart Contracts and Test Libraries, and use these libraries to build your own applications.
>>>>>>> 51c0146f12a355b02b2632e6254c0474b159d6da

## What you need to know

It is recommended you have prior knowledge about

* Linux or OSx
* Programming knowledge
  * JavaScript and/or Python
  * Rust and/or Assembly script.

## How this guide is organized

This documentation is accessed here and located on our [GitHub](https://github.com/CasperLabs/techspec) repository, the single source of truth for all Smart Contract Developer documentation. The topics on the index include present and future documentation initiatives in our roadmap and are organized so that you will be able to:

- Understand what CasperLabs is building and how you can build your applications
- Learn how to build and operate applications on the platform
- Learn how to set up the CasperLabs environment locally
- Learn how to create and test Smart Contracts with our Libraries
- Work with our Contracts API to access our Rust resources.

See the overview and instructions for Getting Started [here](#getting-started.md).

## Background

The motivation for our roadmap is inspired by feedback we are receiving from your recommendations. We hope you continue to provide your feedback as you embark on this journey with us -- we look forward to building a decentralized future together.

## Coding Standards

[Coding Standards and Review](https://github.com/CasperLabs/CasperLabs/blob/dev/CONTRIBUTING.md) include recommendations on coding standards, and how to review and publish your code.

## Getting Help

[Getting Help](https://github.com/CasperLabs/CasperLabs/tree/dev#getting-help) - CasperLabs makes available the following resources for you to connect and get support where you can:

* Connect live with members of our Engineering Team on our [Discord Channel](https://discordapp.com/invite/mpZ9AYD) there to support you with the progress of your projects.
* Join the [CasperLabs Community Forum](https://forums.casperlabs.io/) that includes Technical discussions on using the CasperLabs features, obtain support, and pose questions to the CasperLabs core development team.
* Subscribe to CasperLabs Official [Telegram channel]((https://t.me/CasperLabs)) for general information and updated notifications about our platform.

## Feedback

If you have feedback or suggestions for improvement, please share with us.
You can [file an issue](https://github.com/CasperLabs/CasperLabs/issues/new) on our GitHub repository.

Note: For documentation feedback please file issues with links to our docs repo accessed with each page on this site. You can submit a pull request with your suggestions.

## Where will bugs be filed?

You can  report a bug on our [GitHub](https://github.com/CasperLabs/CasperLabs/issues/new) also.

