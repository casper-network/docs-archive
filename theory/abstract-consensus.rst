Abstract Casper Consensus
=========================

Introduction
------------

We are considering a collection of processes (**validators**) communicating over
a message-passing network. The goal they collectively pursue is to agree on
selecting a single value from a finite set :math:`C` we call the set of
**consensus values**. Once the agreement is achieved, the problem is solved and the processes can terminate.

The space of possible distributed algorithms fulfilling the mission as described above is probably immense. Therefore, we want to limit our attention only to a restricted family of such solutions. In doing so, we introduce several assumptions:

-  we set a very specific format of messages that validators exchange
-  we enforce some constraints on the behavior of validators
-  we expect certain guarantees from the message-oriented communication layer validators use

We call this restricted model **Abstract Casper Consensus (ACC)**.

We primarily see ACC as a definition of a problem to be solved. Solutions of this problem are going to be pairs :math:`<EST, FD>` -- where :math:`EST` is some estimator and :math:`FD` is some finality detector. The remainder of this document is mostly devoted to explaining in detail what **estimator** and **finality detector** really mean.

In CasperLabs we work with a diversity of **ACC** solutions. For us, an **ACC**
solution is what lives in the heart of a blockchain design. Different solutions
of an **ACC** problem lead to different blockchains.

**Note 1:** Be warned that ACC is NOT a blockchain. Abstract-consensus and
blockchain consensus are two separate problems. In the abstract consensus model
nodes talk to agree on a value and then they stop talking. In a blockchain model
nodes never stop talking because they want to keep extending the chain of
blocks forever. So, at some point they need to agree on adding yet another block
to the chain - this is where the ACC problem shows up and this is why we first
study this sub-problem in isolation. After having studied the sub-problem 
enough, we apply it in the wider context, i.e. building a
blockchain.

**Note 2**: As the target audience of this document is software developers; here
and there we add some pseudo-code snippets to illustrate the concepts with a
language closer to a developer’s perspective. This pseudo-code generally alludes
to Scala syntax, but is modified so that non-scala developers will be able to
follow the meaning.

The model
---------

Validators and their weights
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Validators are just processes (actors / applications / entities) able to do computing; communicating via message passing.

Every validator has a **weight** -- a non-zero integer value, and thought of as “the voting power of this validator”. In the context of proof-of-stake blockchains, this corresponds to the bonded stake.

::

   val validators: Map[Validator, Int]

Network
~~~~~~~

Validators are communicating over a network. We assume that all the communication stack layers taken together provide the following semantics:

1. Communication between validators is based on the “broadcast” principle: at any time, a validator can broadcast a message :math:`m`.
2. Once broadcast, the message :math:`m` will be eventually delivered to every validator in the network. The delivery will happen exactly once. The delivery delay may be of arbitrary length.

Given the assumptions above, it follows that the order of delivery may not coincide with the order of broadcasting, i.e. if a validator :math:`A` broadcasts message :math:`m_1` and later it  broadcasts message :math:`m_2`, and :math:`B` is another validator, then we cannot say anything certain about the order of receiving :math:`m_1` and :math:`m_2` by :math:`B`.

::

   interface GossipService {
     proc broadcast(message: Message)
   }

   interface Validator {
     proc handleMessageFromNetwork(message: Message)
   }

Messages
~~~~~~~~

We assume that every message contains the following information:

-  **message id** (= unique identifier for a message)
-  **creator id** (= id of validator that created this message)
-  **justifications** (= collection of message ids that the creator acknowledges as seen at the moment of creation of this message; may be empty)
-  **consensus value** (= a value this message is voting for; this value is optional; if not present then this message is voting for nothing)
-  **daglevel** (= an integer value)

We reference properties of message :math:`m` using dot notation, for example:

:math:`m.daglevel`

Daglevel is calculated in the following way:

-  if the list of justifications is empty: :math:`daglevel = 0`
-  otherwise: :math:`daglevel = \max (\text{daglevels of justifications}) + 1`

When validator :math:`v` creates and broadcasts a message with consensus value :math:`X`, we say that :math:`V` is voting for :math:`X`.

