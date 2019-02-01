# Sharding

## Motivation

_(MB: Should this be moved to another part of the paper instead of being in the technical section?)_

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

A _shard_ is an independently replicated blockdag, with its own independent set
of validators. In most respects, different shards are independent instances of
the Casper Labs platform. The exception to this is the Casper Labs native token,
which will be common throughout all shards. This allows clients to easily do
business in multiple shards, or move between shards as needed. The way in which
this is accomplished is by imposing a tree structure on the shards. There is a
single _root shard_, which is governed by the community and is where the Casper
Labs token mint lives (see [the tokens page](./tokens.md) for more information).
The root has zero or more _child shards_ who receive their supply of tokens from
the root via smart contracts detailed below. The intuition is that the tokens
available in a child shard are "backed" by tokens in its parent, all the way up
to the root where the original mint is. This is similar to how countries were
allowed to print money back when the "gold standard" was enforced. The purpose
of this system is to ensure smaller shards do not compromise the security of the
token supply because a parent shard will not accept more tokens to be
transferred back than were originally allocated. Therefore, even if a shard is
corrupt and its validators are producing invalid blocks which forge tokens,
these cannot impact the rest of the network because they can never be moved out
into the parent shard.

_(TODO: picture of an example shard tree probably needed @jack mills)_

### Communication between shards

Since different shards are independent blockdags, the only way they can
communicate is as clients of one another. However, for security reasons, it is
not sufficient to have one validator speak for the entire shard they are a part
of; instead there must be assurance that the shard as a whole agrees to the
communication and the message it conveys. For this purpose we introduce the
k-of-n (KON) blessed contract, which functions as a voting mechanism for
validators to agree with the sending of a message. At a high level, the contract
recognizes some participants, each with some weight (the total weight being
`n`), and has a threshold `k`, such that a proposal being voted on is only
accepted if at least a weight of `k` (out of the total `n`, hence the name)
agree. To save on the number of contract calls (and avoid stuck proposals), each
proposal has a time-to-live (TTL). The proposal must reach the threshold before
the TTL or it will be defeated. There is only votes in favour of a proposal, not
votes against, because not voting is considered equivalent to voting no. This
saves on the number of calls to the contract which is needed because nay-sayers
do not need to call the contract to give their opinion. We sketch the API of the
KON contract below.

```javascript
//weights are non-negative, whole numbers
type Weight = Nat
//time is measured in cumulative gas spent; a non-negative number
type Time = Nat

contract KON:
  var participants: Map[PublicKey, Weight]
  var threshold: Weight
  //We assume there is some Proposal data type which holds all 
  //the relevant information (TTL, yes-weight, effect).
  var activeProposals: Set[Proposal]

  //Note: all calls to the contract automatically prune the `activeProposals`
  //      removing the ones which have passed their TTL and applying the effects
  //      of those which have surpassed the threshold.

  //Proposal/vote to update the properties of this contract. The purpose of
  //not having a `vote` end-point is to prevent duplicate proposals from being
  //created. A call to `update` with a new set of parameters creates a new active
  //proposal, where as a call with a set of parameters which is already active
  //is a vote for that proposal. `ttl` does not count as a parameter of the proposal,
  //in the case they differ the larger `ttl` is always chosen; this means a proposal
  //can be kept alive as long as there is sufficiently frequent voting activity on it.
  //Note: the current participants must meet the current threshold for
  //      the change to be applied. If an update proposal is successful then
  //      all other existing active proposals are now compared against the
  //      new standards to determine if they are successful.
  function update(
      newParticipants: Map[PublicKey, Weight], 
      newThreshold: Weight,
      ttl: Time //proposal must be successful before `ttl`
    ): Unit
  
  //Proposal/vote to release tokens into a particular address. Once again
  //there is no `vote` end-point to avoid creating duplicate proposals.
  //More details about what how `release` has access to tokens to send to
  //the destination address are given in the next section.
  function release(amount: Nat, destination: Address, ttl: Time): Unit
```

Note that a parent shard will need separate KON contracts for each child it has.
In order to prevent shards from needing to watch each other's DAGs, the KON
contract containing the participants corresponding to validators in the parent
shard lives in the child shard, and vice versa. The disadvantage of this
approach is that shards need to keep each other up to date with
bonding/unbonding events that occur via cross-shard `update` proposals to the
KON contract. However, even though validators in one shard act as clients of the
other shard, calls validators make to the KON contract will not be charged in
the way user transactions normally are. It costs both parties resources to send
and process KON transactions, but both are also compensated. In the case of a
user transferring tokens from one shard to the other, the sender is compensated
because the user pays to initiate the transaction in that shard, and the
receiver is compensated because the value of their shard is increased by the
influx of new tokens. In the case of bonding/unbonding there is no explicit
compensation for either party; this is simply the overhead of continuing to do
business with one another. This overhead should be low though because KON
operations are reasonably simple (and therefore do not consume a large number of
resources), and bonding/unbonding operations will be much less common than
general user transactions.

### Moving tokens between shards

Each KON contract is paired with another contract for managing the tokens. This
contract is different depending on the shard's role (parent or child). The
parent shard has a `depository` contract, which holds the tokens that have been
sent to the child. The child shard has a local mint contract which creates "new"
tokens to correspond to those locked up in the parent's depository. The local
mint also accepts tokens to burn which will be released from the depository in
the parent (corresponding to moving the tokens back to the parent shard). The
`release` API of the KON contract is the only mechanism for taking tokens out of
the depository/local mint, while the API for giving tokens back to the
depository/local mint (this initiating a cross-shard transfer) is available to
all users. The API for the `depository` contract is given below. Note that the
same notation used on [the tokens page](./tokens.md) is used again to indicate
that a depository is parametric in the type of token (labelled by the unforgable
reference `r`) it uses.

