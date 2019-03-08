---
description: 'purses, etc.'
---

# Token

Here, we describe how tokens work on the CasperLabs platform. Many existing platforms use a single data structure \(such as a ledger or map of balances\) to keep track of tokens. However the problem with such a solution is that it does not scale; a single source of truth means that only a single transaction can be processed at a time. Contrast this with how cash works. Arbitrarily many cash transactions can happen in parallel because each individual needs to only use their own cash resources, independent of the balances of anyone else. _Purses_ are designed to obtain the same scalability as cash by distributing the resources, while also ensuring that they cannot be forged.

## Capability and Value

Fundamentally, all things with value must be limited in supply. In this case, this means that it should not be possible for an arbitrary person to create tokens. Yet, controlled inflation is a property of most crypto-currencies today, so we want new tokens to be created under some conditions. Therefore, the _capability_ to create new tokens must be delegated carefully. Similarly, the capability of taking tokens must be limited, while the capability of receiving tokens should be available to anyone.

Framing the problem in this way, we can apply concepts from _object capabilities_ \(OCaps\) literature to develop a solution which respects these requirements, while avoiding the single source of truth mentioned in the introduction. We will publish further information about OCaps, but for now we will focus on the idea of a reference which cannot be forged \(from here on referred to as an _unforgeable_ reference\). By "forged" we mean someone creating a copy of that reference without permission to do so; thus an unforgeable reference is one which can only be obtained from someone who already has the reference \(owning a reference gives you the ability to make a copy and send it to others\) or by creating a fresh reference that has not been used ever before.

An unforgeable reference can be used to securely define a mint \(creator of tokens\), as well as purses \(containers for tokens\). Moreover, each unforgeable references can represent a different token, thus natively allowing multiple tokens to exist together in a rich ecosystem. We say an unforgeable reference "labels" the type of token the mint can create or purse can hold.

## Mints and Purses

Let `R` be the set of unforgeable references and `r` $$\in$$ `R` an unforgeable reference which is used to label a type of token \(e.g. the native CasperLabs token\). Let `M` be the set of possible _mints_, which are objects having the capability to create tokens. `m(r)` $$\in$$ `M` is the mint which can create tokens of type `r`. Let `P` be the set of possible _purses_, which are objects with the capability to hold tokens. `P[r]` $$\subset$$ `P` is the set of possible purses which can hold tokens of type `r` and `p` $$\in$$ `P[r]` is a particular purse capable of holding tokens of type `r`.

For all `r` $$\in$$ `R` and `m(r)` $$\in$$ `M`, `m(r)` has the following method:

```text
create(n: Nat): P[r]
```

where `Nat` is the type for a non-negative number. Note that we are slightly abusing the notation here by using `P[r]` both as a set \(as defined above\) and as the return _type_ of methods that produce purses of a specific token \(such as `create`\). To be perfectly clear, the _value_ returned is a specific purse, i.e. some `p` $$\in$$ `P[r]`, we are simply declaring the _type_ of that value in the method definition above. Similarly, for the input `n`, we are saying that it is of _type_ `Nat`, but the _value_ of `n` will be some concrete number.

For all `r` $$\in$$ `R` and `p` $$\in$$ `P[r]`, `p` has the following methods:

```text
split(n: Nat): <Unit, P[r]>
merge(q: P[r]): Unit
balance(): Nat
```

where `<L, R>` denotes a "co-product" type, i.e. the result is either of type `L` or type `R` and `Unit` is a type used to indicate there is no meaningful return value. The `Unit` result case for `split` occurs when the balance of `p` is less than `n`. Note that the types of `split` and `merge` indicate that operations on purses of different tokens are undefined. This is done on purpose to prevent "turning lead into gold" \(i.e. accidentally exchanging tokens that do not have the same value\). Note also that, while we are presenting the API a mint and purse implementation must satisfy in terms of types, a specific implementation could be written in any language \(statically typed or not\); the properties of these objects are simply being defined in this \(convenient\) abstract framework.

Any valid implementation of these methods must satisfy the following laws:

### Create/balance identity

```text
m(r).create(n).balance() == n
```

### Merge correctness

```text
let p = m(r).create(n)
let q = m(r).create(k)
p.merge(q)
p.balance() == n + k
q.balance() == 0
```

