# Execution Semantics

## Motivation

One of the biggest challenges that blochchain faces is the one of throughput. When new projects are being evaluated people often compare how many transactions per second it can run and how does it compare to Visa \( according to some sources it may vary from [1700 TPS ](https://news.bitcoin.com/no-visa-doesnt-handle-24000-tps-and-neither-does-your-pet-blockchain/)to[ 4400 TPS](https://medium.com/@aat.de.kwaasteniet/the-nonsense-of-tps-transactions-per-second-2d7156df5e53) \). It is value that none of the currently operating blockchains can achieve. One of the fundamental design choices that new projects may make is to build a DAG \(directly acyclic graph\) rather than linear chain \(as it is done in Bitcoin or Ethereum\). The idea behind building a DAG is that validators may build a blockchain "in parallel" \(imagine multiple threads that originate from the same place, run in parallel but join at some point in the future to form a single thread again\). One of the fundamental issues with this design is conflict resolution. What to do when there are multiple transactions that want to modify the same account? We can't apply changes from all of them blindly. This may lead to overdraws \(or double spends\). This problem is not trivial and there are potentially multiple ways to solve it. This document presents how we do it in CasperLabs. 

## Commutativity of transactions

### Introduction

Let's consider the execution of transactions included in a single block. So we have a **Block\(B\)** and a collection of transactions:

$$
t_1, t_2, ..., t_n \in Block(B)
$$

As part of the validation of block **Block\(B\)**, any validator receiving this block has to execute all transactions so to calculate the global state after applying this block. In principle, all these transactions could be executed sequentially, which is the easiest approach and does not bring any problems. Unfortunately, it is also the slowest one.

Given the multi-core architecture of contemporary computers one is interested in exploiting all possibilities where things can be executed concurrently. In the case of transaction execution, we anticipate that vast majority of transactions are "independent" from each other, so their execution could be parallelized.

The approach we apply in execution engine is as follows: 

* We expect that blocks are marked as SEQ or PAR by their creator.
* If a block is marked as SEQ, we execute all transactions sequentially.
* If a block is marked as PAR, we assume these transactions are mutually independent, so we can execute them in parallel and then "merge" the resulting global state to reflect the final global state.

However along the parallel execution, some precautions must be taken to discover any possible violation of mutual independence of transactions rule. In such case we signal to the consensus layer that the badly marked block was found, so its creator may be punished for violation of the protocol.

In this chapter we formalize the intuitive concept of "mutual independent transactions". We explain how such a concept can be defined and we sketch the proof of its correctness.

### Transactions

Let GS denote the set of global states. So an element gs ∈ GS is just a fixed state of the memory of our "blockchain computer" \(which implementation-wise corresponds to a map from keys to values, as was explained [here](global-state.md)\):

$$
gs: Keys \rightarrow Values
$$

A transaction t is an execution of a program that reads the global state and possibly changes it. So it may be represented as a function:

$$
ts: GS \rightarrow GS
$$

**Caution**: Hidden here are assumptions about what features a smart contract programmer can access inside a body of a smart contract. No _random_ function is available. In other words, the execution of a transaction is completely determined by a global state is is applied to and parameters of the contract.

Further, it is not true that we are interested in every possible functions GS ⟶ GS. Really, we are only interested in computable functions, so functions implementable as Turing Machine programs, where the only extra feature is the access to our global state. Hence such programs are sequential by nature and every access to global state can be traced.

Formally, by transactions over GS we understand the following set:

$$
Transactions(GS) = { t \in GS^{GS}: t \space is \space computable }
$$

### Commutativity of transactions

Consider two transactions t1, t2 ∈ Transactions\(GS\) and a fixed global state gs ∈ GS. To express that t1 and t2 are mutually independent in the context of gs, we just want to say that it does not matter in which order we apply them to gs, because the final result is going to be the same anyway.

Formally, we say that transactions t1 and t2 are coherent in the context of global state gs∈ GS, iff

$$
t_1(t_2(gs)) = t_2(t_1(gs))
\newline or \space alternatively:
\newline (t_1 \circ t_2)(gs) = (t_2 \circ t_1)(gs)
$$

Obviously, this definition can easily be extended to a finite set of transactions: we say that a set T = {t1, ...., tn} is coherent in the context of global state gs∈ GS iff for all permutations p: {1, ..., n} ⟶ {1, ..., n}:

$$
(t_{p(1)} \circ t_{p(2)} \circ … \circ t_{p(n)}) (gs) = (t_1 \circ t_2 \circ … t_n)(gs)
$$

### Checking coherence

For a given set of transactions, unfortunately, checking their coherence is rather non-trivial and the cost of such checking may easily overweight any gain in performance achieved by parallel execution of transactions. So, we are only really interested in performing such check if it is doable in a reasonably cheap way.

A pretty straightforward check algorithm can be established by storing a trace of all accesses to the global state done by a transaction, and then checking for a possible conflict by comparing traces.

The intuition comes from a classical example in concurrent programming: the readers-writers problem. This is a situation where people \(=processes\) wait in a queue to access a library \(= data store\). Some of people want only to read data, others are willing to write data as well. Although this problem is mainly analyzed for solving the synchronization issues, it brings as a side effect some useful observations: readers are commutative and writers are not.

For tracing the execution of transactions, we extend the readers-writers model with one additional case. Let's look for example at the adding operation:

$$
+ : Int \rightarrow Int \rightarrow Int
$$

Adding is commutative, but in the context of mutating global state, we want to see adding as a function of one variable. For example:

$$
Add2: Int \rightarrow Int \newline
Add(2) = x + 2
$$

If we consider again the queue of processes that want to access the storage:

$$
Read \rightarrow Write \rightarrow Write \rightarrow Read \rightarrow Read \rightarrow Add2 \rightarrow Add42 \rightarrow Read
$$

then it is easy to notice, that we can shuffle consecutive readers and consecutive adders, but not writers. Also swapping a reader with a writer is going to be a problem.

The "adding" case can be actually generalized. We can change the order of any operations that come from a commutative Monoid \(like integers with adding, integers with multiplication or hash maps with merging\). We can generalize this even further, saying that apart from Read and Write operations, any commutative family of functions can be used, as long as we can easily recognize \(while tracing\) to which commutative family of functions given operation belongs.

Distinguished families of such commutative functions operating on Values are pre-selected and include most typical operations that we want to recognize as commutative: 

* numeric addition
* storing key-value pair in a map
* removing a key from a map
* merging maps
* adding element to a set
* removing elements from a set

Such a collection of selected commutative families of functions that are supported by the execution engine we will denote here as _CommutingFamilies_, or CF. So, using previously established notation for adding, we can recognize two example elements in _CommutingFamilies_ that cover the integer addition and adding element to sets of integers:

$$
\{ Add_i : i \in Int \} \in CF, where \space Add_i: Int \rightarrow Int, Add_i(x) = x + i
\newline
\{Add_a: a \in A\} \in CF, where \space Add_a: Set[Int]\rightarrow Set[Int] , Add_a(s) = s \cup \{a\}
$$

### Correctness theorem

We define a trace of execution of a transaction t to be an ordered sequence of _Ops_ capturing the sequence of accesses to the global state made by the program executing the transaction, once applied to a given gs ∈ GS:

$$
Trace(t, gs) = <op_1, op_2, …, op_n>
$$

Here, every op is a pair: &lt;address, signature&gt; where

$$
address \in Keys
\newline
signature \in \{ Read, Write, <cf, f> where \space cf \in CommutingFamilies \wedge f \in cf
$$

An example trace of execution could look like this:

$$
<203, Read>
\newline
<132, write>
\newline
<132, <Add, Add_51>>
\newline
<203, Write>
\newline
<203, Read>
<203, Read>
$$

We reduce such trace in two steps:

1. Grouping operations by address
2. Merging signatures in every, according to the following merging table:

<table>
  <thead>
    <tr>
      <th style="text-align:left"></th>
      <th style="text-align:left">Read</th>
      <th style="text-align:left">Write</th>
      <th style="text-align:left">
        <cf_2, ?>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Read</td>
      <td style="text-align:left">Read</td>
      <td style="text-align:left">Write</td>
      <td style="text-align:left">Write</td>
    </tr>
    <tr>
      <td style="text-align:left">Write</td>
      <td style="text-align:left">Write</td>
      <td style="text-align:left">Write</td>
      <td style="text-align:left">Write</td>
    </tr>
    <tr>
      <td style="text-align:left">
        <cf_2, ?>
      </td>
      <td style="text-align:left">Write</td>
      <td style="text-align:left">Write</td>
      <td style="text-align:left">
        <p>if (cf_1 = cf_2) cf_1</p>
        <p>else error</p>
      </td>
    </tr>
  </tbody>
</table>Above table could also be explained as follows:

* Writes conflicts with everything 
* Reads commute with Reads only 
* Members of a commutative family commute with other members of the same family

Finally, the reduced execution trace of a transaction t can be represented as a function:

$$
ReducedTrace(t, gs): K \rightarrow \{Read, Write\} \cup CF, where \space K \subset Keys
$$

For a pair of transactions t1, t2, and their traces ReducedTrace\(t1, gs\), ReducedTrace\(t2, gs\) we introduce the following way of checking if reduced traces are coherent:

$$
\forall k \space IsCoherent(k) : k \in Dom(ReducedTrace(t_1, gs)) \space \cap Dom(ReducedTrace(t_2,gs))
$$

where IsCoherent function is defined using following rules:

| IsCoherent | Read | Write | cf\_2 |
| :--- | :--- | :--- | :--- |
| Read | true | false | false |
| Write | false | false | false |
| cf\_1 | false | false | cf\_1 = cf\_2 |

**Theorem:** If two transactions t\_1 and t\_2 have coherent reduced traces they are coherent. Formally:

$$
\forall gs \in GS, \space \forall t_1,t_2 \in Transactions(GS)
\newline
ReducedTrace(t_1, gs) \sim ReduedTrace(t_2, gs) \implies (t_1 \circ t_2)(gs) = (t_2 \circ t_1)(gs)
$$

**Caution**: the inverse theorem is not true, which can be observed in the following examples.

**Example:** transactions commute but their reduced traces are not coherent.

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

This phenomenon happens thanks to the fact, that transaction 1 actually ignores the value retrieved from location 42. We are not able to detect this by just pure analysis of execution traces and the reduced traces coherence test will signal a potential conflict.

### Proof of theorem \(sketch\)

**Lemma**: Intuitively, only Read\(k\) operations influence how the program executing the transaction operates. For two global states gs1, gs2 ∈ GS, if the same transaction applied to gs1 created a different execution trace than when applied to gs2 then at some point of the trace there must be a Read\(k\) operation where gs1\(k\) &lt;&gt; gs2\(k\).

Assuming that t1 and t2 commute, we are going to prove:

$$
ReducedTrace(t_1, t_2(gs))\sim ReducedTrace(t_1, gs)
$$

This is to say that transaction t1 somehow is not able to notice that global state t2\(gs\) is different than gs and so it operates following exactly the same storage access flow in both cases. 

Let's assume the contrary is true so:

$$
ReducedTrace(t1, t2(gs)) <> ReducedTrace(t1, gs)
$$

Using lemma, this would mean that at some point of the trace there must be a Read\(k\) operation where gs\(k\) &lt;&gt; t2\(gs\)\(k\). Which is to say that some key k was modified by t2 and the same key k is being read by t1.

But modification of key k by transaction t2 must have been caused by Write\(k\) or CF\(k\). And at the same time, we claim that at the key k transaction t1 executes Read\(k\), because it still follows the original execution path.

This is, however, a contradiction with reduced trace calculation conditions \(see the table\).

End of the proof.

