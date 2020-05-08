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