Note that `merge` must be an atomic operation; there should be no case in which the balance of the destination purse increases and the balance of the source purse does not decrease.

### Split correctness

```text
let p = m(r).create(n)
let q = p.split(k)
if n >= k
  p.balance() == n - k
  q.castRight().balance() == k
else
  p.balance() == n
  q.isLeft() == true
```

Note that `split` must be an atomic operation; there should be no case in which a purse with non-zero balance is created without decreasing the balance of the original purse.

## Security Properties of Mints and Purses

The concept for mints and purses are based on ideas from OCaps, so the security model is different from those traditionally used in many financial contexts. Notice that the `split` method contains no arguments for verifying the identity \(e.g. a cryptographic signature\) of the agent requesting the withdraw. Therefore, anyone with access to the purse has the _capability_ to make a withdraw from it. Similarly, anyone with access to a `mint` can create new tokens of the corresponding type. Thinking about security in terms of capabilities instead of identities takes some getting used to, but allows for much safer, more powerful security patterns to be defined and enforced. In short, capabilities should be delegated as needed, so because the owner of a purse does not want anyone but themselves to be able to withdraw tokens, they hold the purse under an unforgeable reference which only they have access to. Other capabilities of the purse can still be shared via an _attenuated forwarder_. For example, it would be reasonable to make public a forwarder called `deposit` which only exposes the `merge` method of the underlying purse. This enables anyone to give the purse more tokens without compromising its security.

Similarly, owners of mints cannot expose `create` directly, otherwise there would be run-away inflation, however `create(0)` is safe because anyone should be able to create an empty purse. Defining an attenuated forwarder called `empty` makes it possible to expose only the creation of empty purses capability without risking the security of the mint itself.

Examples follow which illustrate some of the ways in which purses and other OCaps principles can be applied to writing secure interactions between parties.

## Examples

### Token transfer

This example is meant to help illustrate the concepts introduced with the mints and purses model. However a higher level `transfer` function will likely exist in the CasperLabs platform, so that clients do not need to worry about these details in day-to-day transactions.

The pseudo code snippet here expands on the example above making use of unforgeable references to secure a purse, but exposing only the `merge` capability through a public forwarder.

```javascript
//Alice sends Bob 10 tokens.
//We assume Alice and Bob both have purses of the same type of token.

let p = Alice.purse //only accessible by Alice
let bobPayment = p.split(10)
if bobPayment.isLeft() {
  //Alice had insufficient funds, return an error
} else {
  let bob = Bob.deposit //public reference to forward the merge method
  bob.merge(bobPayment.castRight())
}
```

### Lottery contract

The purpose of this example is to illustrate how purses could be held by contracts as well, and thus used to enforce some agreement about how tokens should be handled. In this example we consider a simple lottery contract, however this could be applied equally well to other financial agreements, e.g. multi-signature wallets, betting, auctions, etc.

In our simple example, we will assume that the game is played by each participant purchasing a "ticket" for a fixed number of tokens, and a single winner is chosen uniformly at random, who then is awarded all the tokens spent by all participants.

```javascript
//Type alias indicating that "tickets" are simply unforgable references.
//The idea is that a Ticket encodes the capability of claiming a prize, which
//only the owner of the ticket should be able to do.
type Ticket = URef

contract lottery:
  //Contract purse, assumed to work with Casper Labs (cl) tokens.
  //Note: creating an empty purse of a particular type of token should
  //always be allowed via a forwarder of the `create(0)` call.
  var p: P[cl] = empty()
  //map keeping track of who has won
  var winners: Map[Ticket, P[cl]] = Map.empty()
  //set keeping track of who has entered the next draw
  var candidates: Set[Ticket] = Set.empty()
  //value not important, one was chosen for the sake of the example
  const COST: Nat = 50


  //API for buying a lottery ticket
  //Note: a user calling this function should not supply their whole purse.
  //      Since only `COST` tokens are needed the user should only provide 
  //      that many tokens by splitting them off from their main purse.
  function play(q: P[cl]): <Unit, Ticket> = {
    //Ensure the right number of tokens were provided and take control of them
    //by putting them in a purse known only to the contract.
    let payment = q.split(COST)
    if payment.isLeft() {
      //error case omitted for brevity
    } else {
      p.merge(payment.castRight())
      //system function for returning a fresh unforgable reference
      let ticket = newURef()
      candidates.add(ticket)
      return ticket
    }
  }

  //API for selecting a winner
  function draw(): Unit = {
    //for simplicity we assume this function exists;
    //the details are not important for the sake of the example
    let winner = selectRandomElement(candidates)
    let prize = p.split(p.balance()).castRight()
    candidates.clear()
    winners.add(winner, prize)
  }

  //API for claiming your prize
  function claim(t: Ticket): <Unit, P[cl]> = {
    if winners.contains(t) {
      let prize = winners.get(t)
      winners.remove(t)
      return prize
    } else {
      //error case omitted for brevity
    }
  }
```

