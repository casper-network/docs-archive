A
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

AssemblyScript
^^^^^^^^^^^^^^
Is a TypeScript-based programming language (essentially JavaScript with static types) that is optimized for WebAssembly and compiled to WebAssembly using asc, the reference AssemblyScript compiler. It is developed by the AssemblyScript Project and the AssemblyScript community.

Auction
^^^^^^^
The auction determines the composition of the validator set for each era of the protocol. It is a "first-price" auction (where winning bids become stakes) with a fixed number of spots, chosen to balance security with performance. Because rewards are proportional to the stake, it is expected that this competitive mechanism will provide a powerful impetus for staking as many tokens as possible.

Auction contract
^^^^^^^^^^^^^^^^
The auction contract acts as a front-end user interface to the `auction <auction>`_ by accepting bids from validators and delegators directly. It also contains the logic necessary for carrying out the auction.

Auction delay
^^^^^^^^^^^^
The number of full eras that pass between the `booking block <B.html#booking-block>`_ and the era whose validator set it defines. The auction delay is configurable and can be several eras long.