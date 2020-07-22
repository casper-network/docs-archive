# Working with Ethereum Keys

CasperLabs platform supports two types of signatures: secp256k1 and ed25519. 
In this section we'll explore secp256k1, that is used in Ethereum.

## Keys Generation
CasperLabs Client allows to generate a new secp256k1 key-pair and the coresponding Account Hash.
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
It is possible to use already existing secp256k1 keys. Ethereum private keys usually are presented
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

The last missing element is obtaining the Account Hash. One can simply make a deploy and read the header value.

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

`account_public_key_hash` shows the Account Hash generated from the `eth-private.pem`.