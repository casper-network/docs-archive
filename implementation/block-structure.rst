.. _block-structure-head:

Block Structure
===============

.. _block-structure-intro:

Introduction
------------

A *block* is the primary data structure by which information about the state of the CasperLabs system is communicated between nodes of the network. We briefly describe here the format of this data structure.

.. _block-structure-proto:

Protobuf definition
-------------------

Messages between nodes are communicated using `Google’s protocol
buffers <https://developers.google.com/protocol-buffers/>`__. The complete definition of a block in this format can be `found on
GitHub <https://github.com/CasperLabs/CasperLabs/blob/c78e35f4d8f0f7fd9b8cf45a4b17a630ae6ab18f/protobuf/io/casperlabs/casper/consensus/consensus.proto#L111>`__ ; the description here is only meant to provide an overview of the block format; the protobuf definition is authoritative.

.. _block-structure-data:

Data fields
-----------

A block consists of the following:

-  a ``block_hash``
-  a header
-  a body

Each of these are detailed in the subsequent sections.

``block_hash``
~~~~~~~~~~~~~~

The ``block_hash`` is the ``blake2b256`` hash of the header (serialized according to the protobuf specification).

Header
~~~~~~

The block header contains the following fields:

-  ``parent_hashes``

   -  a list of ``block_hash``\ s giving the parents of the block

-  justifications

   -  a list of ``block_hash``\ s givin the justifications of the block (see consensus
      description in part A for more details)

-  a summary of the global state, including

   -  the :ref:`root hash of the global state trie <global-state-trie>` prior to executing
      the deploys in this block (``pre_state_hash``)
   -  the root hash of the global state trie after executing the deploys in this
      block (``post_state_hash``)
   -  the list of currently bonded validators, and their stakes

-  the ``blake2b256`` hash of the body of the block (serialized according to the
   protobuf specification)
-  the time the block was created
-  the protocol version the block was executed with
-  the number of deploys in the block
-  the human-readable name corresponding to this instance of the CasperLabs
   system (``chain_id``)
-  an indicator for whether this message is intended as a true block, or merely a *ballot* (see consensus description in part A for more details)


Body
~~~~

The block body contains an **ordered** list of ``DeployHashes`` which refer to deploys, and an **ordered** list of ``DeployHashes`` for native transfers (which are specialized deploys that only transfer token between accounts). All deploys, including a specialization such as native transfer, can be broadly categorized as some unit of work that when executed and committed affect change to global state :ref:`Global State<global-state-intro>`.
The block body also contains the public key of the validator that proposed the block. It should be noted that a valid block may contain no deploys and / or native transfers.

Refer to the :ref:`Deploy Serialization Standard <serialization-standard-deploy>` for additional information on deploys and how they are serialized.
Refer to :ref:`Block Serialization Standard <serialization-standard-block>` for how blocks are serialized.