::

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

J-dag
~~~~~

Justifications are pointing to previously received messages. Let us consider any set of messages :math:`M` closed under taking justifications. Let us define the following directed graph:

-  take vertices to be all elements of :math:`M`;
-  take edges (= arrows) to be all pairs :math:`m_1 → m_2` such that :math:`m_2 \in m1.justifications`.

Such a graph is always acyclic because a cycle in this graph would mean
time-traveling is possible (i.e. we assume that listing a message as a justification is only possible if this message was first created).

We call any such structure **j-dag**. We generally assume that every validator maintains a (mutable) representation of **j-dag** reflecting the most up-to-date knowledge on the on-going consensus-establishing process. Observe that **j-dag** may be equivalently seen as a POSET because of the well-known equivalence between transitively closed DAGs and POSETs. When talking about consensus, the distinction between DAG-based and POSET-based languages is frequently blurred.

Please observe that for any message **m**, the collection :math:`m.justifications` determines a sub-dag of the **j-dag**.

In the context of any **j-dag** we introduce the following concepts:

-  **transitive justification of message** :math:`A`** is any message :math:`B` such that **j-dag** contains a path :math:`A → ... → B`; this naming reflects the fact that an arrow in **j-DAG** goes always from newer messages to older messages; in POSET lingo it translates to :math:`B < A`, and we specifically pick here the direction of the ordering relation to reflect the time flow, so :math:`B < A` because :math:`B` must be older than :math:`A` (= :math:`A` confirms that it saw :math:`B`)
-  **j-past-cone of block A** or shortly :math:`j\_past\_cone(A)` is the full subgraph of **j-dag** formed by taking all as vertices all transitive justifications of messages :math:`A`, plus the message :math:`A` itself; in POSET lingo it is just the set of all :math:`B` such that :math:`B <= A`
-  **swimlane of validator V** (or just **V-swimlane**) is: (1) take the transitive closure of **j-dag** (2) cut it to a subgraph by taking only messages created by V
-  **j-dag tip** is a message :math:`m` that is not a justification of any other message in **j-dag**; in POSET lingo it is just a maximal element in a **j-dag**
-  **panorama of message B** - for a validator :math:`V` cut **V-swimlane** down to vertices included in :math:`j-past-cone(B)`; the resulting subgraph of **V-swimlane** we will be calling **V-swimlane-cut-to-B**; now iterate over the collection of all validators, for every validator :math:`V_i` take all tips of :math:`V_i\_swimlane\_cut\_to\_B`; sum of such tips is what we want to call the :math:`panorama(B)`
-  **validator V is honest** if :math:`V\_swimlane` is a chain; in POSET language: :math:`V\_swimlane` is a linear order
-  **validator V is an equivocator** if V is not honest
-  **equivocation** is a proof that validator :math:`V` is not honest; in other words it is pair of messages :math:`A`, :math:`B`, both created by :math:`V`, such that :math:`A` is not a transitive justification of :math:`B` and **B** is not a transitive justification of :math:`A`
-  **latest message of a validator V** is a j-dag tip of **V-swimlane**; if :math:`V` is honest then it has at most one latest message
-  **latest message of validator Z that honest validator Y can see** is the following situation (notice we define it in the context of a local j-dag maintained by any validator V)

   -  both :math:`Y` and :math:`Z` are honest
   -  take :math:`m` = latest message of :math:`Y` (must be unique because :math:`Y` is honest)
   -  take the intersection of :math:`panorama(m)` and :math:`Z\_swimlane` - must contain at most one element, because :math:`Z` is honest - this is the “latest message” we are talking about

-  **honest validator Y can see a honest validator Z voting for consensus value P** is when latest message of validator :math:`Z` that validator :math:`Y` can see is voting for :math:`P`

::

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

Protocol states
~~~~~~~~~~~~~~~

Any set of messages closed under traversing via justifications is a j-dag. We typically use j-dags in two contexts:

