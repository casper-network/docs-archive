---
description: 'Accounts, K/V'
---

# Global State

### Introduction

Blockchain can be viewed as decentralized, distributed database with verifiable computation layer on top. In order to do anything meaningful we need a way to store data \(in blockchain context these may be contracts, accounts etc\). From a Computer Engineering perspective Global State \(as we call this distributed and decentralized database\) can be thought of as key-value store, a mapping between byte-arrays and byte-arrays that is being replicated between nodes in the network.

### Keys

We define three types of keys:

1. Account - a 160-bit identifier similar to Ethereum. Account addresses are derived from some cryptographic public key and \(as the name would suggest\) has a corresponding value which is an account. These addresses are forgable – they can be written down by anyone at any time, however, the account security is maintained via cryptography. 
2. Contract hashes are \(as the name would suggest\) derived from the hash used to label a contract stored on-chain. These hashes are derived from the triple \(public key, nonce, ID\), where the public key and the nonce come from the account that made the deploy which is storing the contract \(this is the same as Ethereum\) and the ID is simply a sequential identifier allowing each deploy to store multiple contracts and still have a unique hash for each of them. Like addresses, these are forgable keys, meaning they can be written down by anyone at any time. Unlike accounts though, the security is maintained via immutability instead of cryptographic authentication. The contract referenced by a hash is immutable by a rule enforced by the runtime, similar to Ethereum. Note that a versioned contract could be created by having an immutable contract which holds a read-only unforgable reference to the real contract; the contract maintainer could then change the contents of the mutable cell the unforgable reference points to in order to update the contract.
3. Specific unforgable references. These cannot be created by any source code, though new, yet unused ones, can be. The value associated with an unforgable key in the global state is a mutable cell of some data type \(see the values section below\). Unforgable references enable OCaps security by allowing dApp developers to delegate authority \(e.g. to access data or perform some action\) using these references.

