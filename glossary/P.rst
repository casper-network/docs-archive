P
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Partial synchrony
^^^^^^^^^^^^^^^^^
Partial synchrony is used to define the fault tolerance of a consensus protocol, which is a time-bound mechanism to note suspicions or problems (failure, crashes, etc.).
When a protocol is provably live under partial synchrony, it means that the nodes will make a decision within a fixed time period. Once the decision is made and a block is committed, it cannot be reverted. Also see `Correct-by-construction <C.html#correct-by-construction>`_.

Participate in consensus
^^^^^^^^^^^^^^^^^^^^^^^^
The process of following the `consensus <C.html#consensus>`_ algorithm. The primary participants are `validators <V.html#validator>`_, bonded with their stake and part of the validator set for that particular era. `Delegators <D.html#delegator>`_ participate indirectly by delegating their tokens to one or more of these validators and contributing by increasing the total stake that ensures the security of the network.

Payment code
^^^^^^^^^^^^
The *payment code* is the `WASM <W.html#webassembly>`_ program that pays the transaction execution fee. 

Peer node
^^^^^^^^^
A node on a peer-to-peer (P2P) network.

Permissionless
^^^^^^^^^^^^^^
A permissionless blockchain network has its consensus and transaction validation process open and available for anyone to participate. Being permissionless is an essential characteristic of most public blockchains, enabling decentralization, transparency, and value exchange between participants. 

Primary token
^^^^^^^^^^^^^
See `CSPR <C.html#cspr>`_.

Private key
^^^^^^^^^^^
See `secret key <S.html#secret-key>`_.

Proof-of-Stake
^^^^^^^^^^^^^^
Proof-of-Stake (PoS) is a mechanism by which a cryptocurrency blockchain network achieves permissionless-ness. The voting power in consensus is proportional to the number of staked tokens (digital currency specific to this system). The validator vouches with their tokens for the correct operation of their node. A popular choice in such systems is to periodically (once per era, in our case) delegate a fixed size committee of participants, which then is responsible for running the consensus on which blocks to add to the blockchain.

Proof-of-Work
^^^^^^^^^^^^^
A mechanism used in Bitcoin and Etherium for incentivizing participation and securing the system. In these protocols, a participant's voting power is proportional to the amount of computational power possessed.

Proof-of-Stake contract
^^^^^^^^^^^^^^^^^^^^^^^
The Proof-of-Stake (PoS) contract holds on to transaction fees for the time while the state transition is happening (contracts are being executed). The PoS contract remits the transaction fees to the block proposer.

Proto block
^^^^^^^^^^^
The block proposed by the leader, which the consensus processes (in `highway <H.html#highway>`_). Only after consensus is complete, the proto block is executed, and the global state is updated.

A leader is selected from the validator set of that era for each round. The chance of getting selected as a leader is in proportion to the stake one has in that era.