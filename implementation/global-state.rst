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
-  32-byte local reference identifier (called a “local key”)

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

.. _global-state-local-key:

Local key
~~~~~~~~~

This key type is used for storing any kind of value (except ``Account``) privately
within an account or contract (collectively called a “context”). Unlike ``URef``\ s,
access to a local key cannot be shared. The 32-byte identifier is derived from
the ``blake2b256`` hash of a 32-byte “seed” concatenated with some user data. The
“seed” is equal to the 32-byte identifier of the key under which the current
context is stored. For example, a contract stored under a ``URef`` would use the
32-byte identifier of the ``URef`` as its local seed, and an account would use its
32-byte identity as its local seed. The user data, that also contributes to the
hash, allows local keys to be used as a private key-value store embedded within
the larger global state. However, this “local state” has no restrictions on its
key type so long as it can be serialized into bytes for hashing.

.. _global-state-values:

Values
------

A value stored in the global state is a ``StoredValue``. A ``StoredValue`` is
one of three possible variants:

- A ``CLValue``
- A contract
- An account

We discuss ``CLValue`` and contract in more detail below, details about
accounts can be found in :ref:`accounts-head`.

Each ``StoredValue`` is serialized when written to the global state. The
serialization format consists of a single byte tag, indicating which variant of
``StoredValue`` it is, followed by the serialization of that variant.  The tag
for each variant is as follows:

- ``CLValue`` is ``0``
- ``Account`` is ``1``
- ``Contract`` is ``2``

The details of ``CLType`` serialization is in the following section. Using the
serialization format for ``CLValue`` as a basis, we can succinctly write the
serialization rules for contracts and accounts:

- contracts serialize in the same way as data with ``CLType`` equal to
  ``Tuple3(List(U8), Map(String, Key), Tuple3(U32, U32, U32))``;

- accounts serialize in the same way as data with ``CLType`` equal to
  ``Tuple5(FixedList(U8, 32), Map(String, Key), URef, Map(FixedList(U8, 32), U8), Tuple2(U8, U8))``.

Note: ``Tuple5`` is not a presently supported ``CLType``, however it is clear
how to generalize the rules for ``Tuple1``, ``Tuple2``, ``Tuple3`` to any size
tuple.

Note: links to further serialization examples and a reference implementation are
found in :ref:`Appendix B <appendix-b>`.

``CLValue``
~~~~~~~~~~~

``CLValue`` is used to describe data that is used by smart contracts. This could
be as a local state variable, input argument or return value. A ``CLValue``
consists of two parts: a ``CLType`` describing the type of the value, and an
array of bytes which represent the data in our serialization format.

``CLType`` is described by the following recursive data type:

.. code:: rust

   enum CLType {
      Bool, // boolean primitive
      I32, // signed 32-bit integer primitive
      I64, // signed 64-bit integer primitive
      U8, // unsigned 8-bit integer primitive
      U32, // unsigned 32-bit integer primitive
      U64, // unsigned 64-bit integer primitive
      U128, // unsigned 128-bit integer primitive
      U256, // unsigned 256-bit integer primitive
      U512, // unsigned 512-bit integer primitive
      Unit, // singleton value without additional semantics
      String, // e.g. "Hello, World!"
      URef, // unforgable reference (see above)
      Key, // global state key (see above)
      Option(CLType), // optional value of the given type
      List(CLType), // list of values of the given type (e.g. Vec in rust)
      FixedList(CLType, u32), // same as `List` above, but number of elements
                              // is statically known (e.g. arrays in rust)
      Result(CLType, CLType), // co-product of the the given types;
                              // one variant meaning success, the other failure
      Map(CLType, CLType), // key-value association where keys and values have the given types
      Tuple1(CLType), // single value of the given type
      Tuple2(CLType, CLType), // pair consisting of elements of the given types
      Tuple3(CLType, CLType, CLType), // triple consisting of elements of the given types
      Any // Indicates the type is not known
   }

All data which can be assigned a (non-``Any``) ``CLType`` can be serialized according to the
following rules (this defines the CasperLabs serialization format):

