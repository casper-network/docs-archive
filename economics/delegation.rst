Delegation Details
===================

This section provides a detailed explanation of the delegation cost mechanism, how the gas cost relates with delegations, where to find the details etc. Please note that the cost amounts are likely to change with time, and you may have to check the latest release details to get the most up-to-date and accurate details.

Delegation Cost
---------------

The delegation cost is defined in the `chainspec.toml` file for each Casper Network. In this `example chainspec <https://github.com/casper-network/casper-node/blob/release-1.3.2/resources/production/chainspec.toml>`_ , the delegation is set to cost 2.5 CSPR. However, **when you perform the delegation, you see that it costs a little more** than what is specified in the `chainspec`. Let’s discuss why this happens.

When you delegate, the system charges some gas to set up related data in the global state of the network to track your delegation. This cost is in addition to the delegation cost defined in the `chainspec` file.

For example, the chainspec file in release `1.3.2` will contain the following information. This is how the delegation cost is defined in the `chainspec.toml` file of a Casper Network:

.. image:: ../assets/economic-delegationCost.png 
   :width: 400px 
   :align: center

**Figure 1** - Delegation cost is defined in the `chainspec.toml` file of a Casper Network.

On Testnet or Mainnet, the transaction fee for a delegation is a little bit higher than 2.5 CSPR.

.. image:: ../assets/economic-delegationDetails.png
   :width: 400px
   :align: center

|

Delegation fees may change over time, so it is essential to stay up to date. To do so, select the latest release in `Github <https://github.com/casper-network/casper-node>`_, and navigate to the `chainspec.toml` file. 

Command-Line Delegations
^^^^^^^^^^^^^^^^^^^^^^^^
When performing a `delegation using the command line <https://docs.casperlabs.io/en/latest/workflow/delegate.html>`_ , we recommend you specify a little more than the base transaction payment to ensure that the transaction will go through without failure. 


.. note::
   Transaction costs depend on each Casper Network and the cost tables defined in the `chainspec`. The examples you will find in the documentation are general.
|

Lastly, we recommend you try out delegations on the `Casper Testnet <https://testnet.cspr.live/>`_ before making actual transactions on the `Casper Mainnet <https://cspr.live/>`_. This way, you will understand the costs involved in delegating tokens.

If you are unsure about something, please join the `Discord channel <https://discord.gg/PjAQVXRx4Y>`_ to ask us questions.