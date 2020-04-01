Abstract Casper Consensus
=========================

Stating the problem
-------------------

We are considering a collection of processes - **validators** - communicating over a message-passing network. Every
validator has a **weight** -- a non-zero integer value representing the "voting power".

The goal validators collectively pursue is to pick a single value from a finite set :math:`Con` we call
the set of **consensus values**. Once the agreement is achieved, the problem is considered solved (i.e. validators
terminate their operation).

The resulting solution of this problem is not a blockchain yet. It is however a core building block of our blockchain
design. The way abstract consensus is used for building a blockchain is explained in subsequent chapers.

Caution: we use **ACC** as the shortcut for **Abstract Casper Consensus**.


Network model
-------------

We assume a fully asynchronous network model with delivery guarantee and a single primitive: `broadcast(m)`. Precisely
speaking:

1. Communication between validators is based on the “broadcast” primitive: at any time, a validator can broadcast a
   message :math:`m`.
2. Once broadcast, the message :math:`m` will be eventually delivered to every other validator in the network. The
   delivery will happen exactly once but with arbitrary delay.

Given the assumptions above, it follows that the order of delivery generally is not going to be preserved. In other
words when a validator :math:`A` broadcast sequence of messages :math:`(m_1, m_2, ... m_k)` then another validator
:math:`B` will receive all the messages in the sequence, but with delivery chronology following arbitrary permutation
:math:`p:(1,..,k) \rightarrow (1,..,k)`, i.e. :math:`(m_{p(1)}, m_{p(2)}, ... m_{p(k)})`.

Messages
--------

All the messages broadcast by validators have the same structure. Every message :math:`m`:

- has unique identifier - :math:`m.id`
- includes the identifier of the validator who created :math:`m.creator`
- references messages the creator confirms as seen at the moment of creating :math:`m` - we call this list
  "justifications" - :math:`m.justifications`
- points to the consensus value that creator is voting for - :math:`m.consensusValue`
- is cryptographically signed by the creator

The consensus value included in the message is however optional - it is OK to broadcast an "empty vote" message. The
semantics of such empty vote is "I support my previous vote, unchanged". If the previous vote is empty, it counts
as "vote for nothing".

J-dag
-----

Let us consider arbitrary set of messages :math:`M` closed under taking justifications, i.e. for every :math:`m \in M`
justifications referenced in :math:`m` also belong to :math:`M`. We will define the following acyclic directed graph
:math:`jDag(M)`:

-  vertices = all elements of :math:`M`;
-  edges = all pairs :math:`m_1 \rightarrow m_2` such that :math:`m_2 \in m_1.justifications`.

Why we claim this graph is acyclic ? Well, because a cycle in this graph would mean that either time-traveling is
possible or a validator managed to guess an id of some message before that message was actually created. Time-travelling
we preclude on the basis of physics, while guessing of future message id must be made close-to-impossible via smart
implementation of message identifiers (using message hash should be good enough).

We require that every validator maintains a representation of :math:`jDag(M)` reflecting the most up to date
knowledge on the on going consensus establishing process. Observe that :math:`jDag(M)` may be equivalently seen as
a POSET because of the well-known equivalence between transitively closed DAGs and POSETs. In the remainder of this
chapter we blur the difference :math:`jDag(M)` seen as a DAG and is transitive closure seen as a POSET.
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

Validity conditions
-------------------

On reception of a message, every validator must check certain conditions. Messages not compliant with these conditions
are considered invalid and hence ignored.

Formal validation is:

- message must be correctly structured, following the transport (= binary) representation
- checking of the cryptographic signature of message creator

Semantic validation is:

- consensus value :math:`m.consensusValue` must be compliant with applying the estimator to :math:`jPastCone(m)`
- justifications :math:`m.justifications` must reference messages belonging to distinct swimlanes,
  i.e. if :math:`j_1`, :math:`j_2` are two justifications in :math:`m`, then :math:`creator(j_1) \ne creator(j_2)`

We explain the concept of "estimator" later in this chapter.

Operation of a validator
------------------------

A validator continuously runs two activities:

- **listening loop** - handling messages arriving from the network
- **publishing loop** - creating and broadcasting new messages

**Listening loop**

When a message :math:`m` arrived:

  1. Formal validation of :math:`m` is performed.
  2. If :math:`m.justifications` are already present in the local representation of jdag then:

     - semantic validation of :math:`m` is performed
     - :math:`m` is added to the jdag

     otherwise:

     - :math:`m` is added to the messages buffer, where it waits until all justifications it references are present
       in the jdag

On every message added to the local j-dag:

  1. Messages buffer is checked for messages that have now all justifications present in the jdag and so can be removed
     from the buffer.
  2. Finality detector analyzes local jdag to check if the consensus has already been reached.

**Publishing loop**

We do not determine when exactly a validator decides to create and broadcast a new message. This is pluggable part
of ACC. As soon as a validator, following its publishing strategy, decides to publish a message, it builds a new
message with:

