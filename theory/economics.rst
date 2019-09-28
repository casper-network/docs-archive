Economics
=========

The CasperLabs blockchain implements the first Proof-of-Stake network based on
the CBC Casper family of protocols. The network is permissionless, such that
anybody is allowed to become a validator by staking a minimum number of tokens.
Staking allows validators to receive payments through "seigniorage", and also a
share of the fees from the transactions submitted by the network’s users.

Staking requires the validator to participate in the network by processing transactions; and proposing, validating, and storing blocks. The network’s continuation and maintenance requires that validators adhere to the protocol, which is ensured by the network’s incentive mechanism. This works by rewarding adherence to the protocol and punishing deviation from the protocol.

Rewards are provided through a process called *seigniorage*. New tokens are minted at a constant rate and distributed to participating validators, similar to the block reward mechanism in Bitcoin. Unlike Bitcoin, validators don’t have to wait until a block is mined to realize their rewards. Seigniorage is paid continuously to validators. This ensures stable payments and eliminates the need to create pools. An honest validator therefore receives more tokens at a predictable and satisfying rate without joining a pool.

A malicious validator, on the other hand- is punished through disincentives for various types of undesirable activities such as inactivity, attacks on consensus, and censorship. The protocol is designed to penalize validators that engage in such activities by reducing their payments---called throttling---, and burning a part of their stake---called slashing.

Some attacks, due to their nature, cannot be attributed to the perpetrators they originate from. In such cases, one has no option other than to collectively slash everyone involved. For example, a voluntary absence from proposing a block is indistinguishable from the same proposer’s being censored -- from the protocol’s point of view. For that reason, even honest validators incur a base level of throttling and slashing, called *background throttling* and *slashing*. These are taken into account when tuning network parameters. In an ideal network, incentives and disincentives work hand-in-hand, ensuring the intended regular payments for honest validators, and maximum penalty for malicious validators.

In addition to seigniorage payments, validators receive transaction fees paid by the users. Computation is metered by gas like in Ethereum, where each operation is assigned a cost in gas. Users specify a gas price when submitting their transactions, and the resulting fees are collected by the block proposers.

Tokens
------

The CasperLabs blockchain hosts its own native token, having the symbol CLX,
that serves many functions for the network’s participants. Similar to Ethereum,
users use CLX to fund their transactions, and validators receive rewards in CLX.
Additionally, CLX is used as deposit when becoming a validator, as part of the
Proof of Stake protocol. Users are able to delegate their own CLX to validators
without having to become validators themselves. Validators, in turn, take a
commission out of the rewards and transaction fees earned through delegated CLX.

New CLX is minted through seigniorage to incentivize validators, whereas bonded CLX is slashed occasionally to punish faults. The rate of seigniorage is higher than the rate of slashing, whose parameters are tuned periodically by the governance committee to achieve predictable fees for the validators.

Seigniorage
-----------

Seigniorage provides a base level of payments for validators so that they are still compensated for their work even if there is not a lot of demand for computation on the network. By issuing new CLX for validators, resources necessary to keep the network running are transferred from CLX holders to validators. The depreciation in users’ assets caused by this inflation is simply understood as the price of owning assets on the blockchain.

In each block, the amount of newly minted CLX is calculated by multiplying the current total supply with a ``seigniorage_parameter``:

.. code:: python

   new_CLX = seigniorage_parameter * total_supply
   total_supply = total_supply + new_CLX

In CasperLabs’ CBC Casper, time is divided into ticks and each tick corresponds
to a millisecond. Each validator maintains a private parameter
:math:`n_v(i)\in\mathbb{N}` called *cadence*, corresponding to each tick
:math:`i`. Leaders are selected by a pseudorandom function
:math:`\mathcal{L}(i)\in \mathcal{V}` that maps each tick to a
validator. A validator :math:`v` expects blocks to be proposed
by a leader :math:`\mathcal{L}(j)` at each tick :math:`j`
divisible by :math:`2^{n_v(i)}` and this imposes a universal
rule on the leader selection process, regardless of other
validators’ dragging out. This way, the duration between
blocks can react to global changes affecting the time required
to communicate and process transactions.

This, however, means that the rate at which CLX is minted varies with the
validators’ cadences. Although seigniorage rate may differ from minute to
minute, this variance reduces as the time scale is increased, and becomes
virtually constant when averaged on a monthly or yearly basis.

Let :math:`n_L=(n_1, n_2,\dots,n_m)` be the tuple of leaders’ cadences. To
calculate the ``seigniorage_parameter`` required to achieve a
``target_annual_seigniorage``, we first need to calculate the mean of
:math:`n_L` the following way

