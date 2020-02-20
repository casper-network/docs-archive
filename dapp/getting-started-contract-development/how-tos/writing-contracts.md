Writing contracts
=================

The [ContractAPI](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/#writing-smart-contracts) provides support for writing smart contracts.

All our crates are published on crates.io [here](https://crates.io/search?q=casperlabs)
<!--The ones which I think are worth pointing out to app devs are-->
We highlight the following for DApp developement
1. CasperLabs Rust Types are located [here](https://docs.rs/casperlabs-types)
1. CasperLabs Contract API [here](https://docs.rs/casperlabs-contract)
1. CasperLabs Execution Engine Test Framework is located [here](https://docs.rs/casperlabs-engine-test-support)

1. Additionally, we provide the cargo-casperlabs CLI tool for which the best documentation is either
[here] (https://crates.io/crates/cargo-casperlabs) or [here](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)

(these links have equivalent information - including the README from the crate's root).

The list of contract exit codes is located [here](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)

Structuring your project
------------------------
<!--Video [CasperLabs - Smart contract template repository v0.0.1] (https://www.youtube.com/wat CasperLabs - Smart contract template repository v0.0.1] ch?v=P8SC_upCqAg&feature=youtu.be)-->

Directories structure is designed for developing, building, and testing  Rust contracts.

- Smart Contracts
- Tests
- System contracts
- Cargo
- Rust tool chain


Weighted Keys and Thresholds
----------------------------

Details about the global state and keys is located [here](https://techspec.casperlabs.io/en/latest/implementation/global-state.html#global-state)

Workshop [Weighted Keys](https://casperlabs.atlassian.net/wiki/spaces/REL/pages/213123657/1-23-2020+Workshop+-Weighted+Keys)

Video [Adjusting Key weights and thresholds](https://www.youtube.com/watch?v=R24-3iIau0g)

Confluence [Key Management](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/128974920/Key+Management)

GIT [KEYS.md](https://github.com/CasperLabs/CasperLabs/blob/master/docs/KEYS.md)



##Deploys 

A Deploy consists of two atomic computations, `--payment` and `--session`. The payment code and session code are symmetric in the sense that they are both equally as powerful and everything that applies to one will also apply to the other.

*- Payment code* provides the logic used to pay for the computation the deploy will do. See technical details about Payment Code [here](https://techspec.casperlabs.io/en/latest/implementation/execution-semantics.html#payment-code).

*- Session code*is the second half of a deploy, and contains the logic you really care about, i.e. the reason for what you do on the blockchain in the first place, -- from a simple trivial Token transfer to complex deploy for like booking contracts, aggregating the results, and writing them into a log.

The payment code and session code are both atomic -- they either happen or don't happen. The payment code entirely happens and it gets submitted to the blockchain or it doesn't happen and its effects are reverted. If payment code runs out of gas, all that was done gets reverted and doesn't get committed to the chain. 

Hence, session code is conditional on payment code execution, so if payment code fails, the session code never executes, and if the payment code succeeds, the session code runs with a gas limit based on how much the payment code paid.

For further details about payment and session code see the Techspec [here] 

###Storing and calling contracts

####Stored contracts

A function that is part of the deployed contract's module can be saved on the blockchain with Contract API function `store_function`. Such function becomes a stored contract that can be later called from another contract with `call_contract` or used instead of a WASM file when creating a new deploy on command line.

**Contract address**

A contract stored on blockchain with `store_function` has an address, which is a 256 bits long Blake2b hash of the deploy hash and a 32 bits integer function counter. The function counter is equal `0` for the first function saved with `store_function` during execution of a deploy, `1` for the second stored function, and so on.



### Calling contracts

**Calling a stored contract using its address**

Contract address is a cryptographic hash uniquely identifyiyng a stored contract in the system. Thus, it can be used to call the stored contract, both directly when creating a deploy, e.g. on command line or from another contract.

`casperlabs-client` `deploy` command accepts argument `--session-hash` which can be used to create a deploy using a stored contract instead of a file with a compiled WASM module. Its value should be a base16 representation of the contract address, 

for example: 

`--session-hash 2358448f76c8b3a9e263571007998791a815e954c3c3db2da830a294ea7cba65`.

Note:  `payment-hash` is an option equivalent to `--session-hash` but for specifying address of payment contract.



Detailed information about storing and calling contracts can be found [here](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md#advanced-deploy-options)



Optimizing for Commutativity (Block Merging) properties
-------------------------------------------------------

Optimizations for your contracts for Commutativity](https://techspec.casperlabs.io/en/latest/implementation/global-state.html#permissions), i.e.

1. reduce orphaning (reduce orphaned blocks), and
1. reduce Cost (reduce costs / block sizes)
