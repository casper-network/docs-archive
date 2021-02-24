T
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Testnet
^^^^^^^
The feature-complete, decentralized public Casper platform for testing.

Token
^^^^^
A type of cryptocurrency that represents an asset. See `CSPR <C.html#cspr>`_.

Transaction
^^^^^^^^^^^
An atomic piece of computation initiated by a user and executed against the `blockchain <B.html#blockchain>`_ (where the blockchain is considered a "decentralized virtual computer" in this context). Each `block <B.html#block>`_ contains a collection of `transactions <T.html#transaction>`_ (collectively executed against the `global state <G.html#global state>`_ as part of this `block processing <B.html#block-processing>`_).

The following types of transactions are supported:

#. invoke a `smart contract <S.html#smart-contract>`_
#. create (= store on the blockchain) a new smart contract
#. move tokens between accounts
#. claim block creation reward
#. increase /decrease `bonding <B.html#bond>`_ amount for a calling `validator <V.html#validator>`_
#. execute slashing of a validator

Technically, cases 3 and above are all sub-cases of (1), where the invoked smart contract is *verified*.

A single transaction includes the following information:

*  **Account** – [mandatory] the account in which the user will login
*  **Payment code** – [mandatory] the "short-leash" code (=WASM program) which will pay the execution fee
*  **Session code** – [mandatory] the code (= WASM program) which the user wishes to execute against the blockchain
*  **Gas price** – [mandatory] price of the gas unit (expressed as a number of tokens per single gas unit)
*  **Nonce** – [mandatory] the number which prevents replay attacks by making each signature valid for a single execution
*  **TTL** - [optional] upper limit for P-time of a block this transaction may be included in
*  **Block hook** - [optional] semantic dependency of this transaction, expressed as a hash of a block that is 
*  **Signature** – [mandatory] must be done via a private or secret key (over payment code, session code, conversion rate, nonce), to ensure a valid execution can only do the intended operations.

Transaction execution
^^^^^^^^^^^^^^^^^^^^^
Running a transaction in an instance of a WebAssembly (WASM) interpreter.

Trusted node
^^^^^^^^^^^^
A `bonded <B.html#bonding>`_ node that contains the logic for message passing between nodes on the network (via TCP).