.. math::


   \bar{n}_L = \log_2\left(\frac{1}{m}\sum_{i=1}^m 2^{n_i}\right)

Then ``seigniorage_parameter`` is simply calculated as

.. math::


   \text{seigniorage}\_\text{parameter} = \text{target}\_\text{annual}\_\text{seigniorage}^{2^{\bar{n}_L}/\text{ms}\_\text{in}\_\text{year}}

where ``ms_in_year`` is the number of milliseconds in a year. The governance
committee would do this calculation periodically and update
``seigniorage_parameter`` accordingly.

Transaction Fees
----------------

Users need to specify a fee when submitting their transactions. When it is a
validator’s turn to propose a block, the validator collects transactions from
the transaction pool, executes them in a certain order, and publishes them in a
new block. Fees in a block are distributed to all validators pro rata.

Gas Pricing
~~~~~~~~~~~

It is one of the goals of CasperLabs to maintain a certain level of
predictability for users in terms of gas prices, and for validators in terms
of transaction fees. Blockchains with unregulated fee markets are
susceptible to high volatility in transaction fees, which get pushed up as
demand rises and blocks become full. An in-protocol gas price floor set high
enough can reduce this volatility. The price of gas would be prevented from
falling below a certain value, whereas it can float freely above said value. It
is, however, expected to do so only during unexpectedly high surges, which are
not expected to happen more than a couple of times a year.

Users specify the gas price for a transaction as the amount of CLX they are
willing to pay per the gas they consume. Considering that the primary goal is to
reduce volatility in prices, it makes little sense to set the floor in CLX whose
price in fiat is expectedly volatile, especially in the first few years
following the launch. To this end, it is imperative to have the price floor
denominated in CLX but set in fiat. The baseline is that a single CLX transfer
between two accounts costs $0.05.

A successful implementation of this system requires a reliable on-chain feed of
the CLX’s price in USD. To this end, CasperLabs utilizes a `Chainlink
<https://chain.link>`__ oracle to aggregate prices from different exchanges.

Transaction Fee Splitting
~~~~~~~~~~~~~~~~~~~~~~~~~

Block proposers are incentivized to fill up blocks with users’ transactions as
much as possible, despite the computational cost they would incur.

The network has the following parameters:

-  :math:`G`: Gas in a block.
-  :math:`G_{\text{max}}`: Gas limit (maximum gas allowed in a block). :math:`G
   \leq G_{\text{max}}` for every block :math:`B`.
-  :math:`F`: Total fee collected from users in a block.
-  :math:`P`: Gas price floor regulated by the governance committee. Example:
   Gas price can’t be lower than $1 per million gas.

Additionally, :math:`N` is the current number of validators, :math:`w_i` is the
*weight* and :math:`s_i = w_i/\sum_jw_j` is the *share* of validator :math:`i`.

In a given block, :math:`F` fee is collected from transactions amounting to
:math:`G` gas. Let validator :math:`i` be the block’s proposer.

If :math:`G<G_\text{max}`, validator :math:`i` is obliged to come up with

.. math::


   \boxed{F_c = s_i N  (G_\text{max}-G)}

worth of tokens as compensation. This is deducted from their reward balance if
sufficient, and from their bonded tokens if not. Deduction from stake is
equivalent to slashing, and if it drops below minimum stake size, they cease to
be a validator as usual.

The compensation :math:`F_c` will be added up to :math:`F`, which will be
**distributed pro-rata to the validators**. Change in the validator’s balances
are

.. math::


   \begin{cases}
   +s_i(F+F_c) - F_c & \text{for validator } i,\\
   +s_j(F+F_c) & \text{for every validator } j\neq i.
   \end{cases}

This scheme disincentivizes validators from being “lazy”, i.e. proposing empty
blocks in order not to incur the computational cost of processing transactions.

The block proposer paying a compensation might seem unfair, especially when there
is a lack of submitted transactions. However, every validator’s being subjected
to it ensures fairness in the long term, even at times of low demand.

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

In this sub-chapter, we briefly define the mathematical primitives needed to
conceptualize slashing within the formalism of our protocol. Subsequently, we
use this formalism to describe how slashing will operate with two major types of
faults. These types are *equivocation* faults and *liveness* faults,
corresponding, respectively, to safety and liveness threats.

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

Algorithmic implementation
^^^^^^^^^^^^^^^^^^^^^^^^^^

Liveness faults
~~~~~~~~~~~~~~~

.. _description-1:

