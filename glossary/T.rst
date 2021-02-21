T
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Transaction
^^^^^^^^^^^
An atomic piece of computation initiated by a user and executed against the `blockchain <B.html#blockchain>`_ (where the **blockchain** is considered a "decentralized virtual computer" in this context). Each **block** contains a collection of **transactions** (collectively executed against the **global state** as part of this **block processing**).

The following types of transactions are supported:

#. invoke a **smart contract**
#. create (= store on the blockchain) a new **smart contract**
#. move tokens between accounts
#. claim block creation reward
#. increase /decrease **bonding** amount for a calling **validator**
#. execute slashing of a **validator**

Technically, cases 3 and above are all sub-cases of (1), where the invoked smart contract is a "blessed".

A single transaction includes the following information:

*  **Account** – [mandatory] the account the user will "login" to
*  **Payment code** – [mandatory] the "short-leash" code (=WASM program) which will pay the execution fee
*  **Session code** – [mandatory] the code (= WASM program) which the user wishes to execute against the blockchain
*  **Gas price** – [mandatory] price of gas unit (expressed as number of tokens per single gas unit)
*  **Nonce** – [mandatory] the number which prevents replay attacks by making each signature valid for a single execution only
*  **TTL** - [optional] upper limit for P-time of a block this transaction may be included in
*  **Block hook** - [optional] semantic dependency of this transaction, expressed as a hash of a block that is 
*  **Signature** – [mandatory] must be over (payment code, session code, conversion rate, nonce) to ensure a valid execution can only do the operations the user wants done.
