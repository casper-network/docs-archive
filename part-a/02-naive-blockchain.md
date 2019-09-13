# Naive Casper Blockchain

## Introduction

Blockchain is a P2P network, where a collection of nodes (called **validators**) concurrently update a decentralized, shared database. They do this by collectively building an ever-growing chain of **transactions**. For performance reasons transactions are bundled in **blocks**.

For the "outside world", the blockchain looks like a computer. This blockchain computer has a memory (= shared database) and can execute programs (= transactions). Execution of a program changes the state of the memory. Anybody can send a program to the computer and the computer will do a best effort attempt to execute this program.

We say that a blockchain computer is **decentralized**, i.e. there is no single point of failure in the infrastructure. Significant portion of the network of validators could be suddenly destroyed and nevertheless the blockchain will continue to work. Also, the system is resistant to malicious validators (as long total weight of malicious validators is below 50% of total weight of all validators).

The core of blockchain mechanics is continuous work of validators struggling to agree on consistent history of programs executed on the blockchain computer. This central idea we describe as "achieving **consensus** on the chain of blocks". Because every block contains a chain of transactions, this "consistent history" ends up being a sequence of transactions.

In this spec we use terms **shared database** and **blockchain computer memory** interchangeably. 

## Computing model

### Memory and programs

We need to define the "computational semantics" of a blockchain computer, so what are programs and how they execute. However, because the consensus protocol we will introduce is compatible with a wide range of computing models, it is convenient to keep this part as abstract as possible. Therefore, we represent the "computational semantics" of a blockchain computer as a triple $<GS, Zero, P>$ where:

- $GS$ is a set of states of the shared database (think that each point $gs ∈ GS$ represents a "snapshot" of the shared database); we call them "global states"
- $Zero ∈ GS$ is the initial state of the database
- $P ⊂ Partial(GS ⭢ GS)$ is a non-empty set of partial functions from $GS$ to $GS$, closed under composition; elements of $P$ we call **transactions** (and we just think of them as "executable programs")

Given a state $gs ∈ GS$ and a transaction $p ∈ P$ we can calculate the value $p(gs)$ only in the case when $p$ is defined at $gs$. In our lingo this is **the execution of p**.

When $p$ is not defined at point $gs$, we say that **execution of p on state gs failed**. So this is how we represent errors in program execution.

### Executing sequences of transactions

We want to generalize this notion to sequences of transactions, but in such a way that the information on execution errors is retained.

Having a sequence of transactions $p_1, p_2, ...., p_n∈ P$ we will keep the information on execution success/error as a function $status: [1,2,...,n] → \{false, true\}$.

For any $p ∈ P$ let $\triangle p: GS ⭢ GS$ be a total function that extends $p$ by applying identity whenever $p$ is not defined, so formally:
$$
\triangle p(x)=\begin{cases}
p(x), & x \in dom(p)\\
x, & otherwise
\end{cases}
$$
**Status(i)** represents the overall result (success vs failure) of the execution of **i-th** transaction in the sequence.

Let:

- $TSeq$ be the set of finite sequences of transactions: $TSeq = P^{Int}$
- $StatusTraces$ be the set of finite sequences of Booleans

We define the execution of a sequence of transactions as:
$$
exec: GS \times TSeq → GS \times StatusTraces \\
exec(gs, [p1, p2, ...., pn]) = (resultGS, trace)
$$
... where:

- $resultGS =  ∆pn ∘ ∆pn-1 ∘ ... ∘ ∆p1 (gs)$
- $trace(i) = \begin{cases} false, & execution \space of \space p_i \space failed \\ true, & otherwise \end{cases}$

Intuitively, **exec** takes a pair - initial global state and a sequence of transactions to execute. The result is also a pair - the resulting global state reached by sequentially applying all transactions and a trace of this execution saying which transactions failed along the way.

### Executing sequences of blocks

A block contains a sequences of transactions. Given some initial global state $gs ∈ GS$, whenever we say "execute a block" we mean executing the sequence of transactions it contains, starting from $gs$. We usually call $gs$ the **pre-state** of the block, and we say **post-state** to denote the resulting global state, returned by $exec(gs, sequence)$.

Given any sequence of blocks we may also **execute the sequence of blocks** because it is effectively a sequence of sequences of transactions, so it may be flattened to a single sequence of transactions.

