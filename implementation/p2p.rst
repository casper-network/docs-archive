.. _communications-head:

Communications
==============

.. _communications-discovery:

Node Discovery
--------------

Nodes form a peer-to-peer network, constantly communicating with each other to reach consensus about the state of the blockchain. A node is not necessarily a single physical machine, but it appears as a single logical entity to the rest of its peers by having a unique ID and address where it responds to requests.

Nodes periodically try to discover each other based on elements of the
`Kademlia <https://en.wikipedia.org/wiki/Kademlia>`__ protocol. Unlike the original Kademlia which was using UDP, nodes are using point-to-point `gRPC calls <https://github.com/CasperLabs/CasperLabs/blob/c78e35f4d8f0f7fd9b8cf45a4b17a630ae6ab18f/protobuf/io/casperlabs/comm/discovery/kademlia.proto>`__ for communication. According to this protocol every ``Node`` has the following properties:

-  ``id`` is a Keccak-256 digest of the Public Key from the SSL certificate of the
   node
-  ``host`` is the public endpoint where the node is reachable
-  ``discovery_port`` is where the gRPC service implementing the ``KademliaService``
   is listening
-  ``protocol_port`` is where the gRPC service implementing the consensus related
   functionality is listening

The ``KademliaService`` itself has to implement only two methods:

-  ``Ping`` is used by the ``sender`` to check if the callee is still alive. It also
   gives the callee the chance to update its list of peers and remember that it
   has seen the ``sender`` node.
-  ``Lookup`` asks the node to return a list of Nodes that are closest to the ``id``
   the ``sender`` is looking for, where distance between two Nodes based on the
   longest common prefix of bits in their ``id``.

At startup the nodes should be configured with the address of a well known peer
to bootstrap themselves from. To discover other nodes they can pick from
multiple strategies:

-  Perform one-time lookup on their own ``id`` by the bootstrap node (which
   doesn’t know them yet) to receive a list of peers closest to itself.
   Recursively perform the same lookup with those peers to accumulate more and
   more addresses until there is nothing new to add.
-  Periodically construct artificial keys to try to find peers at certain
   distances from ``id`` and perform a lookup by a random node.

.. _communications-gossiping:

Block Gossiping
---------------

Nodes propose Blocks in parallel by finding Deploys that can be applied
independently of each other. Whenever a new Block is formed, it has to propagate
through the network to become part of the consensus. This is achieved by nodes
making calls to each other via gRPC to invoke methods on their ``GossipService`` `interface <https://github.com/CasperLabs/CasperLabs/blob/release-v0.18/protobuf/io/casperlabs/comm/gossiping/gossiping.proto>`__
which should be listening on the ``protocol_port`` of the ``Node`` that represents
the peers in the network.

Principles
~~~~~~~~~~

We call the method by which information is disseminated on the network
*gossiping*. Gossiping means that when a node comes across new bits of
information it will relay it to a selection of its peers, who do the same,
eventually saturating the network, i.e. get to the point where everyone has been
notified.

Nodes need three layers of information about Blocks to be able to participate in
the consensus:

1. Block meta-data, e.g. parent relationships, validator weights, state hashes.
2. Deploys that were included in given Block.
3. Global State, to be able to run the Deploys, validate Blocks and build new
   ones on top of them.

Out of these only the top two are gossiped between nodes; ---the Global State, they
have to calculate themselves by running Deploys.

We have the following requirements for our gossiping approach:

-  It should be efficient, i.e. minimize the network traffic while maximizing the
   rate at which we reach full saturation.
-  Node operators should have a reasonable expectation that network traffic (a
   finite resource) will scale linearly with the amount of Deploys across the
   network while being less affected by the total number of nodes. This means the
   load should be distributed among the peers rather than create hot-spots.

To achieve these we have the following high-level approach:

-  Gossip only the meta-data about the Blocks to minimize the amount of data
   transfer.
-  Full Blocks can be served on demand when the gossiped meta-data is *new.*
-  Nodes should pick a *relay factor* according to how much network traffic they
   can handle and find that many nodes to gossip to --- nodes for which the
   information is *new*.
-  Nodes should pick a *relay saturation* target beyond which point they don’t
   try to push to new peers, so the last ones to get a message don’t have to
   contact every other peer in futility.
-  Nodes should try to spread the information mostly to their closer neighbors
   (in terms of Kademlia distance), but also to their farther away peers to
   accelerate the spread of information to the far reaches of the network.

Picking Nodes for Gossip
~~~~~~~~~~~~~~~~~~~~~~~~

