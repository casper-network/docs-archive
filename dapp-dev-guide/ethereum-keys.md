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
$ casperlabs_client --host localhost transfer --private-key eth-private.pem -a 100 -t d5fcbd8fc87d8943ce9273f3a4d1e98ec78f1515f05e7fe027a94885dbe043e2
Success! Deploy 3ac411115a0df8c28554e914c078c6ac7efb26b740740d11bce132a0e5c4de2a deployed

$ casperlabs_client --host localhost show-deploy 3ac411115a0df8c28554e914c078c6ac7efb26b740740d11bce132a0e5c4de2a
deploy {
  deploy_hash: "3ac411115a0df8c28554e914c078c6ac7efb26b740740d11bce132a0e5c4de2a"
  header {
    account_public_key_hash: "a58f68fffdb5b0bcc593577696e8c41320b199fae35d866494edca20d314129d"
    timestamp: 1593436760800
    body_hash: "ddc22e669e08ee784af0ca77b8a0fc058860fb80f5db55163c26406aadc08fd1"
  }
  approvals {
    approver_public_key: "24578ce721ef423dda2aeb2703fab6fab86eed120eb09d8e94dc1c2ccd713314"
    signature {
      sig_algorithm: "ed25519"
      sig: "99be8e0c34d9b42fc9c6f589ab5a2d851a188c9b22cd97b8ef8825d07667cf469d72280ad3a0035fcfaafcbcf5d94c4d8cad16571368f679b17fc9e6b0a0f60e"
    }
  }
}
status {
  state: PENDING
}
```

`account_public_key_hash` shows the Account Hash generated from the `eth-private.pem`.