.. _serialization-standard-head:

Serialization Standard
======================
We provide a custom implementation to serialize data structures used by the Casper node to their byte representation. This document details how this custom serialization is implemented, allowing developers to build their own library that implements the custom serialization.


.. _serialization-standard-block:

Block
-----
A block is the core component of the Casper linear blockchain, used in two contexts:

#. A data structure containing a collection of transactions. Blocks form the primary structure of the blockchain.
#. A message that is exchanged between nodes containing the data structure as explained in (1).

Each block has a globally unique ID, achieved by hashing the contents of the block.

Each block points to its parent. An exception is the first block, which has no parent.

A block is structurally defined as follows:

.. code:: rust

    pub struct Block {
        hash: BlockHash,
        header: BlockHeader,
        body: BlockBody,
    }

* hash: A hash over the body of the Block.
* header: The header of the block that contains information about the contents of the block with additional metadata.
* body: The block's body contains the proposer of the block and hashes of deploys and transfers contained within it.

Block hash
~~~~~~~~~~~
The block hash is a Digest over the contents of the Block Header. The BlockHash serializes as the byte representation of the hash itself.

Block header
~~~~~~~~~~~~
The header portion of a Block, structurally, is defined as follows:

.. code:: rust 

    pub struct BlockHeader {
        parent_hash: BlockHash,
        state_root_hash: Digest,
        body_hash: Digest,
        random_bit: bool,
        accumulated_seed: Digest,
        era_end: Option<EraEnd>,
        timestamp: Timestamp,
        era_id: EraId,
        height: u64,
        protocol_version: ProtocolVersion,
    }

* ``parent_hash``: is the hash of the parent block
* ``state_root_hash``: is the current State Root hash
* ``body_hash``: the hash of the block body.
* ``random_bit``: is a boolean whose serialization is described below.
* ``accumulated_seed``: A seed needed for initializing a future era.
* ``era_end``: contains Equivocation and reward information to be included in the terminal finalized block.
* ``timestamp``: The timestamp from when the block was proposed.
* ``era_id``: Era ID in which this block was created.
* ``height``: The height of this block, i.e., the number of ancestors.
* ``protocol_version``: The version of the Casper network when this block was proposed.

When serializing the ``BlockHeader``, we create a buffer that contains the serialized representations of each of the header fields. 

*  ``parent_hash`` serializes to the byte representation of the parent hash. The serialized buffer of the ``parent_hash`` is 32 bytes long.
*  ``state_root_hash`` serializes to the byte representation of the ``state root hash``. The serialized buffer of the ``state_root_hash`` is 32 bytes long.
*  ``body_hash`` is the serialized representation of the hash of the block. The serialized buffer of the ``body_hash`` is 32 bytes long.
*  ``random_bit`` is serialized as a single byte; true maps to 1, while false maps to 0.
*  ``accumulated_seed`` serializes to the byte representation of the parent Hash. The serialized buffer of the ``accumulated_hash`` is 32 bytes long.
*  ``era_end`` is an optional field. Thus if the field is set as ``None``, it serializes to ``0``. The serialization of the other case is described in the following section. 
*  ``timestamp`` serializes as a single ``u64`` value. The serialization of a ``u64`` value is described in its own section below. 
*  ``era_id`` serializes as a single ``u64`` value. The serialization of a ``u64`` value is described in its own section below. 
*  ``proposer`` serializes to the byte representation of the ``PublicKey``. If the ``PublicKey`` is an Ed25519 key, then the first byte within the serialized buffer is ``1`` followed by the bytes of the key itself; else, in the case of Secp256k1, the first byte is ``2``. 

EraEnd
~~~~~~~
`EraEnd` as represented within the block header, is a struct containing two fields.

.. code:: rust

    pub struct EraEnd {
        /// The era end information.
        era_report: EraReport,
        /// The validator weights for the next era.
        next_era_validator_weights: BTreeMap<PublicKey, U512>,
    }

`EraEnd` contains two fields, as shown above. The first is termed as the `EraReport` and contains information relevant to that current era. The second is a map of the weights of the validators for the next era.

`EraReport` itself contains two fields:

    * ``equivocators``: A vector of ``PublicKey``.
    * ``rewards``: A Binary Tree Map of ``PublicKey`` and ``u64``.

When serializing an EraReport, the buffer is first filled with the individual serialization of the PublicKey contained within the vector.

