.. _global-state-head:

Global State
============

.. _global-state-intro:

Introduction
------------

The “global state” is the storage layer for the blockchain. All accounts,
contracts, and any associated data they have are stored in the global state. Our
global state has the semantics of a key-value store (with additional permissions
logic since not all users can access all values in the same way). Refer to :ref:`Keys and Permissions <serialization-standard-state-keys>` for further information on keys. Each block
causes changes to this global state because of the execution of the deploys it
contains. For validators to efficiently judge the correctness of these
changes, information about the new state needs to be communicated succinctly.
Moreover, we need to communicate pieces of the global state to users
while allowing them to verify the correctness of the parts they receive. For
these reasons, the key-value store is implemented as a
:ref:`Merkle trie <global-state-trie>`.

.. _global-state-trie:

Merkle trie structure
------------------------------

At a high level, a Merkle trie is a key-value store data structure that can be shared piece-wise in a verifiable way (via a construction
called a Merkle proof). Each node is labeled by the hash of its data. Leaf nodes are labeled with the hash of their data. Non-leaf nodes are labeled with the hash of the labels of their child nodes.

Our implementation of the trie has radix of 256, meaning each branch node can have up to 256 children. A path through the tree can be an array of bytes, and serialization directly links a key with a path through the tree as its associated value.

Formally, a trie node is one of the following:

-  a leaf, which includes a key and a value
-  a branch, which has up to 256 ``blake2b256`` hashes, pointing to up to 256 other
   nodes in the trie (recall each node is labeled by its hash)
-  an extension node, which includes a byte array (called the affix) and a
   ``blake2b256`` hash pointing to another node in the trie

The purpose of the extension node is to allow path compression. Consider an example where all keys use the same first four bytes for values in the trie. In this case, it would be inefficient to traverse through four branch nodes where there is only
one choice; instead, the root node of the trie could be an extension node with
affix equal to those first four bytes and pointer to the first non-trivial
branch node.

The rust implementation of our trie can be found on GitHub:

-  `definition of the trie data structure <https://github.com/casper-network/casper-node/blob/cb1d20ad1ea6e245cd8237f9406885a1e785c669/execution_engine/src/storage/trie/mod.rs#L320>`_
-  `reading from the trie <https://github.com/casper-network/casper-node/blob/cb1d20ad1ea6e245cd8237f9406885a1e785c669/execution_engine/src/storage/trie_store/operations/mod.rs#L37>`_
-  `writing to the trie <https://github.com/casper-network/casper-node/blob/cb1d20ad1ea6e245cd8237f9406885a1e785c669/execution_engine/src/storage/trie_store/operations/mod.rs#L638>`_

Note: Conceptually, each block has its trie because the state changes
based on the deploys it contains. For this reason, our implementation has a
notion of a ``TrieStore``, which allows us to look up the root node for each
trie.
