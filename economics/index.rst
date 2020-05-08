
.. _economics:

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
the number of validators must weakly decrease network throughput with the present mainnet
architecture, due to increased communication complexity.

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


.. toctree::
   :maxdepth: 2
   :hidden:

   Introduction <self>
   tokens.rst
   seigniorage.rst
   transaction-fees.rst
   open-auctions.rst
   slashing.rst

