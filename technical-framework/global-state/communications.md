---
description: 'gRPC, Block Propogation, Node Discovery'
---

# Communications

## Node Discovery

Nodes for a peer-to-peer network, constantly communicating with each other to reach consensus about the state of the Blockchain. A node is not necessarily a single physical machine, but it appears as a single logical entity to the rest of their peers by having a unique ID and address where it responds to requests.

Nodes periodically try to discover each other based on elements of the [Kademlia](https://en.wikipedia.org/wiki/Kademlia) protocol. Unlike the original Kademlia which was using UDP, nodes are using point-to-point gRPC calls for communication. The specifics can be found under the [gRPC Interfaces](../appendix/grpc-interfaces.md#kademlia-api). According to this protocol every `Node` has the following properties:

* `id` is a Keccak-256 digest of the Public Key from the SSL certificate of the node
* `host` is the public endpoint where the node is reachable
* `discovery_port` is where the gRPC service implementing the `KademliaService` is listening
* `protocol_port` is where the gRPC service implementing the consensus related functionality is listening

The `KademliaService` itself has to implement only two methods:

* `Ping` is used by the `sender` to check if the callee is still alive. It also gives the callee the chance to update its list of peers and remember that it has seen the `sender` node.
* `Lookup` asks the node to return a list of nodes that are closest to the `id` the `sender` is looking for, where distance between two nodes based on the longest common prefix of bits in their `id`.

At startup the nodes should be configured with the address of a well known peer to bootstrap themselves from. To discovery other nodes they can pick from multiple strategies:

* Perform one-time lookup on their own `id` by the bootstrap node \(which doesn't know them yet\) to receive a list of peers closest to itself. Recursively perform the same lookup with those peers to accumulate more and more addresses until there are nothing new to add.
* Periodically construct artificial keys to try to find peers at certain distances from `id` and perform a lookup by a random node.

