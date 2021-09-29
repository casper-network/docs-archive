S
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Safe
^^^^
When a protocol is provably safe, it means that all the participating nodes will make the same decision and continue to produce blocks at some interval. Also, see `Correct-by-construction <C.html#correct-by-construction>`_.

Secret key
^^^^^^^^^^
A cryptographic and confidential key that signs transactions to ensure their correct execution (carrying out only the user's intended operations).

Seigniorage
^^^^^^^^^^^
The reward mechanism by which validators are rewarded for participating in consensus. New tokens are minted and given to validators.

Session code
^^^^^^^^^^^^
The *session code* is a field contained in a deployment directive. The *session code* contains the code the user wishes to execute against the blockchain.  When the session code executes, it performs a transaction. 

Slashing
^^^^^^^^
In Proof-of-Stake, the deposit acts as collateral. The validator guarantees that it correctly follows the protocol. If the validator node violates the protocol, the deposited amount gets *slashed*, i.e., a part of it is removed.

Smart contract
^^^^^^^^^^^^^^
Smart contracts are self-executing computer programs that perform specific actions based on pre-programmed terms stored on the blockchain. Once the pre-programmed terms are met, the smart contract executes the action and eliminates the need for a centralized third party.

On the Casper Network, a smart contract is a WebAssembly (WASM) program that the network stores as a value in the `global state <G.html#global-state>`_. The execution of a smart contract causes changes to the global state.

A smart contract can be invoked by a transaction or by another smart contract. Smart contracts can declare input data as the arguments of a function. When invoking a smart contract, one must provide the input values.

Smart-contract platform
^^^^^^^^^^^^^^^^^^^^^^^
A smart contract platform provides the required blockchain environment for the creation, deployment, and execution of smart contracts.

Staker
^^^^^^
A person that deposits tokens in the `proof-of-stake <P.html#proof-of-stake>`_ contract. A staker is either a `validator <V.html#validator>`_ or a `delegator <D.html#delegator>`_. Stakers take on the slashing risk in exchange for rewards. Stakers will deposit their `tokens <T.html#token>`_ by sending a bonding request in the form of a transaction (deployment) to the system. If a validator is `slashed <#slashing>`_, the staker will lose their tokens.

Staking
^^^^^^^
A feature of Proof-of-Stake protocols that allows token holders to actively participate in the protocol, thus securing the network. The `Staking Guide <https://docs.casperlabs.io/en/latest/staking/index.html>`_ highlights the steps required to stake the CSPR token on the Casper network.