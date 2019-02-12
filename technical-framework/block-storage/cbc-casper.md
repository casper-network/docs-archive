# CBC Casper

## Introduction

Consensus protocol stays in the core of any blockchain technology. It dictates how a distributed set of cooperating nodes comes to a coherent view of the world.

The consensus solution used in Casperlabs blockchain is an effect of a long-running research. Critical milestones of this research can be identified as:

* 1980: Lamport / Shostak - the problem of byzantine consensus defined
* 1985: FLP impossibility theorem
* 1997: Proof-of-work invented (Hashcash)
* 2008: Bitcoin invented by Satoshi Nakamoto
* 2013: Bitcoin idea generalized to a decentralized general-purpose computing platform (Ethereum, Vitalik Buterin)
* 2018: Casper protocol research group released version 1.0 of the specification

The solution we present here is pretty complex. Therefore we introduce it step-by-step, by starting from a simplest possible model first and then enriching the model gradually. This way a sequence of (abstract) models is built, where the understanding developed with every model N is directly utilized in subsequent model N+1.

As our last step we explain how the abstract model actually maps to the real implementation.

## Terms and concepts

We deal with a collection of entities attempting to reach consensus via message passing. These entities are typically referenced in literature as processes, actors, nodes, machines or generals. To be consistent with Casper research tradition, we call them 'validators'.

Technically, validators are going to be computers running a dedicated application, referenced here as "blockchain node", and these validators collectively form a peer-to-peer network, where the message-passing based P2P protocol they use is what we aim to describe here.

Conceptually, validators connected with their P2P consensus protocol form a decentralized computer. This computer has memory (elsewhere in this white paper referenced as "global state") and performs operations (transactions) that change the state of this memory.

We use the following terms:

* **global state** - any snapshot of data stored in the shared database we are executing transactions against
* **transaction** - a program that operates on the global state

We also use the following well-known concepts from mathematics:

* **iff** - shortcut for "if and only if"; frequently used to connect a name of the concept from its definition
* $\mathbf{f \circ g}$ - functions composition: $$f \circ g (x) = f(g(x))$$
* **directed graph** - a structure $$<V,E,source: E \rightarrow V, target: E \rightarrow V >$$, where $$V, E$$ are arbitrary sets; we call elements of $$E$$ - *edges*, and elements of $$V$$ - *vertices*; conceptually we visualize a graph as a collection of dots (vertices) connected by arrows (edges), where functions $$source$$ and $$target$$ are visualized as, respectively, source and target of every arrow
* **path in a directed graph** - any ordered sequence of edges $$<e_1, ..., e_n \in E^n>$$, such that $$source(e_{i+1})=target(e_i)$$
* **cycle in a directed graph** - path $$<e_1, ..., e_n \in E^n>$$, where $$source(e_1)=target(e_n)$$
* **directed acyclic graph** (or just **DAG**) - directed graph which does not contain cycles
* **simple DAG** - a DAG where any pair of vertices is directly connected by at most one edge
* **POSET** - partially ordered set; this is a pair $$<A, R>$$, where $$A$$ is a set, $$R$$ is a relation on $$A$$ which is reflexive, antisymmetric and transitive
* **transitive closure of a relation** - for a relation $$R \subset A \times A$$, a smallest transitive relation $$T \subset A \times A$$ such that $$R \subset A$$
* **transitive reduction of a relation** - for a relation $$R \subset A \times A$$, a smallest relation $$T \subset A \times A$$ such that $$TransitiveClosure(T) ⊂ R$$

Simple directed graphs and 2-argument relations are if fact two languages for talking about the same thing. Every simple DAG can be seen as a POSET (by applying transitive closure). Every POSET can be seen as a simple DAG (by applying transitive reduction).

## Communication layer assumptions

We assume that P2P protocol using for validator-to-validator communication is based on best-effort-broadcasting. So, any time a validator $$v$$ has a new message M to announce, it is announcing the message to all validators in the network. We assume that, once broadcasted, the message M will be eventually delivered to any other validator $$w$$ in the network that is alive, but:

