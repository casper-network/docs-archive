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


Payment Code and Session Code
-----------------------------
**Payment code**

This section overview provides explanation about what payment code is and why we have it.

The purpose of the Payment Code `--payment code` is to pay the system for the computation that the `--session code` is going to do.

The reason we do it this way (as opposed to perhaps more simpler approach like what Etherium does for example) this kind of payment code flexibility allows for more powerful paradigms around how we think about payment.

 We can extend the way we think about payment, e.g. rather than pay from a personal account, pay from a corporate account, or  offer a free trial to some user to have temporary access to freely use the blockchain. There's a lot of use cases the payment code opens up, so that is a rationale for its implementation

The payment code is as powerful as the session code, same exact instructions and libraries that you can use, turing complete im the same way, but limited in the amount of work it can do, by a very stringent amount of gas, so if you don't complete the payment within that limit, your whole deploy is going to fail. So even though payment code is powerful and flexible it also necessarily has to be computationally simple --
<!-- (this is on purpose so that we don't get Dossed out all the time).-->

So a Deploy consists of two atomic computations, `--payment` and `--session`, meaning that the payment code entirely happens and it gets submitted to the blockchain or it doesn't happen and its effects are reverted. So payment code runs out of gas, all that was done gets reverted and doesn't get committed to the chain.

Payment (e.g. transaction failure)

So if a deploy fails, the gas that it is given to run on the outset is considered like a loan, no money was given. If it fails to complete, we take the loan amount out of the accounts main purse.

(There is potential for providing options to pay in a different way if a deploy is within the standard limits, however this documention covers standard deployments.)

Funds are taken from the [main purse](...) for the computation, if the account didn't have enough CLX in the main purse to cover that loan, the account doesn't do any computation at all, it fails as a pre-condition failure.

So the minimum amounts of tokens is this loan, so there's a minimum balance we require accounts to hold. You can have exactly the minimum balance, we won't take any money from it, unless you are I the failure case, so as long as you are always submitting good payment code, you can keep the exactly the minimum balance, and that's fine. One may not choose to use the main purse as the method.

You can use whatever payment method, something other than your main purse and there are infinite ways to do this.

Standard_payment code uses the [main purse](...) of the account.

The payment code is as powerful as the session code in terms as what you are able to express in terms of logic. Whenever you see --session name and --payment the reason it is symmetric is because payment code is as powerful as session code so all of the things options you have for Session Code you have for the payment code, you can send WASM that has logic, and access previously stored contracts, it will always be symmetric because they are equally as powerful.

PC and SC are equally as powerful -- flexibility developed as a conscious piece of the design.

Technical details about Payment Code can be found [here](https://techspec.casperlabs.io/en/latest/implementation/execution-semantics.html#payment-code)


**Session Code**

`--Session Code` is the second half of a deploy, and contains the logic you really care about, i.e., the reason for what you do on the blockchain in the first place, e.g., from a simple trivial Token transfer  to complex deploy for like booking contracts, aggregating the results, and writing them into a log.

The session code is also bounded by a gas limit determined by the amount the payment code paid, less it's loan (E.g. loan is 10 and you paid a 100 you have 90 units remaining to use on your Session Code)

The session code is also an atomic unit in the sense that it entirely happens or entirely does not happen. So, for example if you run out of gas or an error occurs in your deploy, whatever causes it to fail, everything is reverted, so for example if you make nested calls, everything in that nested call gets reverted. So, if at the end of a long chain of calls the deploy runs out of gas, everything that every one of those calls did **triggerred by that session code** gets reverted.

It's a success and all effects happens, or a a failure none of those effects happens (and this conscious by design (the interest is for it  to be impossible for it to end up in a partial state)

So if contract relies on certain invariants we don't want that invariants that temporarily break during the course of an execution we want to be able to assume they are holding for an execution so we want to make it impossible to stop in the middle,

Q do we always pay a fixed amount for payment code

E.g. 10 for the loan,

Can create a payment code that pays less or more
Limited in the sense of number of lines and operations

Technically less than the cost of the payment execution which may or may not be the entire loan (if loan was 20 and Payment cost is 8 Session you would have 92 units)

So the session code is technically less

Q. estimation of execution

Not a formal tool to estimate gas e.g. gas estimator --

The way the EE works can always estimate the gas so you can do this (manual)
The EE can always estimate gas -- with a dry run (a manual process e.g. standalone node, or an EE test framework -- run it locally in same environment you expect it to run in production and estimate it that way)


This is Deterministic

Determinism is incredibly important in Blockchain

You need to get the same answer on every single node on the network, not only deterministic run to run but also on every machine as well.

Summary

PC and SC are symmetric in the sense that they are both equally as powerful and everything said that applies to one will also apply to the other.

Both atomic -- happen or don't

Session Code is conditional on payment code execution, so if payment code fails, the session code never executes, and if it succeeds, runs with a gas limit based on how much the payment code paid.


Techspec



Storing and calling contracts
-----------------------------

Detailed information about storing and calling contracts can be found [here](https://github.com/CasperLabs/CasperLabs/blob/master/docs/CONTRACTS.md#advanced-deploy-options)


Optimizing for Commutativity (Block Merging) properties
-------------------------------------------------------

Optimizations for your contracts for
[Commutativity](https://techspec.casperlabs.io/en/latest/implementation/global-state.html#permissions), i.e.

1. reduce orphaning (reduce orphaned blocks), and
1. reduce Cost (reduce costs / block sizes)