- justifications set to tips of all swimlanes, according to local jdag; in case of equivocators, i.e. when the
  corresponding swimlane has more than one tip - validator picks just one tip (any)
- consensus value determined by estimator, as applied to the justifications

Estimator
---------

Upon creation of a new message :math:`m`, a validator must decide what consensus value :math:`m` will vote for. We limit
the freedom here by enforcing that the selected consensus value is constrained by a certain function called
**estimator**. This function depends only on justifications of message :math:`m`, and it returns a single consensus
value. Estimator value is however not defined for an empty list of justifications.

When a validator makes a vote, it is allowed to:

-  either pick a value from the subset returned by the estimator
-  or pick :math:`None`, and so create an empty vote

Caution: For defining the estimator we need the set of consensus values :math:`Con` to be totally ordered.

For a set of justifications :math:`J`, we calculate the estimator value in the following way:

  1. Take :math:`CJ` a smallest transitive closure of :math:`J`
  2. Take the collection of all honest validators in :math:`CJ`.
  3. Restrict to collection of validators that created at least one message.
  4. For every validator - find its latest message with non-empty vote.
  5. Sum latest messages by weight - this will end up with a mapping :math:`tv: Con \to Int` - for every
     consensus value :math:`c` it returns the sum of weights of validators voting for :math:`c`.
  6. Find all points :math:`c \in Con` such that :math:`tv` has maximum value at :math:`c`.
  7. Using total order on :math:`Con`, from elements found in the previous step pick maximum element :math:`cmax`.
  8. The result is :math:`cmax`.

The concept of finality
-----------------------

When the consensus is reached
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A validator :math:`v` analyzes its local jdag to observe a value :math:`c \in Con` getting "locked" in the following
sense:

- from now on, the estimator applied to jdag tips seen by :math:`v` will always return :math:`c`
- this will happen as well for other validators (eventually)

We call such a situation by saying that **consensus value is now finalized**, so the consensus was reached.
Unfortunately, above definition is not useful enough and needs to be adjusted, what we explain below.

Malicious validators
~~~~~~~~~~~~~~~~~~~~

In general - malicious validators can stop consensus from happening. We need to adjust the concept of finalization
so to account for this problem.

In general there are 4 ways a validator can expose malicious behaviour:

1. Be silent (= stop producing messages)
2. Produce malformed messages.
3. Violate the condition that a message must vote on a value derived from justifications via the estimator.
4. Equivocate.

Case (3) can really be considered a sub-case of (2), and (2) can be evaded by just assuming that validators reject
malformed messages on reception.

So, the only real problems come from (1) and (4).

Problem (1) is something we are not addressing within ACC.

Problem (4) is something we control explicitly in the finality calculation.

Closer look at equivocations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Equivocations do break consensus. Intuition for this is clear - if everybody cheats by concurrently voting for
different values, validators will never come up with a decision the value is finally agreed upon.

It may be not immediately obvious how equivocations are possible in the context of the rule that the estimator function.
It is worth noticing that:

1. The essence of an equivocation is not about voting for different consensus values; it is about behaving in
   a “schizophrenic” way by pretending that “I have not seen my previous message”.
2. A Validator does not have to reveal all messages actually received. “Revealing” happens at the creation of new
   message by listing justifications of this message. The protocol does not prevent a validator from hiding this
   knowledge.
3. Technically, to create an equivocation is very easy - all one have to do is to create a branch in the swimlane.
   Such a branch is created every time when for a message :math:`m` its transitive justifications :math:`jPastCone(m)`
   do not include previous message by :math:`m.creator`.

Finality criteria
~~~~~~~~~~~~~~~~~

Let :math:`\mathcal{M}` be the set of all possible formally correct messages. Let :math:`Snapshots(\mathcal{M})`
be the set of all justifications-closed subsets of :math:`\mathcal{M}`.

Because of equivocations, finality really means “consensus value :math:`c` being locked as long as the fraction
of honest nodes is sufficiently high”. We express the “sufficiently high” part by introducing the concept
of **faults tolerance threshold**, or **FTT** in short. This leads us to the improved definition of finality:

A value :math:`c \in Con` is finalized in a snapshot :math:`S \in Snapshots(\mathcal{M})` with fault tolerance :math:`t`
if:

1. :math:`Estimator(S) = c`
2. For every snapshot :math:`S \in Snapshots(\mathcal{M})` such that :math:`S \subset R` one of the following is true:

  - :math:`Estimator(R) = c`
  - total weights of equivocators visible in :math:`R` is bigger than :math:`t`

**Finality criterion** is any function :math:`fc: Snapshots(\mathcal{M}) \times Int \to C \cup {EMPTY}` such that if
:math:`fc(S,t) = c` then :math:`c` is finalized in :math:`S` with fault tolerance :math:`t`.

