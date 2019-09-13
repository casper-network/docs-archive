# Abstract Casper Consensus

## Introduction

We are considering a collection of processes (called **validators**) communicating over a message-passing network. The goal they collectively pursue is to agree on selecting a single value from a finite set $C$, which we call the set of **consensus values**. Once the agreement is achieved, the problem is solved and so the processes can terminate.

The space of possible distributed algorithms fulfilling the mission as described above is probably huge. Therefore we want to limit our attention only to a restricted family of such solutions. In doing so, we introduce several assumptions:

- we set a very specific format of messages that validators exchange
- we enforce some constraints on the behaviour of validators
- we expect certain guarantees from the message-oriented communication layer that validators use

This restricted model we call **Abstract Casper Consensus (ACC)**.

We primarily see ACC as a definition of a problem to be solved. Solutions of this problem are going to be pairs $<EST, FD>$, where $EST$ is some estimator and $FD$ is some finality detector.  The rest of this document is mostly devoted to explaining in details what **estimator** and **finality detector** really mean.

In CasperLabs we work with diversity of **ACC** solutions. For us, an **ACC** solution is what lives in the heart of a blockchain design. Different solutions of **ACC** problem lead to different blockchains.

**Caution 1:** Be warned that ACC is NOT a blockchain ! Abstract-consensus and blockchain consensus are two separate problems. In abstract consensus model nodes talk to agree on a value and then they stop talking. In a blockchain model nodes never stop talking, because they want to keep extending the chain of blocks forever. So at some point they need to agree on adding yet another block to the chain - this is where the ACC problem shows up and this is why we first study this sub-problem in isolation. After having the sub-problem studied enough, we apply the sub-problem in the wider context, i.e. building a blockchain.

**Caution 2**: As target audience of this document is software developers, here and there we add some pseudo-code snippets to illustrate the concepts with a language closer to developer's perspective. This pseudo-code generally alludes to Scala syntax, but was modified so that non-scala developers will be able to guess the meaning.

## The model

### Validators and their weights

Validators are just processes (actors / applications / entities) able to do computing, communicating over via message passing.

Every validator has a weight, which is a non-zero integer value and is thought of as "the voting power of this validator". In the context of proof-of-stake blockchains it corresponds to the bonded stake.

```
val validators: Map[Validator, Int]
```

### Network

Validators are communicating over a network. We assume that all the communication stack layers taken together provide the following semantics:

1. Communication between validators is based on the "broadcast" principle: at any time, a validator can broadcast a message $m$.
2. Once broadcasted, the message $m$ will be eventually delivered to every validator in the network. The delivery will happen exactly once. The delivery delay may be of arbitrary length.

Given the assumptions above it follows that the order of delivery may not coincide with the order of broadcasting, i.e. if a validator $A$ broadcasts message $m_1$ and later it broadcasts message $m_2$ and $B$ is another validator then we cannot say anything certain about the order of receiving $m_1$ and $m_2$ by $B$.

```
interface GossipService {
  proc broadcast(message: Message)
}

interface Validator {
  proc handleMessageFromNetwork(message: Message)
}
```

### Messages

We assume that every message contains the following information:

- **message id**
- **creator id** (= id of validator that created this message)
- **justifications** (= collection of message ids that the creator acknowledges as seen at the moment of creation of this message; may be empty)
- **consensus value** (= a value this message is voting for; this value is optional; if not present then this message is voting for nothing)
- **daglevel** (an integer value)

We reference properties of message $m$ using dot notation, for example:

$m.daglevel$

Daglevel is calculated in the following way:

- if the list of justifications is empty: $daglevel = 0$
- otherwise: $daglevel = max (daglevels of justifications) + 1$

When validator $V$ creates and braodcasts a message with consensus value $X$, we say that $V is voting for X$.

```
class Message {
  val id: Long
  val creator: Validator
  val justifications: List[Message]
  val consensusValue: Option[Int]

  fun daglevel: Int =
     if (justifications.isEmpty)
       0
     else
       max(justifications map (j => j.daglevel))
}
```

### J-dag

Justifications are pointing to previously received messages. Let us consider any set of messages $M$ closed under taking justifications. Let us define the following directed graph:

- take vertices to be all elements of $M$
- take edges (= arrows) to be all pairs $m_1 →  m_2$ such that $m_2 \in m1.justifications$.

Such a graph is always acyclic because a cycle in this graph would mean time-travelling is possible (i.e. we assume that listing a message as justification is only possible if this message was first created).

We call any such structure **j-dag**. We generally assume that every validator maintains a (mutable) representation of **j-dag** reflecting the most up-to-date knowledge on the on-going consensus establishing process. Observe that **j-dag** may be equivalently seen as a POSET, because of the well known equivalence between transitively closed DAGs and POSETs. We frequently blur the distinction between DAG-based and POSET-based languages when talking about consensus.

Please observe that for any message **m**, the collection $m.justifications$ determines a sub-dag of the **j-dag**.

In the context of any **j-dag** we introduce the following concepts:

- **transitive justification of message $A$** is any message $B$ such that **j-dag** contains a path $A → ... → B$; this naming reflects the fact that an arrow in **j-DAG** goes always from newer messages to older messages; in POSET lingo it translates to $B < A$, and we specifically pick here the direction of the ordering relation to reflect the time flow, so $B < A$ because $B$ must be older than $A$ (= $A$ confirms that it saw $B$)
- **j-past-cone of block A** or shortly $j–past–cone(A)$ is the full subgraph of **j-dag** formed by taking all as vertices all transitive justifications of messages $A$,  plus the message $A$ itself; in POSET lingo it is just the set of all $B$ such that $B <= A$
- **swimlane of validator V** (or just **V-swimlane**) is: (1) take the transitive closure of **j-dag** (2) cut it to a subgraph by taking only messages created by V
- **j-dag tip** is a message $m$ that is not a justification of any other message in **j-dag**; in POSET lingo it is just a maximal element in a **j-dag**
- **panorama of message B** - for a validator $V$ cut **V-swimlane** down to vertices included in $j-past-cone(B)$; the resulting subgraph of **V-swimlane** we will be calling **V-swimlane-cut-to-B**; now iterate over the collection of all validators, for every validator $V_i$ take all tips of $V_i–swimlane–cut–to–B$; sum of such tips is what we want to call the $panorama(B)$
- **validator V is honest** if $V–swimlane$ is a chain; in POSET language: $V–swimlane$ is a linear order
- **validator V is an equivocator** if V is not honest
- **equivocation** is a proof that validator $V$ is not honest; in other words it is pair of messages $A$, $B$, both created by $V$, such that $A$ is not a transitive justification of $B$ and **B** is not a transitive justification of $A$
- **latest message of a validator V** is a j-dag tip of **V-swimlane**; if $V$ is honest then it has at most one latest message
- **latest message of validator Z that honest validator Y can see** is the following situation (notice we define it in the context of a local j-dag maintained by any validator V)
  - both $Y$ and $Z$ are honest
  - take $m$ = latest message of $Y$ (must be unique because $Y$ is honest)
  - take the intersection of $panorama(m)$ and $Z–swimlane$ - must contain at most one element, because $Z$ is honest - this is the "latest message" we are talking about
- **honest validator Y can see a honest validator Z voting for consensus value P** is when latest message of validator $Z$ that validator $Y$ can see is voting for $P$

```
interface JDagOfMessages {
  fun targets(message: Message): Iterable[Message]
  fun sources(message: Message): Iterable[Message]
  fun contains(n: Message): Boolean
  fun tips: Iterable[Message]
  proc insert(n: Message)
}

class ProtocolState {
  val jDagTips: Set[Message]
}
```

### Protocol states

Any set of messages closed under traversing via justifications is a j-dag. We typically use j-dags in two contexts:

- when talking about the **local j-dag**, i.e. the data structure that a validator maintains to reflect the ever-growing knowledge about the on-going consensus
- when talking about the universum of all-possible j-dags over a set $M$ of messages - this universum is an infinite POSET, who has j-dags as elements and the ordering relation is set-inclusion, so, **jdag1 <= jdag2 iff jdag1 ⊂ jdag2**.