As we established in the :ref:`communications-discovery`
section, the nodes maintain a list of peers using a Kademlia table. The table has
one bucket for each possible distance between the bits of their IDs, and they
pick a number *k* to be length of the list of nodes in each of these buckets
that they keep track of.

In statistical terms, half of the nodes in the network will fall in the first
bucket, since the first bit of their ID will either be 0 or 1. Similarly, each
subsequent bucket holds half of the remainder of the network. Since *k* is the
same for each bucket, this means that nodes can track many more of their closest
neighbors than the ones which are far away from them. This is why in Kademlia,
as we perform lookups we get closer and closer to the best possible match
anyone knows about.

In practice, this means that if we have a network of 50 nodes and a *k* of 10,
then from the perspective of any given peer, 25 nodes fall into the first
bucket, but it only tracks 10 of them; ergo it will never gossip to 15 nodes
from the other half that it doesn’t have the room to track in its table.

We can use this skewness to our advantage: say we pick a *relay factor* of 3; if
we make sure to always notify 1 node in the farthest non-empty buckets, and 2 in
the closer neighborhood, we can increase the chance that the information gets to
those Nodes on the other half of the board that we don’t track.

This is illustrated by the following diagram: The black actor on the left represents
our node and the vertical partitions represent the distance from it. The split
in the middle means the right half of the board falls under a single bucket in
the Kademlia table. The black dots on the board are the nodes we track, the
greys are ones we don’t. We know few peers from the right half of the network,
but much more on the left because it’s covered by finer and finer grained
buckets. If we pick nodes to gossip to evenly across the full distance spectrum,
and the Node on the right follows the same rule, it will start distributing our
message on that side of the board with a slightly higher chance than bouncing it
back to the left.

.. figure:: /assets/gossip-2.png
   :alt: Message propagation among peers

   Message propagation among peers

In terms of probabilities of reaching a grey node in the 2nd round, or just the
message being on the right side of the board in the 1st or 2nd round of message
passing, the gains are marginal and depend on how many peers there are in the
Kademlia table. We could give higher weights to the buckets that reach the
un-tracked parts of the network, but the effects will have to be simulated.

In practice the messages don’t have to reach every node on the network.
Achieving 100% saturation would be impractical as it would require a high level
of redundancy, i.e. a node receiving the same message multiple times from
different peers. Tracking who saw a message could bloat the message size or open
it up to tampering. But even if a node isn’t notified about a particular Block
*right now*, it has equal chances of receiving the next Block that builds on top
of that, at which point it can catch up with the missing chain.

Therefore nodes should have a *relay saturation* value beyond which they don’t
try to gossip a message to new nodes. For example, if we pick a *relay factor* of
5 and a *relay saturation* of 80% then it’s enough to try and send to 25 nodes
maximum. If we find less than 5 peers among them to whom the information was
*new*, then we achieved a saturation beyond 80%. This prevents the situation when
the last node to get the message has to contact every other node in a futile
attempt to spread it 5 more times. Assuming that every node tracks a random
subset of peers in the network, the saturation we observe in the nodes we try to
contact is an approximation of the saturation in the whole network, with the
accuracy depending on how many nodes we tried.

.. code:: c

   algorithm BlockGossip is
       input: message M to send,
              relay factor rf,
              relay saturation rs,
              kademlia table K
       output: number of messages sent s

       s <- 0
       P <- flatten the peers in K, ordered by distance from current node
       G <- partition P into R equal sized groups

       n <- an empty set to track notified peers
       m <- rf / (1 - rs) // the maximum number of peers to try to send to
       i <- 0 // the index of the current group

       while i < sizeof(G) and s <= rf and sizeof(n) < m:
           p <- a random peer in G(i)-n or None if empty
           if p is None then
               i <- i + 1
           else
               n <- n + p
               r <- the result of sending M to p, indicating whether M was new to p
               if r is true then
                   i <- i + 1
                   s <- s + 1

       return s

Fairness
~~~~~~~~

We can rightfully ask how the gossip algorithm outlined above fares in the face
of malicious actors that don’t want to take their share in the data
distribution, i.e. what happens if a node decides not to propagate the messages?

The consensus protocol has a built-in protection against lazy validators: to get
their fees from a Block produced by somebody else, they have to build on top of
it. When they do that, they have to gossip about it, otherwise it will not
become part of the DAG or it can get orphaned if conflicting blocks emerge, so
it’s in everyone’s interest for gossiping to happen at a steady pace.

What if they decide to announce *their* Blocks to *everyone* but never relay
other Blocks from other nodes? They have a few incentives against doing this:

