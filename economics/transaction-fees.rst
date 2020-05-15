Transaction Fees
----------------

When a user submits a transaction to perform some computation, the transaction uses up resources provided by network. To make cost accounting simpler, computational resources are denominated in a common unit of account called gas, as pioneered by Ethereum.

Once a transaction finishes execution, the total gas it ends up using is retrieved and multiplied by the gas price, to calculate the final transaction fee. When it is a validator’s turn to propose a block, the validator collects transactions from the transaction pool, executes them in a certain order, and publishes them in a new block. Fees in a block are collected by the block's proposer.

Flexible Payments
~~~~~~~~~~~~~~~~~

TBD

Gas Pricing
~~~~~~~~~~~

It is one of the goals of CasperLabs to maintain a certain level of predictability for users in terms of gas prices, and for validators in terms of transaction fees. Blockchains with unregulated fee markets are susceptible to high volatility in transaction fees, which get pushed up as demand rises and blocks become full.

To this end, as an initial step, Casperlabs is implementing a transaction pricing system that will assign fiat (dollar) prices to all relevant resources, such as bytes of storage, opcodes and standardized computation times for external functions. A successful implementation of this system requires a reliable on-chain feed of the CLX price in USD. To this end, CasperLabs will utilize the `Chainlink <https://chain.link>`_ network of oracles to aggregate a single price from major exchanges.

Normally, there would be no way to prioritize high value transactions with such a fixed price model. To mitigate this issue, we will set our gas price at a level high enough to curb any congestion the network might face on a consistent basis, e.g. `daily <https://solmaz.io/2019/10/21/gas-price-fee-volatility/>`_.
