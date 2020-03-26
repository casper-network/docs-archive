Abstract Casper Consensus
=========================

Stating the problem
-------------------

We are considering a collection of processes (called here and later **validators**) - later referenced as
:math:`Validators` - communicating over a message-passing network. Every validator has a **weight** -- a non-zero
integer value thought of as “the voting power of this validator”.

The goal validators collectively pursue is to agree on selecting a single value from a finite set :math:`Con` we call
the set of **consensus values**. Once the agreement is achieved, the problem is solved and the processes terminate.

The resulting solution is not a blockchain yet. It is just a building block we later on use to design our blockchain.

Caution: we use **ACC** as the shortcut for **Abstract Casper Consensus**.


Network model
-------------

We assume fully asynchronous network model with delivery guarantee and the single primitive: `broadcast(m)`. Precisely
speaking:

1. Communication between validators is based on the “broadcast” primitive: at any time, a validator can broadcast a
   message :math:`m`.
2. Once broadcast, the message :math:`m` will be eventually delivered to every validator in the network. The delivery
   will happen exactly once. The delivery delay may be of arbitrary length.

Given the assumptions above, it follows that the order of delivery may not coincide with the order of broadcasting,
i.e. two messages :math:`m_1`, :math:`m_2` broadcast by a validator :math:`A` may be delivered to another validator
:math:`A` in different order than the broadcasting order.

.. code:: scala

    trait GossipService {
      def broadcast(message: BinaryMessage)
    }

    trait GossipHandler {
      def handleMessageReceivedFromNetwork(message: BinaryMessage)
    }


Messages
--------

Messages broadcast by validators have the following structure:

.. code:: scala

    class Message {
      val messageId: MessageId
      val creator: ValidatorId
      val justifications: Seq[MessageId]
      val consensusValue: Option[Con]
      val dagLevel: Int
    }

-  ``messageId: MessageId`` unique identifier (typically - hash of the message)
-  ``creator: Int`` id of the validator that created this message
-  ``justifications: Seq[MessageId]`` collection of message ids that the creator acknowledges as seen at the moment of
   creation of this message; this collection may possibly be empty
-  ``consensusValue: Option[Con]`` consensus value this message is voting for; the value is optional, because we allow
   empty votes
-  ``daglevel: Int`` height of this message in justifications DAG

When a validator :math:`V` creates and broadcasts a message with consensus value :math:`X`, we say that :math:`V` is
voting for :math:`X`.

J-dag
~~~~~

Justifications are pointing to previously received messages. Let us consider arbitrary set of messages :math:`M` closed
under taking justifications. We will define the following acyclic directed graph :math:`jDag(M)`:

-  vertices = all elements of :math:`M`;
-  edges = all pairs :math:`m_1 \rightarrow m_2` such that :math:`m_2 \in m_1.justifications`.

Why we claim this graph is acyclic ? Well, because a cycle in this graph would mean that either time-traveling is
possible or a validator managed to guess an id of some message before that message was actually created. Time-travelling
we preclude on the basis of physics, while guessing of future message id must be made close-to-impossible via smart
implementation of message identifiers (using message hash should be good enough).

We require that every validator maintains a representation of :math:`jDag(M)` reflecting the most up-to-date
knowledge on the on-going consensus-establishing process. Observe that :math:`jDag(M)` may be equivalently seen as
a POSET because of the well-known equivalence between transitively closed DAGs and POSETs. In the remainder of this
chapter we blur the difference :math:`jDag(M)` seen as a DAG and is transiive closure seen as a POSET.
We will use the relation symbols :math:`<` and :math:`\leqslant` for the implied partial order of :math:`jDag(M)`.

When :math:`m \in M`, we define :math:`jPastCone(m)` as :math:`\{x \in M: x \leqslant m \}`. Of course this is also
a DAG.

In the context of any :math:`jDag(M)` we introduce the following concepts:

