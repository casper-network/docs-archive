.. _communications-head:

Communications
==============

.. _communications-discovery:

Nodes form a peer-to-peer network, constantly communicating with each other to reach consensus about the state of the blockchain. A node is not necessarily a single physical machine, but it appears as a single logical entity to the rest of its peers by having a unique ID and address where it responds to incoming network traffic.

Identity
--------

Each node has an identity on the network (not be confused with its identity in the consensus process), which is based on the fingerprint of the public key of a self-signed TLS certificate. A node generates a new private key each time it starts, ensuring a unique ID.

Each identity is linked with an address, which is an IP and port pair the node is reachable at. The pair of (id, address) is also called an endpoint.

Inter-node connections
----------------------

Should a node want to connect to another node with a known endpoint, it opens a TLS connection to the endpoint's address. In the context of common TLS parlance, this makes the connecting node the "client" and the remote node the "server" for this connection.

During connection setup, the client checks the server's certificate, which must match the expected public identity of the endpoint to ensure we have connected to the right node. Additionally the TLS parameters of the connection and certificate are required to contain the same ciphers, digests, etc. to protect against downgrade attacks.

At the same time, the connecting node sends its own certificate as the client certificate, allowing the server to perform the same check in reverse and establish the client's ID. At the end of the process, both nodes can be sure about which peer they are connected to.

Once a connection is established, if it is a one-way connection, the server will immediately seek to connect back to a node based on its endpoint (see `Node Discovery`_ on how the server finds endpoints). If a bidirectional connection setup cannot be established within a certain amount of time, all connections to the peer ID are dropped.

Connections are used for sending messages one-way only, only the node initiating a connection will send messages on it.

Network
-------

As soon as a node has connected to one node in the network, it partakes in `Node Discovery`_. In general, any node will attempt to connect to any other node on the network it finds as described above, leading to a fully connected network.

Two classes of data transfers happen in the network; broadcasts and gossiping. A broadcast message is sent once, without guarantees, to all other nodes the node is currently connected to. The process of gossiping is described further below.

In general, only consensus messages, which are only sent by active validators, are broadcast, everything else is gossipped.

.. _communications-gossiping:

Gossiping
---------

Multiple types of objects are gossipped, the most prominent ones being blocks, deploys and endpoints (see `Identity`_). Each of these objects have in common that they are immutable and can be identified by a unique hash.

Gossiping is a process of distributing a value across the entire network, without having to send it to each node directly, allowing only a subset of nodes to be connected to the original sender and spreading the bandwidth and processing requirements across the network as a whole, at the cost of latency and overall bandwidth consumed.

The process can be summarized as follows:

Given a message `M` to gossip, a desired saturation `S`, and an infection limit `L`:

1. Pick a subset `T` of `k` nodes from all currently connected nodes.
2. Send `M` to each node in `T`, noting which nodes were already infected (a node is considered infected if it already had received or known `M`).
3. For every node shown as already infected, add another random node outside to `T` and send it `M`, again noting the response.
4. End when we confirm infection of `L` new nodes or encountered `S` already infected nodes.

Through this process, a message will spread to almost all nodes over time.

Requesting missing data
-----------------------

While gossiping and broadcasting are sufficient to distribute data across the network in most cases, nodes can also request missing data from peers should they require it. Common examples are deploys not found in blocks, or consensus DAG vertices that have not reached a peer yet, but are referenced by other vertices.

Validation
~~~~~~~~~~

Objects have a concept of dependencies, for example a block depends on all the deploys whose hashes are listed inside it. A node considers any object valid if all of its dependencies are available on the local node.

Should a node receive an object from peer that is not valid yet, it will attempt to complete its validation before processing it further. In the case of gossiping, this means pausing the gossiping of the object until all its dependencies can be retrieved.

Any node is responsible for only propagating valid objects. Should a node not be able to retrieve all missing dependencies of an object from the peer that sent it, it may punish the peer for doing so.

Node Discovery
--------------

Node discovery happens by each node periodically gossiping its public address. Upon receiving an address via gossip, each node immediately tries to establish a connection to it and notes the resulting endpoint, if successful.