* If the ``PublicKey`` is an ``Ed25519`` key, the first byte within the buffer is a ``1`` followed by the individual bytes of the serialized key.
* If the ``PublicKey`` is an ``Secp256k1`` key, the first byte within the buffer is a ``2`` followed by the individual bytes of the serialized key. 

When serializing the overarching struct of `EraEnd`, we first allocate a buffer, which contains the serialized representation of the `EraReport` as described above, followed by the serialized BTreeMap.

Note that `EraEnd` is an optional field. Thus the above scheme only applies if there is an `EraEnd`; if there is no era end, the field simply serializes to `0`.


Body
~~~~
The body portion of the block, is structurally defined as:

.. code:: rust

    pub struct BlockBody {
        proposer: PublicKey,
        deploy_hashes: Vec<DeployHash>,
        transfer_hashes: Vec<DeployHash>,
    }

* ``proposer``: The PublicKey which proposed this block.
* ``deploy_hashes``: Is a vector of hex-encoded hashes identifying Deploys included in this Block.
* ``transfer_hashes``: Is a vector of hex-encoded hashes identifying Transfers included in this Block.

When we serialize the `BlockBody`, we create a buffer that contains the serialized representations of the individual fields present within the block.

* ``proposer``: serializes to the byte representation of the PublicKey. If the PublicKey is an Ed25519 key, then the first byte within the serialized buffer is 1 followed by the bytes of the key itself; else, in the case of Secp256k1, the first byte is 2.
* ``deploy_hashes``: serializes to the byte representation of all the deploy_hashes within the block header. Its length is `32 * n`, where n denotes the number of deploy hashes present within the body.
* ``transfer_hashes``: serializes to the byte representation of all the deploy_hashes within the block header. Its length is `32 * n`, where n denotes the number of transfers present within the body.


.. _serialization-standard-deploy:

Deploy
------
A deploy is a data structure containing a smart contract and the requester's signature(s). Additionally, the deploy header contains additional metadata about the deploy itself.
A deploy is structurally defined as follows:

.. code:: rust

    pub struct Deploy {
        hash: DeployHash,
        header: DeployHeader,
        payment: ExecutableDeployItem,
        session: ExecutableDeployItem,
        approvals: Vec<Approval>,
        #[serde(skip)]
        is_valid: Option<bool>, 
    }


* Hash: The hash of the deploy header.
* Header: Contains metadata about the deploy. The structure of the header is detailed further in this document.
* Payment: The payment code for contained smart contract.
* Session: The stored contract itself.
* Approvals: A list of signatures:
* is_valid: A flag that marks the validity of the deploy. Note that it is the only field within the struct that is not serialized.

Deploy-Hash
~~~~~~~~~~~~
The Deploy hash is a Digest over the contents of the Deploy header. The Deploy Hash serializes as the byte representation of the hash itself.

Deploy-Header
~~~~~~~~~~~~~
The deploy header is defined as:

.. code:: rust

    pub struct DeployHeader {
        account: PublicKey,
        timestamp: Timestamp,
        ttl: TimeDiff,
        gas_price: u64,
        body_hash: Digest,
        dependencies: Vec<DeployHash>,
        chain_name: String,
    }

- Account is defined as enum, which can either contain an Ed25519 key or secp256k1 key.
- An Ed25519 key is serialized as a buffer of bytes, with the leading byte being ``1`` for Ed25519
- Thus an Ed25519 key ``4dd8edb64cad4bd472f2ab8b0409392306c14b45f5b47ac0c295da461d09b18a`` serializes to ``0x01200000004dd8edb64cad4bd472f2ab8b0409392306c14b45f5b47ac0c295da461d09b18a``
- Correspondingly, a Secp256k1 key is serialized as a buffer of bytes, with the leading byte being ``2``
- Thus an Secp256k1 key ``0365dc07a060cac57c98cdeab9a659e097458d4e72899b4bec4f1b230d57a70d72`` serializes as ``0x02210000000365dc07a060cac57c98cdeab9a659e097458d4e72899b4bec4f1b230d57a70d72``
- A timestamp is a struct that is a unary tuple containing a ``u64`` value. This value is a count of the milliseconds since the UNIX epoch. Thus the value ``1603994401469`` serializes as ``0xbd3a847575010000``
- The gas is ``u64`` value which is serialized as ``u64`` CLValue discussed below.
- Body hash is a hash over the contents of the deploy body, which includes the payment, session, and approval fields. Its serialization is the byte representation of the hash itself.
- Dependencies is a vector of deploy hashes referencing deploys that must execute before the current deploy can be executed. It serializes as a buffer containing the individual serialization of each DeployHash within the Vector.
- Chain name is a human-readable string describing the name of the chain as detailed in the chainspec. It is serialized as a String CLValue described below.