Intuitively, finality is something that is easy to define mathematically but potentially hard to discover by an
efficient calculation. Therefore in general we discuss various finality criteria, which are approximations of finality.
Finality criteria may differ by sensitivity (= how they are not overlooking existing finality) and computational
efficacy.

Calculating finality
--------------------

Introduction
~~~~~~~~~~~~

We describe here the criterion of finality codenamed “Summit theory ver 2”. This criterion has two parameters:

-  **ftt: Int** - “absolute” fault tolerance threshold (expressed as total weight)
-  **ack-level: Int** - acknowledgement level; an integer value bigger than zero

Visual notation
~~~~~~~~~~~~~~~

To investigate the summit theory we developed a simulator and a visual notation.

This is how finality looks like:

.. figure:: pictures/finality-snapshot-2019-08-12T01-27-42-370.png
    :width: 100%
    :align: center

Rectangles on the left represent validators. Dots are messages. Displayed is the local j-dag of validator 0, arranged
accordingly to j-daglevel (X-coordinate of a message corresponds to j-daglevel). Swimlanes correspond to horizontal
lines (a message is displayed with the Y-coordinate the same as its creator).

The color inside of a dot represents the consensus value given message is voting for. The color of the dot's border
represents the so called "confirmation level" (explained below).

Zero-level messages
~~~~~~~~~~~~~~~~~~~

Within a swimlane of an honest validator, **zero-level messages** are all messages since the last change of mind
on the consensus value this validator was voting for (empty votes are not counting as change of mind).

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

** ################## THIS SECTION IS UNDER CONSTRUCTION #################### **

Let’s take a zero-level message :math:`m` and a subset of validators set :math:`S \subset V`.

Def: **0-support of message m in context S** is the set of validators :math:`v \in S` such that some zero-level message
created by :math:`v` is in :math:`j\_past\_cone(m)`.

Def: **1-level message in context S** is a zero-level message :math:`m` such that the total weight of 0-support
of :math:`m` is at least quorum size.

Def: **1-level summit with committee S** is a situation where :math:`S \subset V` is a subset of the validators set such
that:

-  :math:`S` contains only honest nodes
-  every member of :math:`S` is a creator of at least one 1-level message in context S
-  total weight of validators in :math:`S` is at least quorum-size

**Example:**

Below is an example of 1-level summit for 8 validators (all having equal weights 1) with :math:`ftt=2`. Number of
consensus values is 8.

Border of a message signals the following information:

-  black border: this is not 0-level message
-  red border: this is 0-level message
-  yellow border: this is 1-level message
-  dashed border: this message has not arrived yet to validator 0

Validators marked with green rectangles are members of the committee.

.. figure:: pictures/summit-1.png
    :width: 100%
    :align: center

K-level summit
~~~~~~~~~~~~~~

** ################## THIS SECTION IS UNDER CONSTRUCTION #################### **

We recursively generalize the idea of 1-summit to arbitrary acknowledgement level. The parameter :math:`k` here
corresponds to :math:`ack\_level`.

Def: **p-support of message m in context S** is the set of all validators :math:`v \in S` such that some p-level message
created by :math:`v` is in :math:`j\_past\_cone(m)`.

Definition: **k-level message in context S** is a (k-1)-level message :math:`m` such that the total weight of 0-support
of :math:`m` is at least quorum size.

Definition: **k-level summit with committee S** is a situation where :math:`S \subset V` is a subset of the validators
set such that:

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
    :width: 100%
    :align: center

Reference implementation
------------------------

In this section we sketch a "reference" implementation of Abstract Casper Consensus. We use Scala syntax for the code,
but we limit ourselves to elementary language features (so it is readable for any developer familiar with contemporary
programming languages).

Scala primer for non-scala developers:

.. code:: scala

    //value declaration (= constant)
    val localValidatorId: ValidatorId

    //variable declaration (a valued can be assigned to a variable many times)
    val localValidatorId: ValidatorId

    //method declaration
    def containsPair(a: A, b: B): Boolean

    //special type Unit contains only one value, so it is used to signal that a function returns nothing of interest
    def addPair(a: A, b: B): Unit

    //class declaration
    class Person {
      var name: String
      var dateOfBirth: Date
    }

    //class with immutable values
    case class Person(
        name: String,
        dateOfBirth: Date
    )

    //standalone object
    object PersonsManager {
      def findPersonById(id: Int): Option[Person]
      def currentNumberOfPersons: Int
    }

    //interface declaration
    trait Sizeable {
      def size: Int
      def isEmpty: Boolean
    }

    //this is a tuple
    (1,"foo",true)

    //this is convenience notation for 2-tuples; equivalent to (1, "foo")
    1 -> "foo"

    //a loop iterating over a collection of messages
    for (m <- messages)
      println(message.id)

    //a type of functions from ValidatorId to Message
    val panorama: ValidatorId => Message

    //cartesian product of types; means Int x String
    type Prod = (Int,String)

    //a function instance
    val add: (Int,Int) => Int = ((x,y) => x+y)

    //optional values
    val a: Option[Int] = None
    val b: Option[String] = Some("foo")

    //pattern matching
    x match {
      case None => println("1")
      case Some(p) => println(p)
    }

    //transforming a sequence by applying given function to every element
    val coll: Seq[Int] = Seq(1,2,3,4,5)
    val mapped1 = coll.map(n => n*n)
    val mapped2 = coll map (n => n*n) //equivalent, but without a dot

    //transforming a map by applying given function to every element
    val coll: Map[Int,String] = Map(1->"this", 2->"is", 3->"example")
    val mapped: Map[Int,Int] = coll map {case (k,v) => (k*k, v.length)}

