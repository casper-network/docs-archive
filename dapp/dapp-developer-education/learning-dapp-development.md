
Learning About dApp Development
===============================

The following provides in-depth information for what new dApp developers need to know about blockchain and best practices for building smart contracts on the CasperLabs platform.

About Building Contracts
------------------------
(Initiative #1)

[Building Contracts](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md)

About the CasperLabs Blockchain
-------------------------------

[About the CL Blockchain](https://techspec.casperlabs.io/en/latest/implementation/index.html#casperlabs-blockchain-design)

### Blockchain 101

[Blockchain 101](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/8028213/Reading+List#ReadingList-Blockchain101)

- Shared Global State
[Shared global state](https://techspec.casperlabs.io/en/latest/implementation/global-state.html#global-state-head)


### CasperLabs Blockchain 101

- The DAG structure

The DAG structure allows for the acknowledgement (as per the second point) of multiple blocks. This in turn serves as a “join” operation and allows independent branches be merged into a single branch, thus reducing the time to reach consensus.

see [Techspec Theory Blockdag](https://techspec.casperlabs.io/en/latest/theory/naive-blockchain.html#blockdag)

see [Techspec Theory Dag vs Poset Language](https://techspec.casperlabs.io/en/latest/theory/naive-blockchain.html#dag-vs-poset-language)

see [Highway](https://techspec.casperlabs.io/en/latest/theory/highway.html#motivation)

- Block Merging in CL

- Finalization and Safety
  [Finalization](https://techspec.casperlabs.io/en/latest/theory/abstract-consensus.html#finality) & [Safety Theory](https://techspec.casperlabs.io/en/latest/theory/highway.html#highway)

  - [Theory](...)
  - [Implementation](https://techspec.casperlabs.io/en/latest/implementation/p2p.html#communications)


### Rust 101

- Purpose of Rust in general
- Purpose, Objectives, and interest of Rust in CasperLabs
  Contracts are built with Rust and compiled to WASM
  - About WASM
- Composition of Rust Language
- Process of working with Rust Language
- summary, conclusions - relations, synthesis

### Writing Contracts on CasperLabs Platform

About writing contracts on our CasperLabs platform.
How this works.

- The contract API
    - description of the contract api
    - purpose of the contract api
    - composition of the contract api
    - how to use the api
    - summary, conclusions - relations, synthesis

### Structuring your project

- My_project IDE project structure
      - description of your project
      - purpose of your project
      - composition of your project
      - how to open your project
      - how to structure your projects
      - summary, conclusions - relations, synthesis


### Testing your project
- CasperLabs Cargo tool
    - description of the tests
    - purpose, objectives, and interests of the tests
    - composition of the tests
    - process of how to use and run the tests
    - summary, conclusions - relations, synthesis


### Using GraphQL

- CasperLabs Clarity
    - description of the GraphQL
    - purpose, objectives, and interests of GraphQL
    - composition of working with GraphQL
    - process of how to use and run GraphQL
    - summary, conclusions - relations, synthesis


#### GraphQL debug contracts

- GraphQL console located [here](http://devnet-graphql.casperlabs.io:40403/graphql) can also be accessed through our Clarity self service portal for you to interact with the blockchain.

 Pre-requisites

  - description of debugging contracts GraphQL
    - purpose, objectives, and interests of debugging contracts with GraphQL
    - composition of debugging contracts with GraphQL
    - process of how to use and debug contracts with GraphQL
    - summary, conclusions - relations, synthesis


#### Using GQL To learn about the network

- Devnet
  - description of the network
  - purpose, objectives, and interests of the network
  - composition
  - he network
  - summary, conclusions - relations, synthesis

