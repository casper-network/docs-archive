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
The Highway protocol execution is split into eras, and at the start of each era, every validator is initialized. Validators are forced to store the whole DAG, even the units that were created at the very beginning of the protocol execution. To address the large storage challenge, the protocol execution is divided into eras. In each era, 1000 new blocks are added to the blockchain, and importantly a new instance of Highway is run in every era. The validators only need to store blocks that were finalized in the previous eras and the DAG for the current era. One additional benefit of using eras is that it allows to change the validator set according to some prespecified rules and hence move the protocol towards the permissionless model.

External client
^^^^^^^^^^^^^^^
Any hardware/software connecting to a Node for the purpose of sending deploys or querying the state of the blockchain.

Eviction
^^^^^^^^
Validators that fail to participate in `era <E.html#era>`_ will have their bid deactivated by the protocol, suspending their participation until they signal readiness to resume participation by invoking a method in the `auction contract <A.html#auction-contract>`_.