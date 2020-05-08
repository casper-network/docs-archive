Transaction Fees
----------------

Users need to specify a fee when submitting their transactions. When it is a
validator’s turn to propose a block, the validator collects transactions from
the transaction pool, executes them in a certain order, and publishes them in a
new block. Fees in a block are distributed to all validators pro rata. This is
to weaken the incentive to steal transactions from other blocks, in case the
block proposer receives the whole fee.


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
CasperLabs will utilize the `Chainlink<https://chain.link>`_ network of oracles to aggregate
a single price from major exchanges.