- Boolean values serialize as a single byte; ``true`` maps to ``1``, while ``false`` maps to ``0``.

- Numeric values consisting of 64 bits or less serialize in the two's complement
  representation with little-endian byte order, and the appropriate number of
  bytes for the bit-width.

   - E.g. ``7u8`` serializes as ``0x07``
   - E.g. ``7u32`` serializes as ``0x07000000``
   - E.g. ``1024u32`` serializes as ``0x00040000``

- Wider numeric values (i.e. ``U128``, ``U256``, ``U512``) serialize as: one
  byte given the length of the subsequent number (in bytes), followed by the two's
  complement representation with little-endian byte order. The number of bytes
  should be chosen as small as possible to represent the given number. This is
  done to reduce the size of the serialization in the case of small numbers
  represented within a wide data type.

   - E.g. ``U512::from(7)`` serializes as ``0x0107``
   - E.g. ``U512::from(1024)`` serializes as ``0x020004``
   - E.g. ``U512::from("123456789101112131415")`` serializes as ``0x0957ff1ada959f4eb106``

- Unit serializes to an empty byte array.

- Strings serialize as a 32-bit integer representing the length in bytes (note:
  this might be different than the number of characters since special characters,
  such as emojis, take more than one byte), followed by the UTF-8 encoding of the
  characters in the string.

   - E.g. ``"Hello, World!"`` serializes as ``0x0d00000048656c6c6f2c20576f726c6421``

- Optional values serialize with a single byte tag, followed by the
  serialization of the value it self. The tag is equal to ``0`` if the value is
  missing, and ``1`` if it is present.

   - E.g. ``None`` serializes as ``0x00``
   - E.g. ``Some(10u32)`` serializes as ``0x010a000000``

- A list of values serializes as a 32-bit integer representing the number of
  elements in the list (note this differs from strings where it gives the number
  of *bytes*), followed by the concatenation of each serialized element.

   - E.g. ``List()`` serializes as ``0x00000000``
   - E.g. ``List(1u32, 2u32, 3u32)`` serializes as ``0x03000000010000000200000003000000``

- A fixed-length list of values serializes as simply the concatenation of the
  serialized elements. Unlike a variable-length list, the length is not included
  in the serialization because it is statically known by the type of the value.

   - E.g. ``[1u32, 2u32, 3u32]`` serializes as ``0x010000000200000003000000``

- A ``Result`` serializes as a single byte tag followed by the serialization of
  the contained value. The tag is equal to ``1`` for the success variant and ``0``
  for the error variant.

   - E.g. ``Ok(314u64)`` serializes as ``0x013a01000000000000``
   - E.g. ``Err("Uh oh")`` serializes as ``0x00050000005568206f68``

- Tuples serialize as the concatenation of their serialized elements. Similar to
  ``FixedList`` the number of elements is not included in the serialization
  because it is statically known in the type.

   - E.g. ``(1u32, "Hello, World!", true)`` serializes as
     ``0x010000000d00000048656c6c6f2c20576f726c642101``

- A ``Map`` serializes as a list of key-value tuples. There must be a
  well-defined ordering on the keys, and in the serialization the pairs are listed
  in ascending order. This is done to ensure determinism in the serialization, as
  ``Map`` data structures can be unordered.

- ``URef`` values serialize as the concatenation of its address (which is a
  fixed-length list of ``u8``) and a single byte tag representing the access
  rights. Access rights are converted as follows:

+--------------------+---------------+
| Access Rights      | Serialization |
+====================+===============+
| ``NONE``           |             0 |
+--------------------+---------------+
| ``READ``           |             1 |
+--------------------+---------------+
| ``WRITE``          |             2 |
+--------------------+---------------+
| ``READ_WRITE``     |             3 |
+--------------------+---------------+
| ``ADD``            |            4  |
+--------------------+---------------+
| ``READ_ADD``       |            5  |
+--------------------+---------------+
| ``ADD_WRITE``      |            6  |
+--------------------+---------------+
| ``READ_ADD_WRITE`` |            7  |
+--------------------+---------------+

