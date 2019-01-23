---
description: 'Accounts, K/V'
---

# Global State

### Introduction

Blockchain can be viewed as decentralized, distributed database with verifiable computation layer on top. In order to do anything meaningful we need a way to store data \(in blockchain context these may be contracts, accounts etc\). From a Computer Engineering perspective Global State \(as we call this distributed and decentralized database\) can be thought of as key-value store, a mapping between byte-arrays and byte-arrays that is being replicated between nodes in the network.

### Keys

We define three types of keys:

1. Account - 160 bit identifier similar to Ethereum. Account addresses are derived from some cryptographic public key and \(as the name would suggest\) has a corresponding value which is an account. These addresses are forgable – they can be written down by anyone at any time, however, the account security is maintained via cryptography. 
2. Contract hash - 256 bit identifier, \(as the name would suggest\) derived from the hash used to label a contract stored on-chain. These hashes are derived from the triple \(public key, nonce, ID\), where the public key and the nonce come from the account that made the deploy which is storing the contract \(this is the same as Ethereum\) and the ID is simply a sequential identifier allowing each deploy to store multiple contracts and still have a unique hash for each of them. Like addresses, these are forgable keys, meaning they can be written down by anyone at any time. Unlike accounts though, the security is maintained via immutability instead of cryptographic authentication. The contract referenced by a hash is immutable by a rule enforced by the runtime, similar to Ethereum. Note that a versioned contract could be created by having an immutable contract which holds a read-only unforgable reference to the real contract; the contract maintainer could then change the contents of the mutable cell the unforgable reference points to in order to update the contract.
3. Specific unforgable references - 256 bit random identifier. These cannot be created by any source code, though new, yet unused ones, can be. The value associated with an unforgable key in the global state is a mutable cell of some data type \(see the values section below\). Unforgable references enable OCaps security by allowing dApp developers to delegate authority \(e.g. to access data or perform some action\) using these references.

### Values

We support following value types:

1. 32-bit integer
2. byte array
3. list of 32-bit integers
4. string
5. list of strings
6. Named key - tuple of string and _Key_ \(as defined in [Keys](global-state.md#keys) section\).
7. Account. Account addresses are keys in the global data store which point at accounts. Because those references are public, the semantics are much more restrictive than for the mutable cells referenced by unforgable keys. Accounts have the following properties:
   * A public key \(private\)
   * A nonce \(private\)
   * A set of known unforgable names  \(private\). Mapping between strings to names. Idea behind this map is to allow dApp developers use human readable versions of the keys.
   * A public method called `give`, which takes an unforgable reference as an argument. When you call `give` on an account, the provided unforgable reference is added to that account's set of known unforgable references. Key used for persisting the name is derived from the name itself.  **NOTE**: name can be remapped later.  **NOTE**: `give`-ing a name is more expensive that deleting it. This incentivizes dApp developers to not `give` out names.
   * A public method called `authenticate`, which takes a nonce and cryptographic signature as arguments. The `authenticate` method is only called during the first phase of a deploy, called the "login" phase. More detail is given about this below, but the essential point is that the private properties of an account can only be accessed after successfully authenticating. This means that cryptographic \(identity-based\) security is used on the boundary of the system, but full capabilities-based security is used entirely inside the system.
8. Smart Contract. The precise definition of "Smart Contract" is left purposely vague here because we want to remain agnostic to the detail of the local state, however some rules they must follow with respect to their interaction with the global state are given below. A generally good mental model for Smart Contracts would be functions from one data type to another, where these functions could possibly propose changes within the global state



