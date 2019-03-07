# Persistent Storage Model

## Blocks

As stated earlier, which deploys to execute, and the persistent results of that execution, are agreed upon by consensus between distributed nodes. This process takes time. Incurring this overhead on each individual deploy would significantly reduce the rate of forward progress of the decentralized computer. In order to amortize consensus latency over multiple deploys and thereby increase the number of deploys executed per unit time, multiple deploys are packaged into a "block". A block must contain at least one deploy and has a maximum size in bytes.

Blocks are the atomic unit of consensus between nodes - the atomic increment of forward progress of the decentralized computer. Either all deploys contained in a block are executed or none are. The deploys in a block can be executed concurrently \(in no guaranteed order\) or serially \(in the order in which they appear in the block\) as specified by a field in each block.

dApps have no control over how or when their deploys are allocated to blocks or the execution semantics of the blocks in which their deploys appear. dApps can only control contract execution order within a deploy, not across deploys. If a dApp requires a particular contract execution order, all such dependent contracts must be executed within the same deploy by being called in the appropriate order from the session contract. Because of the account nonce described earlier, each deploy will be executed only once by the decentralized computer even if submitted to multiple nodes. In general blocks will contain deploys from different dApps.

## Commutativity

For blocks which specify concurrent execution semantics, certain variable access patterns will lead to non-deterministic behavior when they originate from different deploys. Non-determinism occurs when multiple deploys write to the same persistent variable, or when only one deploy writes to a persistent variable and that same variable is read by one or more other deploys. Deploys have serial execution semantics therefore multiple writes, or mixtures of reads and writes, to the same persistent variable from within the same deploy are deterministic.

When selecting deploys for inclusion in the same concurrent block node software checks to ensure these access patterns do not occur. If necessary the set of deploys in a prospective block will be pared to the maximal set which does not exhibit these patterns. Detection of these patterns is based on urefs, not human-readable names.

Examples of when these patterns may occur are with instances of the same contract appearing in multiple deploys \(accessing the same contract persistent variable\) or with multiple deploys from the same account \(where their payment or session contracts access the same account persistent variable\). This is not an exhaustive list - among other things, it does not cover access patterns arising from the sharing of state between contracts using human-readable names.

There is one case where multiple reads and writes to the same variable from different contracts is deterministic: operations that exhibit the commutative property. An example of such an operation is integer addition: the end result of performing multiple adds on the same integer variable is independent of the order in which those adds are performed.

The general rule for combining deploys in the same concurrent block is that all deploys must "commute". To meet this requirement, all operations performed on a variable must be mutually commutative - if any single operation is non-commutative then the requirement is not met. Currently the only commutative operation supported by the system library for accessing persistent variables is the add\(\) function which only accepts integers and maps.

## The Structure of Persistent Storage

Blocks are the atomic increment of forward progress for the decentralized computer. Each increment is executed relative to some past increment and this dependency is captured by linking these blocks together, i.e. blocks are linked in an order capturing the execution history of the decentralized computer since boot. Any two linked blocks have a parent-child relationship where the parent \(earlier\) block is the context in which the deploys in the child \(later\) block execute. Blocks are uniquely identified by a hash of their contents and blocks have a field containing the identifier of their parent. dApps do not have control over which blocks are parents of any block containing their deploys.

Hereafter, the phrase "block executes" \(or variants thereof\) will be used as shorthand for "the deploys contained in the block execute" - blocks do not execute, only deploys do.

When the decentralized computer is "booted", the boot node creates a "genesis block" \(discussed in more detail below\). The genesis block is the only block without a parent. As nodes join the network they download the then-current state of persistent storage and may then "propose" blocks to their peers which participate in a consensus algorithm to decide which block will be the next increment of forward progress.

A simplified view of the structure of persistent storage is given in Figure 5. This diagram is a snapshot in time. Arrows between blocks point from child to parent. For clarity only deploys are shown inside blocks. The temporal sequence leading to this diagram was that the decentralized computer was booted and the genesis block created, then the decentralized computer incrementally progressed by executing the deploys in blocks 1, 2, and 3 in that order. Block 1 was executed in the context of persistent storage as it appeared after the execution of the genesis block; block 2 was executed in the context of persistent storage as it appeared after the execution of block 1; etc.

![Figure 5: Simplified Structure of Persistent Storage](fig5simpleStorage.png)

