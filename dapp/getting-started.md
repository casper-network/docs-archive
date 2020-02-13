
Getting started
===============


This guide is intended to support the development of smart contracts on the CasperLabs blockchain enabling developers to run smart contracts in the CasperLabs runtime environment included with our CasperLabs contract development kit:

- [System (Genesis) contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/system) - to bond to the network
- [Example contracts](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples) - ERC20 example - smart contract examples
- [Integration tests](...) - to test and debug smart contract examples


How to Use this guide
---------------------

You can use this guide to build DApps to run:

- On our network (DevNet)
- Your own network
- Your local environment

You can use the [CasperLabs environment](https://clarity.casperlabs.io/#/) and choose to use tools you are familiar with to build your contracts and run them in the engine in the order you desire and so observe the effects of contract execution in the global state (the shared database that is the blockchain) -all from within an IDE of your choice.


Pre-requisites
--------------

- [Rust](https://www.rust-lang.org/tools/install)
  - Cargo RPM
- IDE with Rust support
- CasperLabs client
  - client language
- CasperLabs Repository

Using the CasperLabs runtime environment
----------------------------------------

1. Install the CasperLabs Rust Tool Chain
1. Clone the [repository](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine)

1. Check your Pre-requisites


Selecting an IDE
------------------------------------------

Choose an IDE that has Rust support. We recommended you choose an application which enables you to more easily both write and debug your contracts.

You can find Rust recommended tools [here](https://www.rust-lang.org/tools)

1. Select and setup your environment
   1. you have rust language tools
   2. rust
   3. 



`clone https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine`

   1. Check your Pre-requisites


Opening the project
------------------------------------

1. navigate to the directory of the execution engine 

   Your casperlabs directory/execution-engine



Use the CasperLabs runtime environment
---------------------------------------------





Writing Contracts
-----------------

CasperLabs provides capabilities to develop contracts that include but are not limited to the following types:

- Tokenization types to use for exchanging tokens
- Storing assets, catalog and tokenizing what you own ---- power to vote (stake)
- Rewards (e.g. get tokens when you purchase something)
  

#####Example Contracts:

- Tokens -- distributing tokens
- Payment processing
- Receiving payments
- Vesting Contracts
- Auctions 
- Voting
- Games
  - Tic Tac Toe
<!--- Other -- Category-->
<!--  - Specialized commerce apps-->
<!--  - Distributed versions (e.g. ride sharing)-->
<!--  - Supply chain management-->

 

Deploying and Testing contracts to the DevNet
---------------------------------------------

### Deploy

For instructions on Deploying Contracts see [CONTRACT](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md)



### Test

For instructions on Testing your Contracts

See [Execution Engine Test Framework]()



Execution error codes
---------------------

You can find a dynamically generated list with descriptions of each error code in our Rust and source documentation respectively:

see [Enum Contract FFI Error Enum](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/contract_api/enum.Error.html)

see Source [Contract_API error ](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138)