-  If everybody would be doing it then the nodes unknown to the creators would
   get it much later and might produce conflicting blocks, the consensus would
   slow down.
-  When they finally announce a Block they built *everyone* would try to download
   it directly from them, putting extra load on their networks; plus they might
   have to download extra Blocks that the node failed to relay before.
-  If we have to relay to a 100 nodes directly, it could easily take longer
   for each of the 100 to download it from 1 node then for 10 nodes to do so and
   then relay to 10 more nodes each.

Having a *relay factor* together with the mechanism of returning whether the
information was *new*, has the following purpose:

-  By indicating that the information was new, the callee is signalling to the
   caller that once it has done the validation of the Block, it will relay the
   information; therefore the caller can be content that by informing this node
   it carried out the number of gossips it set out to do, i.e., it will have to
   serve the full Blocks up to R number of times.
-  By indicating that the information wasn’t new, the callee is signalling that
   it will not relay the information any longer, and therefore the caller should pick
   another node if it wants to live up to its pledge of relaying to R number of
   new nodes.

Nodes expect the ones which indicated that the Block meta-data was new to them
to later attempt to download the full Blocks. This may not happen, as other
nodes may notify them too, in which case they can download some Blocks from
here, some from there.

There are two forms of lying that can happen here:

1. The callee can say the information wasn’t anything new, but then attempt to
   download the data anyway. Nodes may create a disincentive for this by
   tracking each others' *reputation* and block nodes that lied to them.
2. The callee can say the information was new but not relay. This goes against
   their own interest as well, but it’s difficult to detect. A higher relay
   factor can compensate for the amount of liars on the network.

Nodes may also use reputation tracking and blocking if they receive
notifications about Blocks that cannot be validated or that the notifier isn’t
able to serve when asked.

Syncing the DAG
~~~~~~~~~~~~~~~

Let’s take a closer look at how the methods supported by the ``GossipService`` can
be used to spread the information about Blocks between nodes.

NewBlocks
^^^^^^^^^

When a node creates one or more new Blocks, it should pick a number of peers
according to its *relay factor* and call ``NewBlocks`` on them, passing them the
new ``block_hashes``. The peers check whether they already have the corresponding
blocks: if not, they indicate that the information is *new* and schedule a
download from the ``sender``, otherwise the caller looks for other peers to
notify.

By only sending block hashes can we keep the message size to a minimum. Even
block headers need to contain a lot of information for nodes to be able to do
basic verification; there’s no need to send all that if the receiving end
already knows about it.

Note that the ``sender`` value is known to be correct because nodes talking to
each other over gRPC must use two-way SSL encryption, which means the callee will
see the caller’s public key in the SSL certificate. The ``sender`` can only be a
``Node`` with an ``id`` that matches the hash of the public key.

StreamAncestorBlockSummaries
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When a node receives a ``NewBlock`` request about hashes it didn’t know about, it
must synchronize its Block DAG with the ``sender``. One way to do this is to have
some kind of *download manager* running in the node which:

-  maintains partially connected DAG of ``BlockSummary`` records that it has seen
-  tries to connect the new bits to the existing ones by downloading them from
   the senders
-  tracks which nodes notified it about each Block, to know alternative sources
   to download from
-  tracks which Blocks it promised to relay to other nodes
-  downloads and verifies full Blocks
-  notifies peers about validated Blocks if it promised to do so

``StreamAncestorBlockSummaries`` is a high level method that the caller node can
use to ask another for a *way to get to the block it just shouted about*. It’s a
method to traverse from the *target* block *backwards* along its parents until
every ancestor path can be connected to the DAG of the caller. It has the
following parameters:

-  ``target_block_hashes`` is typically the hashes of the new Blocks the node was
   notified about, but if multiple iterations are needed to find the connection
   points then they can be further back the DAG.
-  ``known_block_hashes`` can be supplied by the caller to provide an early exist
   criteria for the traversal. These can, for example, include the hashes close to
   the tip of the callers DAG, forks, last Blocks seen from validators, and
   approved Blocks (i.e., Blocks with a high safety threshold).
-  ``max_depth`` can be supplied by the caller to limit traversal in case the
   ``known_block_hashes`` don’t stop it earlier. This can be useful during
   iterations when we have to go back *beyond* the callers approved blocks, in
   which case it might be difficult to pick known hashes.

