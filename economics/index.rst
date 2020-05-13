
.. _economics:

Economics
=========

The CasperLabs blockchain implements the first Proof-of-Stake network based on
the CBC Casper family of protocols. The network is permissionless, such that
anybody is allowed to become a validator, once they fulfill certain requirements.
Staking allows validators to receive rewards and share transaction fees.

Staking requires the validator to participate in the network by processing
transactions; and proposing, validating, and storing blocks. The network’s
continuation and maintenance requires that validators adhere to the protocol,
which is ensured by the network’s incentive mechanism. This works by rewarding
adherence to the protocol and punishing deviation from the protocol.

In order to stake in the network, prospective validators participate in bonding auctions
for a limited number of validator positions, with winning bids becoming bonded as stakes.
This approach strikes a balance between security and performance, since increasing
the number of validators must weakly decrease network throughput with the present mainnet
architecture, due to increased communication complexity.

Rewards are provided through a process called *seigniorage*. New tokens are
minted at a constant rate and distributed to participating validators, similar
to the block reward mechanism in Bitcoin. Unlike Bitcoin, validators don’t have
to wait until they mine a block in order to realize their rewards. In each block,
seigniorage is paid to all participating validators. This ensures stable, continuous
payments for honest validators, and eliminates the need to create pools.

A malicious validator, on the other hand, is punished through disincentives for
various types of undesirable activities such as attacks on
consensus, censorship and freeloading. The protocol is designed to penalize validators that
engage in such activities by burning a part of their stake, referred to as
slashing.

In addition to seigniorage payments, validators receive transaction fees paid by
the users. Similar to Ethereum, computation is metered by gas, where each operation
is assigned a cost in gas. However, unlike Ethereum, gas price is fixed in fiat terms,
meaning the expenses of using or hosting a dapp is stable and predictable.
Users do not have to choose a gas price when submitting their
transactions, which greatly simplifies the user experience. Once a transaction is executed,
used gas is calculated with the fixed gas price to calculate the transaction fee.
Unlike seigniorage,
transaction fees are collected by the block proposer, instead of being
distributed to all participating validators.


.. toctree::
   :maxdepth: 2
   :hidden:

   Introduction <self>
   tokens.rst
   seigniorage.rst
   transaction-fees.rst
   staking.rst
   slashing.rst

