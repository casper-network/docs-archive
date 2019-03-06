# Decentralized Consensus

The purpose of the consensus algorithm is to determine the canonical execution path of the decentralized computer. This execution path is not linear but a DAG of multiple parallel and inter-locking paths. Some of these paths may subsequently be discovered to be in conflict in which case some will become dead ends, i.e. they will be "orphaned". The decentralized computer progresses by having nodes attach proposed blocks to then-current leaf blocks. Thus an important function of decentralized consensus is determining which leaf blocks should be parents of proposed blocks. Another important function is determining the conditions under which the sub-DAG rooted at a particular block is sufficient for that block to not be subsequently orphaned. Note that deploys in orphaned blocks can be subsequently included in proposed blocks.

The consensus algorithm operates by nodes exchanging proposal messages with each other. Proposal messages are simply the proposed block itself.

## Validators

All nodes may not provide the same level of service. Some operators may elect to participate in validating block proposals which will require them to expend compute and storage resources and for which they are compensated. Nodes operating in this mode are called "validators". Only validators participate in decentralized consensus, receive compensation, and can propose blocks. There is no restriction on which nodes may become validators and no particular node in the system is required to be validator. As the name implies, the purpose of validators is to validate that the consensus rules outlined below have been followed.

To incentivize honest behavior, in order to become a validator an operator must submit a "stake" which is held in escrow by the system. Operators become validators by submitting a deploy whose session contract \(not payment contract\) calls the aforementioned POS contract with a "bond" argument and the stake amount to transfer to the system. There are minimum and maximum stakes sizes.

The system holds the current stakes of all validators in a "vault". The compensation received by validators for proposing blocks \(and executing the deploys in those blocks\) is also stored in this vault as discussed further below.

Validators may increase or decrease their stake at any time by calling the POS contract with the appropriate argument. Stakes are increased with a "bond" argument \(including increasing their stake from zero\) and decreased with an "unbond" argument \(including decreasing it to zero\). Bonding and unbonding are deploys just like any other deploy, i.e. they are included in blocks which are approved by consensus among the then-current set of validators.

The node that issued the bonding deploy is able to act as a validator for any block that is a descendant of the block that includes this bonding deploy. Thus the set of validators is known for any block in the DAG.

Validators cannot blindly trust the behavior of other validators � fallible behavior must be assumed, whether caused by bugs, network or machine failure, or dishonesty. Therefore validators perform a series of checks on proposal messages they receive from other validators. This process is depicted in Figure 9.

![Figure 9: Block Validation Lifecycle](../../.gitbook/assets/wpfig9validationlifecycle.png)

When a proposed block arrives at a validator, the validator checks the block signature, constructs the pre-state for the proposed block, confirms commutativity for blocks with multiple parents, executes deploys in the block in the context of the pre-state \(confirming it calculates the same gas costs for each deploy\), confirms commutativity for blocks with concurrent execution semantics, confirms the hash of the post-state is equal to that in the propose message, and stores the proposed block in the block store.

Note that it's possible that the validator has not seen all \(or any\) parents of a proposed block. In this case the proposed block is saved in a buffer where it can be validated after arrival of all parents.

