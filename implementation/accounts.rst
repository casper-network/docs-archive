.. _accounts-head:

Accounts
========

.. _accounts-intro:

Introduction
------------

An *account* is a cryptographically secured gateway into the CasperLabs system
used by entities outside the blockchain (e.g. off-chain components of
blockchain-based applications, individual users). All user activity on the
CasperLabs blockchain (i.e. “deploys”) must originate from an account. Each
account has its own context where it can locally store information (e.g.
references to useful contracts, metrics, aggregated data from other parts of the
blockchain). Each account also has a “main purse” where it can hold CasperLabs
tokens (see :ref:`Tokens <tokens-purses-and-accounts>` for more information).

In this chapter we describe the permission model for accounts, their local
storage capabilities, and briefly mention some runtime functions for interacting
with accounts.

.. _accounts-data-structure:

The ``Account`` data structure
------------------------------

An ``Account`` contains the following data:

-  A collection of named keys (this plays the same role as the named keys in a
   :ref:`stored contract <global-state-contracts>`)
-  A ``URef`` representing the account’s “main purse”
-  A collections of “associated keys” (see below for more information)
-  “Action thresholds” (see below for more information)

.. _accounts-permissions:

Permissions model
-----------------

.. _accounts-actions-thresholds:

Actions and thresholds
~~~~~~~~~~~~~~~~~~~~~~

There are two types of actions an account can perform: a deployment, and key
management. A deployment is simply executing some code on the blockchain, while
key management involves changing the associated keys (which will be described in
more detail later). Key management cannot be performed independently, as all
effects to the blockchain must come via a deploy, therefore a key management
action implies that a deployment action is also taking place. The
``ActionThresholds`` contained in the ``Account`` data structure set a ``Weight``
which must be met in order to perform that action. How these weight thresholds
can be met is described in the next section. Since a key management action
requires a deploy action, the key management threshold should always be greater
than or equal to the deploy threshold.

.. _accounts-associated-keys-weights:

Associated keys and weights
~~~~~~~~~~~~~~~~~~~~~~~~~~~

As mentioned in the introduction, accounts are secured via cryptography. The
*associated keys* of an account are the set of public keys which are allowed to
provide signatures on deploys for that account. Each associated key has a
weight; these weights are used to meet the action thresholds provided in the
previous section. Each deploy must be signed by one or more keys associated with
the account that deploy is for, and the sum of the weights of those keys must be
greater than or equal to the deployment threshold weight for that account. We
call the keys that have signed a deploy the “authorizing keys”. Similarly, if
that deploy contains any key management actions (detailed below) then the sum of
the weights of the authorizing keys must be greater than or equal to the key
management action threshold of the account. Note that any key may be used to
help authorize any action; there are no “special keys”, all keys contribute
their weight in exactly the same way.

.. _accounts-key-management:

Key management actions
~~~~~~~~~~~~~~~~~~~~~~

A *key management action* is any change to any of the permissions parameters for
the account. This includes the following:

-  adding or removing an associated key;
-  changing the weight of an associated key;
-  changing the threshold of any action.

Key management action have validity rules which prevent a user from locking
themselves out of their account. For example, it is not allowed to set a
threshold larger than the sum of the weights of all associated keys.

.. _accounts-recovery:

Account security and recovery using key management
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The purpose of this permissions model is to enable keeping accounts safe from
lost or stolen keys, while allowing usage of capabilities of modern mobile
devices. For example, it may be convenient to sign deploys from a smart phone in
day to day usage, and this can be done without worrying about the repercussions
of losing the phone. The recommended setup would be to have a low-weight key on
the phone, only just enough for the deploy threshold, but not enough for key
management, then if the phone is lost or stolen a key management action using
other associated keys from another device (e.g. a home computer) can be used to
remove the lost associated key and add a key which resides on a replacement
phone. Note that it is extremely important to ensure there will always be access
to a sufficient number of keys to perform the key management action, otherwise
future recovery will be impossible (we currently do not support “inactive
recovery”).

.. _accounts-creating:

Creating an account
-------------------

Account creation happens automatically when there is a :ref:`token
transfer <tokens-purses-and-accounts>` to a yet unused :ref:`identity
key <global-state-account-key>`. When an account is first created,
the balance of its main purse is equal to the number of tokens transferred, its
action thresholds are equal to 1 and there is one associated key (equal to the
public key used to derive the identity key) with weight 1.

.. _accounts-context:

The account context
-------------------

A deploy is a user request to perform some execution on the blockchain (see
:ref:`Execution Semantics <execution-semantics-deploys>` for more information). It
contains “payment code” and “session code” which are contracts that contain the
logic to be executed. These contracts are executed in the context of the account
of the deploy. This means these contracts use the named keys of the account and
use the account’s local storage (i.e. the “root” for the :ref:`local
keys <global-state-local-key>` come from the account identity key). Note
that other contracts called from the session code by ``call_contract`` are
executed in their own context, not the account context. This means, an account
(with logic contained in session code) can be used to locally store information
relevant to the user owning the account.

.. _accounts-api-functions:

Functions for interacting with an account
-----------------------------------------

The `CasperLabs rust library <https://crates.io/crates/casperlabs-contract-ffi>`__
contains several functions for working with the various account features:

-  ``add_associated_key``
-  ``remove_associated_key``
-  ``update_associated_key``
-  ``set_action_threshold``
-  ``main_purse``
-  ``list_named_keys``
-  ``get_named_key``
-  ``add_named_key``
