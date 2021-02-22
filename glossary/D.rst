D
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

dApp
^^^^
A distributed application (dApp) is a set of `smart contracts <S.html#smart_contract>`_.

Deploy
^^^^^^
An **external client to node** message that includes two transactions:

#. **payment transaction** - executed to buy gas for the execution of main **transaction**
#. **main transaction** - the actual piece of software that does the actual processing changing the global state

The **external client** sends a deploy hoping that the network will execute the main transaction against the blockchain.

Devnet
^^^^^^
A version of the network that can be used for development. Users can run nodes and connect to a public bootstrap node, validators/node operators can spin up nodes, and developers can deploy and execute smart contracts.

Directed acyclic graph
^^^^^^^^^^^^^^^^^^^^^^
A directed acyclic graph is a directed graph that has no cycles. A vertex *v* of a directed graph is said to be reachable from another vertex *u* when there exists a path that starts at *u* and ends at *v*. 

In the Highway protocol, validators exchange messages in order to reach consensus on proposed blocks and hence validate one of many branches of the produced blockchain. As a way of capturing and spreading the different validators’ knowledge about the already existing messages, it adopts the DAG framework, in which every message broadcast by a validator refers to a certain set of messages sent by validators before. 