Given any set of blocks $B$ we sometimes consider different linear orders of such set. Given a linear order $R$ on set $B$ we will be speaking about **executing the set of blocks B along linear order R**, with the obvious semantics of taking all the blocks, arranging them in a sequence following the order $R$ and then executing the resulting sequence of transactions.

## Blockchain participants

We envision the infrastructure of blockchain participants as a collection of actors (processes) communicating over a network, where each process plays one of the following roles:

- **validators (aka "ring 0")** - they form a P2P network that attempts to reach consensus on the ever-growing history of executed transactions; they do this by creating and validating blocks
- **finalizers (aka "ring 1")** - they observe validators and try to deduce the subset of history that is considered as "confirmed" (while "confirmed" predicate is parameterized so to reflect expected trust level) 
- **clients (aka "ring 2" or "dapps")** - they use the blockchain computer - so they send programs to be executed and react to execution results; a client connects to a validator (one or many) to send transactions, while it also connects to a finalizer (one or many) to observe execution results

## Stake management

### Introduction

In proof-of-stake blockchains, **stake** is a representation of the voting power that a validator has. We leave the question of exact representation of stakes open. We only summarize here the minimal assumptions that we need for the mechanics of the blockchain to work.

### Encoding of stakes

Main assumption is that a global state encodes (among other things) the "weights map" - a mapping of validators to their voting power. So, mathematically, we expect the existence of a function which assigns to every global state a function mapping validators to their weights:
$$
weights–map: GS → Int^{ValidatorId} \\
weights–map(gs): ValidatorId → Int
$$
Intuitively, the stake of a validator will be (usually) defined by the amount of internal blockchain "money" allocated to corresponding account.

### Bonding and unbonding

Blockchain users can increase / decrease the stake of given validator. This is to happen via executing (special) transactions.

Minimal stake **MIN_STAKE** is a parameter of the blockchain.

### Unbonding stages

Unbonding is always a total unbonding, so a validator transitioning to stake=0. There is no partial unbonding.

Unbonding must be go in stages, leading to the following states of validator:

- STAKED
- VOTING_ONLY
- UNBONDING_ESCROW
- ZEROED

While in STAKED, a validator can produce only blocks.

While in VOTING_ONLY, a validator can produce only ballots.

While in UNBONDING_ESCROW and ZEROED, a validator is not supposed to produce messages.

How transitioning between states happens is beyond the scope of this specification (it can be based on wall clock, p-time, j-daglevel, block generation and other approaches).

#### Slashing

Slashing is forced unbonding, where the money used for the stake is burned. The intention is to penalize equivocators.

## Blockdag

#### Visual introduction

The consensus protocol is based on a data structure that we call a **blockdag**, which can be seen as a graph. This is how it looks like:

<img src="./pictures/blockdag-with-ballots-and-equivocations.png" width=500>


The meaning of symbols:

<img src="./pictures/blockdag-with-ballots-legend.png" width=500>

We have 3 types of vertices in the graph:

- **normal blocks** - they contain transactions to be executed against the blockchain computer
- **ballots** - they do not contain transactions, but participate in the consensus
- **genesis** - this is a special block that stands as a root node of the structure

Additionally we say:

- **block** - when we mean "normal block or genesis"
- **message** - when we mean "normal block or ballot"
- **vertex** - when we mean "normal block or ballot or genesis"

We visually mark the creator of a message by placing it in relevant swimlane. Genesis is outside swimlanes because genesis is given at blockchain initialization (= it does not have a creator).

Every normal block points to its **main parent** block (we visualize this with red arrows). Hence blocks form a tree, which we call **the main tree**.

Additionally, any normal block may point to arbitrary number of blocks as **secondary parents**. We visualize them with blue arrows. Blocks + red arrows + blue arrows together form a directed acyclic graph and we call it **the p-dag**.

Any ballot points to exactly one block. We call this block "the target block of a ballot".

Additionally, any message may point to arbitrary number of vertices as **additional justifications**. We visualize them with **dashed arrows**.

All arrows together with all vertices form a directed acyclic graph we call **the j-dag**.

#### DAG vs POSET language

DAG is a common abbreviation for "directed acyclic graph".

POSET is a common abbreviation for "partially ordered set".

