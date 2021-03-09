G
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Gas
^^^
Gas is the virtual currency for calculating the cost of transaction execution. The transaction cost is expressed as a given amount of gas consumed and can be seen intuitively as some cycles of the virtual processor that has to be used to run the computation defined as the transaction's code.

Genesis
^^^^^^^
The state of the virtual machine at the beginning of the blockchain.

Global state
^^^^^^^^^^^^
When thinking of a `blockchain <B.html#blockchain>`_ as a decentralized computer, the global state is its memory state.

When thinking of a `blockchain <B.html#blockchain>`_ as a shared database, the global state is the snapshot of the database's data. 

Technically, a `global state <G.html#global-state>`_ is a (possibly extensive) collection of key-value pairs, where the keys are references (Refs), and the values are large binary objects (BLOBs).

For every `block <B.html#block>`_ B in the `blockchain <B.html#blockchain>`_, one can compute the `global state <G.html#global-state>`_ achieved by executing all `transactions <T.html#transaction>`_ in this block and its ancestors. The `root hash <R.html#root-hash>`_ identifying this state is stored in every executed block.