**transitive justification of message m**
   is any message :math:`p` such that :math:`jDag(M)` contains a path :math:`m \rightarrow ...\rightarrow p`; this naming
   reflects the fact that an arrow in :math:`jDag(M)` goes always from newer messages to older messages; in POSET lingo
   it translates to :math:`p < m`, and we specifically pick here the direction of the ordering relation to reflect
   the time flow, so if :math:`p < m` then message :math:`m` confirms that it saw :math:`p`

**swimlane of validator v**
   or just :math:`swimlane(v,M)` is :math:`\{m \in M: m.creator = v\}`; of course, being a subset of :math:`jDag(M)`,
   :math:`swimlane(v,M)` is also a DAG and a POSET

**tip**
   is a maximal element in :math:`jDag(M)`; of course, being a POSET, :math:`jDag(M)` can contain more than one maximal
   element

**validator v is honest in M**
   if :math:`swimlane(v,M)` is empty or it is a nonempty chain; in POSET language in translates to :math:`swimlane(v,M)`
   being a (possibly empty) linear order

**validator v is an equivocator in M**
   if V is not honest in M

**equivocation by v**
   is a proof that validator :math:`v` is not honest; in other words it is a pair of messages :math:`a,b \in M`,
   both created by :math:`v`, such that :math:`\neg (a < b)` and :math:`\neg (b < a)`

**latest message of a validator v in M**
   is any tip in :math:`swimlane(v,M)`; if :math:`v` is honest in M then it has at most one latest message in M

**honest validators in M**
  :math:`\{v \in Validators: v \space is \space honest \space in \space M \}`

**honest panorama of message m**
   is a function :math:`panorama: HonestValidators(M) \rightarrow M`, :math:`panorama(v) =` *latest message of v in
   jPastCone(m)*

Operation of a validator
~~~~~~~~~~~~~~~~~~~~~~~~

We are using the following abstraction of mutable 2-argument relation:

.. code:: scala

    //Represents a mutable subset of cartesian product AxB
    //A is "source", B is "target"
    trait Relation[A,B] {
      def addPair(a: A, b: B): Unit
      def removePair(a: A, b: B): Unit
      def removeSource(a: A): Unit
      def removeTarget(b: B): Unit
      def containsPair(a: A, b: B): Boolean
      def findTargetsFor(source: A): Iterable[B]
      def findSourcesFor(target: B): Iterable[A]
      def hasSource(a: A): Boolean
      def hasTarget(b: B): Boolean
      def sources: Iterable[A]
      def targets: Iterable[B]
      def size: Int
      def isEmpty: Boolean
    }

... and directed acyclic graph:

.. code:: scala

    //Represents a mutable directed acyclic graph, i.e. a data structure composed of
    //vertices and directed edges. Edges are implicit. Source of vertex v is any
    //vertex s such that the graph contains edge s->v. Target of vertex v is any vertex t
    //such that the graph contains edge v->t.
    trait Dag[Vertex] {
      def targets(n: Vertex): Seq[Vertex]
      def sources(n: Vertex): Seq[Vertex]
      def contains(n: Vertex): Boolean
      def tips: Seq[Vertex]
      def insert(n: Vertex): Boolean
      def toposortTraverseFrom(n: Vertex): Iterator[Vertex]
    }

During its lifetime, a validator maintains the following state:

.. code:: scala

    //A participant of Abstract Casper Consensus protocol
    class Validator extends GossipHandler {
      val id: ValidatorId
      val preferredConsensusValue: Con
      val messagesBuffer: Relation[Message, MessageId]
      val jdagGraph: Dag[Message]
      val jdagMessagesIds: Set[MessageId]
      val latestHonestMessages: Map[ValidatorId,Message]
      val equivocators: Set[ValidatorId]
      val weightsOfValidators: Map[ValidatorId, Int]
      val finalizer: Finalizer
      val gossipService: GossipService
    }

-  ``messagesBuffer: Relation[Message,MessageId]`` - a buffer of messages received, but not incorporated into ``jdag`` yet;
   a pair :math:`(m,j)` in this relation represents buffered message :math:`m` waiting for not-yet-received message
   with id :math:`j`