```javascript
//Lives in the parent shard
contract depository
  //Local CasperLabs-type purse where the tokens transferred 
  //to the child are held.
  var lockup: P[cl]

  //Only accessible via the `release` endpoint of the corresponding 
  //KON contract (controlled by the child validators). Uses the `lockup` 
  //purse as the source of the tokens to send to the `destination`. 
  //If there are insufficient funds in the lockup
  //then whatever tokens remain are sent to the `destination`. This
  //prevents more tokens coming out of the depository than were put in.
  private function release(amount: Nat, destination: Address): Unit

  //Instructs the validators to call the `release` API in the child shard
  //once this transaction is finalized.
  function deposit(purse: P[cl], destination: Address): Unit
```

The API for the local mint contract is as follows:

```javascript
//Lives in the child shard
contract localMint
  //Local mint which is used to create the tokens that correspond
  //to those locked up in the depository.
  var mint: m(cl)

  //Only accessible via the `release` endpoint of the corresponding 
  //KON contract (controlled by the parent validators). The `mint` 
  //in this contract is used as the source of the tokens to send to 
  //`destination`.
  private function release(amount: Nat, destination: Address): Unit

  //Instructs the validators to call the `release` API in the parent shard
  //once this transaction is finalized.
  function deposit(purse: P[cl], destination: Address): Unit
```

To clarify the details of how cross-shard transactions work, we give the
following examples.

**Example 1: Transferring tokens from parent to child**
1. User makes a transaction in the parent shard calling the `deposit` API of the
   `depository` contract (paying for this operation in the parent)
2. As validators see the transaction be finalized they call the `release`
   endpoint of the KON contract in the child with the appropriate parameters.
   This operation costs resources for both parent and child, but both are also
   being compensated. The parent is compensated by the paid transaction in 1.
   and the child by the new tokens entering their shard as a result (increasing
   the value of their shard)
3. When the threshold in KON contract is reached, the new tokens are added to
   the purse at the target address in the child shard (this happens as a
   consequence of one of the KON calls in 2.)

**Example 2: Transferring tokens from child to parent**
1. User makes a transaction in the child shard calling the `deposit` API of the
   `localMint` contract (paying for this operation in the child)
2. As validators see the transaction be finalized they call the `release`
   endpoint of the KON contract in the parent with the appropriate parameters.
   This operation costs resources for both parent and child, but both are also
   being compensated. The child is compensated by the paid transaction in 1. and
   the parent by the new tokens entering their shard as a result (increasing the
   value of their shard)
3. When the threshold in KON contract is reached, the desired amount of tokens
   are taken from the depository and added to the purse at the target address in
   the parent shard (this happens as a consequence of one of the KON calls in
   2.). Note: if insufficient funds are available in the depository then only as
   many tokens that remain in the depository are taken.

_(MB: I am implying that validator nodes will have some logic to automatically detect when it needs to send a KON transaction to another shard. Is this reasonable?)_

### Creating and destroying shards

Fundamentally, a shard only exists as part of the Casper Labs blockdag ecosystem
because either (a) it is the root shard or (b) it has a corresponding
KON+depository contract pair in a parent shard which is part of the ecosystem.
The process of creating and destroying shards amounts therefore amounts to
creating and destroying KON+depository contracts (the root shard is never
created or destroyed, it simply _is_). A shard is created as a child of the root
shard by calling the _shard factory_ contract which produces the KON+depository
corresponding to the shard. The factory takes as parameters the initial KON
participants (i.e. initial shard validators), an initial endowment purse to seed
the depository (this is possibly empty, but non-empty if the genesis block
includes pre-minted Casper Labs tokens), and a shard identifier. The shard
identifier is used to identify nodes which belong to each shard (which is needed
for validators to send KON transactions back and forth). The shard factory will
not allow two shards to be created with the same identifier. Since new shards
(other than the root) are independent blockdags with their own genesis block, we
cannot guarantee that new shards will include the shard factory in the same way
the root has. However, it is encouraged that shards do so if they wish to have
child shards of their own.

_(MB: I am implying in the above paragraph that the P2P network will allow a node to connect to nodes of a different shard, but the node will know it only needs to talk to those nodes when a cross-shard transaction is taking place. Is this reasonable?)_

_(MB: I am also not specifying any restrictions on creating shards, so this operation could be very inexpensive and be used to create "dummy shards". This potentially interacts poorly with seigniorage)_

A shard is destroyed by telling the shard factory to destroy it. A shard can
only be destroyed if its depository is empty.

### Shards and seigniorage

It is planned that seigniorage will be part of the Casper Labs platform to
increase the token supply in a controlled way over time (see ... something ... do
we have a page on this in the whitepaper?). To ensure uniform growth of the
token supply, the seigniorage will also be applied to tokens which are locked up
in a root shard depository (thus increasing the tokens allocated to each child
shard). Again, because the child shards are independent from the root we cannot
guarantee that they will pass on any seigniorage onto their own children (if
they choose to even allow them).

## A Note of Caution

The independence of shards enables rich diversity in the ecosystem, however,
also comes with some risk. Tokens which are transferred into a depository are
technically under the control of the validators for that shard. There is no way
to guarantee that the tokens will appear in the destination address as the
protocol would dictate and no mechanism to re-obtain those tokens in the case
those validators are indeed faulty. Never commit tokens to a shard that you do
not trust.
