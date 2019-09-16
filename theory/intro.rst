Introduction
============

A consensus protocol is at the core of any blockchain technology. It dictates
how a distributed set of trustless nodes comes to a coherent view of the world.

The consensus solution used in CasperLabs blockchain is a latest achievement of
research path that can be traced back to the 1980’s. Important milestones on
this path were:

-  1980: The problem of byzantine consensus defined (Lamport, Shostak)
-  1985: Impossibility of distributed consensus with one faulty process theorem
   (Fischer, Lynch, Paterson)
-  1997: Proof-of-Work invented (Hashcash system)
-  1999: “Practical Byzantine Fault Tolerance” (PBFT) algorithm (Castro, Liskov)
-  2008: Bitcoin invented (Satoshi Nakamoto)
-  2012: First proof-of-stake cryptocurrency system created (Peercoin system)
-  2013: Ethereum invented - cryptocurrency idea generalized to a decentralized
   general-purpose computing platform (Vitalik Buterin)
-  2013: “Greedy Heaviest Observed Subtree” (GHOST) algorithm introduced
   (Sompolinsky, Zohar)
-  2015: Blockchain idea extended to “block DAG” - “Inclusive Block Chain
   Protocols” (Lewenberg, Sompolinsky, Zohar)
-  2017: First draft version of Casper protocol spec published (Ethereum
   research group, Vlad Zamfir)
-  Jul 2018: First implementation of proof-of-stake blockchain built on
   Casper-GHOST-Blockdag combination attempted
-  Dec 2018: CBC Casper protocol 1.0 specification (Ethereum research group,
   Vlad Zamfir)
-  Sep 2019: Leader-based CBC Casper (Daniel Kane, Vlad Zamfir, Andreas Fackler)

The solution we present here is pretty complex. Therefore, we introduce it
step-by-step, starting from the simplest possible model first and then enriching
the model gradually.