When a DAG has at most one edge between any pair of vertices, we say this DAG is "simple".

Any POSET can be seen as a simple DAG when you define an edge **a → b** to be present whenever **a < b**.

Any simple DAG leads to a POSET by taking its transitive closure and saying that **a < b** iff there is an edge **a → b**. By symmetry, taking **a < b** iff there is an edge **b → a** gives also a POSET (just based on inverted order). Going in the other direction - from POSET to a DAG - is analogous. In practice, POSET is "like a simple DAG", where we do not distinguish between DAGs with the same transitive closure, so in particular for visualization purposes it is convenient to draw a POSET as transitive reduction of corresponding DAG.

When talking about **j-dag** and **p-dag**, we blur the difference between DAG language and POSET language, because essentially one language is convertible to another.

#### Understanding the layers of the blockdag

We explain here only the intuition behind the blockdag. These ideas are formalized later.

**J-dag** is all about attesting what I have seen so far. When I am a validator, on creating a new message (= block or ballot) I have to attest what is my current protocol state, so in other words how my current blockdag looks like. I do this by including on the justifications list (which is part of the new message) pointers to all **j-dag** tips present in my blockdag. We will continue to use the terminology established for j-dag in previous chapter.

**Main-tree** encodes the multi-variant progress of transactions history. When a validator creating a block B picks block A as the main parent of B, it means "I want transactions included in B to extend the history of the blockchain that ended at block A, with all transactions in A already executed". This tree is analogous to similar tree of blocks that forms in previous generation of blockchains, like Bitcoin or Ethereum.

**P-dag** and the concept of secondary parents corresponds to "merging of histories" which is a subtle optimization on the way we process transactions. In blockchains like Ethereum, effectively only a single path of the main-tree ends up as "transactions that have been actually executed" while all the rest of main-tree ends up being wasted, or - as we say - "orphaned". In fact the amount of wasted work can be reduced by "merging". While creating a new block, a validator performs careful analysis of all branches of the main-tree and attempts to merge as many of them as is possible without introducing concurrency conflict.

#### Core mechanics of the blockchain

The blockdag emerges as a combination of these central ideas:

- Independently proposing updates of the shared database inevitably leads to a tree of transactions (blocks), because the proposing validator must choose which version of history it is about to extend. This is how the **main-tree** pops up.
- All that remains is to add the mechanics for validators to collectively agree on which branch of the main-tree is the "official" one.
- We solve this problem by recursively applying Abstract Casper Consensus.
- Secondary parents idea is a further refinement of the solution, by merging as many non-agreed paths of main-tree as is possible without introducing inconsistencies.

The single, most crucial trick here is the recursive application of Abstract Casper Consensus. Let's try to understand this trick first, before we dive into detailed specs of how validators and finalizers operate.

Let **b** be any block. So, **b** is a vertex in the main-tree. We will consider a projection of validators P2P protocol to a particular Abstract Casper Consensus model instance, which we will be calling **b-game**. 

| Abstract Casper Consensus concept                 | How this concept maps to b-game                              |
| ------------------------------------------------- | ------------------------------------------------------------ |
| validators                                        | validators with non-zero weight in post-state of **b**       |
| validator weights                                 | **weights-map(globals-states-db(b.post-state-hash))**        |
| message                                           | message (= block or ballot)                                  |
| j-dag                                             | j-dag                                                        |
| consensus value                                   | direct child of **b** in the **main-tree**                   |
| message **m** is voting for consensus value **c** | for a block **m**: **m** is a descendant of **c** along the **main-tree**, for a ballot **m**: **m.target-block** is a descendant of **c** along the **main-tree**; when above conditions are not met, we consider **m** as voting for nothing (empty vote) |

The contents of the table above may be explained as follows:

1. Hypothetically assuming that validators already achieved consensus on the block **b** as being the part of "official" chain of blocks, they will have to decide which direct child of **b** (in main-tree) will be the next "official" chain.
2. So, the focus now is on the block **b** and on its direct main-tree children.
3. We setup Abstract Casper Consensus instance "relative to block **b**", where consensus values are direct children of **b**.
4. Any block **x** can be seen as a vote for some child of **b** only if **x** is a descendant of **b** in main-tree. So if **x** is not a descendant of **b**, we consider **x** as carrying empty vote. 

