**Subcommand Deploy - Constructs a Deploy and sends it**

The following is a list of parameters in the deploy subcommand:

| Subcommand       | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| -p, --payment    | <arg> Path to the ``file` `with payment code.                |
| --payment-``hash | <arg>   Hash of the stored contract to be called ``in` `the payment; base16 encoded. |
| --payment-name   | <arg>  Name of the stored contract (associated with the executing account) to be called ``in` `the payment. |
| --payment-uref   | <arg> URef of the stored contract to be called ``in` `the payment; base16 encoded. |
| --private-key    | <arg> Path to the ``file` `with account private key (Ed25519) |
| --public-key     | <arg> Path to the ``file` `with account public key (Ed25519) |
| -s, --session    | <arg> Path to the ``file` `with session code.                |
| --session-``hash | <arg> Hash of the stored contract to be called ``in` `the session; base16 encoded. |
| --session-name   | <arg> Name of the stored contract (associated with the executing account) to be called ``in` `the session. |
| --session-uref   | <arg> URef of the stored contract to be called ``in` `the session; base16 encoded. |

