Writing contracts
=================

The [ContractAPI](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/#writing-smart-contracts) provides support for writing smart contracts.

Structuring your project
------------------------

<!--Video [CasperLabs - Smart contract template repository v0.0.1] (https://www.youtube.com/wat CasperLabs - Smart contract template repository v0.0.1] ch?v=P8SC_upCqAg&feature=youtu.be)-->

Directories Structure

- Smart Contracts
- Tests
- System contracts
- Cargo
- Rust tool chain


Weighted Keys and Thresholds
----------------------------

Workshop [Weighted Keys](https://casperlabs.atlassian.net/wiki/spaces/REL/pages/213123657/1-23-2020+Workshop+-Weighted+Keys)

Video [Adjusting Key weights and thresholds](https://www.youtube.com/watch?v=R24-3iIau0g)

Confluence [Key Management](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/128974920/Key+Management)

GIT [KEYS.md](https://github.com/CasperLabs/CasperLabs/blob/master/docs/KEYS.md)



[Payment Code](https://techspec.casperlabs.io/en/latest/implementation/execution-semantics.html#payment-code)
------------


[Storing contracts & calling them](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md#advanced-deploy-options)
--------------------------------




Optimizing for Commutativity (Block Merging) properties
-------------------------------------------------------

Optimizations for your contracts for
[Commutativity](https://techspec.casperlabs.io/en/latest/implementation/global-state.html#permissions), i.e.

1. reduce orphaning (reduce orphaned blocks), and
1. reduce Cost (reduce costs / block sizes)
