---
description: 'gRPC, Block Propogation, Node Discovery'
---

# Communications

## Node Discovery

Nodes for a peer-to-peer network, constantly communicating with each other to reach consensus about the state of the Blockchain. A Node is not necessarily a single physical machine, but it appears as a single logical entity to the rest of their peers by having a unique ID and address where it responds to requests.

Nodes periodically try to discover each other based on elements of the [Kademlia](https://en.wikipedia.org/wiki/Kademlia) protocol. Unlike the original Kademlia which was using UDP, Nodes are using point-to-point gRPC calls for communication. The specifics can be found under the [gRPC Interfaces](../appendix/grpc-interfaces.md#kademlia-api). According to this protocol every `Node` has the following properties:

* `id` is a Keccak-256 digest of the Public Key from the SSL certificate of the node
* `host` is the public endpoint where the node is reachable
* `discovery_port` is where the gRPC service implementing the `KademliaService` is listening
* `protocol_port` is where the gRPC service implementing the consensus related functionality is listening

The `KademliaService` itself has to implement only two methods:

* `Ping` is used by the `sender` to check if the callee is still alive. It also gives the callee the chance to update its list of peers and remember that it has seen the `sender` Node.
* `Lookup` asks the Node to return a list of Nodes that are closest to the `id` the `sender` is looking for, where distance between two Nodes based on the longest common prefix of bits in their `id`.

At startup the Nodes should be configured with the address of a well known peer to bootstrap themselves from. To discovery other Nodes they can pick from multiple strategies:

* Perform one-time lookup on their own `id` by the bootstrap Node \(which doesn't know them yet\) to receive a list of peers closest to itself. Recursively perform the same lookup with those peers to accumulate more and more addresses until there are nothing new to add.
* Periodically construct artificial keys to try to find peers at certain distances from `id` and perform a lookup by a random Node.

## Deployments

Clients send Deploys to one or more Nodes on the network who will validate them and try to include them in future Blocks. To do this Clients need to make a call to the `DeploymentService`. The specifics can be found under [gRPC Interfaces](../appendix/grpc-interfaces.md#deployment-api).

The `Deploy` message has the following notable fields:

* `session_code` is the WASM byte code to be executed on the Blockchain
* `payment_code` is the WASM byte code that provides funds in the form of a token transfer in exchange for the validators executing the `session_code` 
* `gas_price` is the rate at which the tokens transferred by the `payment_code` are burned up during the execution of the `session_code`
* `nonce` has to correspond to the next sequence number the Account sending the Deploy. The Nodes will hold on to the Deploy until the previous nonce has been included in the Block they are trying to build on.
* `account_public_key` is the public key associated with the Account and the one that is used to sign the Deploy. This is how Nodes can identify Accounts and find out what the currently expected nonce is.

Only existing Accounts can send Deploys. The way for a user to create an Account is to go to an exchange \(or friend\) that already has an Account and tokens and to pay them to create one for the user by calling a blessed contract on the Blockchain which will transfer tokens from the exchange to the user and store the users' public key on the chain as well. The exchange does this in form of a Deploy. As soon as that Deploy appears in one of the Blocks the user is free to send their own Deploys. To identify the Deploy in question the user has to know the public key of the exchange and the nonce it used to create the Account.

The user has to sign the request for which it has to calculate the hashes of all its parts. Currently the only supported hashing algorithm is Blake2b-256. If that needs to change in the future then the name of the algorithm will be added to the `Signature`.

## Block gossiping

Nodes propose Blocks in parallel by finding Deploys that can be applied independently of each other. Whenever a new Block is formed, it has to propagate through the network to become part of the consensus. This is achieved by Nodes making calls to each other via gRPC to invoke methods on their `BlockService` interface which should be listening on the `protocol_port` of the `Node` that represents the peers in the network. The details of the service can be seen under [gRPC Interfaces](../appendix/grpc-interfaces.md#gossiping-api).