-  when talking about the **local j-dag**, i.e. the data structure that a validator maintains to reflect the ever-growing knowledge about the on-going consensus
-  when talking about the universe of all-possible j-dags over a set :math:`M` of messages - this universe is an infinite POSET that has j-dags as elements and the ordering relation is set-inclusion, so **jdag1 <= jdag2 iff jdag1 \subset jdag2**.

From the point of view of pure mathematics, the local **j-dag** corresponds to a chain in the universe - on receiving some message, a validator updates its local j-dag, and the updated j-dag will then be a superset of the previous j-dag they have.

But historically, two different ways of talking about this situation emerged and both ways tend to be actually useful:

-  when talking about the universe, we prefer to speak about the **protocol states**; so a protocol state is a point in the universe of j-dags representing a set of messages closed under justifications
-  when talking implementation-wise, we tend to speak about j-dags, meaning “a DAG formed with messages and justifications”, because we frequently also have other DAGs around (also taking messages as vertices, but using other sets of edges).

So for a software engineer, a protocol state might well be seen as a snapshot of the **j-dag**.

When talking about the universe of protocol states, we usually use speak about the order of protocol states (= the inclusion relation) using the time flow metaphor. So for example, when :math:`ps_1` and :math:`ps_2` are protocol states and :math:`ps_1 < ps_2`, we say that :math:`ps_1` is earlier than :math:`ps_2`, or that :math:`ps_2` is “in the future of :math:`ps_1`”.

Lifecycle of a validator
~~~~~~~~~~~~~~~~~~~~~~~~

A validator continuously runs two activities:

-  listens to messages incoming from other validators, and on every incoming message, runs the finality detection algorithm to see if the consensus has already been reached (we explain finality detection in detail later in this document) 

- and (from time to time) decides to cast a vote by creating a new message :math:`m` and broadcasting it

A validator itself must decide when to create and broadcast new messages — this is what we call a **validator strategy.**

Estimator
~~~~~~~~~

Upon creation of a new message :math:`m`, a validator must decide what consensus value :math:`m` will vote for. We limit the freedom here by enforcing that the selected consensus value is constrained by a certain function called **estimator**. The assumption here is that an estimator is fixed upfront and used by all validators. This function is allowed to depend only on justifications of message :math:`m`, and it returns a subset of consensus values; when a validator makes a vote, it is allowed to:

-  either pick a value from the subset returned by the estimator
-  or pick :math:`None`, and so create a message voting for nothing

We can now rewrite the definition of Message class with this assumption applied:

::

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

The reference estimator
~~~~~~~~~~~~~~~~~~~~~~~

In fact, in all solutions considered so far by CasperLabs, we are reusing the
same pattern for estimators construction. The pattern assumes the set of
consensus values :math:`C` is totally ordered.

For a protocol state :math:`ps`, we calculate the estimator value in the following way:

-  if :math:`ps` is empty then the result is :math:`C`
-  otherwise - we apply the following algorithm:

   1. Take the collection of all honest validators in :math:`ps`.
   2. Restrict to collection of validators that created at least one message.
   3. For every validator - find its latest message with non-empty vote.
   4. Sum latest messages by weight - this will end up with a mapping :math:`total\_votes: C \to Int` - for every consensus value :math:`c` it returns the sum of weights of validators voting for :math:`c`.
   5. Find all points :math:`c \in C` such that :math:`total\_votes` has maximum value at :math:`c`.
   6. Using total order on :math:`C`, from elements found in the previous step pick maximum element :math:`cmax`.
   7. The result is one-element set :math:`{cmax}`.

Finality
--------

Equivocations
~~~~~~~~~~~~~

Finality cannot really be “absolute” because validators may cheat, i.e. they can violate “fair play”. There are 3 ways a validator can violate fair play:

1. Produce a malformed message.
2. Violate the condition that a message is allowed to vote on a value picked from what the estimator tells.
3. Equivocate.

Case (2) can really be considered a sub-case of (1), and (1) can be evaded by just assuming that validators reject malformed messages on reception. So, the only real problem comes from (3). Equivocations do break consensus and the intuition for this is clear - if everybody cheats by concurrently voting for different values, validators will never come up with a decision the value is finally agreed upon.

