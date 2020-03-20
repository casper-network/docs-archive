# About CasperLabs ERC20

The ERC20 standard, the foundation upon which the CasperLabs ERC20 is implemented, is a well established standard originating from the Ethereum ecosystem. Most Smart contract developers familiar with ERC20 use this standard as a guideline to create tokens for their own implementations.

### ERC20 model

The [example token](_) contract, modeled after ERC20, includes buy and sell methods enabling us to create our own token on the platform and move this token between accounts.
Note: CLX is required to fund these transactions.

Our mandatory and optional methods allow for provisioning and transfer of tokens to be approved for spending by third party stakeholders, and used by decentralized applications, e.g. purses, etc..

The following sections guide you through the implementation of our ERC20 as follows:

- Preparation - setting up your erc20 project and library
- Logic - modifying the environment and implementing methods we use, this topic describes how our ERC20 works to store transactions, and our virtual machine capable of running on a blockchain supports tokens and other currencies
- Testing - setting up and running erc20 tests in the CasperLabs test framework
- Usage - working with the erc20 contract on our devnet

### <!--Basics on our platform blockchain and virtual machine-->



increment the balance





<!--Created by a smart contract, managing transactions, tracking the balance of each token holder-->

<!--Create, transfer and track balances, errors are important-->

<!--Interoperability -- custom code, talk to your contract Wallets ---->
<!--Structure - guideline-->

<!--Mandatory functions-->
<!--methods defines total  supply of token-->
<!--balance of # of tokens an address has-->
<!--transfer methods-->
<!--transfer -- total has-->
<!--transferFrom-->
<!--approve -- give to user-->
<!--allows -- checks if a user has-->
<!--name-->
<!--symbol-->

<!--Optional-->