Common abstractions
~~~~~~~~~~~~~~~~~~~

We use the following type aliases:

.. code:: scala

    type ValidatorId = Long
    type MessageId = Hash
    type Con = Int
    type BinaryMessage = Array[Byte]
    type Weight = Long

We are using the following abstraction of mutable 2-argument relation:

.. code:: scala

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

    trait Dag[Vertex] {

      /**
       * Returns targets reachable (in one step) from given vertex by going along the arrows.
       * @param v vertex
       * @return collection of vertices
       */
      def targets(v: Vertex): Iterable[Vertex]

      /**
       * Returns sources reachable (in one step) from given vertex by going against the arrows.
       * @param v vertex
       * @return collection of vertices
       */
      def sources(v: Vertex): Iterable[Vertex]

      /**
       * Returns true if given vertex is a member of this DAG.
       * @param v vertex
       * @return true if this DAG contains vertex
       */
      def contains(v: Vertex): Boolean

      /**
       * List of nodes which are only sources, but not targets,
       * i.e. nodes with only outgoing arrows and no incoming arrows.
       * @return list of nodes which are only sources.
       */
      def tips: Iterable[Vertex]

      /**
       * Add a new node to the DAG.
       * Sources and targets of this node must be inferred (so we assume that this information is somehow encoded
       * inside the vertex itself).
       * @param v new vertex to be added; targets of v must be already present in the DAG
       * @return true if the vertex was actually added, false if the vertex was already present in the DAG
       */
      def insert(v: Vertex): Boolean

      /**
       * Traverses the DAG (breadth-first-search) along the arrows.
       * @param v vertex from which we start the traversal
       * @return iterator of vertices, sorted by dagLevel (descending)
       */
      def toposortTraverseFrom(v: Vertex): Iterator[Vertex]

      /**
       * Traverses the DAG (breadth-first-search) along the arrows.
       * @param coll collection of vertices from which we start the traversal
       * @return iterator of vertices, sorted by dagLevel (descending)
       */
      def toposortTraverseFrom(coll: Iterable[Vertex]): Iterator[Vertex]

    }

We say nothing about hashing in use, we just assume that hashes can be seen as binary arrays:

.. code:: scala

    trait Hash extends Ordered[Hash] {
      def bytes: Array[Byte]
    }

Messages
~~~~~~~~

Message structure:

.. code:: scala

    case class Message(
      id: MessageId,
      creator: ValidatorId,
      previous: Option[MessageId],
      justifications: Seq[MessageId],
      consensusValue: Option[Con],
      dagLevel: Int
    )

-  ``id: MessageId`` unique identifier - hash of other fields
-  ``creator: Int`` id of the validator that created this message
-  `previous: Option[MessageId]` distinguished justification that points to previous message published by creator
-  ``justifications: Seq[MessageId]`` collection of messages that the creator acknowledges as seen at the moment of
   creation of this message; this collection may possibly be empty; only message identifiers are kept here
-  ``consensusValue: Option[Con]`` consensus value this message is voting for; the value is optional, because we allow
   empty votes
-  ``daglevel: Int`` height of this message in justifications DAG

Serialization of messages joins the logical layer and transport layer:

.. code:: scala

    trait MessagesSerializer {

      //conversion binary message --> message
      //validates:
      //  (1) binary format of the message
      //  (2) message's hash
      //  (3) message's signature
      def decodeBinaryMessage(bm: BinaryMessage): (Message, EnvelopeValidationResult)

      //conversion message --> binary message
      def convertToBinaryRepresentationWithSignature(m: Message): BinaryMessage

    }

Network abstraction
~~~~~~~~~~~~~~~~~~~

Broadcasting messages:

.. code:: scala

    trait GossipService {
      def broadcast(message: BinaryMessage)
    }

Receiving messages:

.. code:: scala

    trait GossipHandler {
      def handleMessageReceivedFromNetwork(message: BinaryMessage): HandlerResult
    }

Panoramas
~~~~~~~~~

We use panoramas to encode the "perspective on the jdag as seen from given message".