\[each validator's individual dag must be a chain; pdag+jdag\]

The operation of the decentralized consensus algorithms will be illustrated with an example DAG. For clarity this example is given under the following conditions: all multi-parent blocks commute, validator stakes do not change, no validator fails, all validators are honest.

Figure 10 depicts the DAG we will be using to illustrate the workings of the decentralized consensus algorithms. This diagram depicts the state of the DAG at a particular point with links pointing from child to parent. For clarity, and with no loss of generality, blocks are depicted as arriving in columns � in reality blocks arrive asynchronously with respect to each other. There are three validators: Orange, Purple, and Green � all three started as validators at system boot. Orange's stake is 75, Purple 50, and Green 25. At any point in time each node will see a different state of the DAG. Below each column, and for each validator proposing a block in that column, is a description of that state of the DAG seen by those validators.

Each validator sees a different DAG topology and this example is from the perspective of one of the validators proposing a block after having seen all blocks in the example.

![Figure 10: DAG Example](../../.gitbook/assets/wpfig10exampledag.png)

## Fork Choice Rule

When a fork exists in the DAG, a validator proposing a block must select one or more parents from the current leaf blocks � this is the role of the "fork choice rule". In simple terms, the fork choice rule prioritizes leaves by the stakes of their creators then by the gas expended by the decentralized computer on the execution paths leading to that leaf. The fork choice rule is based on two goals: \(1\) validators influence the behavior of the decentralized computer in proportion to their stakes; and \(2\) blocks that are the culmination of a larger expenditure of gas are preferred over those that are of a lesser expenditure. The fork choice rule uses two parameters corresponding to these two goals: score and cumulative gas. These are calculated for each block currently in the DAG.

\[requires using max number of leaves; in event of commute conflict, need to priority; if we're going to throw a leaf away, want to throw away the minumum amount of work\]

## Block Score

The first step in calculating block scores is to identify the latest block proposed by each validator. Note that a latest block may not be a leaf block but all leaf blocks will be latest blocks. The latest block for each validator is highlighted in red in Figure 11. Each of these blocks is assigned a weight equal to the stake of the creator.

![Figure 11: Calculating Block Scores](../../.gitbook/assets/wpfig11blockscores.png)

To calculate the score for a given block, start at that block, initialize its score to zero, then follow all incoming links \(i.e. from parent to child\) until a leaf block is reached. Along the way sum the weights of any latest blocks encountered.

We will illustrate with B6: We initialize B6's score to zero then follow the only incoming arc to B7. B7 is not a latest block so there is no change in score; it is not a leaf so we follow its incoming arcs to B9, B10, and B8. All of these are latest blocks so B6's score is incremented by their weights of 75, 50, 25 \(=150\). B9 and B10 are leaves but B8 is not. At this point we would normally follow the incoming arcs of B8 and continue the process. However, the maximum score for any block is the sum of all validator stakes which in this case is 150. Once a block's score reaches maximum there is no further need to continue DAG traversal.

And now for B5: We initialize B5's score to zero, follow the incoming arc to B8 which is a latest block with weight 25. We increment B5's score by 25 and follow the incoming arc to B10 which is also a latest block. We increment B5's score by 50 bringing the score to 75. B10 is a leaf and traversal terminates.

The score of a leaf block is simply the stake of its creator.

The score for all blocks in the DAG is given in red.

for block scores, may need justification arcs to determine "latest block", after that only need parent arcs; cannot select parent unless it and all it's decendants have been "processed" \(if a proposal message does not have all descendants in the block store then it's send to the foster block buffer\)

## Cumulative Gas

The fork choice rule also requires calculation of cumulative gas for each block which is illustrated in Figure 12. As stated earlier, blocks include the gas expended to execute each deploy in that block. These can be summed to get the total gas expenditure for a block. Total gas expenditure is listed inside each block in the diagram.

![Figure 12: Calculating Cumulative Gas](../../.gitbook/assets/wpfig12cumgas.png)

To calculate cumulative gas for a given block, start at that block, initialize its cumulative gas to zero, then follow all outgoing links \(i.e. from child to parent\) until genesis is reached. Along the way sum the total gas of each unique block encountered.

We will illustrate with B6 with the running total cumulative gas in square brackets in the following text: We initialize B6's cumulative gas to zero \[0\], then follow the outgoing arc to B4 which has a total gas cost of 6 \[6\], then to B3 \[10\], then to B1 \[20\] and B2 \[22\], then to genesis where traversal terminates \[22\].

Note that cumulative gas is the sum of total gas from only the unique blocks encountered during traversal. Figure 13 illustrates the calculation of cumulative gas for B7. We initialize B7's cumulative gas to zero \[0\], then follow the outgoing arcs to B6 \[8\] and B4 \[14\]. B6 also has an outgoing arc to B4 but B4's total gas has already been added so it's not added again. We continue with B3 \[18\], B1 \[28\], B2 \[30\], and terminate at genesis \[30\].

The cumulative gas for all blocks in the DAG is given in blue.

![Figure 13: Calculating Cumulative Gas](../../.gitbook/assets/wpfig13cumgas2.png)

With both block score and cumulative gas calculated for all blocks in the DAG, we can now apply the fork choice rule to determine parents. Figure 14 shows the score and cumulative gas for all blocks in the example DAG. A list of blocks is created containing only the genesis block. We then iteratively replace each block in the list with its children \(if any\) until the list only contains leaf blocks. For blocks with multiple children, said children are sorted first high-to-low in order of score, then high-to-low in order of cumulative gas, then by block hash \(which is guaranteed to be unique\). If there are duplicates on the list, the second and subsequent duplicates are removed. The table below delineates this process for the example DAG.

![Figure 14: Block Score and Cumulative Gas](../../.gitbook/assets/wpfig14scorecumgas.png)

Once the iteration process completes and there are only leaf blocks on the list. The first block on the list is required to be a parent \(B10 in this case\). For each subsequent block on the list, if that block commutes with all blocks then-currently on the list, then that block must also be a parent. In this example, if B9 commutes with B10 then it also must be a parent.

It should be noted that the actual implementation of the algorithms described above do not traverse the entire DAG between genesis and leaves in order to calculate block score or cumulative gas. A more efficient incremental algorithm is used.

## Finalization and Safety

Each block is finalized independently. \[but is it true that children cannot be finalized unless all their parents are?\]

It is therefore necessary for validators to be aware of the DAG \(leaves\) seen by all other validators. Parent arcs convey this information � since proposed blocks can only descend from then-current leaf blocks. When validators send a proposed block, they need to indicate the most recent blocks they have seen for all validators \(including themselves\). however some most recent blocks seen indication of observability but there are more � this is the role of "justifications". When a validator emits a proposed block, not only does it indicate parent blocks, it also indicates which blocks it has seen by all other validators \(that may not have been leaves\). There is an additional field in the block header for justifications.

Except for the first blocks proposed after genesis, the sum of parent arcs and justification arcs should equal total validator count.

Figure 15 depicts the example DAG with all justifcation arcs. These correspond to the descriptions of the state of the DAG seen by each validator given in Figure 10.

![Figure 15: Clique Oracle](../../.gitbook/assets/wpfig15cliqueoracle.png)

For clarity, and without loss of accuracy, in Figure ? Purple is shown as updating the clique oracle for B3 only when Purple sends a proposal. In reality validators update the affected clique oracles after successfully processing \[upon being stored into the block store\] each proposal message received.

what is known in the literature as a "clique oracle". The oracle is a graph with one vertex per validator where each vertex has a weight equal to the stake of the corresponding validator. There is a clique oracle per block constructed and updated by the block creator. When a block is first proposed, its clique oracle is created with none of the vertices connected by edges \(without any edges\). When a parent or justification arc is seen by that creator, an arc is added between the creator vertex and the vertex of the relevant validator. The sum of the weights of all currently connected vertices is the "safety" value. When this value reaches ? the block is considered finalized.

When B3 is proposed Purple creates B3's clique oracle with no connected vertices and initial safety of 50 \(by definition, at the time of proposal creators support their blocks\).

At the time Purple proposes B6 it has seen B4 \(indicated by the parent edge\) and B2 \(indicated by the justification edge\). Having seen B4 \(and therefore the parent edge from B4 to B3\) Purple now knows that Orange has seen B3. Therefore Purple adds an edge in B3's clique oracle between the Purple and Orange vertices and updates B3's safety to the sum of all then-currently connected vertices in the clique oracle \(125\).

At the time Purple proposes B10 it has seen B8 which requires that it had also seen B5. Having seen B5 \(and therefore the parent edge from B5 to B3\) Purple now knows that Green has seen B3. Therefore Purple adds an edge in B3's clique oracle between the Purple and Green vertices and updates B3's safety to 150. Having seen B8 \(and therefore the parent edge from B8 to B7\) Purple also knows that Green knows that Orange has seen B3 \(because of the B7 to B6 to B3 edges\). At this point all validators have seen B3 and Purple can confirm that other validators know that they have seen B3, and therefore B3 is finalized.

\[all validators are operating clique oracles for B3 � not just Purple. Purple can infer some of the state of other validators' B3 clique oracles from the parent and justificaton edges\]

This example did not need to make use of any justification edges but that is not generally the case.

It was noted earlier that some blocks \(or sub-DAG's of blocks\) may be "orphaned". The definition of "orphaned" is that the justification/parent edges reach a topology such that it can be determined that these blocks will never reach finalization. This was a simple example under the conditions described in the ? paragraph.

