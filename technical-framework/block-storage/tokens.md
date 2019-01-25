---
description: 'purses, etc.'
---

# Tokens

Here, we describe how tokens work on the CasperLabs platform. Many existing
platforms use a single data structure (such as a ledger or map of balances) to
keep track of tokens. However the problem with such a solution is that it does
not scale; a single source of truth means that only a single transaction can be
processed at a time. Contrast this with how cash works. Arbitrarily many cash
transactions can happen in parallel because each individual needs to only use
their own cash resources, independent of the balances of anyone else. _Purses_
are designed to obtain the same scalability as cash by distributing the
resources, while also ensuring that they cannot be forged.

## Capability and Value

Fundamentally, all things with value must be limited in supply. In this case,
this means that it should not be possible for an arbitrary person to create
tokens. Yet, controlled inflation is a property of most crypto-currencies today,
so we want new tokens to be created under some conditions. Therefore, the
_capability_ to create new tokens must be delegated carefully. Similarly, the
capability of taking tokens must be limited, while the capability of receiving
tokens should be available to anyone. 

Framing the problem in this way, we can apply concepts from _object
capabilities_ (OCaps) literature to develop a solution which respects these
requirements, while avoiding the single source of truth mentioned in the
introduction. For more information about OCaps, see [the
appendix](../appendix/ocaps-security.md), but for now we will focus on the idea
of a reference which cannot be forged (from here on referred to as an
_unforgable_ reference). By "forged" we mean someone creating a copy of that
reference without permission to do so; thus an unforgable reference is one which
can only be obtained from someone who already has the reference (owning a
reference gives you the ability to make a copy and send it to others) or by
creating a fresh reference that has not been used ever before.

This concept can be applied here by "labelling" each type of token by a
different unforgable reference and then using that label in each mint (creator
of tokens) and purse (container for tokens).

## Mints and Purses

Let `R` be the set of unforgable references and `r` $\in$ `R` an unforgable
reference which is used to label a type of token (e.g. the native CasperLabs
token). Let `M` be the set of possible _mints_, which are objects having the
capability to create tokens. `m(r)` $\in$ `M` is the mint which can create
tokens of type `r`. Let `P` be the set of possible _purses_, which are objects
with the capability to hold tokens. `P[r]` $\subset$ `P` is the set of possible
purses which can hold tokens of type `r` and `p` $\in$ `P[r]` is a particular
purse capable of holding tokens of type `r`.

For all `r` $\in$ `R` and `m(r)` $\in$ `M`, `m(r)` has the following method:
```
create(n: Nat): P[r]
```
where `Nat` is the type for a non-negative number. For all `r` $\in$ `R` and `p`
$\in$ `P[r]`, `p` has the following methods:
```
split(n: Nat): <Unit, P[r]>
merge(q: P[r]): Unit
balance(): Nat
```
where `<L, R>` denotes a "co-product" type, i.e. the result is either of type
`L` or type `R` and `Unit` is the trivial type with a single value. The `Unit`
result case for `split` occurs when the balance of `p` is less than `n`. Note
that the types of `split` and `merge` statically guarantee that operations on
purses of different tokens are undefined.

These methods satisfy the following laws:
### Create/balance identity
```
m(r).create(n).balance() == n
```
### Merge correctness
```
let p = m(r).create(n)
let q = m(r).create(k)
p.merge(q)
p.balance() == n + k
q.balance() == 0
```
### Split correctness
```
let p = m(r).create(n)
let q = p.split(k)
if n >= k
  p.balance() == n - k
  q.castRight().balance() == k
else
  p.balance() == n
  q.isLeft() == true
```

## An Implementation Note

It is clear from the type `P[r]` that purses must be aware of the mint they
originate from, however this cannot be exposed directly, otherwise a malicious
actor could use the unforgable reference inside a purse to derive the original
mint and thus break the capabilities model presented here (i.e. only mints can
create tokens and only purses can hold tokens). This can be done by making the
purse aware of an "equality-only" version of `r`, say `r*`, which does not
provide the full capability of `r`, but is still able to distinguish itself from
others. I.e. `r* == s*` if and only if `r == s`. By not providing the full
capability we mean that `r*` $\not \in$ `R`, so cannot be used in place of `r`
in any context (in particular cannot be used to create a mint object).