**<u>Caution:</u>** when defining the players of **b-game**, we exclude all equivocators as seen in the current protocol state. This means that b-game is not "absolute", it is rather depending on the current perspective on the blockchain that given validator has. Also, the collection of equivocators grows over time, which means that over time we may need to recalculate b-game, excluding more validators. This aspect plays crucial role in how **finalizers** work - see below the chapter on finalizers.

Not all **b-games** tend to be equally important. What happens is the following pattern:

1. The **Genesis** block is given. So, **Genesis-game** is the first game.
2. As the blockdag grows, the **Genesis-game** is progressing towards finality.
3. Finality of **Genesis-game** means picking some direct child of **Genesis**. Let us name this child **LFB1** 
4. Then, **LFB1-game** becomes the "important" game that everybody look at.
5. As the blockdag grows, the **LFB1-game** is progressing towards finality.
6. Finality of **LFB1-game** means picking some direct child of **LFB1**. Let us name this child **LFB2**
7. This pattern goes on forever.

"LFB" stands for "last finalized block". For symmetry, we set **LFB0** = **Genesis**.

#### Why do we need ballots ?

The security of proof-of-stake blockchain is based on the stake in two ways:

- Large investment (=money) is needed to revert/overtake the history of transactions using honest means.
- Malicious behavior (= hacking) implies that the stake will get slashed.

Therefore, we would like only bonded validators to be able to participate in blockchain evolution. The problem here is that - when a validator unbonds, some of the **b-games** he was a player of, might not be completed (= finalized) yet. We would like to allow the validator still participate in these games, while not allowing him to join new games. This is where ballots come into play. Ballots allow to continue the consensus game for validators that are no longer bonded.

## Merging of histories

#### Topological sortings of p-past-cone

This is previous example of a blockdag, reduced to **p-dag** only:

<img src="./pictures/p-dag.png" width=450>

We define **p-past-cone(b)** as the set of all blocks $x$ such that $x \leqslant b$ (in the POSET corresponding to p-dag, $x \leqslant y \iff y → x$).

**<u>Example:</u>** Let's look at the block $3$. Its p-past-cone is $\{Genesis, 1, 2, 3\}$. Let's look at the block $9$. Its p-past-cone is $\{Genesis, 1,2,3,4,5,9\}$.

Of course, any **p-past-cone(b)** inherits the order from the whole **p-dag**, so it can be seen as a POSET as well.

For $<A,R>$ any POSET,  topological sorting of $<A,R>$ is any linear order $<A,T>$ such that $identity: <A,R> → <A,T>$ is monotonic. In other words, topological sorting is converting a POSET into a total order in a way that preserves the original order. For a given POSET this can be usually done in many ways.

<u>**Example:**</u> Let's take the $p–past–cone(3)$ from our example. As a POSET it looks like this:

<img src="./pictures/p-past-cone-for-block-3.png" width=270>

It can be topo-sorted in two ways only:

<img src="./pictures/p-past-cone-of-block-3-topo-sorts.png" width=400>

Example: Let's take the p-past-cone(9) from our example. As a POSET it looks like this:

<img src="./pictures/p-past-cone-for-block-9.png" width=320>

It can be topo-sorted in many ways. One such topo-sort is shown below:

<img src="./pictures/p-past-cone-for-block-9-toposort.png" width=150>

#### The context of merging problem

Let's assume that current p-dag as seen by a validator **v** looks like this:

<img src="./pictures/situation-before-merging.png" width=400>

To add a new block $x$, validator $V$ needs to decide which blocks to take as parents of $x$. In other words, which variants of transactions history block $x$ will continue. Merging is all about defining what does it mean that **x** continues more than one version of the history:

<img src="./pictures/merging-problem-illustrated.png" width=500>

We have blocks 8, 9 and 10 as current tips of p-dag, so they are candidates for becoming parents of the new block. But usually we won't be able to take all such tips as parents, because the versions of transactions history they represent are in conflict.

#### Formal definition of merging

We say that a set of blocks $B = \{b_1, b_2, ..., b_n\}$ is **mergeable** (= **not in conflict**) when the following holds:

1. take the sum $S$ of $p–past–cone(b_i)$ for $i=1,..., n$ - this is a sub-POSET of p-dag

