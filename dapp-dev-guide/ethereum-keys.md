# Working with Ethereum Keys

The Casper platform supports two types of signatures for the creation of accounts and signing of transactions: secp256k1 and ed25519.  Internally, the system does this is by representing the account as the hash of the public key + encryption type.  By taking the hash of the public key and algorithm name, the likelihood of account collision is eliminated.  

In this section we'll explore secp256k1, commonly known as Ethereum keys.

## Keys Generation
Thhe CasperLabs Client enables the creatin of a new secp256k1 key-pair and the coresponding Account Hash.
```bash
$ mkdir secp256k1-keys

$ casperlabs_client keygen -a secp256k1 secp256k1-keys/
Keys successfully created in directory: /tmp/secp256k1-keys

$ tree secp256k1-keys/
secp256k1-keys/
├── account-id-hex
├── account-private.pem
└── account-public.pem
```

## Using Ethereum Keys in CasperLabs
It is possible to use existing secp256k1 keys. Ethereum private keys usually are presented
in the form of hex string that represents 256 bits.

Example of the Ethereum private key.
```
18d763eef165a8334e32f8a7c6c6592f053d1716d779a0cad76ee5cddee79e8c
```

CasperLabs requires the private key to be in the PEM format, so it's required to do the conversion.

This is the example JS script to do it:

```bash
$ cat convert-to-pem.js 
var KeyEncoder = require('key-encoder'),
    keyEncoder = new KeyEncoder.default('secp256k1');
let priv_hex = "18d763eef165a8334e32f8a7c6c6592f053d1716d779a0cad76ee5cddee79e8c";
let priv_pem = keyEncoder.encodePrivate(priv_hex, "raw", "pem");
console.log(priv_pem);

$ node convert-to-pem.js > eth-private.pem

$ cat eth-private.pem 
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIBjXY+7xZagzTjL4p8bGWS8FPRcW13mgytdu5c3e556MoAcGBSuBBAAK
oUQDQgAEpV4dVaPeAEaH0VXrQtLzjpGt1pui1q08311em6wDCchGNjzsnOY7stGF
tlKF2V5RFQn4rzkwipSYnrqaPf1pTA==
-----END EC PRIVATE KEY-----
```

The last missing element is obtaining the Account Hash. Because the internal representation 
of accounts is the hash of the public key and the algoirthhm, this hash is necessary
in order to query the state. Making a deploy and reading the header value is the easiest
way to obtain this information.

```bash
$ casperlabs_client --host localhost deploy --private-key eth-private.pem --session contract.wasm --algorithm secp256k1
Success! Deploy a124a6e68d804b4222cc12a3a9dfd1b64d9700589724682095f87705614c54c8 deployed

$ casperlabs_client --host localhost show-deploy a124a6e68d804b4222cc12a3a9dfd1b64d9700589724682095f87705614c54c8
deploy {
  deploy_hash: "a124a6e68d804b4222cc12a3a9dfd1b64d9700589724682095f87705614c54c8"
  header {
    account_public_key_hash: "c1f358d347c3134d0eade886c8379ebf05788ee7fb713d657ce358b6cf3b35a6"
    timestamp: 1594220659169
    body_hash: "e6b3f3fcf2fb5d3ab1cc74a4fa0271b68c4f75a9273d6982a95ffb9ee4cdd4e7"
  }
  approvals {
    ...
  }
}
status {
  state: PENDING
}
```

`account_public_key_hash` shows the Account Hash generated from `eth-private.pem`.