.. code:: scala

    case class Panorama(
                         honestSwimlanesTips: Map[ValidatorId,Message],
                         equivocators: Set[ValidatorId]
                       ) {

      def honestValidatorsWithNonEmptySwimlane: Iterable[ValidatorId] = honestSwimlanesTips.keys
    }

    object Panorama {
      val empty: Panorama = Panorama(honestSwimlanesTips = Map.empty, equivocators = Set.empty)

      def atomic(msg: Message): Panorama = Panorama(
        honestSwimlanesTips = Map(msg.creator -> msg),
        equivocators = Set.empty[ValidatorId]
      )
    }

Validator
~~~~~~~~~

The abstraction of the estimator:

.. code:: scala

    trait Estimator {

      //calculates correct consensus value to be voted for, given the j-dag snapshot (represented as a panorama)
      def deriveConsensusValueFrom(panorama: Panorama): Option[Con]

      //convert panorama to votes
      //this involves traversing down every corresponding swimlane so to find latest non-empty vote
      def extractVotesFrom(panorama: Panorama): Map[ValidatorId, Con]

    }

... and finality detector (implementing the "summit theory" finality criterion):

.. code:: scala

    trait FinalityDetector {
      def onLocalJDagUpdated(latestPanorama: Panorama): Option[Summit]
    }

The implementation of a validator is complex so we split it into sections.


.. code:: scala

    //A participant of Abstract Casper Consensus protocol
    abstract class Validator extends GossipHandler {
    }

**Validator configuration**

.. code:: scala

  val localValidatorId: ValidatorId
  val weightsOfValidators: Map[ValidatorId, Weight]
  val gossipService: GossipService
  val serializer: MessagesSerializer
  val preferredConsensusValue: Con

-  ``weightsOfValidators: Map[ValidatorId, Int]`` - weights of validators
-  ``finalizer: Finalizer`` - finality detector
-  ``gossipService: GossipService`` - communication layer API used to broadcast messages

**Protocol state**

.. code:: scala

  val messagesBuffer: Relation[Message, MessageId]
  val jdagGraph: Dag[Message]
  val messageIdToMessage: mutable.Map[MessageId, Message]
  var globalPanorama: Panorama = Panorama.empty
  val message2panorama: mutable.Map[Message,Panorama]
  val finalityDetector: FinalityDetector
  val estimator: Estimator = new ReferenceEstimator(messageIdToMessage, weightsOfValidators)
  var myLastMessagePublished: Option[Message] = None

-  ``messagesBuffer: Relation[Message,MessageId]`` - a buffer of messages received, but not incorporated into ``jdag``
   yet; a pair :math:`(m,j)` in this relation represents buffered message :math:`m` waiting for not-yet-received message
   with id :math:`j`
-  ``jdagGraph`` - representation of :math:`jDag(M)`, where :math:`M` is the set of all messages known, such that
   their dependencies are fulfilled; in other words, before a message :math:`m` can be added to ``jdag``, all
   justifications of :math:`m` must be already present in ``jdag``
-  ``jdagIdToMessage: mutable.Map[MessageId, Message]`` - indexing of messages by id

**Handling of incoming messages**

.. code:: scala

  def handleMessageReceivedFromNetwork(bm: BinaryMessage): HandlerResult = {
    val (message, validationResult) = serializer.decodeBinaryMessage(bm)
    if (validationResult == EnvelopeValidationResult.Error)
      return HandlerResult.InvalidMessage

    if (message.justifications.forall(id => messageIdToMessage.contains(id)))
      runBufferPruningCascadeFor(message)
    else {
      val missingDependencies = message.justifications.filter(j => ! messageIdToMessage.contains(j))
      for (j <- missingDependencies)
        messagesBuffer.addPair(message,j)
    }

    return HandlerResult.Accepted
  }

  def runBufferPruningCascadeFor(message: Message): Unit = {
    val queue = new mutable.Queue[Message]()
    queue enqueue message

    while (queue.nonEmpty) {
      val nextMsg = queue.dequeue()
      if (! messageIdToMessage.contains(nextMsg.id) && isValid(nextMsg)) {
        addToLocalJdag(nextMsg)
        val waitingForThisOne = messagesBuffer.findSourcesFor(nextMsg.id)
        messagesBuffer.removeTarget(nextMsg.id)
        val unblockedMessages = waitingForThisOne.filterNot(b => messagesBuffer.hasSource(b))
        queue enqueueAll unblockedMessages
      }
    }
  }

**Publishing of new messages**