The state of persistent storage after the execution of a block is called the "post-state" of that block. In the figure, block 3 executes in the context of the post-state of block 2. The post-state of a block is not simply the variables written during the execution of that block - it includes all then-currently live variables independent of how far back in time they were last written. Thus when block 3 reads "a" it receives the value written in block 2; when it reads "b" it receives the value written in block 1. The node software's storage subsystem is designed to access variables in post-state in constant time independent of how many blocks in the past they were written.

Because nodes are distributed over a network and are executing concurrently, multiple nodes may concurrently propose different blocks as children of the same parent - thus creating a "fork". Upon seeing this fork, other nodes may concurrently propose blocks on any branch of that fork. Thus, in general, persistent storage is not a linear chain of blocks as depicted in Figure 5 but a directed acyclic graph \(DAG\) of blocks as depicted in Figure 6.

![Figure 6: Structure of Persistent Storage](fig6storage.png)

In the diagram, the DAG grows \(i.e. the decentralized computer executes\) from left-to-right with arrows pointing from child to parent. For clarity only deploys are shown inside blocks. The post-state of each block is shown below the block in blue.

A "leaf" block is a block with no children. Nodes select from the current leaves of the DAG when selecting parents for proposed blocks. When there are multiple parents the context in which the proposed block executes is the merged post-state of all parents. This merged post-state is called the "pre-state" of the proposed block. In the case of a single parent a proposed block's pre-state is simply the parent's post-state. In the diagram, the pre-state for multi-parent blocks is shown in grey. Unlike post-state, multi-parent pre-state does not correspond to a specific block in the DAG.

In order to avoid non-deterministic behavior, the post-state of all prospective parents must commute per the same rules as for deploys contained in the same concurrent block. Any parent whose post-state does not commute is removed from the list of prospective parents.

It may appear that the post-state of Blocks 2 and 3 does not commute since "a" has a value of 5 in one and 6 in another. In order to determine commutativity, it is necessary to consider not only the value of a variable but also the set of operations performed on that variable by any deploys in the associated block. In Figure 6 all variables have either zero or one operation performed on them.

In the case of Blocks 2 and 3, "a" was written in Block 2 and had no operation performed on it in Block 3, i.e. it was neither read nor written. Consider the scenario where all deploys in Blocks 2 and 3 were contained in the same block. In this scenario this access pattern is not a commute violation since only a single write was performed. This is but one of several permutations of variable access patterns and block topologies to consider when establishing commutativity - the complete list will not be discussed here.

The CasperLabs system is designed to give operators control over the execution path of the decentralized computer. Node software is designed with an interface to an external process in which the operator runs a block decision algorithm of their choosing. This decision algorithm decides when to propose blocks, which deploys are contained in those blocks, and the execution semantics of those blocks \(concurrent or serial\). When deploys arrive at a node, a message is sent to the operator's block decision process informing it of the arrival. At a time of its choosing the operator's block decision process sends a message to node software indicating the specifics of block proposal.

We will now revisit the lifecycle of deploys in Figure 7. Upon arrival at a node deploys are stored in a buffer and a message is sent to the operator's block decision process. At some point the block decision process will send a message to the node software indicating when to propose a block and the specific deploys to include in it. Node software will then select a parent block \(to be discussed in more detail below\), execute all deploys in the proposed block on the VM in the context of the parent's post-state \(confirming commutativity if concurrent execution semantics are specified\), and then "propose" that block to its peers as the next increment of forward progress.

![Figure 7: Deploy Lifecycle](fig7deployLifecycle.png)

Note that at any given point in time, each node may perceive a different DAG topology. Because this topology is the context in which nodes make block proposal decisions, situations will arise where some forks of the DAG will be in conflict. As discussed below, one objective of the consensus algorithm is deciding which fork is canonical in the event of conflicting forks.

## Block Format

The simplified format of a block is depicted in Figure 8. Blocks are composed of three sections: header, body, and signature. Most fields should be self-explanatory. The post-state hash is discussed in the next paragraph. The timestamp is the time the creating node sent this block onto the network. The signature field covers the entire block.

Note that blocks do not contain the state of persistent storage. This is for two reasons: \(1\) persistent storage can be very large and passing it around would consume enormous network bandwidth; \(2\) even if persistent storage were included in blocks, nodes receiving a proposed block must execute all deploys in that block to confirm they get the same results as the block's creator. The hash of the post-state is included in the block to be used for this purpose.

The body is an array containing the deploy messages as received by the creator along with the gas cost of executing each deploy. When node software receives a block proposed by another node, it confirms that it calculates the same gas cost for each deploy as the creator.

![Figure 8: Simplified Block Format](fig8simpleBlock.png)