From the point of view of pure mathematics, the local **j-dag** corresponds to a chain in the universum - on receiving some message, a validator updates its local j-dag, and the updated j-dag will then be a superset of the previous j-dag he has.

But historically, two different ways of talking about this situation emerged and both ways tend to be actually useful:

- when talking about the universum, we prefer to speak about the **protocol states**; so, a protocol state is a point in the universum of j-dags, representing a set of messages closed under justifications
- when talking implementation-wise, we tend to speak about j-dags, meaning "a DAG formed with messages and justifications" because we frequently have also other DAGs around (also taking messages as vertices, but using other sets of edges)

So, for a software engineer, a protocol state might well be seen as a snapshot of the **j-dag**.

When talking about the universum of protocol states, we usually use speak about the order of protocol states (= the inclusion relation) using the time flow metaphor, so for example when $ps_1$ and $ps_2$ are protocol states and $ps_1 < ps_2$, we say that $ps_1$ is earlier than $ps_2$, or that $ps_2$ is "in the future of $ps_1$".

### Lifecycle of a validator

A validator continuosly runs two activities:

- listens to messages incoming from other validators and on every incoming message runs the finality detection algorithm to see if the consensus has already been reached (we explain finality detection in detail later in the document)
- (from time to time) decides to cast his vote - by creating a new message $m$ and broadcasting it

A validator itself must decide when to create and broadcast new messages - this is what we call a **validator strategy.**

### Estimator

Upon creation of a new message $m$, a validator must decide what consensus value $m$ will vote for. We limit the freedom here by enforcing that the selected consensus value is constrained by certain function, called **estimator**. Assumption here is that estimator is fixed upfront and used by all validators. This function as allowed to depend only on justifications of message $m$ and it returns a subset of consensus values. When a validator makes a vote, it is allowed to:

- either pick a value from the subset returned by the estimator
- or pick $None$, so create a message voting for nothing

We can now rewrite the definition of Message class with this assumption applied:

```
class Message {
  val id: Long
  val creator: Validator
  val justifications: List[Message]
  val consensusValue: Option[Int]

  fun daglevel: Int =
     if (justifications.isEmpty)
       0
     else
       max(justifications map (j => j.daglevel))
}

class Validator {
  var currentProtocolState

  fun estimator(pc: ProtocolState): Set[Int]

  fun pickValueFrom(subsetOfConsensusValues: Set[Int]): Int

  fun createNewMessage(): Message = new Message(
      id = generateMessageId,
      creator = this,
      justifications = currentProtocolState.tips,
      consensusValue =
        if (shouldNextVoteBeEmpty())
          None
        else
         pickValueFrom(estimator(currentProtocolState)))

  fun generateMessageId(): Long

  fun shouldNextVoteBeEmpty(): Boolean
}
```

### The reference estimator

In fact, in all solutions considered so far by Casperlabs we are reusing the same pattern for estimators construction. It assumes that the set of consensus values $C$ is totally ordered.

For a protocol state $ps$ we calculate the estimator value in the following way:

- if $ps$ is empty then the result is $C$
- otherwise - we apply the following algorithm:
  1. take the collection of all honest validators in $ps$
  2. restrict to collection of validators that created at least one message
  3. for every validator - find its latest message
  4. sum latest messages by weight - this end up with a mapping $total–votes: C \to Int$ - for every consensus value $c$ it returns the sum of weights of validators voting for $c$
  5. find all points $c ∈ C$ such that $total–votes$ has maximum value at $c$
  6. using total order on $C$, from elements found in previous step pick maximum element $cmax$
  7. the result is one-element set ${cmax}$

## Finality

### What is finality ?

Finality is a situation where certain consensus value $c$ gets "locked", i.e. eventually every honest validator $V$ starts voting for $c$ and there is no way that $V$ will vote for another consensus value in the future.

The challenge here is that, while finality may be already achieved, it is not quite easy to actually recognize it. Please keep in mind that we want to recognize the finality from the perspective of the knowledge that a single validator has, so although some "ultimate observer" able so see the current state of all validators could deduce finality, individual validators may still struggle to make such conclusion.

### Equivocations

Finality cannot really be "absolute" because validators may cheat, i.e. they can violate "fair play". There are 3 ways a validator can violate fair play:

