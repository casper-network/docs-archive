E
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Ecosystem
^^^^^^^^^
The ecosystem layer in Casper encompasses dApp design and operation.

Era
^^^
A period of time during which the validator set does not change.

In the Casper Network, validators cannot join and leave at any point in time, but only at era boundaries. An era's validators are determined using an `auction <A.html#auction>`_. At the beginning of the era, the validators create a new instance of the Highway protocol and run this consensus protocol until they finalize the era's last block (see `booking block <B.html#id3>`_).

Eviction
^^^^^^^^
Validators that fail to participate in `era <E.html#era>`_ will have their bid deactivated by the protocol, suspending their participation until they signal readiness to resume participation by invoking a method in the `auction contract <A.html#auction-contract>`_.

External client
^^^^^^^^^^^^^^^
Any hardware/software connecting to a Node for the purpose of sending deploys or querying the state of the blockchain.
