Transaction Fees
----------------

When a user submits a transaction to perform some computation, the transaction uses up resources provided by network. To make cost accounting simpler, computational resources are denominated in a common unit of account called gas, `as pioneered by Ethereum <https://docs.ethhub.io/using-ethereum/transactions/>`_.

Once a transaction finishes its execution, the total gas it ends up using is retrieved and multiplied by the gas price, to calculate the final transaction fee. When it is a validator’s turn to propose a block, the validator collects transactions from the transaction pool, executes them in a certain order, and publishes them in a new block. Fees in a block are collected by the block's proposer.

Gas Pricing
~~~~~~~~~~~

It is one of the goals of CasperLabs to maintain a certain level of predictability for users in terms of gas prices, and for validators in terms of transaction fees. Blockchains with unregulated fee markets are susceptible to high volatility in transaction fees, which get pushed up as demand rises and blocks become full.

To this end, as an initial step, Casperlabs is implementing a transaction pricing system that assigns fiat (dollar) prices to all relevant resources, such as bytes of storage, opcodes and standardized computation times for external functions. A successful implementation of this system requires a reliable on-chain feed of the CSPR price in USD. To this end, CasperLabs utilizes a network of oracles to aggregate a single price from major exchanges.

Normally, there would be no way to prioritize high value transactions with such a fixed price model. To mitigate this issue, we will offer a gas futures market, enabling users to book space in future blocks at current prices.

Flexible Payments
~~~~~~~~~~~~~~~~~

A major feature of Highway is the ability to implement arbitrary payment logic with :ref:`payment codes <execution-semantics-payment>`. This has a number of advantages:

- It enables dapp maintainers to pay for the transactions of their users without additional complexity, greatly improving the onboarding of new users.
- It allows the platform to support all kinds of payment schemes that future businesses might want to adapt.
- It makes it possible to have multiple parties pay for a transaction, or contracts that pay for their own transactions.

Payment codes render Highway future-proof, that is, its economic layer has enough room for every possibility that one can imagine.