* the delay between sending $$M$$ and receiving $$M$$ is arbitrary long
* there is no guarantee on messages ordering, so delivered order may differ from broadcasting order
* the same message may be delivered more than once
* in principle messages can also get lost, but we expect this is going to be masked by lower layers of communication, so on in the consensus layer disappearing of messages is visible as delays

## Base model: distributed database with DAG of transactions

Our base model describes the set of nodes (validators) concurrently updating a shared database (global state).

### Validators

Let $$V$$ denote the (finite) set of validators.

### Global states

Let $$<GS, Zero \in GS>$$ be a set with a distinguished point. We will be calling this set "global states" and distinguished point will be the "initial state".

Intuition here is that validators are going to establish a common view on "virtual memory of a decentralized computer" or, if you wish, a "shared database". A point $$gs ∈ GS$$ represents a single snapshot of this shared memory.

Implementation remark: the actual layout of global states in Casperlabs blockchain is described here [ADD LINK].

### Transactions

A transaction is any partial function $$t:GS \longrightarrow GS$$. Set of all possible transactions $$TR=GS^{GS}$$.

Example 1: Take global states to be $$<\mathbb{N},0>$$. Example transactions:
* $$f(n)=n / 2$$ (defined only for even numbers)
* $$f(n)=n+1$$ (defined for all numbers)

Example 2: Let $$A=\{Alice, Bob, Charlie\}$$. Take global states to be $$\mathbb{N}^A$$. Intuitively this can be seen as a simple banking system accounts, with only 3 accounts and non-negative integer balances. Let's define a transaction:
$$
f:\mathbb{N}^A \rightarrow \mathbb{N}^A
$$
$$
f(b)=\{(Alice, b(Alice) - 1), (Bob, p(Bob)+1)\, (Charlie, p(Charlie))\}
$$

Obviously, $$f$$ is defined only for $$\{b \in \mathbb{N}^A:b(Alice)>0\}$$.

This is how a single token transferring transaction looks in our notation.

### Evolution graph

Evolution of the database happens as application of transactions to global states.

In the world of classical ACID databases, transactions are applied sequentially to the state of a database.

![Evolution graph example (sequential)](../../.gitbook/assets/casper-evolution-graph-seq.svg)

Caution: on this picture "time" goes upwards. This is going to happen thorough this chapter.

Sequential evolution is (as may be expected) not really good enough for our needs. We need to generalize it to a parallel evolution of the database state.

Formally: an **evolution graph** is any directed acyclic graph where:
* vertices are labelled with global states
* edges are labelled with transactions
* having an edge $$x - (f) \rightarrow y$$ , we have $$y = f(y)$$, where $$x,y ∈ GS$$, $$f ∈ TR$$
* every path can be extended to a path starting from Zero.

![Evolution graph example (non-sequential)](../../.gitbook/assets/casper-evolution-graph-example.svg)

On such diagram, the same transaction may of course appear several times. When there is more than one path connecting two vertices, this implies an equation.

