.. _global-state-head:

Global State
============

.. _global-state-intro:

Introduction
------------

The “global state” is the storage layer for the blockchain. All accounts,
contracts, and any associated data they have are stored in the global state. Our
global state has the semantics of a key-value store (with additional permissions
logic, since not all users can access all values in the same way). Refer to :ref:`Keys and Permissions <serialization-standard-state-keys>` for further information on keys. Each block
causes changes to this global state because of the execution of the deploys it
contains. In order for validators to efficiently judge the correctness of these
changes, information about the new state needs to be communicated succinctly.
Moreover, we need to be able to communicate pieces of the global state to users,
while allowing them to verify the correctness of the parts they receive. For
these reasons, the key-value store is implemented as a
:ref:`Merkle trie <global-state-trie>`.

.. _global-state-trie:

Merkle trie structure
------------------------------

At a high level, a Merkle trie is a key-value store data structure
which is able to be shared piece-wise in a verifiable way (via a construction
called a Merkle proof). Each node is labelled by the hash of its data; for leaf
nodes ---that is the data stored in that part of the tree, for other node types ---
that is the data which references other nodes in the trie. Our implementation of
the trie has radix of 256, this means each branch node can have up to 256
children. This is convenient because it means a path through the tree can be
described as an array of bytes, and thus serialization directly links a key with
a path through the tree to its associated value.

Formally, a trie node is one of the following:

-  a leaf, which includes a key and a value
-  a branch, which has up to 256 ``blake2b256`` hashes, pointing to up to 256 other
   nodes in the trie (recall each node is labelled by its hash)
-  an extension node, which includes a byte array (called the affix) and a
   ``blake2b256`` hash pointing to another node in the trie

The purpose of the extension node is to allow path compression. For example, if
all keys for values in the trie used the same first four bytes, then it would be
inefficient to need to traverse through four branch nodes where there is only
one choice, and instead the root node of the trie could be an extension node with
affix equal to those first four bytes and pointer to the first non-trivial
branch node.

The rust implementation of our trie can be found on GitHub:

-  `definition of the trie data
   structure <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/engine-storage/src/trie/mod.rs#L163>`__
-  `reading from the
   trie <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/engine-storage/src/trie_store/operations/mod.rs#L34>`__
-  `writing to the
   trie <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/engine-storage/src/trie_store/operations/mod.rs#L616>`__

Note: that conceptually, each block has its own trie because the state changes
based on the deploys it contains. For this reason, our implementation has a
notion of a ``TrieStore`` which allows us to look up the root node for each
trie.