2. given any topo-sort $T$ of $S$

3. the execution of transactions in $B$ along $T$ give:

   1. the same final global state (regardless of the selection of **T)**
2. the same subset of transactions that failed (regardless of the selection of **T**) 



## Operation of a validator

The spec is written from the perspective of a validator. We say this **local validator** to reference the validator which is running the algorithm. Let **vid** be the id of local validator.

### Validators P2P protocol - messages

Validators exchange messages which can be of 2 types:

- **blocks**
- **ballots**

A **block** contains the following data:

- **block id**
- **creator id** (= id of validator that created this block)
- **main parent** (id of another block)
- **secondary parents** (collection of block ids, may be empty)
- **justifications** (collection of message ids that the creator confirms as seen at the moment of creation of this block; excluding main parent and secondary parents; may be empty)
- **transactions list** (nonempty)
- **pre-state-hash** - hash of global state that represents state after executing all parents of this block
- **post-state hash** - hash of global state achieved after executing transactions in this block (and all previous block, as implied by p-dag)

For a block $b$ we define the collection $b.all–justifications$ as main parent + secondary parents + justifications. This collection is always non-empty because **main parent** is a mandatory field. 

A **ballot** contains the following data:

- **block id**
- **creator id** (= id of validator that created this ballot)
- **target block** (id of a block)
- **justifications** (collection of message ids that the creator confirms as seen at the moment of creation of this ballot, excluding target block; may be empty)

For a ballot **b** we define the collection $b.all–justifications$ as target block + additional justifications. This collection is always non-empty because target block is a mandatory field.

From the definitions above it follows that for every message $m$ there is a **j-dag** path from $m$ to $Genesis$.  

### Validators P2P protocol - behavior

We use the same assumptions on message-passing network as were stated in Abstract Casper Consensus model. So validators only exchange information by broadcasting messages, where the broadcasting implementation provides exactly-once delivery guarantee, but the delays and shuffling of messages are arbitrary.

During its lifetime, a validator maintains the following data structures:

- **deploys-buffer** - a buffer of transactions sent by clients, to be executed on the blockchain computer  
- **blockdag** - keeping all blocks and ballots either he produced by or received from other validators
- **messages-buffer** - a buffer of messages received, but not yet incorporated into the **blockdag**
- **latest-honest-messages** - a mapping from validator id to message id, pointing every validator known in the **blockdag**, excluding **equivocators**, to the corresponding swimlane tip
- **equivocators** - a collection of validators for which current blockdag contains an equivocation
- **reference-finalizer** - an instance of finalizer used internally (see later in this spec what finalizers are)
- **global-states-db** - mapping of global state hash to global state

A message $m$ can be added to the $blockdag$ only if all justifications of $m$ are already present in the blockdag. So if a validator receives a message before receiving some of its justifications, the received message must wait in the $messages–buffer$.

A validator is concurrently executing two infinite loops of processing:

**<u>Listening loop:</u>**

Listen to messages incoming from other validators. Whenever a message $m$ (block or ballot) arrives, follow this handling scenario:

1. Validate the formal structure of $m$. In case of any error - drop $m$ (invalid message) and exit.

2. Check if all justifications of $m$ are already included in $blockdag$.

   1. if yes: continue
2. otherwise: append $m$ to the $messages–buffer$, then exit
   
3. Perform processing specific to type of $m$ (block or ballot) - see below.

4. If $equivocators$ does not contain $m.creator$:

   1. Check if $m$ introduces new equivocation - this is the case when $latest–honest–messages(m.creator)$ is not member of $j–past–cone(m)$
2. If yes then add $m.creator$ to $equivocators$
   
5. If $equivocators$ does not contain $m.creator$, update $latest–honest–messages$ map by setting $latest–honest–messages(m.creator) = m$

6. Check if there is any message $x$ in $messages–buffer$ that can now leave the buffer and be included in the $blockdag$ because of $x.all–justifications$ are now present in the $blockdag$. For first such $x$ found apply steps (3) - (4) - (5) . 

7. ("Buffer pruning cascade") Repeat step (6) as many times as there are blocks which can be released from the buffer.

Processing specific to type of $m$ goes as follows:

If $m$ is a block:

1. Validate whether $m$ parents (main parent and secondary parents) were selected correctly:

   1. run the fork-choice for the protocol state derived from justifications of $m$

   2. compare calculated parents with actual parent of $m$:

      1. if they are the same: append $m$ to $blockdag$.
2. are different than actual parents - drop the block (invalid block) and exit
   
2. Check if parents of $m$ are not conflicting. If they are conflicting then drop the block (invalid block) and exit.

3. Calculate pre-state for $m$ by executing the transactions in the merged history that is determined by all parents of $m$. Check if calculated hash of pre-state is equal to pre-state-hash stored in $m$. If not, then drop $m$ (invalid block) and exit.

4. Calculate post-state for $m$ by sequentially applying all transactions in $m$ on top of global state calculated in step (3). Check if calculated hash of post-state is equal to post-state-hash stored in $m$. If not, then drop $m$ (invalid block) and exit.

5. Store post-state calculated in step (4) in $global–states–db$.

If $m$ is a ballot - do nothing.

**<u>Publishing loop:</u>**

1. Sleep unless the next time for proposing a block arrives (typically this may be a periodic activity based on wall clock).

2. Run fork-choice against the current blockdag (see next section). The result is:

   1. Main parent - $mp$.
   2. Collection of secondary parents - $sp$ - sorted by preference.

3. Pick the maximal non-conflicting subset $mncsp ⊂ sp$, respecting the selection of $mp$ and the ordering of $sp$.

4. Calculate merged global state $merged–gs$ derived from $\{mp\} ∪ mncsp$.

5. Check the weight of local validator in merged global state: $weights–map(merged–gs)(vid)$

   1. If weight is non-zero and $deploys-buffer$ is nonempty, we will be creating and publishing a new block.
2. otherwise - check the status of local validator:
      1. VOTING_ONLY => create and publish a new ballot 
      2. otherwise => exit

Case 1: new block 

1. Take desired subset of transactions $trans$ from $deploys-buffer$ (this part of behavior is subject to separate spec; on this level of abstraction we accept any strategy of picking transactions from the buffer).
2. Apply $trans$ sequentially on top of $merged–gs$. Let $post–gs$ be the resulting global state.
3. Create new block:
   - block id = hash of the binary representation of this block
   - creator id = $vid$
   - main parent = $mp$
   - secondary parents = $mncsp$
   - justifications = $latest–honest–messages$ after removing main parent, secondary parents and redundant messages (see explanation below)
   - transactions list = $trans$
   - pre-state-hash = $hash(merged–gs)$
   - post-state hash = $hash(post–gs)$
4. Store $post–gs$ in $global–states–db$
5. Broadcast new block across validators P2P network.

Case 2: new ballot

1. Create new ballot:

   - block id = hash of the binary representation of this block
   - creator id = $vid$
   - target block = $mp$
   - justifications = $latest–honest–messages$ after removing: target block and redundant messages (see explanation below)

2. Broadcast new ballot across validators P2P network.

3. Caution: we generally want to keep the collection $m.justifications$ as short as possible. For this, we never include there main parent, secondary parents and target block, and also we want the collection of justifications included in the message to be transitively reduced (= included justifications form an antichain).

   ### Relative votes

   We will need the concept of "last message created by validator **v** that was non-empty vote in **b-game**". Given any block $b$ and any validator $V$ let us take look at the swimlane of $V$. If $v$ is honest, then this swimlane is a chain. Any message $m$ counts as non-empty vote in **b-game** only if:

   - $m$ is a block and the ancestor of $m$ (in main-tree) is $b$
   - $m$ is a ballot and the ancestor of $m.target–block$ (in main-tree) is $b$

   We start from the latest (= top-most on the diagram) message in the $swimlane(v)$ and we traverse the swimlane down, stopping as soon as we find a message that is counts as non-empty vote in **b-game**.

   <u>**Example:**</u>

   Below is the original example of the blockdag, but with all messages that are non-empty votes in 3-game highlighted with green:

   <img src="./pictures/fork-choice-paradox.png" width=400>

   **Example:**

   Let us again look at the example of a blockdag:

   <img src="./pictures/blockdag-with-ballots-and-equivocations.png" width=400>

   Let's apply this definition using validator 3 as the example and find last votes of validator 3 in various games.

   | Block b | Last non-empty vote of validator 3 in b-game |
   | ------- | -------------------------------------------- |
   | Genesis | 14                                           |
   | 1       | 9                                            |
   | 2       | 14                                           |
   | 3       | 9                                            |
   | 4       | (none)                                       |
   | 5       | 14                                           |
   | 6       | (none)                                       |

   #### Fork choice

   The goal of fork-choice is to take the decision on top of which version of shared database history we want to build in the next step. This decision can be seen as iterative application of the reference estimator from "Abstract Casper Consensus". As a result we want to get a list of blocks (ordered by preference) which will serve as parent candidates for the new block.

   The algorithm goes as follows:

   1. Decide which protocol state $ps$ to use:

      1. When using fork choice for creation of new block this is the point where the validator can decide on the subset of his local knowledge to reveal to outside world. Ideally, the validator reveals all local knowledge, so it takes as protocol state the whole local blockdag.
   2. When using fork choice for validation of received message $m$, the protocol state to take is $j–past–cone(m)$.
   
