D
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

dApp
^^^^
A distributed application (dApp) is a set of `smart contracts <S.html#smart_contract>`_.

Delegation rate
^^^^^^^^^^^^^^^
Node operators (`validators <V.html#validator>`_) define a commission that they take in exchange for providing staking services. This commission is represented as a percentage of the rewards that the node operator retains for their services.

Delegator
^^^^^^^^^
Delegators are users who participate in the platform's security by delegating their tokens to validators (which adds to their weight) and collecting a part of the rewards proportional to their delegations, net of a cut ("delegation rate") that is collected by the validator.

Deploy
^^^^^^
A deployment or deploy, in short, is a message from an external client to a `node <N.html#node>`_. The message contains a smart contract to be stored on the chain, along with the requester's signature(s) and other essential properties for execution:

* A *hash* of the serialized header for this deploy
* A *header* describing the account, blockchain, and deploy properties
* The smart contract to be stored on the blockchain; the execution will change the `global state <G.html#global-state>`_
* A transfer to buy gas for contract execution
* A list containing the requester's signature(s)
* A flag returning true if and only if the deploy hash is correct, the body hash is correct, and all approvals are valid signatures of the deploy hash.

The external client sends a deploy hoping that the network will execute the smart contract against the `blockchain <B.html#blockchain>`_. The implementation details are in `GitHub <https://github.com/CasperLabs/casper-node/blob/master/node/src/types/deploy.rs#L475>`_.
