# Working with Ethereum Keys

The Casper platform supports two types of signatures for the creation of accounts and signing of transactions: secp256k1 and ed25519.

In this section we'll explore secp256k1, commonly known as Ethereum keys.

## Key Generation
The CasperLabs client enables the creation of a new ed25519 key-pair and the coresponding account hash.
```bash
$ mkdir secp256k1-keys

$ casper-client keygen -a secp256k1 secp256k1-keys/
Keys successfully created in directory: /tmp/secp256k1-keys

$ tree secp256k1-keys/
secp256k1-keys/
├── account-id-hex
├── account-private.pem
└── account-public.pem
```

## Using Ethereum Keys in CasperLabs
It is possible to use existing secp256k1 keys. Ethereum secret keys usually are presented
in the form of hex string that represents 256 bits.

Example of an Ethereum secret key.
```
18d763eef165a8334e32f8a7c6c6592f053d1716d779a0cad76ee5cddee79e8c
```
The rust casper-client requires the secret key to be in PEM format, so if you want to use existing Eth keys with the rust client, a conversion is needed.
It's possible to create clients, or serialize your own deploys also.

This is an example JS script that generates a pem file. It uses [key encoder](https://github.com/blockstack/key-encoder-js) and node.js.
To install these components do the following:

```bash
$ sudo apt install nodejs
$ npm install  key-encoder
```
Then create the js script `convert-to-pem.js` using vi or nano and include these contents.

```bash

var KeyEncoder = require('key-encoder'),
    keyEncoder = new KeyEncoder.default('secp256k1');
let priv_hex = "THE SECRET KEY TO ENCODE";
let priv_pem = keyEncoder.encodePrivate(priv_hex, "raw", "pem");
console.log(priv_pem);
```
Then run the script using node.js.  Name the secret key something different.
```bash

$ node convert-to-pem.js > eth-secret.pem
```
To view the secret key, cat the file:

``` bash

$ cat eth-secret.pem 
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIBjXY+7xZagzTjL4p8bGWS8FPRcW13mgytdu5c3e556MoAcGBSuBBAAK
oUQDQgAEpV4dVaPeAEaH0VXrQtLzjpGt1pui1q08311em6wDCchGNjzsnOY7stGF
tlKF2V5RFQn4rzkwipSYnrqaPf1pTA==
-----END EC PRIVATE KEY-----
```
