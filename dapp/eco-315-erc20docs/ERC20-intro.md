## About ERC20

The ERC20 standard, the foundation upon which the CasperLabs ERC20 is implemented, is a well established standard originating from the Ethereum ecosystem. Most Smart contract developers familiar with ERC20 use this standard to create tokens for their own implementations.

The following provides step-by-step examples to guide you through basic and advanced features of our ERC20 implementation on our blockchain using the CasperLabs development framework. Our methods allow for provisioning and transfer of tokens to be approved for spending by third party stakeholders, and used by decentralized applications, e.g. purses, etc.. Our implementation of ERC20 is covered in these sections as follows:

- Preparation - setting up your erc20 project and library
- Logic - modifying the environment and implementing methods we use
- Testing - setting up and running erc20 tests in the CasperLabs test framework
- Usage - working with the erc20 contract on our devnet

### Before getting started

Though most smart contract developers are familiar with the ERC20, we highly recommend, you take the opportunity to carefully read through the Etherium [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#). It provides for the definition of methods we'll be implementing.