The result should be a partial traversal of the DAG in *reverse BFS order*
returning a stream of ``BlockSummaries`` that the caller can partially verify,
merge into its DAG of pending Blocks, then recursively call
``StreamAncestorBlockSummaries`` on any Block that didn’t connect with a known
part of the DAG. Ultimately, all paths lead back to the Genesis; so eventually we
should find the connection, or the caller can decide to give up pursuing a
potentially false lead from a malicious actor.

The following diagram illustrates the algorithm. The dots in the graph represent
the Blocks; the ones with a thicker outer ring are the ones passed as
``target_block_hashes``. The dashed rectangles are what’s being returned in a
stream from one invocation to ``StreamAncestorBlockSummaries``.

1. Initially the we only know about the black Blocks, which form our DAG.
2. We are notified about the white Block, which is not yet part of our DAG.
3. We call ``StreamAncestorBlockSummaries`` passing the white Block’s hash as
   target and a ``max_depth`` of 2 (passing some of our known block hashes as
   well).
4. We get a stream of two ``BlockSummary`` records in reverse order from the 1st,
   and we add them to our DAG. But, we can see that the grandparents of the of
   the white Block are still not known to us.
5. We call ``StreamAncestorBlockSummaries`` a 2nd time passing the grandparents’
   hashes as targets.
6. From the 2nd stream we can see that at least one of the Blocks is connected
   to the tip our DAG, but there are again Blocks with missing dependencies.
7. We call ``StreamAncestorBlockSummaries`` a 3rd time and now we can form a full
   connection with the known parts of the DAG, there are no more Blocks with
   missing parents.

.. figure:: /assets/ancestry.png
   :alt: Backwards traversal to sync the DAGs

   Backwards traversal to sync the DAGs

The following algorithm describes the server’s role:

.. code:: c

   algorithm StreamAncestorBlockSummaries is
       input: target block hashes T,
              known block hashes K,
              maximum depth m,
              block summary map B
       output: stream of ancestry DAG in child to parent order

       G <- an empty DAG of block hashes
       Q <- an empty priority queue of (depth, hash) pairs
       A <- an empty list of ancestor block summaries
       V <- an empty set of visited block hashes

       for each hash h in T do
           push (0, h) to Q

       while Q is not empty do
           pop (d, h) from Q
           if h in V then
               continue
           if h is not in B then
               continue
           b <- B(h)
           A <- A + b
           V <- V + h
           for each parent hash p of b do
               G <- G + (h, p)
               if d < m and p not in K do
                   push (d+1, p) to Q

       return stream of A

And the next one depicts syncing DAGs from the client’s perspective:

.. code:: c

   algorithm SyncDAG is
       input: sender node s,
              new block hashes N,
              block summary map B
       output: new block summaries sorted in topological order from parent to child

       G <- an empty DAG of block hashes
       A <- an empty map of block summaries
       m <- a suitable maximum depth, say 100

       function Traverse is
           input: block hashes H
           output: number of summaries traversed
           S <- s.StreamAncestorBlockSummaries(H, m)
           for each block summary b in S do
               if b cannot be validated then
                   return 0
               if b is not connected to H with a path or the path is longer than m then
                   return 0
               if we see an abnormally shallow and wide DAG being built then
                   // the server is trying to feed exponential amount of data
                   // by branching wide while staying within the maximum depth
                   return 0
               h <- the block hash of b
               A(h) <- b
               for each parent p of b do
                   if p is not in B do
                       G <- G + (p, h)
           return sizeof(S)

       Traverse(N)

       define "hashes in G having missing dependencies" as
       hash h having no parent in G and h is not in B

       while there are hashes in G with missing dependencies do
           H <- the hashes in G with missing dependencies
           if Traverse(H) equals 0 then
               break

       if there are hashes in G with missing dependencies then
           return empty because the DAG did not connect
       else
           return A(h) for hashes h in G sorted in topological order from parent to child

``SyncDAG`` needs to have some protection against malicious actors trying to lead
it down the garden path and feeding it infinite streams of data.

Once ``SyncDAG`` indicates that the summaries from the ``sender`` of ``NewBlocks``
have a common ancestry with the DAG we have, we can schedule the download of
data.

