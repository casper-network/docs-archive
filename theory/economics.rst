Economics
=========

The CasperLabs blockchain implements the first Proof-of-Stake network based on
the CBC Casper family of protocols. The network is permissionless, such that
anybody is allowed to become a validator by staking a minimum number of tokens.
Staking allows validators to receive payments through "seigniorage", and also a
share of the fees from the transactions submitted by the network’s users.

Staking requires the validator to participate in the network by processing
transactions; and proposing, validating, and storing blocks. The network’s
continuation and maintenance requires that validators adhere to the protocol,
which is ensured by the network’s incentive mechanism. This works by rewarding
adherence to the protocol and punishing deviation from the protocol.

In order to stake the network, prospective validators participate in open auctions 
for a limited number of validator positions, with winning bids becoming bonded as stakes.
This approach strikes a balance between security and performance, since increasing
the number of validators must weakly decrease network throuhput with the present mainnet
architecture.

Rewards are provided through a process called *seigniorage*. New tokens are
minted at a constant rate and distributed to participating validators, similar
to the block reward mechanism in Bitcoin. Unlike Bitcoin, validators don’t have
to wait until a block is mined to realize their rewards. Seigniorage is paid
continuously to validators. This ensures stable payments and eliminates the need
to create pools. An honest validator therefore receives more tokens at a
predictable and satisfying rate without joining a pool.

A malicious validator, on the other hand- is punished through disincentives for
various types of undesirable activities such as inactivity, attacks on
consensus, and censorship. The protocol is designed to penalize validators that
engage in such activities by burning a part of their stake, referred to as
slashing.

In addition to seigniorage payments, validators receive transaction fees paid by
the users. Computation is metered by gas like in Ethereum, where each operation
is assigned a cost in gas. Users specify a gas price when submitting their
transactions, and the resulting fees are collected by the block proposers.

Tokens
------

The CasperLabs blockchain hosts its own native token, having the symbol CLX,
that serves many functions for the network’s participants. Similar to Ethereum,
users use CLX to fund their transactions, and validators receive rewards in CLX.
Additionally, CLX is used as deposit when becoming a validator, as part of the
Proof of Stake protocol. New CLX is minted through seigniorage to incentivize
validators, whereas bonded CLX is slashed occasionally to punish faults.

Users are able to delegate their own CLX to validators
without having to become validators themselves. Validators, in turn, take a
commission out of the rewards and transaction fees earned through delegated CLX. 
Further, delegated tokens can be used in bidding for validator slots.

Open Auctions
-------------

Because the present blockchain model relies on universal validation of blocks 
included in the consensus history, there is a sharp tradeoff between intuitive 
notions of decentralization/security and performance. Choosing the correct 
balance requires setting proper incentives, or even hard rules, for validator entry, 
in a manner that ensures performance remains acceptable without exposing 
the platform to oligopolistic capture.

An open auction with open bids, a simple, first-”price” resolution and a 
fixed number of slots solves the issue with imprecise control over the 
security/performance tradeoff, while offering prospective validators 
an easy to understand procedure for joining.

Seigniorage
-----------

Seigniorage provides a base level of payments for validators so that they are
still compensated for their work even if there is not a lot of demand for
computation on the network. By issuing new CLX for validators, resources
necessary to keep the network running are transferred from CLX holders to
validators.

CLX is issued at a fixed rate and distributed to validators in proportion to
their stake. This is analogous to block rewards in Proof of Work blockchains,
except for two major differences:

- The growth of CLX supply is exponential instead of linear.
- New CLX is minted at the end of each era, and distributed to validators
  proportional to their score for that era. This score is calculated based on
  the validators' stake and their performance.

The following formulas are used to calculate the amount of CLX minted at
the end of each era, which is equal to 1 week:

.. math::
   \begin{aligned}
   \text{supply}(x) &= \text{initial}\_\text{supply}\times (1+\text{seigniorage}\_\text{rate})^{x/52} \\
   \Delta(x) &= \text{supply}(x+1) - \text{supply}(x)
   \end{aligned}

where :math:`x=1,2,\dots` is the week's index, *initial supply* is the number of CLX
at the Mainnet launch and *seigniorage rate* is the annual rate at which new CLX
is minted.

Transaction Fees
----------------

Users need to specify a fee when submitting their transactions. When it is a
validator’s turn to propose a block, the validator collects transactions from
the transaction pool, executes them in a certain order, and publishes them in a
new block. Fees in a block are distributed to all validators pro rata. This is
to weaken the incentive to steal transactions from other blocks, in case the
block proposer receives the whole fee.

Compensation Fee
~~~~~~~~~~~~~~~~

Distributing transaction fees to everyone causes a malicious strategy to emerge,
where validators propose empty blocks in order not to incur the computational
cost of processing transactions. As long as there are enough honest validators
including transactions, these "lazy" validators can keep on receiving a share of
the transactions fees, despite not including transactions themselves.
The following scheme is an attempt at solving the lazy validator problem by
disincentivizing proposing empty or partially full blocks. This is achieved by
making the validators pay a fine, called the compensation fee, proportional to
the space in the block left out empty.

The protocol has the following parameters:

- :math:`P`: Average gas price of the previous era. This value is updated at the end
  of each era, calculated by dividing total collected fees by total consumed
  gas.
- :math:`G`: Gas in a block.
- :math:`G_{\text{max}}`: Block gas limit. :math:`G \leq G_{\text{max}}` for every block.
- :math:`F`: Total fee collected from transactions in a block.
- :math:`N` is the current number of validators,
- :math:`w_i` is the normalized weight of validator :math:`i`.

In a given block, :math:`F` fee is collected from transactions amounting to :math:`G` gas.
Let validator :math:`i` be the **block proposer**. If :math:`G<G_\text{max}`, validator :math:`i`
is obliged to come up with

.. math::
   F_c = P (G_\text{max}-G)

worth of tokens as compensation. This is deducted from their reward balance if
sufficient, and from their bonded tokens if not. Deduction from stake is
equivalent to slashing, and if it drops below minimum stake size, they cease to
be a validator as usual.

The compensation :math:`F_c` will be added up to :math:`F`, which will be **distributed
pro-rata to the validators**. Change in a validator :math:`j`\'s balance is equal to

.. math::
   \Delta_j =
   \begin{cases}
   w_i(F+F_c) - F_c & \text{if}\quad j=i\\
   w_j(F+F_c) & \text{otherwise }
   \end{cases}

The block proposer paying a fine might seem unfair, especially when there
is a lack of submitted transactions. However, since every validator is subjected
to it, this scheme ensures fairness in the long term, even at times of low demand.

Gas Pricing
~~~~~~~~~~~

It is one of the goals of CasperLabs to maintain a certain level of
predictability for users in terms of gas prices, and for validators in terms
of transaction fees. Blockchains with unregulated fee markets are
susceptible to high volatility in transaction fees, which get pushed up as
demand rises and blocks become full.

To this end, as an initial step, Casperlabs is implementing a transaction pricing system
that will assign fiat (dollar) prices to all relevant resources, such as bytes of storage,
opcodes and standardized computation times for external functions. A successful implementation 
of this system requires a reliable on-chain feed of the CLX price in USD. To this end, 
CasperLabs will utilizer a `Chainlink<https://chain.link>`__ network of oracles to aggregate 
a single price from major exchanges.

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
