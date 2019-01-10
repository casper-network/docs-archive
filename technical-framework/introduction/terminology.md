# Terminology

* Account – a special part of the global state with cryptographic protection. All deploys must "login" to an account before executing. This pushes all non-Object Capability security to the very boundary of the system.
* Commute – Two deploys, A and B, commute if the same final global state is reached independent of the order they are applied, i.e. GS -\(AB\)→ GS'; GS -\(BA\)→ GS''; GS' == GS''. In general, a set of deploys commute if they can be applied to the global state in any order and reach the same final state. 
* DAG – Directed Acyclic Graph
* Deploy – an atomic piece of code sent by a user to be executed on-chain. E.g. declaring a new contract for others to use; calling an existing contract; transferring tokens; etc.
* Global state – the state which is replicated by the blockdag. E.g. on Ethereum this is the set of accounts \(including their balances, code and storage\); This will be a key-value store supporting particular operations to enable concurrent access.
* Hash – One-way function for computing a fixed length output from a variable length input. The hash function we will use will be blake2b256.
* Local state – the private state which only a single deploy has access to. E.g. on Ethereum this is the EVM state. This will be the wasm interpreter state.
* Payment code – Deploy piece; WASM bytecode which is run on "credit" and pays the validators for running the "session code".
* Session code – Deploy piece; the WASM bytecode the user wishes to execute and cause effects on-chain \(e.g. transferring tokens, interacting with a dapp\). Must be paid for by "payment code".
* Unforgable reference – A type of key for the global state. A specific unforgeable reference cannot be created, it can only come from the original. This is important in the Object Capability security model.