Description
^^^^^^^^^^^

Liveness faults constitute a less severe threat to the expected operation of the
blockchain than equivocation, since they do not preclude eventual convergence to
a unique history. Nevertheless, it is critical that validators be
incentivized to carry out the necessary computations promptly and communicate
when expected. Liveness faults need not arise because of unexpected or malicious
behavior alone. They can also be the result of power and network outages, as
well as hardware malfunctions. However, validators need to be incentivized to
keep their availability high, with slashing for attributable forms of liveness
faults as the incentive.

Liveness faults come in three forms, unlike equivocations. It is expected that
validators:

-  Create and send a block when their internal *cadence*, referred to as the
   “private parameter” in the theory paper, aligns with a tick in which they are
   assigned to lead, or create and send a block (failure to do this is a
   “failure to lead”)
-  If the cadence is misaligned or they are not the assigned leader, forward the
   leader’s block as soon as it is received (failure to do this is a “failure to
   talk”)
-  Always send an interim message no later than a certain time after their last
   aligned tick and before the next one (failure to do this is a “failure to
   wake”)

Slashing can only be applied to the first and second faults implicit in the
above, since the second implicit fault is not attributable. Slashing is
necessary here, just as in the case of equivocations, because it is difficult to
enforce the expected behavior using required properties of blocks. The slashing
proportion is expected to approximate :math:`\min(1, ax^b)` over the duration of
a single fault (i.e., a sequence of ticks where a validator misses all
communication windows), with :math:`x` corresponding to time elapsed between
last missing message from the validator and the current tick, assuming the
validator sent no further messages, calculated from the message timestamps and
local time of any third party evaluating the function. Further information on
parameter settings and estimation of expected stake losses will be published in
the validator onboarding documentation.

All validators must communicate their cadence in the blocks they send out, with
changes in cadence expected to be kept for all subsequent communications after
the current window of ticks concludes. All information concerning missing
messages is also to be embedded in the blocks and incrementally amended as
messages are propagated, should a message appear to be missing because of
latency. The parametrizing block containing the relevant information is the
parent of the current block being produced, with the slashing function computed
incrementally.

Definition (failure to lead)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let :math:`b' = \text{Prev(b)}`. Formally, a *recent failure to lead* has
occured in state :math:`\sigma`, observed at tick :math:`i` (the time assigned
to the block :math:`b` being built, with :math:`J(b) = \sigma`) if

