V
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Validator
^^^^^^^^^
Validators are responsible for maintaining platform security by building an ever-growing chain of finalized blocks, backing this chain's security with their stakes. Their importance (often referred to as "weight") both to protocol operation and security is, in fact, equal to their stake, which includes both their own and delegated tokens.

The responsibilities of a validator include:

* `block creation <B.html#block-creation>`_ and `block proposal <B.html#block-proposal>`_
* `block validation <B.html#block-validation>`_
* `block gossiping <B.html#block-gossiping>`_

Validators are bonded because they are responsible for progressing the system's state as clients use it (e.g., sending deploys). Validators and `stakers <S.html#staker>`_ can lose their bond (be slashed) for not following the protocol correctly. Validators are also paid for by creating blocks (also by validating blocks – though this is only indirectly; validators cannot be paid for if they do not validate by design), giving them more incentive to serve the network correctly.
