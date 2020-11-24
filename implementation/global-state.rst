.. _global-state-head:

Global State
============

.. _global-state-intro:

Introduction
------------

The “global state” is the storage layer for the blockchain. All accounts,
contracts, and any associated data they have are stored in the global state. Our
global state has the semantics of a key-value store (with additional permissions
logic, since not all users can access all values in the same way). Each block
causes changes to this global state because of the execution of the deploys it
contains. In order for validators to efficiently judge the correctness of these
changes, information about the new state needs to be communicated succinctly.
Moreover, we need to be able to communicate pieces of the global state to users,
while allowing them to verify the correctness of the parts they receive. For
these reasons, the key-value store is implemented as a
:ref:`Merkle trie <global-state-trie>`.

In this chapter we describe what constitutes a “key”, what constitutes a
“value”, the permissions model for the keys, and the Merkle trie
structure.

.. _global-state-keys:

Keys
----

A *key* in the global state is one of the following four data types:

-  32-byte account identifier (called an “account identity key”)
-  32-byte immutable contract identifier (called a “hash key”)
-  32-byte reference identifier (called an “unforgable reference”)

We cover each of these key types in more detail in the sections that follow.

.. _global-state-account-key:

Account identity key
~~~~~~~~~~~~~~~~~~~~

This key type is used specifically for accounts in the global state. All
accounts in the system must be stored under an account identity key, and no
other type. The 32-byte identifier which represents this key is derived from the
``blake2b256`` hash of the public key used to create the associated account (see
:ref:`Accounts <accounts-associated-keys-weights>` for more information).

.. _global-state-hash-key:

Hash key
~~~~~~~~

This key type is used for storing contracts immutably. Once a contract is
written under a hash key, that contract can never change. The 32-byte identifier
representing this key is derived from the ``blake2b256`` hash of the deploy hash
(see :ref:`block-structure-head` for more information) concatenated
with a 4-byte sequential ID. The ID begins at zero for each deploy and
increments by 1 each time a contract is stored. The purpose of this ID is to
allow each contract stored in the same deploy to have a unique key.

.. _global-state-uref:

Unforgable Reference (``URef``)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This key type is used for storing any type of value except ``Account``.
Additionally, ``URef``\ s used in contracts carry permission information with them
to prevent unauthorized usage of the value stored under the key. This permission
information is tracked by the runtime, meaning that if a malicious contract
attempts to produce a ``URef`` with permissions that contract does not actually
have, we say the contract has attempted to “forge” the unforgable reference, and
the runtime will raise a forged ``URef`` error. Permissions for a ``URef`` can be
given across contract calls, allowing data stored under a ``URef`` to be shared in
a controlled way. The 32-byte identifier representing the key is generated
randomly by the runtime (see :ref:`Execution Semantics <execution-semantics-urefs>` for
for more information).

Refer to :ref:`Serialization format for Deploys and Values <serialization-standard-head>` on how deploys and CLValues are serialized and sent over rpc.

.. _global-state-permissions:

Permissions
-----------

There are three types of actions which can be done on a value: read, write, add.
The reason for add to be called out separately from write is to allow for
commutativity checking. The available actions depends on the key type and the
context. This is summarized in the table below:

+-----------------------------------+-----------------------------------+
| Key Type                          | Available Actions                 |
+===================================+===================================+
| Account                           | Read + Add if the context is the  |
|                                   | current account otherwise None    |
+-----------------------------------+-----------------------------------+
| Hash                              | Read                              |
+-----------------------------------+-----------------------------------+
| URef                              | See note below                    |
+-----------------------------------+-----------------------------------+
| Local                             | Read + Write + Add if the context |
|                                   | seed used to construct the key    |
|                                   | matches the current context       |
+-----------------------------------+-----------------------------------+

.. _global-state-urefs-permissions:

Permissions for ``URef``\ s
~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the runtime, a ``URef`` carries its own permissions called ``AccessRights``.
Additionally, the runtime tracks what ``AccessRights`` would be valid for each
``URef`` to have in each context. As mentioned above, if a malicious contract
attempts to use a ``URef`` with ``AccessRights`` that are not valid in its
context, then the runtime will raise an error; this is what enforces the
security properties of all keys. By default, in all contexts, all ``URef``\ s
are invalid (both with any ``AccessRights``, or no ``AccessRights``); however, a
``URef`` can be added to a context in the following ways:

-  it can exist in a set of “known” ``URef``\ s
-  it can be freshly created by the runtime via the ``new_uref`` function
-  for called contracts, it can be passed in by the caller via the arguments to
   ``call_contract``
-  it can be returned back to the caller from ``call_contract`` via the ``ret``
   function

Note: that only valid ``URef``\ s may be added to the known ``URef``\ s or cross call
boundaries; this means the system cannot be tricked into accepted a forged
``URef`` by getting it through a contract or stashing it in the known ``URef``\ s.

The ability to pass ``URef``\ s between contexts via ``call_contract`` / ``ret``, allows
them to be used to share state among a fixed number of parties, while keeping it
private from all others.

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

