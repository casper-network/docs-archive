# Motivation

## Background

The last 10 years we have witnessed a fast paced evolution of distributed consensus systems. With release of the first Bitcoin whitepaper by Nakamoto in 2008, the first Byzantine Fault Tolerant distributed ledger saw the light of day. Since then, this concept has been iterated upon by many derivative and alternative projects. The most notable innovation was accomplished with the launch of Ethereum in 2013, with its stated goal launching an unstoppable, turing-complete global computer, rather than a distributed transaction ledger. It's aim was to maintain an immutable, unstoppable global state through BFT consensus. Similar to Bitcoin, it adopted a Proof-of-Work consensus model and launched its Ethereum Virtual Machine, allowing developers to launch "distributed Apps" \(dApps\), or software applications that run on numerous machines distributed globally, and not controlled by any centralized entity.   
While rightfully credited for heralding in the age of the dApp, certain shortcoming have been universally recognized:

* Consensus Method: Ethereum has adopted Proof-of-Work as its consensus method, which is wasteful both from an energy consumption perspective, as well as from a computational efficiency perspective \(rather than leveraging the majority of the computational power in the global network for running dApps, it is used to solve PoW related math problems\). 
* Throughput: The Ethereum network can effectively process between 10-20 events per second. This is not sufficient to support global decentralized computation needs.
* Serial Computation: The Ethereum Virtual Machine is single threaded, meaning it runs one process at the time, in sequence. New processes have to line up in queue before being run.
* One Size Fits All: regardless of the use case, geography and other economical considerations, the network fees to execute a transaction or to run a dApp follow globally uniform pricing across the network. All other aspects of the network are globally uniform too for all dApps that run on the network, without regard for their underlying needs.

Many projects have tried to address one or several of these shortcoming in recent years. Within the Ethereum community itself, multiple proposals exist to retrofit solutions onto the network to address some of the above. In the context of Ethereum, replacing fundemental components of the network 5+ years into its existence appears to be akin to replacing an engine on an airplane mid-flight. Technically the risks are extremely large, while economically the changes appear at least equally prohibitive. 

## Compromises

Many alternative projects have proposed solutions to these shortcomings, but usually not without making compromises in other areas, resulting in new shortcomings. For example, several projects have proposed methods to increase Throughput, but usually these proposals involved sacrificing the decentralized nature of the network to some degree. 