It may be not immediately obvious how equivocations are possible in the context of the estimator, which forces us to pick certain values. It is worth noticing that:

1. The essence of an equivocation is not about voting for different consensus values; it is about behaving in a “schizophrenic” way by pretending that “I have not seen my previous message”.
2. An Estimator returns a set, not a single value. When this set has size >0, it leaves some extra freedom.
3. Even if the size of the set returned by the estimator is actually 1, there is always a possibility to cast an empty vote. Voting for empty, vs voting for a value, is a freedom.
4. A Validator does not have to reveal all messages actually received. “Revealing” happens at the creation of new message by listing justifications of this message. It is legal to hide some knowledge here as long as a validator does this hiding in a consistent way (if I once admit I have seen message :math:`m`, I cannot un-admit this later).

Finality criteria
~~~~~~~~~~~~~~~~~

Because of equivocations, finality really means “consensus value :math:`c` being locked as long as the fraction of honest nodes is sufficiently high”. We typically express the “sufficiently high” part by introducing the concept of **faults tolerance threshold**, or **FTT** in short.

Finality criterion is a function :math:`fc: protocol\_states \times Int \to C \cup {EMPTY}`.

We interpret this function as providing the answer as to if the finality was achieved (and if yes, then which consensus value is finalized) given the following input data:

-  protocol state (so, a j-dag)
-  fault tolerance threshold (integer number)

And the result, if not empty, gives the “locked” consensus value that will be locked as long as the total weight of equivocators will not exceed **FTT**.

Finality theorems
~~~~~~~~~~~~~~~~~

Finality criterion is a strictly mathematical concept. To introduce new finality criterion, one has to:

1. Define suitable :math:`fc` function.
2. Prove the finality theorem for :math:`fc`.

On our way to CasperLabs blockchain, we expect to see a diversity of finality criteria to be discovered and used. As of September 2019 we have been working with 3 finality criteria (so far):

-  E-clique
-  The Inspector
-  Summit theory by Daniel Kane

For a protocol state :math:`ps`, let :math:`eq(ps)` denote the total weight of equivocators (so validators :math:`V` such that :math:`ps` includes an equivocation by :math:`V`).

A finality theorem for a criterion :math:`fc` says:

IF

-  :math:`ps` is some protocol state
-  :math:`FTT` is some integer value
-  :math:`c \in C`
-  :math:`fc(pc, FTT) = c`

THEN

-  :math:`estimator(ps) = {c}`

-  for every protocol state :math:`fps` such that :math:`PS \leqslant fps` and :math:`eq(fps) < eq (ps) + FTT` the following holds:

   -    :math:`estimator(fps) = {c}`

Finality detectors
~~~~~~~~~~~~~~~~~~

Finality criterion is a purely mathematical construct. On the software side, it will typically map to several different implementations. For example, in the case of “The Inspector” finality criterion, we currently have the following implementations (with more to come):

-  reference implementation (very simple but also quite slow)
-  single-sweep implementation (order of magnitude faster than reference implementation)
-  voting matrix (order of magnitude faster than single sweep, but limited to acknowledgement level 1)

Therefore, the distinction between finality criterion and a finality detector is quite important in practice.

The following code snippet shows the contract for incremental finality detectors that is used in our abstract consensus simulator:

::

   interface FinalityDetector {
     fun onNewMessageAddedToTheJDag(
       msg: Message,
       latestHonestMessages: ValidatorId => Option[Message]): Option[Commitee[C]]
   }

Of course, a convenient contract for finality detectors will typically be dependent on the exact shape of the surrounding software - usually because of various optimizations in place.

Calculating finality
--------------------

.. _introduction-1:

Introduction
~~~~~~~~~~~~

We describe here the criterion of finality known as “The summit theory”. A
**summit** is a situation in the j-dag when the finality of a certain consensus
value has been established.

This criterion has two parameters:

-  **ftt: Int** - “absolute” fault tolerance threshold (expressed as total weight)
-  **ack-level: Int** - acknowledgement level; an integer value bigger than zero

