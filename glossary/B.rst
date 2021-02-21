B
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Block
^^^^^^^^^^^
Used in two contexts:

#. A data structure containing a collection of transactions; Blocks form the BlockDAG and as such are a primary structure of the blockchain.
#. A message exchanged between nodes, containing the data structure as explained in (1).

Each block has a globally unique ID, achieved by hashing the contents of the block.

Each block points to his parents (one or many) and justification blocks (one or many). Parents are a subset of justifications. An exception is the Genesis block, which has no parents and no justifications.

Blockchain
^^^^^^^^^^^
Blockchain is a P2P network where the collection of nodes (**validators**) concurrently update a decentralized, shared database. They do this collectively, building an ever-growing chain of **transactions**. For performance reasons, transactions are bundled in **blocks**. According to a particular cooperation protocol (consensus protocol), the collection of `nodes <N.html#node>`_ connected via a P2P network cooperate to maintain this shared database as a single source of truth. The database's current state is called the **global state** and has a sizeable map-like collection.

Block time
^^^^^^^^^^^
For a block B this is an integer number calculated as a total amount of gas used for executing all transactions that precede block B. Because we have two notions of "precede", there are two notions of block time:

* J-time: sum of gas burned in J-past-cone of B (excluding transactions in B)
* P-time: sum of gas burned in P-past-cone of B (excluding transactions in B)
