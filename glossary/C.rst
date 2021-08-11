C
===

============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 
`A <A.html>`_  `B <B.html>`_  `C <C.html>`_  `D <D.html>`_  `E <E.html>`_  `F <F.html>`_  `G <G.html>`_  `H <H.html>`_  `I <I.html>`_  `J <J.html>`_  `K <K.html>`_  `L <L.html>`_  `M <M.html>`_  `N <N.html>`_  `O <O.html>`_  `P <P.html>`_  `Q <Q.html>`_  `R <R.html>`_  `S <S.html>`_  `T <T.html>`_  `U <U.html>`_  `V <V.html>`_  `W <W.html>`_  `X <X.html>`_  `Y <Y.html>`_  `Z <Z.html>`_  
============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== ============== 

Cargo
^^^^^
Cargo is Rust’s build system and package manager. This tool manages Rust projects, such as building code and downloading dependencies.

Casper network
^^^^^^^^^^^^^^
The Casper network is a Proof-of-Stake blockchain that allows validators to stake the Casper native token CSPR on the network. Validators receive CSPR as an incentive for continuing to maintain and secure the network. CSPR rewards are distributed as blocks are validated into existence and organized into eras.

CBC
^^^
Correct by construction. CBC Casper is a family of consensus algorithms developed by Vlad Zamfir.

Chainspec
^^^^^^^^^
A collection of configuration settings describing the state of the system at genesis and upgrades to basic system functionality (including system contracts and gas costs) occurring after `genesis <G.html#genesis>`_.

Consensus
^^^^^^^^^
An algorithm used to mandate agreement on the `blockchain <B.html#blockchain>`_ between all nodes. The blockchain, although being built in a decentralized way, eventually converges so that all nodes eventually agree on whether a given block is part of the chain or not.

Casper uses the `Highway <https://docs.casperlabs.io/en/latest/theory/highway.html>`_ algorithm in the *CBC Casper* family of consensus algorithms. The algorithm for securing an agreement is what is known as *consensus*. The consensus layer contains the algorithm, but the algorithm should not be confused with the consensus layer.

Contract runtime
^^^^^^^^^^^^^^^^
Enables developers to use a seamless workflow for authoring and testing their `smart contracts <S.html#smart-contract>`_. This environment can also be used for continuous integration, enabling Rust smart contracts to be managed using development best practices.

Crate
^^^^^
A compilation unit in Rust. A crate can be compiled into a binary or into a library. By default, *rustc*, the compiler for the Rust programming language, will produce a binary from a crate.

CSPR
^^^^
CSPR is the Casper token pre-defined on the Casper network and used to pay for transaction execution and for `staking <S.html#staking>`_ (securing the network). The total number of CSPR tokens is 10 billion.