Payment & Session
~~~~~~~~~~~~~~~~~

Payment and Session are both defined as ``ExecutableDeployItems``. ``ExecutableDeployItems`` is an enum described as follows:

.. code:: rust

    pub enum ExecutableDeployItem {
        ModuleBytes {
            #[serde(with = "HexForm::<Vec<u8>>")]
            module_bytes: Vec<u8>,
            // assumes implicit `call` noarg entrypoint
            #[serde(with = "HexForm::<Vec<u8>>")]
            args: Vec<u8>,
        },
        StoredContractByHash {
            #[serde(with = "HexForm::<[u8; KEY_HASH_LENGTH]>")]
            hash: ContractHash,
            entry_point: String,
            #[serde(with = "HexForm::<Vec<u8>>")]
            args: Vec<u8>,
        },
        StoredContractByName {
            name: String,
            entry_point: String,
            #[serde(with = "HexForm::<Vec<u8>>")]
            args: Vec<u8>,
        },
        StoredVersionedContractByHash {
            #[serde(with = "HexForm::<[u8; KEY_HASH_LENGTH]>")]
            hash: ContractPackageHash,
            version: Option<ContractVersion>, // defaults to highest enabled version
            entry_point: String,
            #[serde(with = "HexForm::<Vec<u8>>")]
            args: Vec<u8>,
        },
        StoredVersionedContractByName {
            name: String,
            version: Option<ContractVersion>, // defaults to highest enabled version
            entry_point: String,
            #[serde(with = "HexForm::<Vec<u8>>")]
            args: Vec<u8>,
        },
        Transfer {
            #[serde(with = "HexForm::<Vec<u8>>")]
            args: Vec<u8>,
        },
    }

- Module Bytes are serialized such that the first byte within the serialized buffer is ``0`` with the rest of the buffer containing the bytes present.
    - ``ModuleBytes { module_bytes: "[72 bytes]", args: 434705a38470ec2b008bb693426f47f330802f3bd63588ee275e943407649d3bab1898897ab0400d7fa09fe02ab7b7e8ea443d28069ca557e206916515a7e21d15e5be5eb46235f5 }`` will serialize to
    - ``0x0048000000420481b0d5a665c8a7678398103d4333c684461a71e9ee2a13f6e859fb6cd419ed5f8876fc6c3e12dce4385acc777edf42dcf8d8d844bf6a704e5b2446750559911a4a328d649ddd48000000434705a38470ec2b008bb693426f47f330802f3bd63588ee275e943407649d3bab1898897ab0400d7fa09fe02ab7b7e8ea443d28069ca557e206916515a7e21d15e5be5eb46235f5``

- StoredContractByHash serializes such that the first byte within the serialized buffer is 1u8. This is followed by the byte representation of the remain fields.
    - ``StoredContractByHash { hash: c4c411864f7b717c27839e56f6f1ebe5da3f35ec0043f437324325d65a22afa4, entry_point: "pclphXwfYmCmdITj8hnh", args: d8b59728274edd2334ea328b3292ed15eaf9134f9a00dce31a87d9050570fb0267a4002c85f3a8384d2502733b2e46f44981df85fed5e4854200bbca313e3bca8d888a84a76a1c5b1b3d236a12401a2999d3cad003c9b9d98c92ab1850 }``
    - ``0x01c4c411864f7b717c27839e56f6f1ebe5da3f35ec0043f437324325d65a22afa41400000070636c7068587766596d436d6449546a38686e685d000000d8b59728274edd2334ea328b3292ed15eaf9134f9a00dce31a87d9050570fb0267a4002c85f3a8384d2502733b2e46f44981df85fed5e4854200bbca313e3bca8d888a84a76a1c5b1b3d236a12401a2999d3cad003c9b9d98c92ab1850``