Visual notation
~~~~~~~~~~~~~~~

To understand the summit theory we developed a simulator and a visual notation.

This is how finality looks like:

.. figure:: pictures/finality-snapshot-2019-08-12T01-27-42-370.png
    :width: 80%
    :align: center

Rectangles on the left represent validators. Dots are messages. Displayed is the local j-dag of validator 0, arranged accordingly to j-daglevel (X-coordinate of a message corresponds to j-daglevel).

Swimlanes correspond to horizontal lines (a message is displayed with the Y-coordinate the same as its creator).

A color inside of a dot represents a consensus value this message is voting for.

Zero-level messages
~~~~~~~~~~~~~~~~~~~

Within a swimlane of an honest validator, **zero-level messages** are all messages since the last change of mind on the consensus value this validator was voting for (empty votes are not counting as change of mind).

**Example:** if the sequence of messages in the swimlane looks like this:

A, B, C, A, Empty, A, Empty, A, Empty, Empty

… then all messages starting from second “A” are zero-level.

In this case:

A, B, C, A, B, C

… zero-level is just the last message.

Quorum size
~~~~~~~~~~~

Quorum size is an integer value calculated as:

.. math::


   q = ceiling(\frac{1}{2}(\frac{ftt}{1-2^{-k}}+tw))

… where:

-  :math:`tw` - sum of weights of validators
-  :math:`k` - ack-level
-  :math:`ceiling` - is rounding towards positive infinity

1-level summit
~~~~~~~~~~~~~~

Let’s take a zero-level message :math:`m` and a subset of validators set :math:`S \subset V`.

Def: **0-support of message m in context S** is the set of validators :math:`v \in S` such that some zero-level message created by :math:`v` is in :math:`j\_past\_cone(m)`.

Def: **1-level message in context S** is a zero-level message :math:`m` such that the total weight of 0-support of :math:`m` is at least quorum size.

Def: **1-level summit with committee S** is a situation where :math:`S \subset V` is a subset of the validators set such that:

-  :math:`S` contains only honest nodes
-  every member of :math:`S` is a creator of at least one 1-level message in context S
-  total weight of validators in :math:`S` is at least quorum-size

**Example:**

Below is an example of 1-level summit for 8 validators (all having equal weights 1) with :math:`ftt=2`. Number of consensus values is 8.

Border of a message signals the following information:

-  black border: this is not 0-level message
-  red border: this is 0-level message
-  yellow border: this is 1-level message
-  dashed border: this message has not arrived yet to validator 0

Validators marked with green rectangles are members of the committee.

.. figure:: pictures/summit-1.png
    :width: 80%
    :align: center

K-level summit
~~~~~~~~~~~~~~

We recursively generalize the idea of 1-summit to arbitrary acknowledgement level. The parameter :math:`k` here corresponds to :math:`ack\_level`.

Def: **p-support of message m in context S** is the set of validators :math:`v \in S` such that some p-level message created by :math:`v` is in :math:`j\_past\_cone(m)`.

Def: **k-level message in context S** is a (k-1)-level message :math:`m` such that the total weight of 0-support of :math:`m` is at least quorum size.

Def: **k-level summit with committee S** is a situation where :math:`S \subset V` is a subset of the validators set such that:

-  there exists :math:`R \subset V` such that :math:`S \subset R` and we have (k-1)-summit at R
-  every member of :math:`S` is a creator of at least one k-level message in context S
-  total weight of the validators in :math:`S` is at least quorum-size

**Example:**

Below is an example of 1-level summit for 8 validators (all having equal weights 1) with :math:`ftt=2` and :math:`k=4`.

The Border of a message signals the following information:

-  black border: this is not 0-level message
-  red border: this is 0-level message
-  yellow border: this is 1-level message
-  green border: this is 2-level message
-  lime border: this is 3-level message
-  blue border: this is 4-level message
-  dashed border: this message has not arrived yet to validator 0

.. figure:: pictures/summit-2.png
    :width: 80%
    :align: center


