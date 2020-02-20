## Get started with Contract Development

This guide is intended to support the development of smart contracts on the CasperLabs blockchain. Content covers what is included in our CasperLabs contract development kit enabling developers to run smart contracts in the CasperLabs runtime environment. The development Kit includes:

- system (Genesis) contracts - to bond to the network
- Example contracts - smart contract examples
- Integration tests - to test and debug smart contract examples

With this Kit Using you will be able to build, debug, deploy contracts using our CasperLabs environment or the environment of your choice for the following scenarios:

- the CasperLabs Network
- a network of your choice
- locally

#### Supported Operating Systems
- Unix
- Mac OS
- Windows
- Docker

#### Supported Languages to build contracts

We support building smart contracts with libraries provided for the following languages.

- [Rust](...) A Rust library for writing smart contracts on the [CasperLabs Platform](https://techspec.casperlabs.io/).
- [Assemblyscript](https://github.com/AssemblyScript/assemblyscript) Typescript  Library 
  - [Truffle](...)

### Pre-requisites to build smart contracts

- Using our [CasperLabs  binaries](https://github.com/CasperLabs/CasperLabs/releases) you can build your contracts to deploy to the CasperLabs Network or network of your choice

- [Building from source](https://github.com/CasperLabs/CasperLabs/tree/dev/comm#build-from-the-source) for
  - building your contracts to deploy to the CasperLabs Network or network of your choice
  - customization, versioning, optimization of compiling process 
  - making your code visible on the blockchain for full transparency

##### Pre-requisites

- Install [rustup](https://rustup.rs/)
- Install the [Casperlabs client]() (`WASM`, `Python`)
- [Cargo](https://crates.io/) -- "Cargo is the build tool for Rust. It bundles all common actions into a single command. No boilerplate required."
- [SBT](https://www.scala-sbt.org/index.html)
"The interactive Scala build tool where you can efine your tasks in Scala and run them in parallel from sbt's interactive shell."
  

  ## What you need to Know

  [How contracts are built and how they work with the platform](https://github.com/CasperLabs/CasperLabs/tree/release-v0.12/execution-engine/contracts/examples)

  Contracts are written in supported languages and compiled with WASM.

  - [GIT Repository](https://github.com/CasperLabs/CasperLabs/tree/master)
  All our code is open source on GitHub.

  What's it for, what's in it, how is it used for DApp developers

  - [Contract Categories] -- Categories of contracts and their purpose

    - ...
    - ...
    - ...


  - [Coding Standards and Review](https://github.com/CasperLabs/CasperLabs/blob/dev/CONTRIBUTING.md)-- recommendations on coding standards, and how to review and publish your code

  - [Getting Help](https://github.com/CasperLabs/CasperLabs/tree/dev#getting-help) - Find us on Discord and Telegram.

  - [Your feedback is welcome](...) If you have feedback or suggestions for improvement, please share with us. For documentation feedback please file issues on our docs repo or submit a pull request with your edits.


  ## Using Rust

  [GITHub Source](https://github.com/CasperLabs/CasperLabs/blob/master/execution-engine/contract-ffi/src/lib.rs)


  ## SmartContractAPI.md

The [Smart contract API](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/) is a Rust library for writing smart contracts on the [CasperLabs Platform](https://techspec.casperlabs.io). With the modules, and most importantly the submodules of the `contract_api` the core set of contract-writing modules, function documentation, and in-line examples in certain cases

  ### Setting up your environment


  ### [CasperLabs Execution Environment](https://github.com/CasperLabs/CasperLabs/tree/main)

Purpose of what it is for, What it is - composition, process - how does it work, 

  - system (Genesis) contracts - to bond to the network
  - Example contracts - smart contract examples
      ERC20 example,
      Vesting,
      Tic Tac toe

  - Integration tests - to test and debug smart contract examples

  ### [IDE of your choice](https://www.rust-lang.org/tools)

  ### 	[CasperLabs Dev Kit Repo](...)

          - Structure
            - Cargo
            - Smart Contracts
            - Tests


​    

    ## WritingContracts.md
    
    #### Contract samples
    
    - Bonding     call - to bond to a network 
    
    - Call     Counter - Implementation of smart contract, that     increments previously deployed counter.
    
    - Deploy Counter - Implementation of URef-based counter.
    
    - Payment     Code
    - ERC 20 -- 
    
    ## Instructions

  1. [Clone the repository] (https://github.com/CasperLabs/CasperLabs/tree/main)

  2. Install the kit

  3. [Open the project in your IDE]
   4. Navigate to `casperlabs-smart-contract`

  - View Directories

  - cargo - what's in it and what it's for

  - [contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples) - with sample contracts from main repo (Rust)

    - [template ](...)- examples
    - [counter define](...) - create smartcontract that holds the counter
    - [counter call](...) -- bumps the counter
    - [vesting](...) --

  - tests

    tests to build, deploy, and debug your contracts

    - Cargo.toml - for the purposes of
    - [Cl_test_..py](...) - in order to
    - [Cl_test_...py](...) - in order to
    - [Makefile.toml](...) - to build the contract
    - [README.md](...) - 
    - [rust-toolchain](...) - to build and deploy your test contracts

    

    Scenario 1

    Deploy as wasm follows -- to block chain, 

    check count value -- 

    - functions - get value (graph QL checks value of counter after deployment should be zero 0 
    - deploy counter call and value should be 1, do it again and it should bump the value  


  #### Debuggingcontracts.md

 To debug contract ... 

####Deploying Contracts

- Once contracts are debugged, you can deploy them following the instructions [here](https://github.com/CasperLabs/CasperLabs/blob/dev/docs/DEVNET.md#deploying-code)

  to the CasperLabs Network [DEVNET.md]()



  #### Errors

Error Types
- [System](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/types/src/system_contract_errors) contract errors

- smart contract errors

- [Api errors](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/types/src/api_error.rs) (PoS, Mint errors,...) 
  
- Contract FFI [Errors] (...)
  
  

 

 

 

 

 

