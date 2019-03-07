# Deployments

### The Deploy Message

Clients send Deploys to one or more nodes on the network who will validate them and try to include them in future Blocks. To do this Clients need to make a call to the `DeploymentService`. The specifics can be found under [Deployment API](../appendix/grpc-interfaces.md#deployment-api).

The `Deploy` message has the following notable fields:

* `session_code` is the WASM byte code to be executed on the Blockchain
* `payment_code` is the WASM byte code that provides funds in the form of a token transfer in exchange for the validators executing the `session_code`
* `gas_price` is the rate at which the tokens transferred by the `payment_code` are burned up during the execution of the `session_code`
* `nonce` has to correspond to the next sequence number the Account sending the Deploy. The nodes will hold on to the Deploy until the previous nonce has been included in the Block they are trying to build on.
* `account_public_key` is the public key associated with the Account and the one that is used to sign the Deploy. This is how nodes can identify Accounts and find out what the currently expected nonce is.

Only existing Accounts can send Deploys. The way for a user to create an Account is to:

1. generate a public/private key pair for themselves offline
2. give the public key to an exchange \(or friend\) that already has an Account and tokens, and ask them to send a Deploy which transfers some tokens to the user, and by doing so establishes the user's Account
3. probably pay fiat money for the service/favor.

Users have to sign the Deploys, for which they have to calculate the hashes of all its parts. Currently the only supported hashing algorithm is Blake2b-256. If that needs to change in the future then the name of the algorithm will be added to the `Signature`.