- StoredContractByName serializes such that the first byte within the serialized buffer is 2u8. This followed by the indiviual byte representation of the remaining fields.
    - ``StoredContractByName { name: "U5A74bSZH8abT8HqVaK9", entry_point: "gIetSxltnRDvMhWdxTqQ", args: 07beadc3da884faa17454a }``
    - ``0x0214000000553541373462535a483861625438487156614b39140000006749657453786c746e5244764d685764785471510b00000007beadc3da884faa17454a``

- StoredVersionedContractByHash serializes such that the first byte within the serialized buffer is 3u8. However, the field version within the enum serializes as a Option CLValue, i.e if the value is None as shown in the example, it serializes to 0, else it serializes the inner u32 value which is described below.
    - ``StoredVersionedContractByHash { hash: b348fdd0d0b3f66468687df93141b5924f6bb957d5893c08b60d5a78d0b9a423, version: None, entry_point: "PsLz5c7JsqT8BK8ll0kF", args: 3d0d7f193f70740386cb78b383e2e30c4f976cf3fa834bafbda4ed9dbfeb52ce1777817e8ed8868cfac6462b7cd31028aa5a7a60066db35371a2f8 }``
    - ``0x03b348fdd0d0b3f66468687df93141b5924f6bb957d5893c08b60d5a78d0b9a423001400000050734c7a3563374a73715438424b386c6c306b463b0000003d0d7f193f70740386cb78b383e2e30c4f976cf3fa834bafbda4ed9dbfeb52ce1777817e8ed8868cfac6462b7cd31028aa5a7a60066db35371a2f8``

- StoredVersionedContractByName serializes such that the first byte within the serialized buffer is 4u8. The name and entry_point are serialized as a String CLValue, with the Option version field serializing to 0 if the value is None, else it serializes the inner u32 value as described below.
    - ``StoredVersionedContractByName { name: "lWJWKdZUEudSakJzw1tn", version: Some(1632552656), entry_point: "S1cXRT3E1jyFlWBAIVQ8", args: 9975e6957ea6b07176c7d8471478fb28df9f02a61689ef58234b1a3cffaebf9f303e3ef60ae0d8 }``
    - ``0x04140000006c574a574b645a5545756453616b4a7a7731746e01d0c64e61140000005331635852543345316a79466c57424149565138270000009975e6957ea6b07176c7d8471478fb28df9f02a61689ef58234b1a3cffaebf9f303e3ef60ae0d8``

- Transfer serializes such that the first byte within the serialized buffer contains is 5u8, with the remaining bytes of the buffer containing the bytes contained within the args field of Transfer.

is_valid
~~~~~~~~
This is the only field within the deploy that is not serialized.

Deploy Serialization at High Level
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider the following deploy:

.. code:: json

    {
    "hash": "2640413b0a9f9179d6ae0c7424335483682a4a240a71b0e438be07796c68548b",
    "header": {
        "account": "018e8560906e20ac3059fbc0498a86a9f775d51d54c0b36d00c830c4e29a6587f7",
        "timestamp": "2020-10-29T15:28:44.620Z",
        "ttl": "22m 6s 290ms",
        "gas_price": 83,
        "body_hash": "cf0e5d669745d5acea0abb8ee784ee55adf26afc3a3f2e9b8523115a65de679a",
        "dependencies": [
        "5315e77c1cfeb0d6f3b60e863daeffbfcf6ebd3ea85b288b9ca4929039106395",
        "c753ec013bb77522a210c7fed68c359308f0d9536c00216c2ddd5b3442835a03",
        "8fc364a7266ee2c0a17e8c7f86f3fdcc2b1d590fa5c61e969bf2bf1811366643"
        ],
        "chain_name": "casper-example"
    },
    "payment": {
        "ModuleBytes": {
        "module_bytes": "9babcba5d0afbe3f06c2adbd907e61f179fb",
        "args": "831728a0fe7862148d71cb5dc812c89c01965d1849"
        }
    },
    "session": {
        "Transfer": {
        "args": "9d836ba4cc5b272c362ecdf4c70e1bed0401bbb8bcee18c7ca13945e8f73"
        }
    },
    "approvals": [
        {
        "signer": "018e8560906e20ac3059fbc0498a86a9f775d51d54c0b36d00c830c4e29a6587f7",
        "signature": "01fb9a66c5ad0fe86bc5c5afb98dad6f1dde1b82af7ca7522866b558ccc516b020ce2e5d6728c760c72bd5b7c2c5b9c62cc4f0743edd3ac519679342fc5f7d2c03"
        }
    ]
    }

The above deploy will serialize to:

``0x20000000000000002640413b0a9f9179d6ae0c7424335483682a4a240a71b0e438be07796c68548b0000000020000000000000008e8560906e20ac3059fbc0498a86a9f775d51d54c0b36d00c830c4e29a6587f74cbaf97475010000d23c14000000000053000000000000002000000000000000cf0e5d669745d5acea0abb8ee784ee55adf26afc3a3f2e9b8523115a65de679a030000000000000020000000000000005315e77c1cfeb0d6f3b60e863daeffbfcf6ebd3ea85b288b9ca49290391063952000000000000000c753ec013bb77522a210c7fed68c359308f0d9536c00216c2ddd5b3442835a0320000000000000008fc364a7266ee2c0a17e8c7f86f3fdcc2b1d590fa5c61e969bf2bf18113666430e000000000000006361737065722d6578616d706c650000000012000000000000009babcba5d0afbe3f06c2adbd907e61f179fb1500000000000000831728a0fe7862148d71cb5dc812c89c01965d1849050000001e000000000000009d836ba4cc5b272c362ecdf4c70e1bed0401bbb8bcee18c7ca13945e8f7301000000000000000000000020000000000000008e8560906e20ac3059fbc0498a86a9f775d51d54c0b36d00c830c4e29a6587f7000000004000000000000000fb9a66c5ad0fe86bc5c5afb98dad6f1dde1b82af7ca7522866b558ccc516b020ce2e5d6728c760c72bd5b7c2c5b9c62cc4f0743edd3ac519679342fc5f7d2c03``


.. _serialization-standard-values:

Values
------

A value stored in the global state is a ``StoredValue``. A ``StoredValue`` is one of three possible variants:

- A ``CLValue``
- A contract
- An account

We discuss ``CLValue`` and contract in more detail below. Details about
accounts can be found in :ref:`accounts-head`.

Each ``StoredValue`` is serialized when written to the global state. The
serialization format consists of a single byte tag, indicating which variant of
``StoredValue`` it is, followed by the serialization of that variant.  The tag
for each variant is as follows:

- ``CLValue`` is ``0``
- ``Account`` is ``1``
- ``Contract`` is ``2``

The details of ``CLType`` serialization are in the following section. Using the serialization format for ``CLValue`` as a basis, we can succinctly write the serialization rules for contracts and accounts:

- contracts serialize in the same way as data with ``CLType`` equal to
  ``Tuple3(List(U8), Map(String, Key), Tuple3(U32, U32, U32))``;

- accounts serialize in the same way as data with ``CLType`` equal to
  ``Tuple5(FixedList(U8, 32), Map(String, Key), URef, Map(FixedList(U8, 32), U8), Tuple2(U8, U8))``.

Note: ``Tuple5`` is not a presently supported ``CLType``. However it is clear how to generalize the rules for ``Tuple1``, ``Tuple2``, ``Tuple3`` to any size tuple.

Note: links to further serialization examples and a reference implementation are found in :ref:`Appendix B <appendix-b>`.

``CLValue``
~~~~~~~~~~~

``CLValue`` is used to describe data that is used by smart contracts. This could be as a local state variable, input argument, or return value. A ``CLValue`` consists of two parts: a ``CLType`` describing the type of the value and an array of bytes representing the data in our serialization format.

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
following rules (this defines the Casper serialization format):

- Boolean values serialize as a single byte; ``true`` maps to ``1``, while ``false`` maps to ``0``.

- Numeric values consisting of 64 bits or less serialize in the two's complement
  representation with little-endian byte order, and the appropriate number of
  bytes for the bit-width.

   - E.g. ``7u8`` serializes as ``0x07``
   - E.g. ``7u32`` serializes as ``0x07000000``
   - E.g. ``1024u32`` serializes as ``0x00040000``

- Wider numeric values (i.e. ``U128``, ``U256``, ``U512``) serialize as one byte given the length of the next number (in bytes), followed by the two's complement representation with little-endian byte order. The number of bytes should be chosen as small as possible to represent the given number. This is done to reduce the serialization size when small numbers are represented within a wide data type.

   - E.g. ``U512::from(7)`` serializes as ``0x0107``
   - E.g. ``U512::from(1024)`` serializes as ``0x020004``
   - E.g. ``U512::from("123456789101112131415")`` serializes as ``0x0957ff1ada959f4eb106``

- Unit serializes to an empty byte array.