1. produce a malformed messages
2. violate the condition that message is allowed to vote on a value picked from what estimator tells
3. equivocate

Case (2) can be really considered a subcase of (1), and (1) can be evaded by just assuming that validators reject malformed messages on reception. So, the only real problem comes from (3). Equivocations do break consensus and the intuition for this is clear - if everybody cheats by concurrently voting for different values, validators will never come up with a decision which value is finally agreed.

It may be not immediately obvious how equivocations are possible in the context of the estimator, which forces us to pick certain values. It is worth noticing that:

1. The essence of an equivocation is not voting for different consensus values but behaving in a "schizophrenic" way by pretending that "I have not seen my previous message".
2. Estimator returns a set, not a single value. When this set has size >0, it leaves some extra freedom.
3. Even if the size of the set returned by the estimator is actually 1, there is always a possibility to cast an empty vote. Voting for empty vs voting for a value is a freedom.
4. Validator does not have to reveal all messages actually received. "Revealing" happens at the creation of new message - by listing justifications of this message. It is legal to hide some knowledge here, as long as a validator does this hiding in a consistent way (if I once admit I have seen message $m$, I cannot un-admit this later).

### Finality criteria

Because of equivocations, finality really means "consensus value $c$ being locked as long as the fraction of honest nodes is sufficiently high". We typically express the "sufficiently high" part by introducing the concept of **faults tolerance threshold**, or **FTT** in short.

Finality criterion is a function $fc: protocol–states \times Int \to C \cup {EMPTY}$.

We interpret this function as providing the answer if the finality was achieved (and if yes, then which consensus value is finalized), given the following input data:

- protocol state (so, a j-dag)
- fault tolerance threshold (integer number)

And the result, if not empty, gives the "locked" consensus value that will be locked as long as the total weight of equivocators will not exceed **FTT**.

### Finality theorems

Finality criterion is a strictly mathematical concept. To introduce new finality criterion one has to:

1. Define suitable $fc$ function.
2. Prove the finality theorem for $fc$.

On our way to CasperLabs blockchain we expect to see a diversity of finality criterions to be discovered and used. As of September 2019 we have been working with 3 finality criterions (so far):

- E-clique
- The Inspector
- Summit theory by Daniel Kane

For a protocol state $ps$, let $eq(ps)$ denote the total weight of equivocators (so validators $V$ such that $ps$ includes an equivocation by $V$).

A finality theorem for a criterion $fc$ says:

IF

- $ps$ is some protocol state
- $FTT$ is some integer value
- $c ∈ C$
- $fc(pc, FTT) = c$

THEN

- $estimator(ps) = {c}$

- for every protocol state $fps$ such that $PS \leqslant fps$ and $eq(fps) < eq (ps) + FTT$ the following holds:

  - $estimator(fps) = {c}$

### Finality detectors

Finality criterion is a purely mathematical construct. On the software side it will typically map to several different implementations. For example in the case of "The Inspector" finality criterion, we currently have the following implementations (and more are to come):

- reference implementation (very simple but also quite slow)
- single-sweep implementation (order of magnitude faster than reference implementation)
- voting matrix (order of magnitude faster than single sweep, but limited to acknowledgement level 1)

Therefore, the distinction between finality criterion and finality detector is quite important in practice.

The following code snippet shows the contract for incremental finality detectors that is used in our abstract consensus simulator:

```
interface FinalityDetector {
  fun onNewMessageAddedToTheJDag(
    msg: Message,
    latestHonestMessages: ValidatorId => Option[Message]): Option[Commitee[C]]
}
```

Of course, a convenient contract for finality detectors will typically dependent on the exact shape of the surrounding software - usually because of various optimizations in place.

## Calculating finality

### Introduction

UNDER CONSTRUCTION

### Visual notation

UNDER CONSTRUCTION

### Zero-level blocks

UNDER CONSTRUCTION

### Quorum

UNDER CONSTRUCTION

### Acknowledgement level 1

UNDER CONSTRUCTION

### Acknowledgement level 2

UNDER CONSTRUCTION

### General case

UNDER CONSTRUCTION