## Relationship to Existing Token Models \(E.g. ERC20\)

For readers familiar with ERC20 or similar specifications, the description here may seem to be missing some features \(e.g. max supply, "number of decimals", etc.\). This section is meant to help such readers connect what has been presented here with their understanding of these other platforms.

The supply of a particular token type is managed by the mint. At a practical level, this will typically mean that the only copy of the mint's core unforgeable reference that exists will be held by some smart contract with pre-defined rules \(which can be audited before deployment\) on how to increase the supply. The simplest case is where a fixed number of tokens are created in purses at the beginning \(perhaps the largest one being some kind of "reserve" that is given to the creator of the token\), and then the mint \(and its unforgeable reference\) is thrown away forever \(i.e. there actually is no contract which holds on to the mint\). This corresponds to the case of a fixed supply and the size of that supply is entirely up to the creator of the token. Another example would be an initial number of tokens is produced, but then the mint is also held by a contract which will periodically produce new tokens at an exponentially falling rate. This corresponds to a model similar to Bitcoin, where the total supply is finite, but it is not all made available at once like in the fixed supply case. These are just two example, but one of the benefits of the specification here is the freedom it provides to come up with other useful schemes for managing the supply of a custom token; the _logic_ of when to create tokens is totally decoupled from the mint, which is simply the _capability_ to create tokens.

It is well known to those writing software for dealing with money that floating point numbers are inadequate for representing monetary units which can be sub-divided \(e.g. dollars into cents, Bitcoin into Satoshi, Ether in to Wei\). This is because of the rounding error that floating point arithmetic can cause. This problem is solved by specifying a smallest, indivisible unit of the money and then representing all balances using whole numbers of those units. The "number of decimals" field in the ERC20 specification is simply saying how large the "logical" token is relative to this indivisible unit. For example, 1 Bitcoin is $$1 \times 10^8$$ Satoshi and 1 Ether is $$1 \times 10^{18}$$ Wei. In this specification we assume all balances are whole numbers \(denoted as `Nat` above\), so while we use the word token, it would perhaps be more accurate to say that the API is defined in terms of these indivisible units of tokens. Once again, the specification is purposely left flexible, and it is up to token creators to define a larger logical unit for their token if they so desire. For example, one could write a wrapper over a purse which will express the balance in different logical units for the user's convenience.

## Implementation Notes

In the conceptual motivation we refer to tokens as if they are objects themselves, however in the descriptions of mints and purses we do not give a definition of the token object; this is done purposely. The idea is that tokens do not need to exist as objects on their own because they are always held in purses, and a purse needs only to keep track of the number of tokens it has \(i.e. simply a number\). Therefore, the term "token" is used purely as a conceptual aid, and there is no corresponding object in a reasonable implementation of the above description.

It is clear from the type `P[r]` that purses must be aware of the type of token they contain, however this cannot be exposed directly, otherwise a malicious actor could use the unforgeable reference inside a purse to derive the original mint and thus break the capabilities model presented here \(i.e. only mints can create tokens and only purses can hold tokens\). This can be done by making the purse aware of an "equality-only" version of `r`, say `r*`, which does not provide the full capability of `r`, but is still able to distinguish itself from others. I.e. `r* == s*` if and only if `r == s`. By not providing the full capability we mean that `r*` $$\not \in$$ `R`, so cannot be used in place of `r` in any context \(in particular cannot be used to create a mint object\).

