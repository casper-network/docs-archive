# About CasperLabs ERC20

The ERC20 standard, the foundation upon which the CasperLabs ERC20 is implemented, is a well established standard originating from the Ethereum ecosystem. Most Smart contract developers familiar with ERC20 use this standard as a guideline to create tokens for their own implementations.

### CasperLabs ERC20 model

The CasperLabs [example erc20](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/erc20-smart-contract)  token contract, modeled after ERC20, includes buy and sell methods enabling us to create our own token on the platform and move this token between accounts.
Note: CLX is required to fund these transactions.

Our mandatory and optional methods allow for provisioning and transfer of tokens to be approved for spending by third party stakeholders, and used by decentralized applications, e.g. purses, etc..

Topics in this section cover the entire implementation of our ERC20 as follows:

- Preparation - setting up your erc20 project and library
- Logic - modifying the environment and implementing methods we use, this topic describes how our ERC20 functions to store transactions, and how our execution engine vm, capable of simulating deployment on our blockchain, supports tokens and other currencies
- Testing - setting up and running erc20 tests in the CasperLabs test framework
- Usage - working with the erc20 contract on our devnet

### Basics on our platform blockchain and virtual machine

Create a smart contract, managing transactions, tracking the balance of each token holder
Create, transfer and track balances, precision about errors is important to deployment
Interoperability -- custom code, talk to your contract purse
Structure - guideline

We have a blockchain that stores transactions, an execution engine that runs smart contracts, and tokens that are live on our blockchain (CRX - CasperLabs native currency (motes)) to represent many things not just currency. -- so it is very important that this is set up and managed properly since storing them on the blockchain is immutable.

**How tokens are created**
A smart contract can create a token. This smart contract not only creates tokens but also sets up how transactions are managed.

**Token variability** our ERC20 provides guidelines for you setting up and managing your tokens on our blockchain and allow for variability in how this is done,.

**How tokens are managed**
How to get tokens, you have to send some amount to the smart contract which will give you an amount of tokens in return.

**Token balances**
How to keep track account balance

**Transactions**

- Assigning authority to a user and over time, and allocating balances to that user to use in transactions, so possible for 3rd parties to handle transactions. 

- Transfers from one user address to another.


**Mandatory functions**

Our mandatory methods define the following - i.e. they must be set up in order to for the erc20 to be viable

- total -- supply of token
- balance of -- # of tokens an address has
- transfer methods -- what kinds of transfers there are a - total  supply of token
- balance of -- # of tokens an address has
- transfer methods what kinds of transfers there are and how they are done
- transfer -- total has checking the balance
- transferFrom -- address a transfer originates from
- approve -- given to user
- allows -- checks if a user has by
- name --
- symbol -- and how they are done
- transfer --  total has checking the balance
- transferFrom address -- a transfer originates from
- approve -- given to user
- allows -- checks if a user has by name
- symbol -- of token

**Optional functions**
TODOs
Our optional methods defined:
- ...
- ...
- ...
- 