For example, reading above evolution graph we can deduce that:
$$
f (g(Zero))= g(f(Zero)
$$
$$
f(g(Zero)) = f(q(p(g(Zero)))
$$

### Double spend problem and merging

In our decentralized network of validators, different validators will independently try to propose transactions. Sometimes such propositions are inherently inconsistent, while in other cases they will be mergeable.

To understand this phenomenon on the level of evolution graph.

For example let's assume our database keeps accounts and balances. Our initial state of the database is: [Alice: 10, Bob: 0, Charlie: 0].

Consider the following transactions:
* $$a$$ - is Alice transferring 6 dollars to Bob
* $$b$$ - is Alice transferring 7 dollars to Charlie
* $$c$$ - is Alice transferring 4 dollars to Charlie
* $$d$$ - is Charlie transferring 4 dollars to Bob

Our intuition is that $$a$$ and $$b$$ cannot happen together - Alice does not have enough money. On the other hand $$a$$ and $$c$$ look totally mergeable and so is the case for $$a$$ and $$c$$. In case of $$b$$ and $$d$$ the situation is unclear, because $$d$$ followed by $$b$$ makes sense, while the other way around looks impossible.

The correct law is actually easy to discover. We say that **transactions f and g commute at global state gs** iff:
$$
f \circ g (gs) = g \circ f (gs)
$$

If transactions do not commute, we say they are conflicting. Please notice that this all works relatively to a point in the space of all global states - two transactions may commute at some points, while they are conflicting at others.

On the evolution graph below, there are two places where merging of commutative transactions can happen - we market both mergeable pairs with colors.

![Evolution graph (before merging step)](../../.gitbook/assets/casper-evolution-graph-alice-bob-charlie-1.svg)

Transactions $$a$$ and $$b$$ commute on global state [Alice: 10, Bob: 0, Charlie: 0]. Transactions $$c$$ and $$d$$ commute on global state [Alice: 6, Bob: 0, Charlie 4].

Let's see how the evolution graph will look after these two mergings are appended:

![Evolution graph (after merging step)](../../.gitbook/assets/casper-evolution-graph-alice-bob-charlie-2.svg)

Merging can be seen as an operation that picks two global states in an evolution graph and - if relevant paths commute - extends the evolution graph by adding new state that materializes the commutativity.

### Blocks and blockdags

The evolution graph alone is a not sufficient to implement a distributed consensus - we need a richer data structure for this purpose. If I am a validator, I have to maintain data structures that will provide to me at least the ability to record:

  * transactions I applied so far to the database 
  * my knowledge about other validators' activity 

For this purpose we introduce a dedicated data structure. A **blockdag** is a directed acyclic graph made of blocks.

A **block** is a tuple consisting of:

  * a validator
  * a transaction
  * a finite non-empty list of parent blocks

$$
B = <creator , transaction: GS ⟶ GS, parents = <b_1, ..., b_n>>
$$

Remark: as long as we are in set theory, a set of all possible blocks must be defined using well-founded induction. We skip this technical detail in hope that intuitively the concept is clear enough.

Having a collection of block, we consider it being a directed acyclic graph by taking:
 * vertices are blocks, plus one "special" vertex called Genesis
 * edge $$A \longrightarrow B$$ exists iff block A contains B on the list of parents

We require that in a blockdag every block can be connected by a path with Genesis.

This is an example of a blockdag:

![Blockdag example](../../.gitbook/assets/casper-dag-example.svg)

We use the following conventions to visually represent blockdags:

* block label $$b6: f$$ means that this is block $$b6$$ and it stores information about execution transaction $$f$$
* vertical swimlines correspond to validators; block is displayed in a swimline of its creator
* every block is a source of one of more arrows and this way we represent block's parents
* graph is displayed following the topological sorting, so arrows always are directed downwards and over time the structure grows upwards

### Blockdags vs evolution graphs

Blockdag is really just a smart notation for evolution graphs, with "block's creator" concept added. "Smartness" comes here from keeping global states implicit and encoding mergeable pairs by the parents concept.

Let's see how a blockdag maps to an evolution graph in a simple case:

![Blockdag to evolution graph transformation (sequential case)](../../.gitbook/assets/casper-blockdag-to-graph-seq-case.svg)

With blockdag in place we have now the perfectly clear narration of the chronology of events in our network of validators:

1. Validator C proposed block $$b_1$$ by executing transaction $$f$$ on top of state Zero.
2. Validator B proposed block $$b_2$$ by building on top of block $$b_1$$ and executing transaction $$g$$.
3. Validator A proposed block $$b_3$$ by building on top of block $$b_2$$ and executing transaction $$h$$.

Let's see how this will look when merging comes into play:

![Blockdag to evolution graph transformation (simplest merging case)](../../.gitbook/assets/casper-blockdag-to-graph-merging-case.svg)

Let's again translate events to plain English:

1. Validators A and C independently proposed blocks $$b_1$$ and $$b_2$$. Block $$b_1$$ was executing transaction $$f$$. Block $$b_2$$ was executing transaction $$g$$.
2. Validator B discovered that blocks b1 and b2 are mergeable, so he proposed block b3 by merging b1 and b2 and executing transaction $$h$$ on top of it.

Please observe (see the red dot) how the intermediate state $$f(g(Zero)) = g(f(Zero))$$ is hidden from the picture on the left and its existence is just implicitly given by fact that block $$b_3$$ has more than one parent.

To better illustrate the transformation from a blockdag to the corresponding evolution graph, here is slightly more complex example:

![Blockdag to evolution graph transformation (general merging case)](../../.gitbook/assets/casper-blockdag-to-graph-merging-case-2.svg)

Crucial is to observe that once two mergeable paths are discovered - in this case $$b \circ a$$ commutes with $$c$$ at state $$Zero$$ - the construction of implicit merged global state (red dot) is by directly applying commutativity. So the merged state in this case is calculated as:

$$
c(a \circ b (Zero))
$$

.. which turns out to be equal to:

$$
a \circ b (c(Zero))
$$

... thanks to blocks $$b_2$$ and $$b_3$$ being mergeable (which by definition of mergeability means that transactions $$b \circ a$$ and $$c$$ are commutative on global state Zero).

### Implementation of a shared database

We are now prepared enough to introduce the distributed-consensus based implementation of a shared database.

During his lifetime, a validator $$v$$ maintains two collections:
  *  **blockdag** with all blocks either produced by $$v$$ or received from other validators; however a block $$b$$ can only be added to the blockdag if all justifications of $$b$$ were collected and added before $$b$$
  *  **blocks-buffer**: a buffer of blocks received, but not yet incorporated into blockdag

Every validator $$v$$ is busy executing two infinite loops of processing (concurrently):

Publishing loop:

1. Select a transaction $$t ∈ TR$$ to be executed as the next one.
2. Select  a subset $$p$$ of  blockdag vertices (to be used as parents of the new block).
3. Create a new block $$b = <creator = v, transaction = t, parents = p>$$.
4. Add $$b$$ to the local blockdag.
5. Broadcast $$b$$ to all validators in the network.

Listening loop:

1. Listen do blocks incoming from other validators.
2. When a block $$b$$ arrived: check if all parents of b are already included in the blockdag.
 - if yes - append $$b$$ to blockdag
 - else - append $$b$$ to blocks-buffer.
3. Check if any block in blocks-buffer can now leave the buffer and be included in the blockdag, because all its justifications are now in blockdag.
4. Repeat step 3 as many times as needed.

How parents of a new block are selected (publishing loop, step 2) is the most critical point of the whole distributed consensus. We call this the **fork choice rule**.

### Adding causal structure to blockdag

For the fork choice rule to be defined we need to enrich our model with some sort of causal structure. It could be thought of as "weak time" and it can be considered a different solution of the same problem that [Lamport synchronization](https://en.wikipedia.org/wiki/Lamport_timestamps) solves.

When a validator is going to create a new block B, he will use the fork choice role against his copy of the blockdag to determine suitable parents for B. The input data for making this decision is - the blockdag itself. We want to make this input data be sealed into B.

Formally, this means we require each block $$B$$ created by validator $$V$$ to contain a snapshot of a blockdag maintained by V at the moment of creating B.  Technically, thanks to the monotonic nature of blockdag, this snapshot can be equivalently encoded by just enumerating "generators", so a transitive reduction of the blockdag in question. Basically, it is enough to enlist only a subset of blocks collection, starting from which all other blocks can be reached by traversing justification links. This new field in the block we call - **justifications**.

To summarize, let's state the improved definition of a block. A **block** is a tuple consisting of:

  * a validator
  * a transaction
  * a finite non-empty list of justification blocks
  * a finite non-empty list of parent blocks

For a block to be valid, every selected parent block must be included in set of block reachable from justifications sets (by following justification links).
  
In lame terms, a on creating a new block $$B$$, a validator seals into the block two sets of links:
  * justifications: means "what was my knowledge when I was creating block $$B$$"
  * parents: means "which paths of shared database evolution I am merging with block $$B$$"

Both parent-child and justifications form directed acyclic graphs. They share the same set of vertices, only justification graph has possibly more edges. So, now within a single blockdag we have two DAGs:
  * $$pDAG$$: where arrows are from a block to its justification block
  * $$jDAG$$: where arrows are from a block to its parent

And we have an inclusion: $$pDAG \subset jDAG$$

The structure of a block looks now like this:

$$
B = <creator , transaction: GS ⟶ GS, parents = <b_1, ..., b_n>, justifications=<j_1, ..., j_n>>
$$

To carry the enriched structure we have to adjust the way we draw blockdags.

![Blockdag with justifications](../../.gitbook/assets/casper-blockdag-with-justifications-example.svg)

The drawing convention is:
* black arrows are from $pDAG$ d
* red arrows are from $jDAG \setminus pDAG$ 
* we avoid drawing redundant red arrows (so when a red arrow can be deduced as pats of red-or-block arrows)

### Equivocation

On the previous example, it looks like when a validator looks at his blockdag and when he focuses on his own swimline (so blocks he proposed), this swimline considered a subgraph of $$jDAG$$ is a chain. This is not surprising because, logically, when I am proposing a new block, all blocks I proposed so far are within my knowledge, so I am including them in justifications of the new block. At least I **should** do so.

So, if all validators are acting honestly in the above sense, then on our picture, all swimlines are going to be chains.

The problem is that in a distributed network of validators such an "honest" behaviour cannot be technically enforced. Instead, we have to accept that the reality will look like this:

![Equivocation as seen in a blockdag](../../.gitbook/assets/casper-equivocation.svg)

In this example, validator A violates the "honesty" rule by splitting his chain on block $$b_5$$. Both $$b_8$$ and $$b_9$$ are referencing $$b_5$$ and yet there are not visible to each-other via justifications. This looks like validator A is not aware of his own blocks he proposed !

We call this **equivocation**.

### Implementation remark: block hash

Of course we are trying to make a good balance between precision (given by mathematical description of the solution) and programmer's intuition (which goes much closer along the actual implementation details). These two perspectives are sometimes quite different. And one such thing is block hash.

On the mathematical side, we start with the space of global states $$GS$$, then we have the set $$TR$$ of transactions over $$GS$$, then we have the set of blocks over $$TR$$. As all this is formally based on first-order logic and set theory, the identity of blocks comes for free. Also they are immutable for free. The only thing we will need, that is still missing, is the total ordering on the set of blocks, but because every set can be well-ordered (Zermelo's theorem) we can fix any such ordering and just use it.

On the implementation side, the same set of goals is addressed in quite different way. Blocks are going to be pieces of data (so, encoded as byte arrays) exchanged between nodes. For having identity and immutability that cannot be tampered, we have digest functions and public-key cryptography. A side effect of this is that each block must include a digest (=hash) or its body and this hash can be used as block id. Also, this hash gives us a total ordering of blocks by lexicographic sorting of hashes. In this approach we of course ignore the fact, that collisions of hashes exist - by naive assumption that such a collision will never happen in practice.

### Scoring

The selection of candidates for parents of a new block starts with scoring phase. Scoring is a way of assigning an integer value to every block in a blockdag.

Scoring starts by finding the latest block in every swimline. This is easy for honest validators (because their swimlines are just chains). When equivocation are present, we pick the block with biggest p-height (where p-height is the length of longest path in pDAG from the block to Genesis).

In case more than one block having the biggest p-height, we take the one with smallest block hash.

This is how it worked for our last example:

![Scoring phase 1](../../.gitbook/assets/casper-scoring-phase-1.svg)

Please observe how for validator A we preferred block $$b_10$$ over $$b_8$$ because $$pHeight(b_10)=5$$ and $$pHeight(b_8)=4$$.

Let $$LastBlocks(blockdag)$$ denote the set of blocks chosen by the above algorithm. This is how scoring works:

$$
Score(block) = \{tip \in LastBlocks(blockdag): b \triangleleft tip \}
$$

## Fork choice

UNDER CONSTRUCTION

## Increment 1: dynamic set of validators

UNDER CONSTRUCTION

## Increment 2: multi-transactional blocks

UNDER CONSTRUCTION

## Increment 3: transaction fees

UNDER CONSTRUCTION

## Increment 4: proof-of-stake

UNDER CONSTRUCTION

## Finality

UNDER CONSTRUCTION