2. Take $HV$ - all honest validators (all creators of messages in $ps$ minus these seen equivocating with messages in $ps$).
   
3. Find latest message $lm(v)$ created by each validator $v ∊ HV$, ignoring validators that produced no message.
   
4. For all validators that have $lm(v)$ defined take:
      $$
   tipBlock(v)=\begin{cases} lm(v), & lm(v) \space is \space a \space block \\lm(v).target–block, & otherwise \end{cases}
   $$

   5. Take $lca–block$ = latest common ancestor along main-tree of all $tipBlock(v)$

   6. Initialize resulting collection of blocks as one-element list $Result = [lca–block]$

   7. For each block $b$ in $Result$ replace $b$ with its direct children in main-tree: $c_1, c_2, ..., c_n$, where the list of children is ordered following this recipe:

      1. For each honest validator $v$ find $lmb(v)$ - the last message by $v$ voting in **b-game.**
   2. Find a child $c_i$ that $lmb(v)$ is voting for - by traversing down the main-tree.
      3. Using $validator–weights(b)$ count the votes.
   4. Order the sequence $c_i$ by calculated votes, using $ci.id$ (= block hash) as tie-breaker.
   
8. Repeat step 7 as long as it is changing **Result**.
   
9. The **Result** is the list of blocks we want. First block on the list is the main parent candidate, remaining blocks are secondary parents candidates.  
   
   ## Operation of a finalizer
   
   ### The objective

   Finalizer observes the growing blokchain. The objective is to recognize the subset of transactions history that:

   - is already agreed (as a result of on-going consensus)
- cannot be reverted (unless the equivocators collection exceeds - by total weight - predefined threshold)
  
### Parameters

In general - different finalizers will be based on different finality criteria. For the current design we assume that the criterion described [here](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/135921775/Finality+3+Summits) is in use.

Hence, the finalizer is parameterized by:

   - the type of finality detector to be used
- **K** - acknowledgement level
   - **WP** (weight percentage) - expressed as a number between 0 and 1

   ### State

   The assumption is that a finalizer can traverse the blockdag, reading contents of blocks. Also, for any block b it should be able to read post-state of b and in particular get weights-map from this post-state.

   Caution: refer to subsequent sections to 
   
   The internal state of the "reference" implementation of a finalizer would be:

   - **equivocators: Set[ValidatorId]**
- **current-game-id: Int**
  
   - current finality detector instance - the one observing **LFB(current-game-id)-game**
- **LFB: Seq[Block]** for **i=0 ... current-game-id**
  
   - **initial-players: Seq[Set[ValidatorId]]**
- **excluded-players: Seq[Set[ValidatorId]]**
   - **FTT: Seq[Int]**

   Initial state (on the beginning of the blockchain, the only block is Genesis):
   
   - **equivocators** = empty set
   - **current-game-id** = 0
   - current finality detector instance = new instance (according to configured type of finality detector to be used)
   - **LFB** = empty sequence
   - **initial-players** = one element sequence, with the single element being the set of ids of validators bonded at Genesis
- **excluded-players** = one element sequence, with the single element being the empty set
   - **FTT(0) = ceiling(WP \* total-weight(post-state of Genesis))**

   ### Behaviour - the general plan
   
   The operation of a finalizer can be decomposed as the following, partially independent activities:
   
   1. Maintaining equivocators collection corresponding to current protocol state.
   2. Building the **LFB** chain
   3. Propagating **LFB** chain finality via secondary parents (indirect finalization).