.. math:: \exists v \in V, j \in \mathbb{N}, j \text{ mod } 2^{n_v (i)} = 0
          \land \mathcal{L}(j) = v \land \max_{\mu \in \text{Swim}_v (\sigma)}
          T(\mu) < j \land j \geq T(b')

We will use :math:`b'` to parametrize an incrementally computable slashing
function, using information in :math:`b'` to determine whether a particular
faulty validator was already at fault at the time of the parent block. We can
now define the *failure to lead slashing function*, coordinate-wise, as

.. math::


   s_{\text{FL},b'}^{v, 0} (\sigma) =
       \begin{cases}
           1 \text{ if } \exists v \in V, j \in \mathbb{N}, j \text{ mod }
           2^{n_v (i)} = 0 \land \mathcal{L}(j) = v \land \max_{\mu \in
           \text{Swim}_v (\sigma)} T(\mu) < j \land j \geq T(b')\\
           1 \text{ if } s_{\text{FL},\text{Prev}(b')}^{v, 0} (J(b')) = 1 \land
           \not\exists j, j \geq T(b') \land \mathcal{L}(j) = v\\
           0 \text{ otherwise}
       \end{cases}

.. math::


   s_{\text{FL},b'}^{v, 1} (\sigma) =
       \begin{cases}
           s(T(b) - \max_{\mu \in \text{Swim}_v (\sigma) \cap \mathcal{B}}
           T(\mu), s_{\text{FL},\text{Prev}(b')}^{v, 1} (J(b'))) \text{ if }
           s_{\text{EQ},b'}^{v, 0} (\sigma) = 1\\
           0 \text{ otherwise}
       \end{cases}

The function :math:`s` in the above definition is meant to represent a
computationally efficient approximation to :math:`\min(1, ax^b)` potentially
utilizing past slashing results. The ground case of the recursive definition is
secured by the absence of recorded failures to lead in the genesis block.

For liveness faults, :math:`w_{\min}` is the minimum bond amount vector.

Definition (failure to wake)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The formal definition follows that of slashing for failure to lead, but with
conditions indicating leadership, given by the function :math:`\mathcal{L}`,
replaced by a condition indicating that a validator did not communicate by the
specified cutoff.

.. _algorithmic-implementation-1:

Algorithmic implementation
^^^^^^^^^^^^^^^^^^^^^^^^^^

Throttling
----------

Throttling is a mechanism implemented to disincentivize liveness faults. While
collective liveness slashing slowly reduces everyone’s total stake, throttling
reduces everyone’s seigniorage for the same purpose.

Inactivity is measured between seigniorage payouts, and payouts are scaled down linearly with increased inactivity. For example, if a validator coalition comprising 90% of the total stake successfully censors a minority comprising 10% of the total stake, this will result in a 10% reduction of seigniorage for everyone for the duration of the censorship.

Validator Account Management
----------------------------

Balances
~~~~~~~~

Each validator has 4 different balances to flexibly accommodate all state
transitions during bonding, unbonding and expulsion:

-  ``bonded_balance``: Contains the bonded tokens of the validator
-  ``buffer_balance``: Contains additional tokens provided by the validator, in
   case they don’t want slashings to be incurred directly on their
   ``bonded_balance``.
-  ``reward_balance`` (optional): Rewards can be paid out to this separate
   balance instead of directly to the ``buffer_balance`` if the validator
   chooses to opt-in (see below).
-  ``slashed_balance``: Contains the already slashed tokens of the validator.
   This balance is effectively inaccessible, unless its contents are reimbursed
   through a transaction from the governance committee.

Bonding
~~~~~~~

While bonding, every validator specifies a ``target_stake >= minimum_stake`` and
send ``submitted_amount >= target_stake`` tokens with their bonding request.

.. code:: python

   bonded_balance += target_stake

   if submitted_amount > target_stake:
       buffer_balance += submitted_stake - target_stake
   elif submitted_amount < target_stake:
       raise Exception()

Validator weights are calculated at the beginning of each era using
``bonded_balance``\ s.

Slashing and Expulsion
~~~~~~~~~~~~~~~~~~~~~~

Validators will likely start being slashed as soon as they bond, even if they
adhere to the protocol. Called *background slashing*, this is due to the
collective slashing of validators as a part of the incentive mechanism.
Background slashing should be minimal (though not negligible) in a well
functioning network. When a validator is slashed, the amount is deducted from their
``buffer_balance``. If ``buffer_balance`` is not high enough to compensate a
slashed amount, **the difference is deducted from** ``bonded_balance``.

A validator is required to bond ``minimum_stake`` number of tokens in order to participate in consensus. Rewards and slashings are incurred when a new block is proposed, and the slashing can potentially be high enough to reduce ``bonded_balance`` below ``minimum_stake``. An incurred slashing cannot exceed the amount required to reduce ``bonded_balance`` to ``minimum_stake``. If ``bonded_balance - minimum_stake`` is not high enough to compensate a slashed amount, the validator is considered to be *expelled*---kicked out of the validator set. An expelled validator cannot propose blocks even though they have assigned ticks left in that era, and they are fully removed from the validator set when the era ends.

.. code:: python

   # Given a slashed_amount,
   if buffer_balance >= slashed_amount:
       buffer_balance -= slashed_amount
   else:
       difference = slashed_amount - buffer_balance
       buffer_balance = 0
       if bonded_balance - minimum_stake > difference:
           bonded_balance -= difference
       else:
           bonded_balance = minimum_stake
           expel()

This might be undesirable if the validator is aiming to stay above a specific
weight. In that case, the validator has to make sure that their
``buffer_balance`` is topped up with enough tokens at all times.

Rewards
~~~~~~~

New tokens are minted and distributed to active validators as part of the
incentive mechanism. This process is called *seigniorage*, and seigniorage
rewards are paid out to a separate ``reward_balance`` as described above.

A validator’s ``buffer_balance`` decreases continuously due to background
slashing. If the validator wants to retain their ``bonded_balance``, they would
have to top up their ``buffer_balance`` at regular intervals.

To reduce the operational risk of having to look after their ``buffer_balance``, a validator can instead **opt-in** to have their seigniorage rewards paid out directly to their ``buffer_balance``.

.. code:: python

   if opted_in:
       buffer_balance += seigniorage_rewards - background_slashing
   else:
       reward_balance += seigniorage_rewards
       buffer_balance -= background_slashing

Since the overall rate of seigniorage rewards are expected to be higher than
background slashing in a well functioning network, an honest validator’s
``buffer_balance`` is expected to **grow** instead of decreasing. This feature
has no direct effect on the economics of the network, and is purely a matter of
UX and bookkeeping.

