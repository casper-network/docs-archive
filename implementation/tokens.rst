.. _tokens-head:

Tokens
======

.. _tokens-intro:

Introduction
------------

The Casper Network is a decentralized blockchain platform based on a Proof-of-Stake consensus algorithm called `Highway <https://github.com/CasperLabs/highway>`_. Having a unit of value is required to make this system work because users must pay for computation, and validators must have `stake <https://docs.casperlabs.io/en/latest/staking/index.html>`_ to bond. In the blockchain space, this unit of value is a *token*.

This chapter describes how we define tokens and how one can use them on the Casper platform.

Token Generation and Distribution
---------------------------------

A blockchain system generally needs to have a supply of tokens available to pay for computation and reward validators for processing transactions on the network. A great deal of effort has been taken to ensure that no single individual or entity acquires more than 1% of the tokens from the onset.

In addition to the initial supply, the system will have a low rate of inflation, the results of which will be paid out to validators in the form of seigniorage.

The number of tokens used as a basis for calculating seigniorage is 10 billion.

.. _tokens-divisibility:

Divisibility of Tokens
----------------------

Typically, a *token* is divisible into some number of parts. We call the indivisible units which make up the CSPR token *motes*. Each CSPR is divisible into :math:`10^{9}` motes. To avoid rounding errors, it is essential to always represent token balances in motes.  In comparison, Ether is divisible into :math:`10^{18}` parts called Wei.

.. _tokens-mints-and-purses:

Mints and Purses
----------------

A *mint* is a contract that can produce new motes of a particular type. We allow for multiple mote types (each of which would have its mint contract) because we anticipate the existence of a large ecosystem of different tokens, similar to the way Etherum works with ERC20 tokens. Casper will deploy a specific mint contract, and it will manage the CSPR utility token (used for paying for computation and bonding onto the network). The mint also maintains all the balances for its type of mote. Each balance is associated with a ``URef``, which acts as a key to instruct the mint to perform actions on that balance (e.g., transfer motes). Informally, we will refer to these balances as *purses* and conceptually represent a container for motes. The ``URef`` is how a purse is referenced externally, outside the mint.

The ``AccessRights`` of the :ref:`URefs <global-state-urefs-permissions>` permissions model determine what actions are allowed to be performed when using a ``URef`` associated with a purse.

As all ``URef``\ s are unforgeable, so the only way to interact with a purse is for a ``URef`` with appropriate ``AccessRights`` to be given to the current context in a valid way (see :ref:`URefs <global-state-urefs-permissions>` permissions for details).

The basic global state options map onto more standard monetary operations according to the table below:

=================== =============================
Global State Action Monetary Action
=================== =============================
Add                 Deposit (i.e. transfer to)
Write               Withdraw (i.e. transfer from)
Read                Balance check
=================== =============================

We will use these definitions throughout this chapter to describe the implementation and usage of tokens on the Casper system.

.. _tokens-mint-interface:

The mint Contract Interface
-----------------------------

A valid mint contract exposes the following methods (recall that many mint implementations may exist, each corresponding to a different currency):

-  ``transfer(source: URef, target: URef, amount: Motes) -> TransferResult``

   -  ``source`` must have at least ``Write`` access rights, ``target`` must have at
      least ``Add`` access rights
   -  ``TransferResult`` may be a success acknowledgment or an error in the case of
      invalid ``source`` or ``target`` or insufficient balance in the ``source`` purse

-  ``mint(amount: Motes) -> MintResult``

   -  ``MintResult`` either gives the created ``URef`` (with full access rights),
      which now has a balance equal to the given ``amount``; or an error due to the
      minting of new motes not being allowed
   -  In the Casper mint, only the system account can call ``mint``, and it has
      no private key to produce valid cryptographic signatures, which means only
      the software itself can execute contracts in the context of the system
      account

-  ``create() -> URef``

   -  a convenience function for ``mint(0)`` which cannot fail because it is always
      allowed to create an empty purse

-  ``balance(purse: URef) -> Option<Motes>``

   -  ``purse`` must have at least ``Read`` access rights
   -  ``BalanceResult`` either returns the number of motes held by the ``purse``, or
      nothing if the ``URef`` is not valid

.. _tokens-using-purses:

Using purse ``URef``\ s
-----------------------

It is dangerous to pass a purse's ``URef`` with ``Write`` permissions to a contract. A malicious contract may use that access to take more tokens than were intended or share that ``URef`` with another contract that was not meant to have that access. Therefore, if a contract requires a purse with ``Write`` permissions, it is always recommended to use a “payment purse” -- a purse used for that single transaction and nothing else. This ensures that even if the ``URef`` becomes compromised, it does not contain any more funds than the user intended on giving.

.. code:: rust

   let main_purse = contract_api::main_purse();
   let payment_purse = contract_api::create_purse();

   match contract_api::transfer_purse_to_purse(main_purse, payment_purse, payment_amount) {
       TransferResult::Success => contract_api::call_contract(contract_to_pay, payment_purse),
       _ => contract_api::revert(1),
   }

To avoid this inconvenience, it is a better practice for application developers intending to accept payment on-chain to make a version of their own purse ``URef`` with ``Read`` access rights publicly available. This allows clients to pay via a transfer using their purse, without either party exposing ``Write`` access to any purse.


.. _tokens-purses-and-accounts:

Purses and Accounts
-------------------

All :ref:`accounts-head` on the Casper system have a purse associated with the Casper system mint, which we call the *main purse*. However, for security reasons, the ``URef`` of the main purse is only available to code running in the context of that account (i.e. only in payment or session code). Therefore, the mint’s ``transfer`` method which accepts ``URef``\ s is not the most convenient to use when transferring between account main purses. For this reason, Casper supplies a `transfer_to_account <https://docs.rs/casper-contract/latest/casper_contract/contract_api/system/fn.transfer_to_account.html>`_ function which takes the public key used to derive the
:ref:`identity key <global-state-account-key>` of the account. This function uses the mint transfer function with the current account’s main purse as the ``source`` and the main purse of the account at the provided key as the ``target``.
