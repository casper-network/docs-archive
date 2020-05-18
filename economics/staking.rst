Staking and Delegation
----------------------

Bonding Auctions
~~~~~~~~~~~~~~~~

Because the present blockchain model relies on universal validation of blocks
included in the consensus history, there is a sharp tradeoff between intuitive
notions of decentralization/security and performance. Choosing the correct
balance requires setting proper incentives, or even hard rules, for validator entry,
in a manner that ensures performance remains acceptable without exposing
the platform to oligopolistic capture.

An open auction with open bids, a simple, first-"price" resolution and a
fixed number of slots solves the issue with imprecise control over the
security/performance tradeoff, while offering prospective validators
an easy to understand procedure for joining. There is no minimum stake and
the security/performance tradeoff is handled by an automatic on-chain slot
number adjustment mechanism.

Delegation
~~~~~~~~~~

Users are able to delegate their own CLX to validators
without having to become validators themselves. Validators, in turn, take a
commission out of the rewards and transaction fees earned through delegated CLX.
Delegated tokens are subject to the same unbonding rules as the tokens staked by
validator from their own accounts.
Further, delegated tokens can be used in bidding for validator slots and can be
lost due to equivocations.
