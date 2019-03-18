# Execution Semantics

## Motivation

One of the biggest challenges that blockchain faces is the one of throughput. When new projects are being evaluated people often compare how many transactions per second it can run and how does it compare to Visa \( according to some sources it may vary from [1700 TPS ](https://news.bitcoin.com/no-visa-doesnt-handle-24000-tps-and-neither-does-your-pet-blockchain/)to[ 4400 TPS](https://medium.com/@aat.de.kwaasteniet/the-nonsense-of-tps-transactions-per-second-2d7156df5e53) \). It is value that none of the currently operating decentralized blockchains can achieve. One of the fundamental design choices that new projects may make is to build a DAG \(directed acyclic graph\) rather than linear chain \(as it is done in Bitcoin or Ethereum\). The idea behind building a DAG is that validators may build a blockchain "in parallel" \(imagine multiple threads that originate from the same place, run in parallel but join at some point in the future to form a single thread again\). One of the fundamental issues with this design is conflict resolution. What to do when there are multiple transactions that want to modify the same account? We can't apply changes from all of them blindly. This may lead to overdraws \(or double spends\). This problem is not trivial and there are potentially multiple ways to solve it. This document presents how we address this in the CasperLabs platform.

## Commutativity of transactions

### Introduction

Let's consider the execution of transactions included in a single block. So we have a $$Block(B)$$ and a collection of transactions:

$$
t_1, t_2, ..., t_n \in Block(B)
$$

As part of the validation of block $$Block(B)$$, any validator receiving this block has to execute all transactions so to calculate the global state after applying this block. In principle, all these transactions could be executed sequentially, which is the easiest approach and does not bring any problems. Unfortunately, it is also the slowest one.

Given the multi-core architecture of contemporary computers one is interested in exploiting all possibilities where things can be executed concurrently. In the case of transaction execution, we anticipate that vast majority of transactions are "independent" from each other, so their execution could be parallelized.

The approach we apply in execution engine is as follows:

* We expect that blocks are marked as SEQ or PAR by their creator.
* If a block is marked as SEQ, we execute all transactions sequentially.
* If a block is marked as PAR, we assume these transactions are mutually independent, so we can execute them in parallel and then "merge" the resulting global state to reflect the final global state.

However along the parallel execution, some precautions must be taken to discover any possible violation of mutual independence of transactions rule. In such case we signal to the consensus layer that the badly marked block was found, so its creator may be punished for violation of the protocol.

In this chapter we formalize the intuitive concept of "mutual independent transactions". We explain how such a concept can be defined and we sketch the proof of its correctness.

### Transactions

Let GS denote the set of global states. So an element $$gs \in GS$$ is just a fixed state of the memory of our "blockchain computer" \(which implementation-wise corresponds to a map from keys to values, as was explained [here](global-state.md)\):

$$
gs: Keys \rightarrow Values
$$

A transaction t is an execution of a program that reads the global state and possibly changes it. So it may be represented as a function:

$$
ts: GS \rightarrow GS
$$

**Caution**: Hidden here are assumptions about what features a smart contract programmer can access inside a body of a smart contract. No _non-deterministic_ function is available. In other words, the execution of a transaction is completely determined by the global state it is applied to and parameters of the contract.

Further, it is not true that we are interested in every possible functions $$GS \rightarrow GS$$. Really, we are only interested in computable functions, so functions implementable as Turing Machine programs, where the only extra feature is the access to our global state. Hence such programs are sequential by nature and every access to global state can be traced.

Formally, by $$transactions\space over\space GS$$ we understand the following set:

$$
Transactions(GS) = \{ t \in GS^{GS}: t \space is \space computable \}
$$

{% hint style="info" %}
$$GS^{GS}$$ means "all possible $$GS \rightarrow GS$$ functions"
{% endhint %}

### Commutativity of transactions

Consider two transactions $$t_1, t_2 \in Transactions(GS)$$ and a fixed global state $$gs \in GS$$. To express that $$t_1$$ and $$t_2$$ are mutually independent in the context of gs, we just want to say that it does not matter in which order we apply them to gs, because the final result is going to be the same anyway.

Formally, we say that transactions $$t_1$$ and $$t_2$$ are commutative in the context of global state $$gs \in GS$$, $$iff$$

$$
t_1(t_2(gs)) = t_2(t_1(gs))
\newline or \space equivalently:
\newline (t_1 \circ t_2)(gs) = (t_2 \circ t_1)(gs)
$$

Obviously, this definition can easily be extended to a finite set of transactions: we say that a set $$T = \{t_1, …, t_n\}$$ is commutative in the context of global state $$gs \in GS$$ iff for all permutations $$p: \{1, …, n\} \rightarrow \{1, …, n\}$$:

$$
(t_{p(1)} \circ t_{p(2)} \circ … \circ t_{p(n)}) (gs) = (t_1 \circ t_2 \circ … t_n)(gs)
$$

### Checking commutativity

For a given set of transactions, unfortunately, checking their coherence is rather non-trivial and the cost of such checking may easily outweigh any gain in performance achieved by parallel execution of transactions. So, we are only interested in performing these checks if they are both possible and efficient.

A pretty straightforward check algorithm can be established by storing a trace of all accesses to the global state done by a transaction, and then checking for a possible conflict by comparing traces.

For tracing the execution of transactions, we extend the read-write model with one additional case. Let's look for example at the addition operation:

$$
+ : Int \rightarrow Int \rightarrow Int
$$

Adding is commutative, but in the context of mutating global state, we want to see adding as a function of one variable. For example:

$$
Add_2: Int \rightarrow Int \newline
Add_2(x) = x + 2
$$

If we consider the sequence of transactions that want to access the storage:

$$
Read \rightarrow Write \rightarrow Write \rightarrow Read \rightarrow Read \rightarrow Add_2 \rightarrow Add_{42} \rightarrow Read
$$

then it is easy to notice, that we can shuffle consecutive readers and consecutive adders, but not writers. Also swapping a reader with a writer \(or reader and adder\) is going to be a problem.

The "adding" case can be actually generalized. We can change the order of any operations that come from a commutative Monoid \(like integers with adding, integers with multiplication or hash maps with merging\). We can generalize this even further, saying that apart from Read and Write operations, any commutative family of functions can be used, as long as we can easily recognize \(while tracing\) to which commutative family of functions given operation belongs.

Distinguished families of such commutative functions operating on Values are pre-selected and include most typical operations that we want to recognize as commutative:

* numeric addition
* storing key-value pair in a map
* removing a key from a map
* merging maps
* adding element to a set
* removing elements from a set

Such a collection of selected commutative families of functions that are supported by the execution engine we will denote here as $$CommutingFamilies$$, or CF. So, using previously established notation for adding, we can recognize two example elements in $$CommutingFamilies$$ that cover the integer addition and adding element of type $$A$$ to $$Set[A]$$:

$$
\{ Add_i : i \in Int \} \in CF, where \space Add_i: Int \rightarrow Int, Add_i(x) = x + i
\newline
\{Add_a: a \in A\} \in CF, where \space Add_a: Set[A]\rightarrow Set[A] , Add_a(s) = s \cup \{a\}
$$

### Correctness theorem

We define a $$trace \space of \space execution$$ of a transaction $$t$$ to be an ordered sequence of $$actions$$ capturing subsequent accesses to the global state made by the program executing the transaction, once applied to a given $$gs \in GS$$:

$$
Trace(t, gs) = <action_1, action_2, …, action_n>
$$

Here, every $$action$$ is a pair: $$<key, op>$$ where

$$
key \in Keys
\newline
Op = \{ Read, Write \} \cup \{<cf, f>: \space cf \in CommutingFamilies \wedge f \in cf \} \\
op \in Op
$$

An example trace of execution could look like this:

$$
<203, Read> \\\
<132, Write> \\\
<132, <Add, Add_{51}>> \\
<203, Write> \\
<203, Read> \\
<203, Read> \\
$$

We reduce such trace in two steps:

1. Grouping operations by key
2. Merging operations in every group, according to the following merging table:

| + | Read | Write | Add |
| :--- | :--- | :--- | :--- |
| Read | Read | Write | Write |
| Write | Write | Write | Write |
| Add | Write | Write | $$if (cf_1 = cf_2) cf_1 <br> else error$$ |

* Members of a commutative family commute with other members of the same family

Finally, the reduced execution trace of a transaction t can be represented as a function:

$$
ReducedTrace(t, gs): K \rightarrow Op, where \space K \subset Keys
$$

For a pair of transactions $$t_1$$, $$t_2$$, and their traces $$ReducedTrace(t_1, gs)$$, $$ReducedTrace(t_2, gs)$$ we introduce the following way of checking if reduced traces commute:

$$
\forall k \space Commutes(k) : k \in Dom(ReducedTrace(t_1, gs))\space\cap Dom(ReducedTrace(t_2,gs))
$$

where $$Commutes$$ function is defined using following rules:

| Commutes | Read | Write | $$cf_2$$ |
| :--- | :--- | :--- | :--- |
| Read | true | false | false |
| Write | false | false | false |
| $$cf_1$$ | false | false | $$cf_1 = cf_2$$ |

**Theorem:** If two transactions $$t_1$$ and $$t_2$$ have commuting reduced traces they commute. Formally:

$$
\forall gs \in GS, \space \forall t_1,t_2 \in Transactions(GS)
\newline
ReducedTrace(t_1, gs) \sim ReducedTrace(t_2, gs) \implies (t_1 \circ t_2)(gs) = (t_2 \circ t_1)(gs)
$$

**Caution**: the inverse theorem is not true, which can be observed in the following example.

{% hint style="info" %}
We use $$\sim$$ \(tilde\) to denote that two things commute \(it doesn't matter in which order they are applied\).
{% endhint %}

**Example:** Transactions commute but their reduced traces don't.

{% code-tabs %}
{% code-tabs-item title="Transaction 1" %}
```javascript
Contract:
   val a = read(42)
   write(43, 1)
```
{% endcode-tabs-item %}
{% endcode-tabs %}

{% code-tabs %}
{% code-tabs-item title="Transaction 2" %}
```javascript
Contract:
   add(42, 1)
```
{% endcode-tabs-item %}
{% endcode-tabs %}

When reading above example contracts it's easy to see that transactions should be able to run in parallel \(each of them modified different key\). This is thanks to the fact that although transaction 1 reads from key 42 \(which transaction 2 modifies\) but it ignores its value. Unfortunately, we are not able to detect this by just pure analysis of execution traces and the reduced traces commutativity test will signal a potential conflict.

### Proof of theorem \(sketch\)

**Lemma**: Intuitively, only $$Read(k)$$ operations influence how the program executing the transaction operates. For two global states $$gs_1, gs_2 \in GS$$ if the same transaction applied to $$gs_1$$ created a different execution trace than when applied to $$gs_2$$ then at some point of the trace there must be a $$Read(k)$$ operation where $$gs_1(k) \not = gs_2(k)$$.

Assume that $$ReducedTrace(t_1, gs) \sim ReducedTrace(t_2, gs)$$. We are going to prove:

$$
ReducedTrace(t_1, t_2(gs)) = ReducedTrace(t_1, gs)
$$

This is to say that transaction $$t_1$$ is not affected by $$t_2(gs)$$ and so it operates following exactly the same storage access flow in both cases.

Let's assume the contrary is true:

$$
ReducedTrace(t_1, t_2(gs)) \not = ReducedTrace(t_1, gs)
$$

Using lemma, this would mean that at some point of the $$t_1$$trace there must be a $$Read(k)$$ operation where $$gs(k) \not = t_2(gs)(k)$$. Which is to say that some key _k_ was modified by $$t_2$$ and the same key _k_ is being read by $$t_1$$. This, however, contradicts our assumption that $$t_1$$and $$t_2$$ commute.

End of the proof.