- ``Key`` values serialize as a single byte tag representing the variant,
  followed by the serialization of the data that variant contains. For most
  variants this is simply a fixed-length 32 byte array. The exception is
  ``Key::URef`` which contains a ``URef``, so its data serializes per the
  description above. The tags are as follows: ``Key::Account`` serializes as
  ``0``, ``Key::Hash`` as ``1``, ``Key::URef`` as ``2`` and ``Key::Local`` as
  ``3``.

``CLType`` itself also has rules for serialization. A ``CLType`` serializes as a
single byte tag, followed by the concatenation of serialized inner types, if any
(e.g. lists, and tuples have inner types). ``FixedList`` is a minor exception
because it also includes the length in the type, however this simply means that
the length included in the serialization as well (as a 32-bit integer, per the
serialization rules above), following the serialization of the inner type. The
tags are as follows:

+---------------+-------------------+
| ``CLType``    | Serialization Tag |
+===============+===================+
| ``Bool``      |                 0 |
+---------------+-------------------+
| ``I32``       |                 1 |
+---------------+-------------------+
| ``I64``       |                 2 |
+---------------+-------------------+
| ``U8``        |                 3 |
+---------------+-------------------+
| ``U32``       |                 4 |
+---------------+-------------------+
| ``U64``       |                 5 |
+---------------+-------------------+
| ``U128``      |                 6 |
+---------------+-------------------+
| ``U256``      |                 7 |
+---------------+-------------------+
| ``U512``      |                 8 |
+---------------+-------------------+
| ``Unit``      |                 9 |
+---------------+-------------------+
| ``String``    |                10 |
+---------------+-------------------+
| ``URef``      |                11 |
+---------------+-------------------+
| ``Key``       |                12 |
+---------------+-------------------+
| ``Option``    |                13 |
+---------------+-------------------+
| ``List``      |                14 |
+---------------+-------------------+
| ``FixedList`` |                15 |
+---------------+-------------------+
| ``Result``    |                16 |
+---------------+-------------------+
| ``Map``       |                17 |
+---------------+-------------------+
| ``Tuple1``    |                18 |
+---------------+-------------------+
| ``Tuple2``    |                19 |
+---------------+-------------------+
| ``Tuple3``    |                20 |
+---------------+-------------------+
| ``Any``       |                21 |
+---------------+-------------------+

A complete ``CLValue``, including both the data and the type can also be
serialized (in order to store it in the global state). This is done by
concatenating: the serialization of the length (as a 32-bit integer) of the
serialized data (in bytes), the serialized data itself, and the serialization of
the type.

.. _global-state-contracts:

Contracts
~~~~~~~~~

Contracts are a special value type because they contain the on-chain logic of
the applications running on the CasperLabs system. A *contract* contains the
following data:

-  a `wasm module <https://webassembly.org/docs/modules/>`__
-  a collection of named keys
-  a protocol version

The wasm module must contain a function named ``call`` which takes no arguments
and returns no values. This is the main entry point into the contract. Moreover,
the module may import any of the functions supported by the CasperLabs runtime;
a list of all supported functions can be found in :ref:`Appendix A
<appendix-a>`.

Note: though the ``call`` function signature has no arguments and no return
value, within the ``call`` function body the ``get_arg`` runtime function can be
used to accept arguments (by ordinal) and the ``ret`` runtime function can be used
to return a single ``CLValue`` to the caller.

The named keys are used to give human-readable names to keys in the global state
which are important to the contract. For example, the hash key of another
contract it frequently calls may be stored under a meaningful name. It is also
used to store the ``URef``\ s which are known to the contract (see below
section on Permissions for details).

Note: purely local state should be stored under local keys rather than under
``URef``\ s in the named keys map. A primary advantage of ``URef``\ s is their
portability (between on-chain contexts), but for unshared, private variables,
where portability is not a factor, local keys are more efficient.

The protocol version says which version of the CasperLabs protocol this contract
was compiled to be compatible with. Contracts which are not compatible with the
active major protocol version will not be executed by any node in the CasperLabs
network.

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
