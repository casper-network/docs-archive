B
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Block
^^^^^
Used in two contexts:

#. A data structure containing a collection of transactions. Blocks form the primary structure of the blockchain.
#. A message that is exchanged between nodes containing the data structure as explained in (1).

Each block has a globally unique ID, achieved by hashing the contents of the block.

Each block points to its parent. An exception is the first block, which has no parent.

Block creation
^^^^^^^^^^^^^^
Block creation means computing the deployment results and collecting the results that belong together into a block. We follow a process called *execution after consensus*. 

The `block proposal <B.html#block-proposal>`_ happens first, and the proposed `proto block <P.html#proto-block>`_ contains a set of deploys that have not been executed yet.

Only after consensus on a *proto block* has been reached, the deploys are executed. The resulting new global state `root hash <R.html#root hash>`_ is put into an actual block, together with the executed deploys.

Note that only validators can create valid blocks.

Block finality
^^^^^^^^^^^^^^
A block is "finalized" if the validators agree on adding it to the blockchain.

There are different levels of *finality* in the `Highway <H.html#highway>`_ protocol. A finalized block has a fault-tolerance *F*, expressed as a fraction of the total stake. For an observer to see a conflicting block as finalized, several validators whose total stake exceeds *F* would have to collude and show different information in a way that would ultimately be detected and punished (see `slashing <S.html#slashing>`_).

Block gossiping
^^^^^^^^^^^^^^^
Block gossiping occurs when a message containing a block is sent to one or more nodes on the network. In other words, block gossiping is sending a block validated by the current node but created by another node. The terms *block gossiping* and <#block-passing> are interchangeable.

Block passing
^^^^^^^^^^^^^
See <#block-gossiping>.

Block processing
^^^^^^^^^^^^^^^^
Block processing consists of running the deploys in a block received from another node to determine updates to the global state. Note that this is an essential part of `block validating <B.html#block-validating>`_.

Block proposal
^^^^^^^^^^^^^^
Sending a (newly) created block to the other nodes on the network for potential inclusion in the blockchain. Note that this term applies to NEW blocks only.

Block validation
^^^^^^^^^^^^^^^^
The process of determining the validity of a block obtained from another node on the network.

Blockchain
^^^^^^^^^^^
Blockchain is a P2P network where the collection of nodes (`validators <V.html#validator>`_) concurrently updates a decentralized, shared database. They do this collectively, building an ever-growing chain of `transactions <T.html#transaction>`_. For performance reasons, transactions are bundled in `blocks <#block>`_. According to a particular cooperation protocol (consensus protocol), the collection of `nodes <N.html#node>`_ connected via a P2P network cooperate to maintain this shared database as a single source of truth. The database's current state is called the `global state <G.html#global-state>`_ and has a sizeable map-like collection.

Block store
^^^^^^^^^^^
The layer of the node software responsible for storing blocks. This layer is persisted and can be used to allow a node to recover its state after a crash.

Bond
^^^^
The amount of money (in crypto-currency) that is allocated by a node in order to participate in `consensus <C.html#consensus>`_ (and to be a `validator <V.html#validator>`_).

Bonding
^^^^^^^
Depositing money in the `auction contract<A.html#auction-contract>`_ and try to become a `staker <S.html#staker>`_. The bonding request is a transaction that transfers tokens to the auction contract. In the next `booking block <B.html#booking-block>`_, a new set of validators is determined, with weights according to their deposits. This new set becomes active in the era(s) using that booking block.

Booking block
^^^^^^^^^^^^^
The booking block for an era is the block that determines the era's validator set. In it, the `auction contract<A.html#auction-contract>`_ selects the highest bidders to be the future era's validators. There is a configurable delay, the *auction_delay*, which is the number of eras between the booking block and the era to which it applies. The booking block is always a switch block, so the booking block for era *N + auction_delay + 1* is the last block of era *N*.

