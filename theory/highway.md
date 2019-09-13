# Highway

## Motivation

For a practically useful decentralized consensus protocol, proofs of two theorems must be provided:

- safety: a theorem saying that nodes cannot come up with conflicting decisions
- liveness: a theorem saying that nodes will keep making decisions (so, that the blockchain wil grow)

First theorem is really another name for the machinery of finality detectors. And it is the easie one. Second theorem tends to be substantially harder to prove and these difficulties are showing up in pretty much any blockchain design studied.

Despite the fact that "naive" design of a blockchain described in previous chapter can be actually implemented and its observed behaviour is promising, so sar we were not successful trying to achieve liveness theorem for it.

As part of this effort, we were actively looking for some hardening of assumptions that lead to provably live protocol, while maintaining our key goals intact, i.e to have a permisionless, full decentralized, Casper-based blockchain, compatible with broadcast-based message passing and partially synchronous network.

**Highway** is one of such attempts, which we found particularly promising. This is a variant of Casper, where liveness theorem is achieved via very careful validator behaviour, which enforces predictable structure of the emerging blockdag.

## Innovations in a nutshell

We generally see Highway as an evolution from Naive Casper Blockchain (later abbreviated as NCB), where key modifications are:

- Organize blocks creation around pseudorandomly generated sequence of leaders. Only a leader can produce a block.
- Use variable lenght of rounds based on the $2^n$ round lenght idea, so the blockchain network can self-adjust to achieve optimal performance.
- Replace continuous bonding/unbonding with era-based solution. This is necessary to keep the solution secure (so that attackers cannot tamper the leader sequence generator).

## New requirements

Interestingly, in comparison to NCB, we need only one new assumption, although a tough one - we need that validators have well synchronized real time clocks.

How to achieve such real time clocks and how to secure the network against intendent or unintented clock drift is in general beyond the shope of this specification. However, we give some hints on certain simple precautions to be made.

## Why "Highway"

To intuitively capture the key idea of $2^n$ round lenght trick, we once imagined a highway, well - a mathematical highway whith infinitely many lanes. Lanes are numbered with integers (all integers, also negative).

This highway is reather a strange one, because it is not for cars, but for frogs, moreover the speed of all frogs is constant. However, on the lane $n$ a frog makes $2^n$ jumps on a distance of one meter.

Therefore, if you switch to the lane on your left hand, you increase the freqency of jumping x2. In you switch to your right hand, you decrease the frequency x2.

Frogs from the lane on your left hand you meet on every jump you make. But frogs on your right hand you meed only every your second jump.

## Liveness strategy

### Ticks

Validators see time in a discrete way, namely - as number of ticks since some hardcoded point of real time. For simplicity we assume that ticks are just milliseconds since "epoch", which is Unix time representation standard.

### Leaders

There is a **leader** assigned to every tik. Leader is always one from currently staked validators.

The precise algorithm of calculating who is the leader of given tick is pretty convoluted and needs a machinery, we will establish step by step. For now it is enough to say that a validator has a recipe to calculate the leader of every tik.

### Rounds

In a leader based system, rounds are inevitable. because a leader cannot lead forever. Hence, it is supposed to lead during a single round.

Picking a fixed round lenght leads obviously to scaling issues. On the other hand, adjusting round lenght on-the-fly is tricky.

In Highway we approach the problem of automatic adjustment of round lenght in unique and unusual way. Every validator selects a private value $n \in Int$, which we call **round exponent**. Over time, a validator will be automatically adjusting this value to optimize its performance and the performance of the blockchain.

Given a round exponent $n$, the length of a round that a validator uses for its operation is $2^n$ ticks.

So, effectively, rounds live in sort of parallel worlds ("lanes of the highway"), where all validators with same round exponent $n$ have the same schedule of rounds. On the other hand, if we compare two validators **Alice** and **Bob**, **Alice** using round exponent $n$, **Bob** using round exponent $m$, and assuming $n < m$, then:

- **Alice** is $2^{m-n}$ faster than **Bob**
- **Alice** participates in all rounds that **Bob** knows about
- **Bob** participates only in some rounds that **Alice** knows about - once every $2^{m-n}$ **Alice**'s rounds

A round is identified by the tick at which it starts. Of course validators with different round exponents will differ in perspective on the lenght of this round.

**<u>Example:</u>** Alice has round exponent 5. Bob has round exponent 7. So, in Alice's world, rounds have length 32 ticks, while in Bob's world rounds have lenght 128 ticks. Timepoint 2019-09-13T13:13:13.088Z corresponds tick 1568380393088 and is a beginning of a round for both Alice and Bob. But, in Alice's world this round will last only for 32 milliseconds, while for Bob this round will last for 128 milliseconds.

### Validator operation

Contrary to NCB, the way ballots are used in Highway is more sophisticated.

In NCB a validator only produces ballots to continue his participation in **b-game**, after he did unbonding. In Highway, only the round leader is allowed to produce blocks, so if I am not the leader of current round, I am going to produce ballots only.

In details, local state and operation of a validator is similar to NCB. The difference is only that we impose very precise rule on when and how to create new message.

#### Rule 1: ignore rounds you cannot see

I operate as if the world is simple and everybody uses the same round exponent as I am using. Which means that I completely ignore existence of rounds starting at tiks not divisible by $2^n$, where $n$ is my round exponent.

#### Rule 2: follow the leader sequence

For every round I use the leaders pseudorandom sequence to figure out the id of validator which is the leader of this round.

#### Rule 3: lambda message

If I am the leader of current round, I produce new block $b$, using all tips of my local j-dag as justifications of $b$. Then I broadcast $b$ to all validators.

We call this message **the lambda message**. There is only one lambda message in every round.

#### Rule 4: lambda response message

If I am not the leader of current round, I setup a handler for receiving lambda message from this round's leader. This handler waits for the lambda message but only up to the end of current round. If the lambda message arrives before the end of current round, I create a ballot, taking as its justifications only the lambda message and my last message.

#### Rule 5: omega message

Let $j$ be the id of current round. At tick $j + R \cdot 2^n$ I create a ballot $b$, using all tips of my local j-dag as justifications of $b$.

## Adjustming round exponent

TBD

## Eras

### Boundary of an era

TBD

### Bonding and unbonding with eras

TBD

### Critical blocks and key blocks

TBD

### Schizophrenia of eras

TBD

## Structure of messages

TBD

## Long range attacks and checkpointing

TBD