- Strings serialize as a 32-bit integer representing the length in bytes (note: this might be different than the number of characters since special characters, such as emojis, take more than one byte), followed by the UTF-8 encoding of the characters in the string.

   - E.g. ``"Hello, World!"`` serializes as ``0x0d00000048656c6c6f2c20576f726c6421``

- Optional values serialize with a single byte tag, followed by the serialization of the value itself. The tag is equal to ``0`` if the value is
  missing, and ``1`` if it is present.

   - E.g. ``None`` serializes as ``0x00``
   - E.g. ``Some(10u32)`` serializes as ``0x010a000000``

- A list of values serializes as a 32-bit integer representing the number of
  elements in the list (note this differs from strings where it gives the number
  of *bytes*), followed by the concatenation of each serialized element.

   - E.g. ``List()`` serializes as ``0x00000000``
   - E.g. ``List(1u32, 2u32, 3u32)`` serializes as ``0x03000000010000000200000003000000``

- A fixed-length list of values serializes as the concatenation of the serialized elements. Unlike a variable-length list, the length is not included in the serialization because it is statically known by the type of the value.

   - E.g. ``[1u32, 2u32, 3u32]`` serializes as ``0x010000000200000003000000``

- A ``Result`` serializes as a single byte tag followed by the serialization of the contained value. The tag is equal to ``1`` for the success variant and ``0`` for the error variant.

   - E.g. ``Ok(314u64)`` serializes as ``0x013a01000000000000``
   - E.g. ``Err("Uh oh")`` serializes as ``0x00050000005568206f68``

- Tuples serialize as the concatenation of their serialized elements. Similar to
  ``FixedList`` the number of elements is not included in the serialization
  because it is statically known in the type.

   - E.g. ``(1u32, "Hello, World!", true)`` serializes as
     ``0x010000000d00000048656c6c6f2c20576f726c642101``

- A ``Map`` serializes as a list of key-value tuples. There must be a
  well-defined ordering on the keys, and in the serialization, the pairs are listed in ascending order. This is done to ensure determinism in the serialization, as
  ``Map`` data structures can be unordered.

- ``URef`` values serialize as the concatenation of its address (which is a fixed-length list of ``u8``) and a single byte tag representing the access rights. Access rights are converted as follows:

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
  followed by the serialization of the data that variant contains. For most variants, this is simply a fixed-length 32-byte array. The exception is
  ``Key::URef``, which contains a ``URef``; so its data serializes per the description above. The tags are as follows: ``Key::Account`` serializes as
  ``0``, ``Key::Hash`` as ``1``, ``Key::URef`` as ``2``.

``CLType`` itself also has rules for serialization. A ``CLType`` serializes as a single-byte tag, followed by the concatenation of serialized inner types, if any (e.g., lists and tuples have inner types). ``FixedList`` is a minor exception because it also includes the length in the type. However, the length is included in the serialization (as a 32-bit integer, per the serialization rules above), following the serialization of the inner type. The tags are as follows:

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

A complete ``CLValue``, including both the data and the type, can also be serialized (to store it in the global state). This is done by concatenating: the serialization of the length (as a 32-bit integer) of the
serialized data (in bytes), the serialized data itself, and the serialization of the type.

.. _global-state-contracts:

Contracts
~~~~~~~~~

Contracts are a special value type because they contain the on-chain logic of the applications running on the Casper network. A *contract* contains the following data:

-  a `wasm module <https://webassembly.org/docs/modules/>`__
-  a collection of named keys
-  a protocol version

The wasm module must contain a function named ``call`` which takes no arguments and returns no values. This is the main entry point into the contract. Moreover, the module may import any of the functions supported by the Casper runtime; a list of all supported functions can be found in :ref:`Appendix A <appendix-a>`.

Note: though the ``call`` function signature has no arguments and no return value, within the ``call`` function body the ``get_named_arg`` runtime function can be used to accept arguments (by ordinal), and the ``ret`` runtime function can be used to return a single ``CLValue`` to the caller.

The named keys are used to give human-readable names to keys in the global state, which are essential to the contract. For example, the hash key of another contract it frequently calls may be stored under a meaningful name. It is also used to store the ``URef``\ s, which are known to the contract (see the section on Permissions for details).

Each contract specifies the Casper protocol version with which the contract should be compatible. Any node in the Casper network will not execute contracts that are not compatible with the active major protocol version.