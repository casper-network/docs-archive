Slashing
--------

The practical utility of a blockchain platform depends on its *safety* and
*liveness*. A safe blockchain is one where users can expect valid transactions
to eventually become recorded in the canonical history, or a linear sequence of
finalized blocks. A live blockchain is one where this process can continue
indefinitely, as long as there are validators to process, disseminate, and record
the transactions in blocks. Actions by validators that constitute a threat to
either the safety or the liveness of the blockchain are termed *faults*.

We can enforce compliance with certain features of the protocol, such as the
fields expected to be populated in a block’s metadata, as part of the
programmatic protocol definition, and reject all blocks failing to satisfy the
conditions as invalid, or faulty. However, some faults cannot be defined as
properties of individual blocks, or directly prohibitied by the protocol
specification. Rather, they must be incentivized by imposing costs for
commission of faults. Direct incentivization of individual validators by these
means is only possible with *attributable* faults, or faults that can be traced
to an individual validator. *Slashing* is the term we use for such
incentivization.

Slashing functions
~~~~~~~~~~~~~~~~~~

We begin with a definition of a generic *slashing function* that represents the
algorithmic implementation of the following process, carried out by each
validator concurrently,

1. Observe the state of the blockchain
2. Retrieve slashing function parameters from a relevant past block in the
   observed state
3. Traverse the state and extract necessary information
4. Calculate slashing for each validator and embed this information in the next
   block

The process outlined above can be adapted to each fault and to various
algorithmic implementations. For example, one could retrieve some information
“left over” from the parent block (in step 2) to calculate slashing
incrementally.

A slashing function is defined as follows

.. math::  s_b : \Sigma_\mathcal{M} \rightarrow \{0, 1\}^{|V|} \times [0,
           1]^{|V|}

We will denote elements of the output corresponding to a validator and tuple
position as :math:`s_{b}^{v,i}, i \in {0,1}`, abusing notation to refer to the
slash proportions only as :math:`s_{b}^{V, 1}` (we will view it as a column
vector). A slashing function is parametrized by a block :math:`b` and maps
states to a list of tuples indicating faulty validators and respective
proportional slash of the bond of each validator found to be faulty. Implicit in
this definition is each validator’s subjective view of the blockchain,
represented by states, and reliance on information about objects such as
validator sets that has to be extracted from specific blocks in the observed
state. Any slashing function would be implemented as a subroutine within the
``step`` function, called when a validator creates a new block.

We can additionally define a function

.. math:: w_b : V\rightarrow \mathbb{R}_{\geq 0}

The function :math:`w_b` is a :math:`b`-parametrized weight function that simply
maps every validator recorded in :math:`b` to its bond amount. Taking some
:math:`b' \leq b`, where :math:`b'` is a valid parametrizing block for
:math:`s`, and assuming that, at most, a single fault by each validator
and that no bonding or unbonding occurred between :math:`b'` and
:math:`b`, :math:`w_b` can be computed as

.. math:: w_b = s_{b'}^{V, 1} (J(b))^\top (w_{\text{Prev}(b)} - w_{\min})

Above, we use :math:`w_{\min}` to denote either a zero vector or a vector of
minimum bond amounts, depending on the application.

Equivocation faults
~~~~~~~~~~~~~~~~~~~

Description
^^^^^^^^^^^

Equivocation faults constitute a direct threat to the safety of the system by
making it difficult to settle on a single canonical history of transactions.
This reduces value of the system for both users and participants, since the
value proposition of a blockchain is precisely that it must eventually finalize
a unique history. Equivocation faults are attributable to individual validators
and are subject to slashing. Moreover, slashing is necessary because it is not
feasible to programmatically forbid validators from equivocating, as
equivocation is not a property of a single block or a message. Because
equivocations constitute a particularly serious threat to the expected operation
of the blockchain and threatens its value to all users and validators,
equivocations require a slash value of 1, without a limit imposed by minimum
bond.

In our protocol, only validators assigned to be leaders in the respective slots
produce blocks, and consequently the relevant information for detecting
equivocations is contained in a key block created prior to each era, as well as
the observed state.

Definition
^^^^^^^^^^

Formally, an equivocation detectable in a state :math:`\sigma` is a pair of
messages :math:`\{\mu, \nu\} \subset \sigma` where :math:`\mu \not \geq \nu
\land \nu \not \geq \mu \land S(\mu) = S(\nu)`. In other words, an equivocation
occurs when a single validator sends two messages, neither of which acknowledges
the other, and these messages are observed by a third party.

For any state :math:`\sigma`, let :math:`b'` denote the key block (the latest
key block in :math:`\sigma`) for the current era. The current era of a state is
formally defined by :math:`\max_{b \in \sigma} k(b)`, where :math:`k` is a
function that extracts the era of a particular block. The era of a block can be
calculated trivially from its timestamp. Given a key block and a state with
:math:`b' \in \sigma`, we can give an explicit coordinate-wise definition to the
*equivocation slashing function*

.. math::


   s_{\text{EQ},b'}^{v, 0} (\sigma) =
       \begin{cases}
           1 \text{ if } \exists \mu, \nu \in \sigma, \mu \not \geq \nu \land
           \nu \not \geq \mu \land S(\mu) = S(\nu)\\
           0 \text{ otherwise}
       \end{cases}

.. math::


   s_{\text{EQ},b'}^{v, 1} (\sigma) =
       \begin{cases}
           1 \text{ if } s_{\text{EQ},b'}^{v, 0} (\sigma) = 1\\
           0 \text{ otherwise}
       \end{cases}

The key block :math:`b'` implicitly sets the range of the variable :math:`v` in
the coordinate-wise definitions above.

For equivocations, :math:`w_{\min}` is the zero vector.