.. code:: scala

  def publishNewMessage(): Unit = {
    val msg = createNewMessage()
    addToLocalJdag(msg)
    val bm = serializer.convertToBinaryRepresentationWithSignature(msg)
    gossipService.broadcast(bm)
  }

  def createNewMessage(): Message = {
    val creator: ValidatorId = localValidatorId
    val justifications: Seq[MessageId] =
      jdagGraph.tips
        .groupBy(m => m.creator)
        .map {case (vid,coll) => coll.head}
        .map(m => m.id)
        .toSeq
    val dagLevel: Int =
      if (justifications.isEmpty)
        0
      else
        (justifications map (j => messageIdToMessage(j).dagLevel)).max + 1
    val consensusValue: Option[Con] =
      if (shouldCurrentVoteBeEmpty())
        None
      else if (justifications.isEmpty)
        Some(preferredConsensusValue)
      else
        estimator.deriveConsensusValueFrom(globalPanorama)

    val msgWithBlankId = Message (
      id = placeholderHash,
      creator,
      previous = myLastMessagePublished map (m => m.id),
      justifications,
      consensusValue,
      dagLevel
    )

    return Message(
      id = generateMessageIdFor(msgWithBlankId),
      msgWithBlankId.creator,
      msgWithBlankId.previous,
      msgWithBlankId.justifications,
      msgWithBlankId.consensusValue,
      msgWithBlankId.dagLevel
    )
  }

**Abstract methods** - i.e. extension points (things outside of this protocol spec)

.. code:: scala

  def shouldCurrentVoteBeEmpty(): Boolean

  def placeholderHash: Hash

  def generateMessageIdFor(message: Message): Hash

  def consensusHasBeenReached(summit: Summit)

**Validation of incoming messages**

.. code:: scala

  def isValid(message: Message): Boolean =
    validityConditionDaglevel(message) &&
    validityConditionDirectJustifications(message) &&
    validityConditionPrevious(message) &&
    validityConditionConsensusValue(message)

  //daglevel must be correct
  def validityConditionDaglevel(message: Message): Boolean = {
    val correctDaglevel: Int = (message.justifications map (j => messageIdToMessage(j).dagLevel)).max + 1
    return message.dagLevel == correctDaglevel
  }

  //direct justifications must not reference the same swimlane twice
  //(while message.previous is considered one of justifications)
  def validityConditionDirectJustifications(message: Message): Boolean = {
    val swimlanesUsed = message.justifications.map(j => messageIdToMessage(j).creator).toSet
    message.previous match {
      case None => //ok
      case Some(p) =>
        if (swimlanesUsed.contains(messageIdToMessage(p).creator))
          return false
    }

    return swimlanesUsed.size == message.justifications.size
  }

  //msg.previous must point to highest element of msg.creator swimlane earlier than msg itself
  def validityConditionPrevious(message: Message): Boolean = {
    val effectiveJustifications: Seq[MessageId] =
      message.previous match {
        case None => message.justifications
        case Some(p) => message.justifications :+ p
      }
    val effectiveJustificationsAsMessages: Seq[Message] = effectiveJustifications map (id => messageIdToMessage(id))
    val toposortIteratorOfJPastCone = jdagGraph.toposortTraverseFrom(effectiveJustificationsAsMessages)

    return message.previous match {
      case None =>
        toposortIteratorOfJPastCone.find(m => m.creator == message.creator) match {
          case Some(x) => false
          case None => true
        }
      case Some(p) =>
        val declaredPreviousMessage: Message = messageIdToMessage(p)
        val realFirst: Message = toposortIteratorOfJPastCone.filter(m => m.creator == message.creator).next()
        declaredPreviousMessage == realFirst
    }
  }

  def validityConditionConsensusValue(message: Message): Boolean =
    message.consensusValue match {
      case None => true
      case Some(consensusValueInMessage) =>
        estimator.deriveConsensusValueFrom(panoramaOf(message)) match {
          case Some(requiredConsensusValue) => consensusValueInMessage == requiredConsensusValue
          case None => true //estimator gave no constraint, so the creator of this message was allowed
                            //to pick any consensus value
        }
    }

**Updating of local j-dag**

.. code:: scala

  def addToLocalJdag(msg: Message): Unit = {
    globalPanorama = mergePanoramas(globalPanorama, panoramaOf(msg))
    jdagGraph insert msg
    messageIdToMessage += msg.id -> msg

    finalityDetector.onLocalJDagUpdated(globalPanorama) match {
      case Some(summit) => consensusHasBeenReached(summit)
      case None => //no consensus yet, do nothing
    }
  }

**Calculating panoramas**

