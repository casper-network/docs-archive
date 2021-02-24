S
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Secret key
^^^^^^^^^^
A cryptographic and confidential key that signs transactions to ensure a valid execution can only do the user's intended operations.

Seigniorage
^^^^^^^^^^^
The reward mechanism by which validators are rewarded for participating in consensus. New tokens are minted and given to validators.

Session code
^^^^^^^^^^^^
The *session code* is a field contained in a deployment directive. The *session code* contains the code the user wishes to execute against the blockchain.  When the session code executes, it performs a transaction. 

Shard
^^^^^
A shard is a subset of the blocks and transactions that have to be processed by only a specific subset of validators.

Slashing
^^^^^^^^
In Proof-of-Stake, the deposit acts as collateral. The validator guarantees that it correctly follows the protocol. If the validator node creates an equivocation or fails to send messages for too long, the deposited amount gets "slashed," i.e., a part of it is removed.

Smart contract
^^^^^^^^^^^^^^
A WebAssembly (WASM) program that the network stores as a value in the global state. The execution of a smart contract causes changes to the global state. A smart contract can be invoked by a transaction or by another smart contract. Smart contracts can declare input data as the arguments of a function. When invoking a smart contract, one must provide the input values. 

Staker
^^^^^^
A person that deposits tokens in the `proof-of-stake <P.html#proof-of-stake>`_ contract. Sometimes a staker is also a `validator <V.html#validator>`_ or a `delegator <D.html#delegator>`_. Stakers take on the slashing risk in exchange for rewards. Stakers will deposit their `tokens <T.html#token>`_ by sending a bonding request in the form of a transaction (deployment) to the system. If a validator is `slashed <#slashing>`_, the staker will lose their tokens.
