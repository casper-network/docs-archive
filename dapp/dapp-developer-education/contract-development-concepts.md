Writing contracts
=================

A Wasm module is not natively able to create any effects outside of reading / writing from its own linear memory. To enable other effects (e.g. reading / writing to the CasperLabs global state), Wasm modules must import functions from the host environment they are running in. In the case of contracts on the CasperLabs blockchain, this host is the CasperLabs Runtime.

Briefly descriptions of the functionalities provided by imported function. All these features are conveniently accessible via functions in the CasperLabs rust library.

For a more detailed description of the functions available for contracts to import, see [Appendix A.](https://techspec.casperlabs.io/en/latest/implementation/execution-semantics.html#the-casperlabs-runtime)

Details about our runtime can be found in our Techspec [here](https://techspec.casperlabs.io/en/latest/implementation/appendix.html#a-list-of-possible-function-imports)

The [ContractAPI](https://docs.rs/casperlabs-contract-ffi/0.22.0/casperlabs_contract_ffi/#writing-smart-contracts) provides support for writing smart contracts.

All our crates are published on [crates.io](https://crates.io/search?q=casperlabs).
We highlight the following for DApp developement

[CasperLabs Rust Types](https://docs.rs/casperlabs-types)

[CasperLabs Contract API](https://docs.rs/casperlabs-contract)

[CasperLabs Execution Engine Test Framework](https://docs.rs/casperlabs-engine-test-support)

[Cargo Casperlabs Crate](https://crates.io/crates/cargo-casperlabs) or 

[Cargo CasperLabs Git Repository](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/cargo-casperlabs)

[Contract exit codes Source](https://docs.rs/casperlabs-types/latest/casperlabs_types/enum.ApiError.html#mappings)

<!--Structuring your project-->
------------------------
<!--<!--Video [CasperLabs - Smart contract template repository v0.0.1] (https://www.youtube.com/watch CasperLabs - Smart contract template repository v0.0.1] ch?v=P8SC_upCqAg&feature=youtu.be)-->-->

<!--Directories structure is designed for developing, building, and testing  Rust contracts.-->

- <!--Smart Contracts-->
- <!--Tests-->
- <!--System contracts-->
- <!--Cargo-->
- <!--Rust tool chain-->

https://github.com/CasperLabs/CasperLabs/blob/master/docs/KEYS.md)



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

#### Deploy Dependencies see [Advanced usage ](CONTRACT.md)

**Commutativity**
the execution order does not matter (the commutativity approach), 

<!--see Mateuz demo from GMT20200128-160316_Sprint-Dem_3840x2160 (1).mp4-->

Commutativity Checking 

[Optimizations for your contracts for Commutativity](https://techspec.casperlabs.io/en/latest/implementation/global-state.html#permissions):

**Merging**

Commutativity is one of ways to establishing merging. Canonical order is just another way. see [here](https://casperlabs.atlassian.net/wiki/spaces/~167734600/pages/88244226/Handling+overflows+during+merging+for+DEVNET)


Concretely Merging -- Merging is about establishing consensus on the order of execution. 

More broadly it about ensuring the resulting post-state is well-defined; that is to say there is no ambiguity as to what the result of the merge is.

Another way to put this is that commutativity checking is one way to ensure the (finalized subdag's) partial order is strong enough to uniquely define that final state.


 Merging condition is based on independence of ordering, the problem of merging is reduced to the problem of checking whether transactions commute. Detect commutativity without needing to re-run transactions in multiple orders. To achieve this we define what has come to be known as the "op-algebra" which summarizes what operations can be done on a value (read, write, add), how they combine when multiple operations are done a single value, and their commutativity properties.

see Techspec [NewBlocks](https://github.com/CasperLabs/techspec/blob/master/implementation/p2p.rst#newblocks)

See [block_hashes and message size](https://github.com/CasperLabs/techspec/blob/master/implementation/p2p.rst#picking-nodes-for-gossip)

### Global State Permissions

1. Reduce orphaning (reduce orphaned blocks) i.e. not becoming part of the DAG.

For more details see Techspec [Fairness](https://techspec.casperlabs.io/en/latest/implementation/p2p.html#fairness)

2. Reduce Cost (reduce costs / block sizes)
