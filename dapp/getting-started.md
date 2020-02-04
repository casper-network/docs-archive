Getting started
===============

This guide is intended to support the development of smart contracts on the CasperLabs blockchain. Content covers what is included in our CasperLabs contract development kit enabling developers to run smart contracts in the CasperLabs runtime environment:

- system (Genesis) contracts
- Example contracts - ERC20 example
- Integration tests

You can use this guide to install and build dApps to run:

- On our network (DevNet)
- Your network of choice
- Your local environment


Selecting an IDE
----------------
You can use the [CasperLabs environment]( ~~LoremIpsem~~) or choose to use tools you are familiar with to build your contracts and run them in the engine in the order you desire and so observe the effects of contract execution in the global state (the shared database that is the blockchain) -all from within an IDE of your choice.


## Pre-requisites

- Rust
- Rust language support
- Cargo
- client (~~LoremIpsem~~)
- client lang

## Using the CasperLabs runtime environment

1. Install the CasperLabs Rust Tool Chain

`clone https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine`

1. Check your Pre-requisites


## Using a Runtime environment of your choice

You must choose an IDE that supports Rust. Additionally, we recommended you choose an application which enables you to more easily both write and debug your contracts.

You can find Rust recommended tools [here](https://www.rust-lang.org/tools)

1. Select and setup your runtime environment

**Example,**

Sublime + Console

We chose to work with sublime for this example.

1. Download and install Sublime

 ....

1. Setup your environment

   1. Install the CasperLabs Rust Tool Chain

`clone https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine`

   1. Check your Pre-requisites



Opening the execution-engine project
------------------------------------

`https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine`



How to use the CasperLabs runtime environment
---------------------------------------------



Deploying and Testing contracts to the DevNet
---------------------------------------------

### Deploy

see [CONTRACT](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md)

1. ...
2. ...
3. ...

### Test

See [Querying the CasperLabs platform](https://github.com/CasperLabs/CasperLabs/blob/master/docs/QUERYING.md#background)

1. ...
2. ...
3. ...


### Execution error codes
-------------------------

You can find a listing and description of each error code at the following locations:

see Enum Contract FFI Error Enum [](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html)

see Source [Contract_API error ](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)

...
