Gas on the Casper Blockchain
==============================

What is gas?
-------------

Gas is the virtual measure of resources utilized when executing transactions on the blockchain. Gas cost is the amount of gas consumed during the virtual processing cycles that execute a transaction on the network. 
Gas is consumed on the network irrespective of whether your transaction was successful or failed. Even when a transaction fails, you have to pay for the validation and computation of the transaction. 

How is gas cost determined?
----------------------------

The amount of gas required for a transaction is determined by how much code is executed on the blockchain. This amount of gas required for execution is the gas cost of the transaction. Currently, gas is allocated at a fixed price of 1 mote (1/10^9 part of a CSPR token) per 1 unit of gas. The gas charged for a transaction on the blockchain is paid to validators securing the network.

Why do we need gas cost?
-------------------------

Casper is a decentralized network of individual validators supplying their computational resources to keep the network live. As such, computations must be rate-limited and priced for the following reasons:

-   Rate-limiting is used for increased security and an efficient engineering system:

    -   Restricts a denial-of-service (DoS) attack. In computer networks, rate-limiting is used to control the rate of requests sent or received by a network to prevent DoS attacks.
    -   Explicitly quantifies system load. The gas cost helps us evaluate the use of computational resources and measure the amount of computational work that validators need to perform for each transaction.

-   Pricing allows for better productivity:

    -   Enables allocation of resources to highest productivity uses. Issuers of transactions and smart contract writers would be more mindful of the network resources used because there is a cost associated with each transaction. This way, we hope that network resources are used in the most efficient way possible.

Why do I see an ‘Out of Gas’ error?
------------------------------------

You might encounter an ‘Out of Gas’ error when the `gas <gas-concepts.html#what-is-gas>`_ allotted for the transaction was insufficient to cover the cost of computation for the transaction. The amount of gas required for a transaction is determined by how much code is executed on the blockchain and also the storage utilized. 
Here is an `example <https://cspr.live/deploy/afeb43036c41e667af8bc34782c48a66cf4da3818defe9f761291fa515cc38b9>`_ of a transaction resulting in an out of gas error on Mainnet.

**Figure 1**: In the “Deploys” tab of an account, a red exclamation mark is shown. By moving the cursor over it, the tooltip displays “Out of gas error”.

.. image:: ../assets/gas-concepts/error-deploys.png
    :width: 550
    :alt: Out of gas error

**Figure 2**: Clicking on the specific deploy, we see more details about the deploy such as the “Deploy Hash”, “Cost”, and the “Status” as an “Out of gas error”.

.. image:: ../assets/gas-concepts/error-account.png
    :width: 550
    :alt: Gas error in account

**Figure 3**: Clicking on the “Show raw data” button, you can see more details about the deploy.

.. image:: ../assets/gas-concepts/error-raw.png
    :width: 550
    :alt: Gas error in raw data

How do I determine the gas cost for a transaction?
----------------------------------------------------

Currently, we are hard at work to create tools to help you estimate gas costs. Meanwhile, we recommend using the NCTL tool on your local machine or the `Testnet <https://testnet.cspr.live/>`_ to `deploy your contracts <https://docs.casperlabs.io/en/latest/dapp-dev-guide/deploying-contracts.html?highlight=gas%20cost#deploying-contracts>`_ in a test environment. You can check a deploy status and roughly see how much it would actually cost when deployed. You can estimate the costs in this way and then add a small buffer if the network state has changed. Note that when estimating gas cost locally or on the Testnet, the blockchain specification needs to match the specification of the Mainnet or the network where you wish to deploy your smart contract, where you need to pay for the transaction with actual CSPR tokens.

Why do I see a gas limit error?
--------------------------------

You sometimes see an error ‘payment: 2.5, cost: 2.5, Error::GasLimit’, this message seems to say that it costs 2.5 CSPR and you paid 2.5 CSPR, yet the transaction resulted in an error. Let’s explore this error message.

When a smart contract hits its gas limit, execution stops. If your limit is 2.5 CSPR, execution stops and that is the computation cost even if the smart contract did not run to completion. So, the error message tries to communicate that execution stopped after 2.5 CSPR. The computation resulted in an error because there were not enough funds to run to completion. It would have cost more than 2.5 CSPR to complete execution, but since one only paid for 2.5 CSPR worth of computation, we stopped there and charged that much. The execution engine does not actually know how much it would have cost if allowed to run to completion, because it did not allow the contract to finish since the contract would have run over its gas limit.
