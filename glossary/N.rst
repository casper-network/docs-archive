N
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Node
^^^^^

A Casper node is a physical or virtual device that is participating in the Casper network. They store, validate, and preserve the blockchain data.

Nodes are constructed of several software components or layers: Client, COMM, Consensus, Execution Engine, and Storage. 

#. gRPC Client - gRPC interfaces to various node functions, including accepting deploys, creating+proposing `blocks <B.html#block>`_ (not exposed publicly), and querying the `blockDAG <B.html#blockdag>`_
#. COMM - contains the logic for message passing between nodes on the network (via TCP)
#. Consensus - contains the logic to update the `blockstore <B.html#blockstore>`_ and `global state <G.html#global state>`_ so that agreement is maintained between nodes.
#. Execution Engine - this is where the actual `transaction <T.html#transaction>`_ execution happens in a WASM interpreter. It contains the logic to record updates to the global state that transactions will do, as well as to apply those updates under the direction of consensus.
#. Storage - this is where the blockstore and the global state are stored.

You will encounter different types of nodes on the network:

* **Bonded node**: any node that can be trusted on the network.
* **Unbonded node**: a type of node on the network that receives and processes blocks but does not create blocks and is not a validator. It is otherwise a fully functioning node, following the consensus protocol to know the current status of the blockDAG (and therefore also the VM state). Such nodes are useful for querying the status of the blockDAG (e.g., to learn information about transaction finalization).

Node operator
^^^^^^^^^^^^^
Anyone who wishes to run node infrastructure on the Casper network either as a standalone private network, or as part of the public network. Synonymous to a `validator <V.html#validator>`_.

Nonce
^^^^^
The number which prevents replay attacks by making each signature valid for a single execution.
