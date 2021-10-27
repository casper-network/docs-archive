.. _checksummed-hex-head:

Checksummed Hex Encoding
========================

.. _checksummed-hex-intro:

Introduction
------------

Checksummed hex encoding is a hex encoding format that includes an embedded checksum.
The checksummed hex encoding spec was defined in **CEP-57** and implemented in **1.x.x**.

Checksummed hex encoded keys are safer to use than lowercase hex encoded keys because they
enforce the validity of the key, and they make it easier to ensure that transactions cannot be
processed with invalid or nonexistent keys. As an example, if you accidentally change a character
in a checksummed, hex encoded key, it will make the key impossible to decode, so tokens
can't sent to invalid addresses. However, if someone accidentally changes a character in a
normal hex-encoded key, the system would accept it, potentially stranding tokens in an
inaccessible account.


The following :ref:`keys _serialization-standard-serialization-key` are checksummed-hex encoded:
- Account
- Hash
- URef
- Transfer
- DeployInfo
- Balance
- Bid
- Withdraw
- Dictionary
- SystemContractRegistry

.. _checksummed-hex-implementation:

Implementation
--------------

At a high level, the current implementation follows the steps below. The implementation was
declared in :ref:`cep-57 <https://github.com/casper-network/ceps/blob/master/text/0057-checksummed-addresses.md>` and implemented in **version**.
The actual implementation is hosted on github :ref:`here <https://github.com/casper-network/casper-node/blob/dev/types/src/checksummed_hex.rs>`.

1. Take a blake2b hash of the input bytes.
2. Convert the hash bytes into a cyclical stream of bits.
3. Convert the input bytes into an array of nibbles.
4. For each nibble, if the nibble is greater than ``10``, meaning it's an
   alphabetical character ``a`` through ``f``, check the next bit in the stream of hash bits.
5. If the bit is ``1``, capitalize the character.



.. _checksummed-hex-public-key-encoding:

How ed25519 and secp256k1 keys are encoded
------------------------------------------

For ed25519 and secp256k1 public keys, the public key bytes are hex encoded with an embedded
checksum, then the hex encoded public key tag is concatenated to the beginning of the encoded
public key.

**Example**
For the ed25519 public key ``01ccDBB42854759141910c134D67cfAf0E78a93AdD396d43045fAa3A567DcABd84``, the encoded public key 
``ccDBB42854759141910c134D67cfAf0E78a93AdD396d43045fAa3A567DcABd84`` is concatenated with the key tag for ed25519 public keys ``01``.

You can find the implementation on github **link**

.. _checksummed-hex-backward-compatibility:

Backward Compatibility
----------------------

.. TODO: Update this with whichever version this ships with.
Version **1.x.x** is backwards-compatible with lower-hex encoded keys, so if you use a public key that is encoded in lowercase hex,
the network will still be able to decode the public key and use it in a transaction.