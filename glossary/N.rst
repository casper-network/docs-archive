N
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Node
^^^^^
A server (= running program) participating in the blockchain P2P network and serving **external clients**. It is constructed of several software components or "layers": Client, COMM, Consensus, Execution Engine, and Storage. 

#. gRPC Client - gRPC interfaces to various node functions, including accepting deploys, creating+proposing **blocks** (not exposed publicly), and querying the **BlockDAG**
#. COMM - contains the logic for message passing between **nodes** on the network (via TCP) as well as discovering new peers (via Kademlia)
#. Consensus - contains the logic to update the **blockstore** so that agreement is maintained between **nodes**. It also contains logic to detect when **deploys** commute (this enables the use of parallelism in **block** creation and in consensus itself via the **BlockDAG**)
#. Execution Engine - this is where the actual **transaction** execution happens in a WASM interpreter. It contains the logic to record updates to the **global state** that **transactions** will do, as well as to apply those updates under the direction of consensus
#. Storage - this is where the **blockstore** and the **global states** are stored.

You will encounter different types of nodes on the network:

* **Bootstrap node**: a peer node on the P2P network that contains the logic for message passing between nodes on the network (via TCP) and discovering new peers so that they may join the network.
* **Stand-alone node**: a mode for starting the node in which it does not attempt to connect to another node that is already part of a P2P network (called the bootstrap node). This mode is useful for local testing.
* **Read-only node**: a type of node on the network that receives and processes blocks but does not create blocks and is not a validator. It is otherwise a fully functioning node, following the consensus protocol to know the current status of the blockDAG (and therefore also the VM state). Such nodes are useful for querying the status of the blockDAG (e.g., to learn information about transaction finalization). 

Node bootstrap
^^^^^^^^^^^^^^
In `node <N.html#node>`_ COMM - contains the logic for message passing between nodes on the network (via TCP) as well as discovering new peers (via Kademlia).