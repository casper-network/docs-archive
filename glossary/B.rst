B
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Block
^^^^^
Used in two contexts:

#. A data structure containing a collection of transactions; Blocks form the BlockDAG and, as such, are a primary structure of the blockchain.
#. A message that is exchanged between nodes containing the data structure as explained in (1).

Each block has a globally unique ID, achieved by hashing the contents of the block.

Each block points to his parents (one or many) and justification blocks (one or many). Parents are a subset of justifications. An exception is the Genesis block, which has no parents and no justifications.

Blockchain
^^^^^^^^^^^
Blockchain is a P2P network where the collection of nodes (`validators <V.html#validator>`_) concurrently updates a decentralized, shared database. They do this collectively, building an ever-growing chain of `transactions <T.html#transaction>`_. For performance reasons, transactions are bundled in `blocks <#block>`_. According to a particular cooperation protocol (consensus protocol), the collection of `nodes <N.html#node>`_ connected via a P2P network cooperate to maintain this shared database as a single source of truth. The database's current state is called the `global state <G.html#global-state>`_ and has a sizeable map-like collection.

BlockDAG
^^^^^^^^
A directed acyclic graph, where the vertices are the blocks. There are two types of graphs:

* **P-Graph**: given an edge AB, where A and B are the vertices, block B mentions A in its list of parent blocks.
* **J-Graph**: given an edge AB, where A and B are the vertices, block B mentions A in its list of justifications blocks.

A P-Graph is a subgraph of a J-Graph because the list of justifications must include the parent node.

Collectively, the collection of all blocks is called a BlockDAG. Every node keeps a "local" view of the BlockDAG, attempting to capture and include all the updates across the nodes' P2P network. In other words, a node continually tries to catch up with the evolution of the BlockDAG, which is happening when the validators attempt to create new blocks.

Blockstore
^^^^^^^^^^
The layer of the node software responsible for storing blocks. This layer is persisted and can be used to allow a node to recover its state after a crash.

Block creation
^^^^^^^^^^^^^^
Block creation is the process of computing the deployment results (not contained in a block known by the node) and collecting the results that belong together into a block. The order in which deployments are applied to the global state does not change the outcome.
Block creation is always followed by "block proposal" (see below) because it does not make sense to create a block without sending it out to the network. Note that only validators can create valid blocks.

Block finality
^^^^^^^^^^^^^^
Block finality in the `Highway <H.html#highway>`_ protocol is expressed by a fraction of nodes that would need to break the protocol rules in order for a block to be reverted. During periods of honest participation finality of blocks might reach well beyond 1/3 (as what would be the maximum for classical protocols), up to even 1 (where 1 is complete certainty).

Block gossiping
^^^^^^^^^^^^^^^
Block gossiping occurs when a message containing a block is sent to one or more nodes on the network. In other words, block gossiping is sending a block validated by the current node but created by another node. The terms *block gossiping* and <#block-passing> are interchangeable.

Block passing
^^^^^^^^^^^^^
See <#block-gossiping>.

Block processing
^^^^^^^^^^^^^^^^
Running the deploys in a block received from another node in order to determine the updates made to the global state. Note that this is an essential part of `block validating <B.html#block-validating>`_

Block proposal
^^^^^^^^^^^^^^
Sending a (newly) created block to the other nodes on the network for potential inclusion in the DAG. Note that this term applies to NEW blocks only. 

Block time
^^^^^^^^^^
For a block B this is an integer number calculated as a total amount of gas used for executing all transactions that precede block B. Because we have two notions of *precede*, there are two notions of block time:

* **J-time**: sum of gas burned in J-past-cone of B (excluding transactions in B)
* **P-time**: sum of gas burned in P-past-cone of B (excluding transactions in B)

Block validation
^^^^^^^^^^^^^^^^
The process of determining the validity of a block obtained from another node on the network. This involves checking all validity conditions, including (but not limited to):

* All required fields are present
* Signature is valid
* Signature is from a bonded participant
* Choice of parent block(s) follow from justifications (fork-choice correctness)
* Deploys' update to VM state is as reported by the block (see "block processing")
* Bonds map matches the PoS contract state

Bond
^^^^
The amount of money (in crypto-currency) that is allocated by a node in order to participate in `consensus <C.html#consensus>`_ (and to be a `validator <V.html#validator>`_).

Bonding
^^^^^^^
Depositing money in the `auction <A.html#auction>`_ contract and try to become a `staker <S.html#staker>`_. The bonding request is a transaction that transfers tokens to the auction contract. In the next `booking block <B.html#booking-block>`_, a new set of validators is determined, with weights according to their deposits. This new set becomes active in the era(s) using that booking block.

Booking block
^^^^^^^^^^^^^
The first block that is less than 11 days way from the beginning of an era. It defines the new era's validator set, weights, but not yet the leader schedule. Each block between the booking block and the key block contains one random bit that contributes to the seed used for the pseudorandom leader schedule.
