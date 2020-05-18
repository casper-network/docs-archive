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
incentivization. Specifically, a *slashed* validator loses some, or all, of the stake,
possibly resulting in ejection.

Currently, we only penalize equivocations, though this may change as we
develop the platform.

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