.. code:: scala

  /**
   * Calculates panorama of given msg.
   */
  def panoramaOf(msg: Message): Panorama =
    message2panorama.get(msg) match {
      case Some(p) => p
      case None =>
        val result =
          msg.justifications.foldLeft(Panorama.empty){case (acc,j) =>
            val justificationMessage = messageIdToMessage(j)
            val tmp = mergePanoramas(panoramaOf(justificationMessage), Panorama.atomic(justificationMessage))
            mergePanoramas(acc, tmp)}
        message2panorama += (msg -> result)
        result
    }

  //sums j-dags defined by two panoramas and represents the result as a panorama
  //caution: this implementation relies on daglevels being correct
  //so validation of daglevel must have happened before
  def mergePanoramas(p1: Panorama, p2: Panorama): Panorama = {
    val mergedTips = new mutable.HashMap[ValidatorId,Message]
    val mergedEquivocators = new mutable.HashSet[ValidatorId]()
    mergedEquivocators ++= p1.equivocators
    mergedEquivocators ++= p2.equivocators

    for (validatorId <- p1.honestValidatorsWithNonEmptySwimlane ++ p2.honestValidatorsWithNonEmptySwimlane) {
      if (! mergedEquivocators.contains(validatorId)) {
        val msg1opt: Option[Message] = p1.honestSwimlanesTips.get(validatorId)
        val msg2opt: Option[Message] = p2.honestSwimlanesTips.get(validatorId)

        (msg1opt,msg2opt) match {
          case (None, None) => //do nothing
          case (None, Some(m)) => mergedTips += (validatorId -> m)
          case (Some(m), None) => mergedTips += (validatorId -> m)
          case (Some(m1), Some(m2)) =>
            if (m1 == m2)
              mergedTips += (validatorId -> m1)
            else if (m1.dagLevel == m2.dagLevel)
              mergedEquivocators += validatorId
            else {
              val higher: Message = if (m1.dagLevel > m2.dagLevel) m1 else m2
              val lower: Message = if (m1.dagLevel < m2.dagLevel) m1 else m2
              if (isEquivocation(higher, lower))
                mergedEquivocators += validatorId
              else
                mergedTips += (validatorId -> higher)
            }
        }
      }
    }

    return Panorama(mergedTips.toMap, mergedEquivocators.toSet)
  }

  //tests if given messages pair from the same swimlane is an equivocation
  //caution: we assume that msg.previous and msg.daglevel are correct (= were validated before)
  def isEquivocation(higher: Message, lower: Message): Boolean = {
    require(lower.creator == higher.creator)

    if (higher == lower)
      false
    else if (higher.dagLevel <= lower.dagLevel)
      true
    else if (higher.previous.isEmpty)
      true
    else
      isEquivocation(messageIdToMessage(higher.previous.get), lower)
  }

Estimator
~~~~~~~~~

.. code:: scala

    class ReferenceEstimator(
                              id2msg: MessageId => Message,
                              weight: ValidatorId => Weight
                            ) extends Estimator {

      def deriveConsensusValueFrom(panorama: Panorama): Option[Con] = {
        //panorama may be empty, which means "no votes yet"
        if (panorama.honestSwimlanesTips.isEmpty)
          return None

        val votes: Map[ValidatorId, Con] = extractVotesFrom(panorama)
        //this may happen if all votes were empty (i.e. consensus value = None)
        if (votes.isEmpty)
          return None

        //summing votes
        val accumulator = new mutable.HashMap[Con, Weight]
        for ((validator, c) <- votes) {
          val oldValue: Weight = accumulator.getOrElse(c, 0L)
          val newValue: Weight = oldValue + weight(validator)
          accumulator += (c -> newValue)
        }

        //if weights are the same, we pick the bigger consensus value
        //tuples (w,c) are ordered lexicographically, so first weight of votes decides
        //if weights are the same, we pick the bigger consensus value
        //total ordering of consensus values is implicitly assumed here
        val (winnerConsensusValue, winnerTotalWeight) = accumulator maxBy { case (c, w) => (w, c) }
        return Some(winnerConsensusValue)
      }

      def extractVotesFrom(panorama: Panorama): Map[ValidatorId, Con] =
        panorama.honestSwimlanesTips
          .map { case (vid, msg) => (vid, vote(msg)) }
          .collect { case (vid, Some(vote)) => (vid, vote) }

      //finds latest non-empty vote as seen from given message by traversing "previous" chain
      @tailrec
      private def vote(message: Message): Option[Con] =
        message.consensusValue match {
          case Some(c) => Some(c)
          case None =>
            message.previous match {
              case Some(m) => vote(id2msg(m))
              case None => None
            }
        }

    }

Finality detector
~~~~~~~~~~~~~~~~~

Representation of a committee:

.. code:: scala

    case class Committee(entries: Map[ValidatorId,Message]) {
      def validators: Iterable[ValidatorId] = entries.keys
      def validatorsSet: Set[ValidatorId] = validators.toSet
    }

Representation of a summit:

.. code:: scala

    case class Summit(
                       relativeFtt: Double,
                       level: Int,
                       committees: Array[Committee]
                     )

Implementation of the "summit theory" finality criterion:

.. code:: scala

    class ReferenceFinalityDetector(
                                     relativeFTT: Double,
                                     ackLevel: Int,
                                     weightsOfValidators: Map[ValidatorId, Weight],
                                     jDag: Dag[Message],
                                     messageIdToMessage: MessageId => Message,
                                     message2panorama: Message => Panorama,
                                     estimator: Estimator
                                   ) extends FinalityDetector {

      val totalWeight: Weight = weightsOfValidators.values.sum
      val absoluteFTT: Weight = math.ceil(relativeFTT * totalWeight).toLong
      val quorum: Weight = {
        val q: Double = (absoluteFTT.toDouble / (1 - math.pow(2, - ackLevel)) + totalWeight.toDouble) / 2
        math.ceil(q).toLong
      }

      override def onLocalJDagUpdated(latestPanorama: Panorama): Option[Summit] = {
        estimator.deriveConsensusValueFrom(latestPanorama) match {
          case None =>
            return None
          case Some(mostSupportedConsensusValue) =>
            val validatorsVotingForThisValue: Iterable[ValidatorId] = estimator.extractVotesFrom(latestPanorama)
                .filter {case (validatorId,vote) => vote == mostSupportedConsensusValue}
                .keys
            val zeroLevelCommittee: Committee =
              findOldestZeroLevelMessages(mostSupportedConsensusValue,validatorsVotingForThisValue, latestPanorama)

            if (sumOfWeights(zeroLevelCommittee.validators) < quorum)
              return None
            else {
              //var committeeOnCurrentLevel: Committee = zeroLevelCommittee
              val committeesFound: Array[Committee] = new Array[Committee](ackLevel + 1)
              committeesFound(0) = zeroLevelCommittee
              for (k <- 1 to ackLevel) {
                val levelKCommittee: Option[Committee] =
                  findLevelNPlus1Committee(committeesFound(k-1), committeesFound(k-1).validatorsSet)
                if (levelKCommittee.isEmpty)
                  return None
                else
                  committeesFound(k) = levelKCommittee.get
              }

              return Some(Summit(relativeFTT, ackLevel, committeesFound))
            }
        }
      }

      private def findOldestZeroLevelMessages(
                                       consensusValue: Con,
                                       validatorsSubset: Iterable[ValidatorId],
                                       latestPanorama: Panorama): Committee = {
        val pairs: Iterable[(ValidatorId, Message)] = for {
          validator <- validatorsSubset
          swimlaneTip: Message = latestPanorama.honestSwimlanesTips(validator)
          oldestZeroLevelMessage: Message = swimlaneIterator(swimlaneTip)
            .takeWhile(m => m.consensusValue.isEmpty || m.consensusValue.get == consensusValue)
            .toSeq
            .last
        }
          yield (validator, oldestZeroLevelMessage)

        return Committee(pairs.toMap)
      }

      @tailrec
      private def findLevelNPlus1Committee(
                                            levelNCommittee: Committee,
                                            candidatesConsidered: Set[ValidatorId]): Option[Committee] = {
        val approximationOfResult: Map[ValidatorId, Message] =
          candidatesConsidered
            .map(validator => (validator, findNextLevelMsg(validator, levelNCommittee, candidatesConsidered)))
            .collect {case (validator, Some(msg)) => (validator, msg)}
            .toMap

        val candidatesAfterPruning: Set[ValidatorId] = approximationOfResult.keys.toSet

        if (sumOfWeights(candidatesAfterPruning) < quorum)
          None
        else
        if (candidatesAfterPruning forall (v => candidatesConsidered.contains(v)))
          Some(Committee(approximationOfResult))
        else
          findLevelNPlus1Committee(levelNCommittee, candidatesAfterPruning)
      }

      private def swimlaneIterator(message: Message): Iterator[Message] =
        new Iterator[Message] {
          var nextElement: Option[Message] = Some(message)

          override def hasNext: Boolean = nextElement.isDefined

          override def next(): Message = {
            val result = nextElement.get
            nextElement = nextElement.get.previous map (m => messageIdToMessage(m))
            return result
          }
        }

      /**
       * In the swimlane of given validator which is part of a committee we attempt finding lowest (= oldest) message
       * that has support at least q (relative to the given committee, ).
       */
      private def findNextLevelMsg(
                                    validator: ValidatorId,
                                    levelNCommittee: Committee,
                                    candidatesConsidered: Set[ValidatorId]
                                  ): Option[Message] =
        findNextLevelMsgRecursive(validator, levelNCommittee, candidatesConsidered, levelNCommittee.entries(validator))

      @tailrec
      private def findNextLevelMsgRecursive(
                                             validator: ValidatorId,
                                             levelNCommittee: Committee,
                                             candidatesConsidered: Set[ValidatorId],
                                             message: Message): Option[Message] = {

        val relevantSubPanorama: Map[ValidatorId, Message] = message2panorama(message).honestSwimlanesTips filter
          {case (v,msg) => candidatesConsidered.contains(v) && msg.dagLevel >= levelNCommittee.entries(v).dagLevel}

        if (sumOfWeights(relevantSubPanorama.keys) >= quorum)
          Some(message)
        else {
          val nextMessageInThisSwimlane = jDag.sources(message).filter(m => m.creator == validator).head
          findNextLevelMsgRecursive(validator, levelNCommittee, candidatesConsidered, nextMessageInThisSwimlane)
        }
      }

      private def sumOfWeights(validators: Iterable[ValidatorId]): Weight = validators.map(v => weightsOfValidators(v)).sum

    }


