Seigniorage
-----------

Seigniorage provides a base level of payments for validators so that they are
still compensated for their work even if there is not a lot of demand for
using the network. By issuing new CLX for validators, we ensure that
the network is secured by sufficient stake, even without the transaction fees.

CLX is issued at a fixed rate and distributed to validators in proportion to
their stake. This is analogous to block rewards in Proof of Work blockchains,
except for two major differences:

- The growth of CLX supply is exponential instead of linear.
- New CLX is minted at the end of each era, called the *era reward*, and distributed to validators
  proportional to their performance in that era.

The following formulas are used to calculate the amount of CLX minted at
the end of each era, which is equal to 1 week:

.. code-block::

   supply(i) = initial_supply * (1 + seigniorage_rate)^(i * era_length / year_length)
   era_reward(i) = supply(i + 1) - supply(i)

where :code:`i = 1, 2, ...` and so on is the era's index, :code:`initial_supply` is the number of CLX
at the Mainnet launch and :code:`seigniorage_rate` is the annual rate at which new CLX
is minted.
