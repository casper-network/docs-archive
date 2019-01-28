# Sharding

## Motivation

Sharding is often discussed in the blockchain space as being a scaling solution
(the term itself being borrowed from other distributed systems, e.g. databases).
However, the Casper Labs platform does not view sharding in this way for a few
reasons. First, our platform is already able to scale throughput via the
concurrent execution model and DAG structure. Nodes can both run and come to
consensus on many transactions in parallel, with the latter parallelism being
able to scale with the size of the network itself (the former being limited by
hardware, but we will come back to this point). Second, there are technical
challenges which to our knowledge have not been overcome by any Turing complete,
permissionless, trustless, blockchain platform. In particular, there is the
issue of verifying transactions in a block from another shard are correct (e.g.
do not contain a double-spend) when the premise of sharding is to divide up the
work among the nodes of the network. Either the verification is done by
re-running the transactions, in which case the work has not been divided up (so
there is no scaling benefit), or it is not, in which case there is an implicit
trust that the other shard is only producing valid blocks (so the network cannot
call itself trustless). One could argue that short proofs (i.e. ones which do
not require re-running all the transactions to prove their correctness) could
solve this problem, however no general method for doing this is known as of yet
in the Turning-complete smart contract setting.

What does sharding provide if not scalability? The answer is heterogeneity.
Existing blockchains are treated as a "single global computer", but this
implicitly assumes there is a "one-size fits all" computer capable of meeting
all use cases. This is obviously false as there are trade offs to be made in all
aspects of the blockchain space that are often talked about (e.g. speed,
security, decentralization, censorship-resistance), and not all use cases
require (or even can work with) the extreme end of these trade-offs. For
example, some industries (e.g. finance, medicine) have strict regulations about
where data can be located; in particular forbidding the usage of a "global
computer" to work with this data. Such regulations clearly limit the amount of
decentralization which can be allowed, yet such industries would still benefit
from the security and verifiability the blockchain offers. Similarly,
transactions which are fast-paced but low value (such as those at a typical
coffee shop) have a much higher requirement for speed as compared to those which
are rare but high value (e.g. purchasing of real estate or other high value, low
liquidity assets). This is idea alluded to above -- some use cases may have high
throughput requirements, which may in turn become requirements on the node
hardware, and this is then finally becomes a requirement of the shard which is
designed for this use case. Considering this example further, higher value
transactions have a higher need for security compared with lower value
transactions. Therefore, a shard designed for high value transactions may prefer
to have many, diverse validators, regardless of their hardware or geographic
location.

The ability to customize parts of the network to meet specific use cases is
essential to delivering a platform which all business sectors can find some
value. Our goal with sharding is to enable that customization. Note that we have
said nothing about removing the "global computer". In the trade-off space, one
can view this as preferring decentralization and security at the cost of speed
(since the rate data can be transferred around the globe is limited); this is a
customization which is completely allowed (and in fact will play a centrally
important role, as we will see).

## Technical Details
