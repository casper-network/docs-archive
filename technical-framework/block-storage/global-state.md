---
description: 'Accounts, K/V'
---

# Global State

## Introduction

Blockchain can be viewed as decentralized, distributed database with verifiable computation layer on top. In order to do anything meaningful we need a way to store data \(in blockchain context these may be contracts, accounts etc\). From a Computer Engineering perspective Global State \(as we call this distributed and decentralized database\) can be thought of as key-value store, a mapping between byte-arrays and byte-arrays that is being replicated between nodes in the network. Although it is not required from the specific implementation of Global State, it is assumed that the implementation will maintain this mapping in a Merkle Patricia tree.

## Keys

We define three types of keys:

1. Account.
2. Contract hash.
3. Unforgeable reference.

### Account

Account is a 160-bit identifier similar to Ethereum. Account addresses are derived from some cryptographic public key and \(as the name would suggest\) has a corresponding value which is an account. These addresses are forgeable – they can be written down by anyone at any time, however, the account security is maintained via cryptography.

### Contract hash

Contract hash is a 256-bit identifier, \(as the name would suggest\) derived from the hash used to label a contract stored on-chain. These hashes are derived from the triple \(public key, nonce, ID\), where the public key and the nonce come from the account that made the deploy which is storing the contract \(this is the same as Ethereum\) and the ID is simply a sequential identifier allowing each deploy to store multiple contracts and still have a unique hash for each of them. Like addresses, these are forgeable keys, meaning they can be written down by anyone at any time. Unlike accounts though, the security is maintained via immutability instead of cryptographic authentication. The contract referenced by a hash is immutable by a rule enforced by the runtime, similar to Ethereum.

### Unforgeable reference

Unforgeable reference \(called `URef` interchangeably in the rest of the document\) is a 256-bit random identifier. These cannot be created by any source code, though new, yet unused ones, can be. The value associated with a `URef` in the global state is a mutable cell of some data type \(see the values section below\). Unforgeable references enable OCaps \(see [OCaps Security Appendix](../appendix/ocaps-security.md)\) security by allowing developers to delegate authority \(e.g. to access data or perform some action\) using these references.

## Values

We support following value types:

1. 32-bit integer
2. byte array
3. list of 32-bit integers
4. string
5. list of strings
6. Named key - tuple of string and _Key_ \(as defined in [Keys](global-state.md#keys) section\).
7. Account.
8. Smart Contract.

### **Account**

Account addresses are keys in the global data store which point at accounts. Because those references are public, the semantics are much more restrictive than for the mutable cells referenced by unforgeable references. Accounts have the following properties:

* A public key \(private\)
* A nonce \(private\)
* A purse field. This is an unforgeable reference to the `purse` object holding funds of the account.
* A set of known `URef`s  \(private\). Mapping between strings to names. Idea behind this map is to allow developers use human readable versions of the keys.
* A public method called `give`, which takes an unforgeable reference as an argument. When you call `give` on an account, the provided `URef` is added to that account's set of known unforgeable references. Key used for persisting the name is derived from the name itself.   **NOTE**: name can be remapped later.  **NOTE**: `give`-ing a name is more expensive that deleting it. This incentivizes developers to not `give` out names.
* A public method called `authenticate`, which takes a nonce and cryptographic signature as arguments. The `authenticate` method is only called during the first phase of a deploy, called the "login" phase. This means that cryptographic \(identity-based\) security is used on the boundary of the system, but full capabilities-based security is used entirely inside the system. _**\(note from Mateusz: I am not sure about this part of the description as it seems like something more developer facet, a bit tutorial-ish. I am not convinced it's something that should be put into whitepaper**_**\)**

### Smart contract

The precise definition of "Smart Contract" is left purposely vague here because we are agnostic to the detail about it. Contracts have the following properties:

* A set of known unforgeable references. Similarly to `Account`.
* bytearray representing serialized body of the contract. At the moment this is serialized Wasm code. This means that in order for the contract to update its state it has to put new data into its `URef` set. _**\(note from Mateusz: I am not sure about this part of the description as it seems like something more developer facet, a bit tutorial-ish. I am not convinced it's something that should be put into whitepaper**_**\)**

## ABI

### Background

The bytecode used to execute transactions on the blockdag is Web Assembly \(wasm\). It is extremely low-level; meaning that interaction with the host runtime environment can only be done by copying bytes back and forth. This happens for example when passing arguments to a smart contract, getting a return value from a smart contract, and getting/putting from/to the global state. The purpose of this document is to specify the Application Binary Interface \(ABI\) to allow higher-order data structures to be communicated via bytes over the host/wasm boundary.

### Specification

### Basic data types  <a id="ApplicationBinaryInterface(ABI)-Basicdatatypes"></a>

#### Numbers  <a id="ApplicationBinaryInterface(ABI)-Numbers"></a>

* Unsigned integers are represented in the typical binary format, with little endian byte order
* Signed integers are represented in the typical two's compliment binary format, with little endian byte order
* 8-bit, 32-bit and 64-bit numbers are supported
* Floating point numbers are not supported

#### Strings  <a id="ApplicationBinaryInterface(ABI)-Strings"></a>

* A string is represented by its length \(in bytes, **NOT** characters – note that these could be different for UTF8 strings using non-ASCII characters\) followed by its UTF8 encoding
* The length is always a 32-bit unsigned integer
* If the first 4 bytes encode the number `n` \(as per the Numbers section above\), then there must be exactly `n` bytes which follow which make up the data for the string \(this is a formatting error otherwise\)
* If the data for the string cannot correctly be interpreted as UTF8 characters then this is a formatting error
* There is no representation for a single character; if this is needed then use a 1 character long string to encode it
* Note that a String is considered a basic data type as opposed to a collection of characters since there is no encoding for a character alone

#### Unit  <a id="ApplicationBinaryInterface(ABI)-Unit"></a>

* The unit data type \(also sometimes referred to as the empty tuple\) is represented as an empty byte array

### Collections  <a id="ApplicationBinaryInterface(ABI)-Collections"></a>

As a general rule of thumb, a collection is represented as its length \(the number of items in that collection\) followed by the ABI-encoded form of those items.

#### Option  <a id="ApplicationBinaryInterface(ABI)-Option"></a>

* `None` is represented by the unsigned, 8-bit number 0
* `Some` is represented by the unsigned 8-bit number 1, followed by the bytes encoding the value the Option holds
* It is an error for the first byte of a byte array representing an Option to be anything other than 0 or 1
* Note this definition is recursive on purpose; if it is possible to encode/decode some type `T` then it is possible to encode/decode `Option<T>`.
* The reference implementation currently uses a 32-bit number to differentiate the `Some` and `None` cases, which is totally unnecessary. \(To be fixed soon\)

#### Either  <a id="ApplicationBinaryInterface(ABI)-Either(orResultinRust)"></a>

This data type distinguishes successful and error cases.

* The first byte defines success or error:
  * 0 = `Left` \( in Rust it's`Err`\)
  * 1 = `Right` \( in Rust it's`Ok`\)
* The subsequent bytes encode the value the Either holds
* It is an error if the first byte is anything other than 0 or 1
* The reference implementation presently does not support Either, but this will likely change

#### Vector/List/Array  <a id="ApplicationBinaryInterface(ABI)-Vector/List/Array"></a>

* A vector is represented by its length \(in number of elements, **NOT** bytes\) followed by the elements encoded via this ABI
* The length is always a 32-bit unsigned integer
* If the first 4 bytes encode the number `n` \(as per the Numbers section above\), then there must be exactly `n` distinct byte arrays \(concatenated together\) which follow
* Note that there is no delimiter between elements; it is assumed that the number of bytes needed for each element can be deduced from the type of elements stored in the vector \(e.g. a vector of 32-bit signed integers would have each element take 4 bytes, and vector of strings would have each element describe its length as per the Strings section above\)
* Similar to `Option`, this definition is recursive in the sense that if `T` can be encoded/decoded, then so can `Vec<T>`, however only certain concrete types are implemented in the reference implementation for efficiency reasons \(though this may change in the future\)
* Note that even though in Rust the length of an array is statically known \(similarly for Vectors in dependently typed languages like Idris\) we still include the length in the encoding because this is a feature relatively unique to Rust and the ABI should be language agnostic. If the length represented by the first 4 bytes does not match the statically known length of the array then a formatting error is raised

#### Tuple  <a id="ApplicationBinaryInterface(ABI)-Tuple"></a>

* Since a tuple is a known, fixed length, the length is not included in the encoding
* A tuple is simply the concatenation of the encoding of each of its elements
* As with Vector, there is no delimiter between elements because it is assumed that the number of bytes to be used can be determined based on the type of the element
* The reference implementation presently does not support arbitrary tuples, however this will likely change in the future

#### Map  <a id="ApplicationBinaryInterface(ABI)-Map"></a>

* A map is considered to be a list of \(key, value\) tuples and encoded as such \(i.e. the first 4 bytes are the number of keys in the map encoded as a 32-bit unsigned integer, then the data follows as a the concatenation of the encodings of all the key-value pairs\)
* Note that the order of elements is not specified and therefore introduces some non-determinism in the encoding

#### Set  <a id="ApplicationBinaryInterface(ABI)-Set"></a>

* A set is encoded as if it were a vector
* Similar to Map, the order of elements is not specified and thus the encoding is non-deterministic
* Note that Sets are not implemented yet in the reference implementation

### Structs/Enums/Classes  <a id="ApplicationBinaryInterface(ABI)-Structs/Enums/Classes"></a>

The ABI does not support arbitrary named structures with named fields. If this is required then the native instance will need to be represented as a tuple containing the same data. However, because of their special importance in the global state, some structs are supported in the ABI and the form of their encoding could be applied to other structs/enums.

#### Key \(the enum used as keys in the global state key-value store\)  <a id="ApplicationBinaryInterface(ABI)-Key(theenumusedaskeysintheglobalstatekey-valuestore)"></a>

* The first byte determines which variant of Key is being used
  * 0 = Account
  * 1 = Hash
  * 2 = URef
* The remaining bytes encode the data for the Key and are different depending on the variant
  * Account: 4 bytes representing the 32-bit unsigned number 20; followed by 20 bytes which represent the account address
  * Hash/URef: 4 bytes representing the 32-bit unsigned number 32; followed by 32 bytes which represent the hash or uref identifier
* If the data does not follow these definitions \(e.g. the first byte is a number different from 0, 1, or 2; or the account "data length" is anything other than 20\) then a formatting error is raised
* Note that even though the length of the data is statically known we still include it in the encoding for consistency with the Collections ABI definitions

#### Account \(the data structure which holds information relevant to on-dag accounts\)  <a id="ApplicationBinaryInterface(ABI)-Account(thedatastructurewhichholdsinformationrelevanttoon-dagaccounts)"></a>

* This is serialized identically to the tuple `([u8; 32], u64, Map<String, Key>)`, or more explicitly the concatenation of:
  * 32 bytes representing the account public key
  * 8 bytes, representing the 64-bit unsigned integer for the nonce
  * 4 bytes giving the number of keys in the known\_urefs map
  * the encoding for the data in the map

#### Value \(the enum used as values in the global state key-value store\)  <a id="ApplicationBinaryInterface(ABI)-Value(theenumusedasvaluesintheglobalstatekey-valuestore)"></a>

* The first byte determines which variant of Value is being used
  * 0 = Int32
  * 1 = ByteArray
  * 2 = ListInt32
  * 3 = String
  * 4 = Account
  * 5 = Contract
  * 6 = NamedKey
  * 7 = ListString
* This is followed by the encoded data for the Value, which depends on the variant being used. The data types are listed below; refer to other sections of this document for how they should be encoded
  * Int32 = 32-bit signed integer
  * ByteArray = Vector of 8-bit unsigned integers
  * ListInt32 = Vector of 32-bit signed integers
  * String = String
  * ListString = Vector of Strings
  * NamedKey = \(String, Key\) tuple
  * Account = Account
  * Contract = \(Vector of 8-bit unsigned integers, Map&lt;String, Key&gt;\) tuple
* It is an error if the data does not conform to these definitions \(e.g. the first byte is anything other than 0 - 7\)

## Reference implementation  <a id="ApplicationBinaryInterface(ABI)-Referenceimplementation"></a>

A Rust reference implementation for those implementing this spec in another language can be found here:

* [https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/bytesrepr.rs](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/bytesrepr.rs)
* [https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/key.rs\#L19](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/key.rs#L19)
* [https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/value.rs\#L150](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/value.rs#L150)
* [https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/value.rs\#L33](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/common/src/value.rs#L33)

