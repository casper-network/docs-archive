.. _generate-keys:

Generate Keys and Certificates for the Node
===========================================

The CasperLabs platform uses three different sets of keys for different
functions.

1. A node operator must provide a\ ``secp256r1`` private key encoded in
   unencrypted ``PKCS#8`` format and an ``X.509`` certificate. These are
   used to encrypt communication with other nodes.
2. A validator must provide an ``ed25519`` keypair for use as their
   identity. If these keys are not provided when the node is started, a
   node will default to read-only mode.
3. A DApp developer must provide an ``ed25519`` keypair for their
   account identity and deploying code.

Generating Node Keys and Validator Keys
---------------------------------------

In order to run a node or validate, you will need the following files:

+------------------------------+--------------------------------------------------------+
| File                         | Contents                                               |
+==============================+========================================================+
| ``node.key.pem``             | A ``secp256r1`` private key                            |
+------------------------------+--------------------------------------------------------+
| ``node.certificate.pem``     | The ``X.509`` certificate containing the ``secp256r1`` |
|                              | public key paired with ``node.key.pem``                |
+------------------------------+--------------------------------------------------------+
| ``node-id``                  | A value that is used to uniquely identify a node on    |
|                              | the network, derived from ``node.key.pem``             |
+------------------------------+--------------------------------------------------------+
| ``validator-private.pem``    | An ``ed25519`` private key                             |
+------------------------------+--------------------------------------------------------+
| ``validator-public.pem``     | The ``ed25519`` public key paired with                 |
|                              | ``validator-private.pem``                              |
+------------------------------+--------------------------------------------------------+
| ``validator-id``             | The base-64 representation of ``validator-public.pem`` |
+------------------------------+--------------------------------------------------------+
| ``validator-id-hex``         | The base-16 representation of                          |
|                              | ``validator-public.pem``, used when issuing certain    |
|                              | commands to the node                                   |
+------------------------------+--------------------------------------------------------+

The recommended method for generating keys is to use the `Docker
image </hack/key-management/Dockerfile>`__ that we provide.

More advanced users may prefer to generate keys directly on their host
OS.

Using casperlabs-client (recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Prerequisites
^^^^^^^^^^^^^

-  `casperlabs-client <https://github.com/CasperLabs/CasperLabs/blob/dev/docs/INSTALL.md>`__

Instructions
^^^^^^^^^^^^

.. code:: none

   mkdir /tmp/keys
   casperlabs-client keygen /tmp/keys

You should see the following output:

.. code:: none

   Keys successfully created in directory: /tmp/keys

Using Docker
~~~~~~~~~~~~

.. _prerequisites-1:

Prerequisites
^^^^^^^^^^^^^

-  `Docker <https://docs.docker.com/install/>`__

.. _instructions-1:

Instructions
^^^^^^^^^^^^

(from the root of this repo)

.. code:: none

   mkdir keys
   ./hack/key-management/docker-gen-keys.sh keys

You should see the following output:

.. code:: none

   using curve name prime256v1 instead of secp256r1
   read EC key
   Generate keys: Success

Using OpenSSL and keccak-256sum
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _prerequisites-2:

Prerequisites
^^^^^^^^^^^^^

-  `OpenSSL <https://www.openssl.org>`__: v1.1.1 or higher
-  `libkeccak <https://github.com/maandree/libkeccak>`__
-  `sha3sum <https://github.com/maandree/sha3sum>`__

If you don’t know how to install these prerequisites, you should
probably use the `above instructions <#using-docker>`__

.. _instructions-2:

Instructions
^^^^^^^^^^^^

.. code:: none

   mkdir keys
   ./hack/key-management/gen-keys.sh keys

You should see the following output:

.. code:: none

   using curve name prime256v1 instead of secp256r1
   read EC key
   Generate keys: Success

Generating Account Keys (For Dapp Developers)
---------------------------------------------

Currently, the recommended method for generating account keys is to use
the `CasperLabs Explorer <https://clarity.casperlabs.io>`__.

These instructions are provided for reference and advanced use-cases.

In order to deploy a contract on the network, you will need the
following files:

+-------------------------+----------------------------------------------------------+
| File                    | Contents                                                 |
+=========================+==========================================================+
| ``account-private.pem`` | An ``ed25519`` private key                               |
|                         |                                                          |
|                         |                                                          |
+-------------------------+----------------------------------------------------------+
| ``account-public.pem``  | The ``ed25519`` public key paired with                   |
|                         | ``account-private.pem``                                  |
|                         |                                                          |
+-------------------------+----------------------------------------------------------+
| ``account-id``          | The base-64 representation of ``account-public.pem``     |
|                         |                                                          |
+-------------------------+----------------------------------------------------------+
| ``account-id-hex``      | The base-16 representation of ``account-public.pem``,    |
|                         | used when issuing certain commands to the node           |
+-------------------------+----------------------------------------------------------+

.. _using-docker-1:

Using Docker
~~~~~~~~~~~~

.. _prerequisites-3:

Prerequisites
^^^^^^^^^^^^^

-  `Docker <https://docs.docker.com/install/>`__

.. _instructions-3:

Instructions
^^^^^^^^^^^^

.. code:: none

   mkdir account-keys
   ./hack/key-management/docker-gen-account-keys.sh account-keys

Using OpenSSL
~~~~~~~~~~~~~

.. _prerequisites-4:

Prerequisites
^^^^^^^^^^^^^

-  `OpenSSL <https://www.openssl.org>`__: v1.1.1 or higher

.. _instructions-4:

Instructions
^^^^^^^^^^^^

.. code:: none

   openssl genpkey -algorithm Ed25519 -out account-private.pem
   openssl pkey -in account-private.pem -pubout -out account-public.pem
   openssl pkey -outform DER -pubout -in account-private.pem | tail -c +13 | openssl base64 > account-id
   cat account-id | openssl base64 -d | hexdump -ve '/1 "%02x" ' | awk '{print $0}' > account-id-hex
