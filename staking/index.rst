.. role:: raw-html-m2r(raw)
   :format: html

=======
Staking
=======

A feature of Proof-of-Stake protocols is that token holders can actively participate in the protocol 
through a mechanism known as **staking**.  

Persons that hold their private keys can choose to stake their tokens with any validator in the Casper network. 
Alternatively, it is possible to stake tokens via an exchange or custody provider as well.

This guide will outline the steps required to stake the CSPR token on the Casper network.


What you need to know before staking
=======

Please read the following sections carefully before staking tokens on the Casper network.

Slashing
--------

Casper does not treat delegated stake differently from validator stake.  If the validator is slashed, all tokens delegated to the validator will also be slashed.

Casper slashes for making inconsistent decisions, known as equivocations. Equivocations can happen if a validator is not careful with keys and spins up duplicate nodes or if a validator is malicious and tries to attack the network. 

An equivocating node is slashed at 100%.  All tokens staked to the node are slashed.
 

Delegation Rate
---------------

Node operators (Validators) define a commission that they take in exchange for providing staking services.  This commission is represented as a percentage of the rewards that the node operator retains for their services.

Rewards
-------

Validators receive rewards for participating in consensus by voting on blocks sending finality signatures (finalizing blocks). There is no precise *per-block* reward. Rewards are split proportionally among stakes within an era. If a validator is offline or cannot vote on many blocks, the rewards earned are also reduced. Delegators can only receive a proportional amount of the validator's rewards minus the validator’s commission (Delegation Rate).

Rewards are distributed at the end of each era.

Selecting a node for Staking
----------------------------

As a prospective delegator, it is important to select a validating node that you can trust.  Please do your due diligence before you stake your tokens 
with a validator.

Check in on your Stake
----------------------

It’s recommended that you check in on how your stake is performing from time to time.  If the validator you staked with decides to unbond, your stake will also be unbonded. Make sure that the validator you have selected is performing as per your expectations. 

Validators have to win a staking auction by competing with prospective and current validators for a  slot.  This process is permissionless, meaning validators can join and leave the auction without restrictions, except the unbonding wait period.


Unbonding Period
----------------

For security purposes, whenever a token is un-staked or un-delegated, the protocol will continue to keep the token locked for 14 hours.


Next Steps
==========

.. toctree::
   :maxdepth: 2

   staking.rst