-  ``jdagGraph`` - representation of :math:`jDag(M)`, where :math:`M` is the set of all messages known, such that
   their dependencies are fulfilled; in other words, before a message :math:`m` can be added to ``jdag``, all
   justifications of :math:`m` must be already present in ``jdag``
-  ``latestHonestMessages: Map[ValidatorId -> Message]`` - a map keeping swimlane tip for every honest validator
-  ``equivocators`` - collection of equivocators visible in ``jdag``
-  ``weightsOfValidators: Map[ValidatorId, Int]`` - weights of validators
-  ``finalizer: Finalizer`` - finality detector
-  ``gossipService: GossipService`` - communication layer API used to broadcast messages

A validator continuously runs two activities:

- **listening loop** - handling messages arriving from the network
- **publishing loop** - creating and broadcasting new messages

The pseudocode below explains detailed working of listening loop and publishing loop.

.. code:: scala

    //A participant of Abstract Casper Consensus protocol
    class Validator extends GossipHandler {
      val id: ValidatorId
      val preferredConsensusValue: Con
      val messagesBuffer: Relation[Message, MessageId]
      val jdagGraph: Dag[Message]
      val jdagMessagesIds: Set[MessageId]
      val latestHonestMessages: Map[ValidatorId,Message]
      val equivocators: Set[ValidatorId]
      val weightsOfValidators: Map[ValidatorId, Int]
      val finalizer: Finalizer
      val gossipService: GossipService

      //logic of listening loop
      def handleMessageReceivedFromNetwork(bm: BinaryMessage): HandlerResult = {
        val validationResult: Boolean = validateFormalStructureOfMessageAndCheckSignature(bm)
        if (validationResult == MessageValidationResult.ERROR)
          return HandlerResult.InvalidMessage

        if (jdagMessageIds containsAll message.justifications)
          runBufferPruningCascadeFor(message)
        else {
          val missingDependencies = message.justifications.filter(j => ! jdagMessageIds.contains(j))
          for (j <- missingDependencies)
            messagesBuffer.addPair(message,j)
        }

        return HandlerResult.Accepted
      }

      def runBufferPruningCascadeFor(message: Message): Unit = {
        val queue = new Queue[Message]()
        queue enqueue message

        while (queue.nonEmpty) {
          val nextMsg = queue.dequeue()
          if (! jdagMessagesIds.contains(nextMsg.id)) {
            addToLocalJdag(nextMsg)
            val waitingForThisOne = messagesBuffer.findSourcesFor(nextMsg.id)
            messagesBuffer.removeTarget(nextMsg.id)
            val unblockedMessages = waitingForThisOne.filterNot(b => messagesBuffer.hasSource(b))
            queue enqueueAll unblockedMessages
          }
        }
      }

      def addToLocalJdag(msg: Message): Unit = {
        if (!equivocators.contains(msg.creator) && checkIfIntroducesAnEquivocation(msg)) {
          equivocators.add(msg.creator)
          latestHonestMessages remove msg.creator
        }
        jdagGraph insert msg
        jdagMessagesIds add msg.id
        if (! equivocators(msg.creator))
          latestHonestMessages add (msg.creator -> msg)

        finalizer.runFinalityDetection(msg)
      }

      def checkIfIntroducesAnEquivocation(msg: Message): Boolean = {
        latestHonestMessages(msg.creator) match {
          case None =>
            false // first message arriving from this validator, so it cannot be an equivocation
          case Some(tip) => //tip of the swimlane
            if (msg.justifications.contains(tip))
              false
            else {
              val toposortIteratorOfJPastCone = jdagGraph.toposortTraverseFrom(msg)
              val decisionPointBlockOption: Option[Message] = toposortIteratorOfJPastCone
                     .find(m => m == tip || m.dagLevel < tip.dagLevel)

          return decisionPointBlock == None || decisionPointBlock.get != tip
        }

      def shouldCurrentVoteBeEmpty(): Boolean

      def estimator(collectionOfMessagesByNonEquivocators: Collection[Message]): Int = {
        val conValueToCollOfVotingMessages =
          collectionOfMessagesByNonEquivocators.groupBy(m => m.consensusValue)
        val summingOfVotes: Collection[Message] => Int = {
          coll => coll.map(m => weightsOfValidators(b.creator)).sum
        }
        val pairsConsensusValueToTotalWeightOfVotes =
          conValueToCollOfVotingMessages map { (consensusValue, collectionOfMessages) =>
            consensusValue -> summingOfVotes(collectionOfMessages)}

        //if weights are the same, we pick the bigger consensus value
        //tuples (w,c) are ordered lexicographically, so first weight of votes decides
        //if weights are the same, we pick the bigger consensus value
        //total ordering of consensus values is implicitly assumed here
        val (winnerConsensusValue, winnerTotalWeight) = pairsConsensusToTotalWeight maxBy { case (c,w) => (w, c) }
        return winnerConsensusValue
      }

      //logic of publishing loop
      def publishNewMessage(): Unit = {
        val msg = createNewMessage()
        addToLocalJdag(msg)
        gossipService.broadcast(msg)
      }

      def createNewMessage(): Message =
        new Message {
          val creator = id
          val justifications = jdagGraph.tips map (t => t.id)
          val consensusValue =
            if (shouldCurrentVoteBeEmpty())
              None
            else
              if (justifications.isEmpty)
                Some(preferredConsensusValue)
              else
                Some(estimator(latestHonestMessages.values))
        }

    }

**Listening loop** is implicit - we assume that as soon as a message arrives from the network, method
``Validator.handleMessageReceivedFromNetwork()`` is invoked. What happens is roughly:

  1. Message is formally validated.
  2. Message is either buffered or added to the ``jdag`` - depending on whether its justifications have already arrived.
  3. ``latestHonestMessages`` map is updated to reflect the updated swimlane.
  4. Jdag is analyzed for new message possibly introducing an equivocation of so-far-honest validator (and if
     yes - ``equivocators`` collection is updated accordingly)
  5. Finalizer state is updated (see below for the explanation how finalizer works).
  6. Steps 3..5 are repeated as long as adding last message to ``jdag`` unblocks some messages waiting in the buffer.

**Publishing loop** is also implicit - we do not determine when exactly a validator decides to create and broadcast
a new message. This is pluggable part of ACC. As soon as a validator, following its publishing strategy, decides to
publish a message, it calls ``Validator.publishNewMessage()``. What happens is roughly:

  (fork choice)




Listen to messages incoming from other validators. Whenever a message :math:`m` arrives, follow this handling scenario:

1. Validate the formal structure of :math:`m`. In case of any error - drop :math:`m` (invalid message) and exit.
2. Check if all justifications of :math:`m` are already included in ``jdag``.
  1. if yes: continue
  2. otherwise: append :math:`m` to the :math:`messages\_buffer`, then exit




A validator continuously runs two activities:

-  listens to messages incoming from other validators, and on every incoming message, runs the finality detection
   algorithm to see if the consensus has already been reached (we explain finality detection in detail later in this
   document)

-  (from time to time) decides to cast a vote by creating a new message :math:`m` and broadcasting it

A validator itself must decide when to create and broadcast new messages — this is what we call
a **validator strategy.**

Estimator
~~~~~~~~~

Upon creation of a new message :math:`m`, a validator must decide what consensus value :math:`m` will vote for. We limit
the freedom here by enforcing that the selected consensus value is constrained by a certain function called
**estimator**. The assumption here is that an estimator is fixed upfront and used by all validators. This function is
allowed to depend only on justifications of message :math:`m`, and it returns a subset of consensus values; when
a validator makes a vote, it is allowed to:

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

In fact, in all solutions considered so far by CasperLabs, we are reusing the same pattern for estimators construction.
The pattern assumes the set of consensus values :math:`C` is totally ordered.

For a protocol state :math:`ps`, we calculate the estimator value in the following way:

-  if :math:`ps` is empty then the result is :math:`C`
-  otherwise - we apply the following algorithm:

   1. Take the collection of all honest validators in :math:`ps`.
   2. Restrict to collection of validators that created at least one message.
   3. For every validator - find its latest message with non-empty vote.
   4. Sum latest messages by weight - this will end up with a mapping :math:`total\_votes: C \to Int` - for every
      consensus value :math:`c` it returns the sum of weights of validators voting for :math:`c`.
   5. Find all points :math:`c \in C` such that :math:`total\_votes` has maximum value at :math:`c`.
   6. Using total order on :math:`C`, from elements found in the previous step pick maximum element :math:`cmax`.
   7. The result is one-element set :math:`{cmax}`.

Finality
--------

Equivocations
~~~~~~~~~~~~~

Finality cannot really be “absolute” because validators may cheat, i.e. they can violate “fair play”. There are 3 ways
a validator can violate fair play:

1. Produce a malformed message.
2. Violate the condition that a message is allowed a vote on a value picked from what the estimator tells.
3. Equivocate.

Case (2) can really be considered a sub-case of (1), and (1) can be evaded by just assuming that validators reject
malformed messages on reception. So, the only real problem comes from (3). Equivocations do break consensus and the
intuition for this is clear - if everybody cheats by concurrently voting for different values, validators will never
come up with a decision the value is finally agreed upon.

It may be not immediately obvious how equivocations are possible in the context of the estimator, which forces us to
pick certain values. It is worth noticing that:

1. The essence of an equivocation is not about voting for different consensus values; it is about behaving in
a “schizophrenic” way by pretending that “I have not seen my previous message”.
2. An Estimator returns a set, not a single value. When this set has size >0, it leaves some extra freedom.
3. Even if the size of the set returned by the estimator is actually 1, there is always a possibility to cast an empty vote. Voting for empty, vs voting
 for a value, is a freedom.
4. A Validator does not have to reveal all messages actually received. “Revealing” happens at the creation of new
message by listing justifications of this message. It is legal to hide some knowledge here as long as a validator does
this hiding in a consistent way (if I once admit I have seen message :math:`m`, I cannot un-admit this later).

Finality criteria
~~~~~~~~~~~~~~~~~

Because of equivocations, finality really means “consensus value :math:`c` being locked as long as the fraction
of honest nodes is sufficiently high”. We typically express the “sufficiently high” part by introducing the concept
of **faults tolerance threshold**, or **FTT** in short.

Finality criterion is a function :math:`fc: protocol\_states \times Int \to C \cup {EMPTY}`.

We interpret this function as providing the answer as to if the finality was achieved (and if yes, then which consensus
value is finalized) given the following input data:

-  protocol state (so, a j-dag)
-  fault tolerance threshold (integer number)

And the result, if not empty, gives the “locked” consensus value that will be locked as long as the total weight of
equivocators will not exceed **FTT**.

Finality theorems
~~~~~~~~~~~~~~~~~

Finality criterion is a strictly mathematical concept. To introduce new finality criterion, one has to:

1. Define suitable :math:`fc` function.
2. Prove the finality theorem for :math:`fc`.

On our way to CasperLabs blockchain, we expect to see a diversity of finality criteria to be discovered and used.
As of March 2020 we have been working with 3 finality criteria (so far):

-  E-clique
-  The Inspector
-  Summit theory by Daniel Kane

For a protocol state :math:`ps`, let :math:`eq(ps)` denote the total weight of equivocators (so validators :math:`V`
such that :math:`ps` includes an equivocation by :math:`V`).

A finality theorem for a criterion :math:`fc` says:

IF

-  :math:`ps` is some protocol state
-  :math:`FTT` is some integer value
-  :math:`c \in C`
-  :math:`fc(pc, FTT) = c`

THEN

-  :math:`estimator(ps) = {c}`

-  for every protocol state :math:`fps` such that :math:`PS \leqslant fps` and :math:`eq(fps) < eq (ps) + FTT` the
   following holds:

   -    :math:`estimator(fps) = {c}`

Finality detectors
~~~~~~~~~~~~~~~~~~

Finality criterion is a purely mathematical construct. On the software side,
it will typically map to several different implementations. For example, in
the case of “The Inspector” finality criterion, we currently have the
following implementations (with more to come):

-  reference implementation (very simple but also quite slow)
-  single-sweep implementation (order of magnitude faster than reference
implementation)
-  voting matrix (order of magnitude faster than single sweep, but limited to
 acknowledgement level 1)

Therefore, the distinction between finality criterion and a finality detector
 is quite important in practice.

The following code snippet shows the contract for incremental finality
detectors that is used in our abstract consensus simulator:

::

   interface FinalityDetector {
     fun onNewMessageAddedToTheJDag(
       msg: Message,
       latestHonestMessages: ValidatorId => Option[Message]): Option[Commitee[C]]
   }

Of course, a convenient contract for finality detectors will typically be
dependent on the exact shape of the surrounding software - usually because of
 various optimizations in place.

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

Rectangles on the left represent validators. Dots are messages. Displayed is
the local j-dag of validator 0, arranged accordingly to j-daglevel
(X-coordinate of a message corresponds to j-daglevel).

Swimlanes correspond to horizontal lines (a message is displayed with the
Y-coordinate the same as its creator).

A color inside of a dot represents a consensus value this message is voting for.

Zero-level messages
~~~~~~~~~~~~~~~~~~~

Within a swimlane of an honest validator, **zero-level messages** are all
messages since the last change of mind on the consensus value this validator
was voting for (empty votes are not counting as change of mind).

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


   q = ceiling\left(\frac{1}{2}\left(\frac{ftt}{1-2^{-k}}+tw\right)\right)

… where:

-  :math:`tw` - sum of weights of validators
-  :math:`k` - ack-level
-  :math:`ceiling` - is rounding towards positive infinity

1-level summit
~~~~~~~~~~~~~~

Let’s take a zero-level message :math:`m` and a subset of validators set
:math:`S \subset V`.

Def: **0-support of message m in context S** is the set of validators
:math:`v \in S` such that some zero-level message created by :math:`v` is in
:math:`j\_past\_cone(m)`.

Def: **1-level message in context S** is a zero-level message :math:`m` such
that the total weight of 0-support of :math:`m` is at least quorum size.

Def: **1-level summit with committee S** is a situation where :math:`S
\subset V` is a subset of the validators set such that:

-  :math:`S` contains only honest nodes
-  every member of :math:`S` is a creator of at least one 1-level message in
context S
-  total weight of validators in :math:`S` is at least quorum-size

**Example:**

Below is an example of 1-level summit for 8 validators (all having equal
weights 1) with :math:`ftt=2`. Number of consensus values is 8.

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

We recursively generalize the idea of 1-summit to arbitrary acknowledgement
level. The parameter :math:`k` here corresponds to :math:`ack\_level`.

Def: **p-support of message m in context S** is the set of validators
:math:`v \in S` such that some p-level message created by :math:`v` is in :math:`j\_past\_cone(m)`.

Def: **k-level message in context S** is a (k-1)-level message :math:`m` such
 that the total weight of 0-support of :math:`m` is at least quorum size.

Def: **k-level summit with committee S** is a situation where :math:`S
\subset V` is a subset of the validators set such that:

-  there exists :math:`R \subset V` such that :math:`S \subset R` and we have (k-1)-summit at R
-  every member of :math:`S` is a creator of at least one k-level message in context S
-  total weight of the validators in :math:`S` is at least quorum-size

**Example:**

Below is an example of 1-level summit for 8 validators (all having equal
weights 1) with :math:`ftt=2` and :math:`k=4`.

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