.. code:: c

   Q <- an empty queue of blocks to sync
   G <- an empty DAG of block dependencies in lieu of a download queue
   S <- a map of source information we keep about blocks
   GBS <- the global block summary map
   GFB <- the global full block map

   function NewBlocks is
       input: sender node s,
              new block hashes N
       output: flag indicating if the information was new

       H <- find hashes h in N where h is not in GBS
       if H is not empty then
           push (s, H) to Q
           return true
       return false


   parallel threads Synchronizer is
       for each (s, N) message m in Q do
           D <- SyncDAG(s, N, GBS)

           for each block summary b in D do
               r <- if hash of b is in N then true else false
               ScheduleDownload(b, s, r)


   function ScheduleDownload is
       input: block summary b,
              sender node s,
              relay flag r

       h <- the hash of b

       if h is in GBS then
           return

       if h is in S then
          S(h) <- S(h) with extra source s
          if r is true then
              S(h) <- S(h) with relay true
       else
          N <- the list of potential source nodes for b with single element s
          S(h) <- (b, N, r)
          if any parent p of b is in pending downloads G then
             add h as a dependant of p in G
          else
             add h to G without dependencies


   parallel threads Downloader is
       rf <- the relay factor from config, say 5
       rs <- the relay saturation from config, say 0.8

       for each new item added to G or after an idle timeout do
           while we can mark a new hash h in G without dependencies as being downloaded do
               (b, N, r) <- S(h)

               n <- a random node in N
               f <- the full block returned by n.GetBlockChunked(h)

               if f is valid then
                   GFB(h) <- f
                   GBS(h) <- b
                   remove h from G

                   if r is true then
                       K <- the current Kademlia table of peers
                       s <- the current node
                       BlockGossip(NewBlocks(s, h), rf, rs, K)

GetBlockChunked
^^^^^^^^^^^^^^^

Full Blocks containing all the deploys can get big, and the HTTP/2 protocol
underlying gRPC has limits on the maximum message size it can transmit in a
request body. Therefore, we need to break the payload up into smaller chunks,
transfer them as streams, and reconstruct them on the other side.

The caller should keep track of the data it receives and compare them to the
``content_length`` it got initially in the header to make sure it’s not being fed
an infinite stream of data.

In theory the method could return a stream of multiple blocks, but asking for
them one by one from multiple peers as the notifications arrive to the node
about alternative sources, should be favoured over downloading from a single
source anyway.

StreamLatestMessages
^^^^^^^^^^^^^^^^^^^^^^^^^^

When a new node joins the network it should ask one or more of its peers about
the tips of their DAG, i.e. the Blocks on which they themselves would be
proposing new blocks. This can be followed by an arbitrary number of calls to
the ``StreamAncestorBlockSummaries`` until the new node has downloaded and
partially verified the full DAG using the algorithms outlined above. It’s worth
cross-correlating the tips of multiple nodes to avoid being lied to by any
single malicious actor.

The same method can also be utilized for pull-based gossiping by picking a
random peer every now and then and asking for their tips of the DAG. This
compensates for the diminishing returns of trying to reach 100% saturation
by push based gossiping: as we reach full saturation it's becoming
harder to find a node that doesn't have the information yet, so more and more
messages are sent in futility; yet for the small percent of nodes that haven't
been reached yet, it's almost guaranteed that if they ask one of their peers
about their state they are going to be talking to someone in the know.



Finally the following sequence diagram demonstrates the life cycle of Block
propagation among nodes. The dashed blocks have been left unconnected for
brevity but they do the same thing as the ones on the left side.

.. figure:: /assets/block-gossiping.png
   :alt: Block Gossiping

   Block Gossiping



Deploy Gossiping
---------------

With certain consensus protocols, nodes can only produce blocks when its their turn to do so.
To make sure that users can send their deploys to any node and see them included in the next
available block on the network, regardless of which validator creates that block, nodes need
to gossip about deploys between each other, independently of blocks.


The principles and mechanisms of deploy gossiping are exactly the same as the block gossiping
depicted above. 

A block may contain one or more deploys that a node already has, so when downloading a block 
only the deploy hashes and their execution results are included and the deploy body and header
are excluded. A downloading node derives which deploys it is missing via the deploy hashes
and downloads them separately.


NewDeploys
^^^^^^^^^^

When a node receives a deploy from the user, or when it downloads it as part of gossiping, it should,
with the same algorithm as we use for blocks, inform some of its peers that it has this particular
deploys available for download. The semantics are exactly the same as for `NewBlocks`.

StreamDeploysChunked
^^^^^^^^^^^^^^^^^^^^

Nodes use this method to retrieve one or more deploys from each other. Typically one deploy is streamed
when deploy gossiping, but when a node determines it is missing one or more deploy bodies in a received
block (derived from the deploy hashes in the block) it will request all of the deploys it is missing.

The semantics are very similar to `GetBlockChunked` but instead of containing a single item,
the stream alternates between header chunks and contents, with each group corresponding to
one deploy hash in the request.
