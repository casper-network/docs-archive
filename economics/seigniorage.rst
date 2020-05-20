Seigniorage
-----------

Seigniorage provides a base level of payments for validators, so that they are
compensated for their work even if there is not a lot of demand for
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

Reward Distribution
~~~~~~~~~~~~~~~~~~~

In Highway, validators are rewarded for proposing and finalizing blocks. New tokens are minted at the end of each era through seigniorage, and distributed to validators according to their performance in that era. We do not have constant block rewards as in Proof of Work blockchains like Bitcoin and Ethereum—instead, block rewards are calculated retrospectively at the end of each era based on multiple factors, such as finality and participated weight. The concept of weight is crucial for understanding reward distribution, so we need to clarify what we mean by weight in different contexts:

- **Weight:** A validator’s bonded stake, used in consensus.
- **Assigned weight of a block/round:** The total stake of validators that are scheduled to participate on a block.
- **Participated weight of a block/round:** The total stake of validators that actually end up participating. Here, *participating* means sending messages to finalize a block before their respective rounds end.

In general, we look at two criteria to determine the validators’ eligibility to receive rewards from a proposed block:

- **On-time finalization (OTF):** Validators should finalize blocks on time, by sending required messages before their respective rounds end. We set OTF to require only a small but sufficient participating weight, for a simple reason: the probability of receiving a message on time decreases as the duration required for that approaches network propagation delay, so there is a trade-off between round lengths and assigned weight. We favor faster rounds over higher short-term safety guarantees, and argue that the latter can be achieved once the rounds end.
- **Eventual finality (EF):** Complementary to the lower safety guarantees of OTF, we want all validators voting for a block once a long enough time passes. This is possible, because validators that are not assigned to a block can still vote for it by participating on one of its descendants. The higher the weight voting for a block, the better.

We emulate the evolution of finality in Proof of Work blockchains by having validators to finalize a block with a relatively low but sufficiently high guarantee in the short run, and incentivizing them to provide the highest guarantee in the long run. This mirrors how a block becomes safer in Proof of Work as more blocks pile up on it.

For a given block, fractions of the block reward is allocated for OTF and EF respectively. Eligibility for OTF rewards follows an all-or-nothing approach: it is burned if the block is not finalized on time. EF eligibility, on the other hand, is on a sliding scale: the more weight votes on a block, the more of the allocated fraction is rewarded. This incentivizes validators to back a block with as much weight as possible in the long run.

Participation Schedule and Validator Rounds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The schedule with which validators send messages are determined by the validators’ rounds, which are in turn determined by their round exponents. A validator with the round exponent :code:`n` has to participate in rounds that repeat every :code:`2^n` ticks.

Each validator is assessed according to their own round exponent. All assigned validators become eligible to receive rewards as long as the block gets finalized with messages that were sent within each validator’s own round.

It is ideal to have the validators converge on the same round exponent, because then the participated weight would be maximized for each block. For that reason, reward allocated per block is a function of the total weight assigned to the corresponding tick.

We dictate a minimum assigned weight for all rounds. Rounds that meet the requirement are said to be *feasible*, and the ones that do not are said to be *infeasible*.

Reward Eligibility
^^^^^^^^^^^^^^^^^^

Once a block has been proposed and enough time has passed, the history of messages can be examined to detect whether the block was indeed finalized on time, according to the conditions given above.

- If the block is *not* finalized on time, validators do not receive any rewards. The tokens allocated for the block are simply burned.
- If the block is finalized on time, only the assigned validators share the allocated OTF reward pro rata, regardless of whether they have sent messages or not. However, EF rewards go to all validators.

Underestimating Round Exponents
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Truthful announcement of round exponents is essential for liveness. However, certain strategies exist where individual validators may earn more rewards by announcing a much lower round exponent than the majority of the validators, e.g. 0. This is basically a catch-all, where the validator is assigned to every tick, rewarded for feasible rounds with successful OTF, but not punished for being assigned to infeasible rounds. If left unaccounted for, such a strategy would increase the odds of receiving rewards. We do not want underestimating round exponents to be a dominant strategy, so we introduce a rule that punishes it:

If a validator assigns himself to :code:`N` (a protocol parameter) or more infeasible ticks consecutively, they do not receive any reward from their next feasible round. The allocated reward is simply burned.