4. Monitoring old games in **LFB** chain for the possibility of equivocation catastrophe.
   5. Reacting to equivocation catastrophe (by recalculating the **LFB** chain).
6. Publishing the stream of finalized blocks (over some streaming API) - this includes possibly also maintaining the collection of subscribers.
   
### **LFB chain**

   **LFB(i)** is supposed to be the "i-th last finalized block". **LFB** chain is achieved in the following way:

   1. Take **LFB(0) = Genesis**
   
   2. Let's assume that LFB(m) is the last-so-far element of the chain, so in other words the last finalized block. 

      1. For deciding which main-tree child of LFB(m) should be taken as LFB(m+1) we need to start a new empty instance of finality detector.

         1. **initial-players(m)** = validators staked at post-state of **m**, excluding current contents of **equivocators**
2. **excluded-players(m)** = empty set
   
2. Finality detector observes the LFB(m)-game, with:
   
   1. game-level acknowledgement level **K** same as defined by parameters of this finalizer
      2. **FTT(m) = ceiling(WP \* total-weight(post-state of m))**, where **ceiling(_)** is integer rounding towards positive infinity.
   
      3. Once **LFB(m)**-game reaches finality, the next element of **LFB** chain is established.

   ### Indirect finalization

   Once **LFB(m)** is established, we consider the whole **p-past-cone(LFB(m))** as finalized.

   ### Equivocation catastrophe

   For any **LFB(m)**, the **LFB(m)-game** may "crash" by total weight of equivocators exceeding **FTT(m)**. Such situation we call **the equivocation catastrophe**.

   Discovery of equivocation catastrophe works as follows. Whenever a new message **m** is added to local blockdag, the following handling is done by the finalizer:

   1. If **m.creator** is already included in **equivocators** collection - do nothing.
   
2. Otherwise - check if m is not introducing a new equivocation. If yes - add **m.creator** to equivocators and:
   
   1. for every i such that m ∈ initial-players(i):
   
      1. add m to **excluded-players(i)**
   2. using weights map from **LFB(i)** post-state, check if total weight of **excluded-players(i)** exceeds **FTT(i)**
      
   2. if for some **LFB(i)** exceeding **FTT(i)** case happened - take the smallest such **i** - we will call the block **LFB(i)** **the catastrophic point**
   

Once an equivocation catastrophe is discovered, the following handling must be applied:

1. Starting from the catastrophic point, re-calculate the **LFB chain** (initializing initial players accordingly to current contents of **equivocators**).
   
   2. Find the first **i** such that the new LFB-chain differs from old LFB chain at index **i**. Usually such **i** will be bigger than the catastrophic point.
3. Publish a rollback event at the level of external API.
   4. Publish re-calculated LFB stream, starting from first difference.

   ### External API of a finalizer

   The API should be stream-based. The decision on the actual streaming technology to use is beyond the scope of this specification.

   We only assume that:

   - external software components may subscribe to the API (to be notified)
- subscribed observers may unsubscribe
   - what a subscribed observer receives is a sequence of events

   Events:

   | Event type  | Contents                                                  | Semantics                                     |
| ----------- | --------------------------------------------------------- | --------------------------------------------- |
   | NEXT_LFB    | event idLFB(i).idisequence of indirectly finalized blocks | published as soon as **LFB(i)** is finalized  |
| CATASTROPHY | event idsequence id of catastrophy point                  | signal that equivocation catastrophe happened |
   

**Example:**

| Event                                | Current snapshot of LFB chain |
| ------------------------------------ | ----------------------------- |
| NEXT_LFB(1, 231, 0, <>)              | (231)                         |
| NEXT_LFB(2, 420, 1, <>)              | (231, 420)                    |
| NEXT_LFB(3, 801, 2, <524,525>)       | (231, 420, 801)               |
| CATASTROPHY(4, 2)                    | (231)                         |
| NEXT_LFB(5, 421, 1, <105, 116, 228>) | (231, 421)                    |
| NEXT_LFB(6, 480, 2, <>)              | (231, 421, 480)               |

   





















