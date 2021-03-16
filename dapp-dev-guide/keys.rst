
Working with Keys
=================

The Casper platform supports two types of signatures for the creation of accounts and signing of transactions: secp256k1 and ed25519.

In this section we'll explore secp256k1, commonly known as Ethereum keys.

Key Generation
--------------

The CasperLabs client enables the creation of keys in both formats. In this example, we create secp256k1 keys. 

.. code-block:: bash

   $ mkdir secp256k1-keys

   $ casper-client keygen -a secp256k1 secp256k1-keys/
   Keys successfully created in directory: /secp256k1-keys

   $ tree secp256k1-keys/
   secp256k1-keys/
   ├── public-key-hex
   ├── secret-key.pem
   └── public-key.pem

Looking at the public-key-hex file we see:

.. code-block:: bash

   ~/ethtest$ cat public_key_hex
   020287e1a79d0d9f3196391808a8b3e5007895f43cde679e4c960e7e9b92841bb98d
   
 secp256k1 public hex keys start with '02' in Casper.


It is also possible to create ed25519 keys:

.. code-block:: bash

   $ mkdir ed25519-keys

   $ casper-client keygen ed25519-keys/
   Keys successfully created in directory: /ed25519-keys

   $ tree ed25519-keys/
   ed25519-keys/
   ├── public-key-hex
   ├── secret-key.pem
   └── public-key.pem
   
 Looking at the public-key-hex file we see:

.. code-block:: bash

   ~/ed25519-keys$ cat public_key_hex
   011724c5c8e2404ca01c872e1bbd9202a0114e5d143760f685086a5cffe261dabd
     
Notice that keys of this type are pre-pended with `01`

Working with Existing Ethereum Keys
===================================

It is also possible to use existing Ethereum keys in  Casper. Here is an example set of Ethereum Keys and corresponding address. 

.. code-block::

   Address:0x7863B6F7232D99FF80B74E4C8BB3BEE3BDE0291F
   Public key:0470fecd1f7ae5c1cd53a52c4ca88cd5b76c2926d7e1d831addaa2a64bea9cc3ede6a8e9981c609ee7ab7e3fa37ba914f2fc52f6eea9b746b6fe663afa96750d66
   Private key:29773906aef3ee1f5868371fd7c50f9092205df26f60e660cafacbf2b95fe086

 
In order to use existing Ethereum keys, the Casper VM  needs to know that they key is a secp256k1 key type. 
The Rust casper-client provides an example of how this works. Pre-pending the public key with a `02` indicates 
the key is a secp256k1 key.  
 
 This transaction sends 100 CSPR to an Ethereum address.

.. code-block:: bash

    casper-client transfer --node-address http://localhost:7777 --chain-name casper -t 020470fecd1f7ae5c1cd53a52c4ca88cd5b76c2926d7e1d831addaa2a64bea9cc3ede6a8e9981c609ee7ab7e3fa37ba914f2fc52f6eea9b746b6fe663afa96750d66
    -a 10000000000 -k /home/mykeys/secret_key.pem -p 10000


To send a transaction from this account, the rust casper-client requires the secret key to be in PEM format, 
so if you want to use existing Eth keys with the rust client, a conversion is needed.
It's possible to create clients, or serialize your own deploys also.

This is an example JS script that generates a pem file. It uses `key encoder <https://github.com/blockstack/key-encoder-js>`_ and node.js.
To install these components do the following:

.. code-block:: bash

   $ sudo apt install nodejs
   $ npm install  key-encoder

Then create the js script ``convert-to-pem.js`` using vi or nano and include these contents.

.. code-block:: bash


   var KeyEncoder = require('key-encoder'),
       keyEncoder = new KeyEncoder.default('secp256k1');
   let priv_hex = "THE SECRET KEY TO ENCODE";
   let priv_pem = keyEncoder.encodePrivate(priv_hex, "raw", "pem");
   console.log(priv_pem);

Then run the script using node.js.  Name the secret key something different.

.. code-block:: bash


   $ node convert-to-pem.js > eth-secret.pem

To view the secret key, cat the file:

.. code-block:: bash


   $ cat eth-secret.pem 
   -----BEGIN EC PRIVATE KEY-----
   MHQCAQEEIBjXY+7xZagzTjL4p8bGWS8FPRcW13mgytdu5c3e556MoAcGBSuBBAAK
   oUQDQgAEpV4dVaPeAEaH0VXrQtLzjpGt1pui1q08311em6wDCchGNjzsnOY7stGF
   tlKF2V5RFQn4rzkwipSYnrqaPf1pTA==
   -----END EC PRIVATE KEY-----

