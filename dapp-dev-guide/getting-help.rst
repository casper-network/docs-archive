
Getting Help
------------

FAQ
^^^
This section covers frequently asked questions and our recommendations.

Deploy Processing
~~~~~~~~~~~~~~~~~
**Question**: How do I know that a deploy was finalized?

**Answer**: If a deploy was executed, then it has been finalized. If the deploy status comes back as null, that means the deploy has not been executed yet. Once the deploy executes, it is finalized, and no other confirmation is needed. Exchanges that are not running a read-only node must also keep track of `finality signatures <#finality-signatures>`_ to prevent any attacks from high-risk nodes.

Finality Signatures
~~~~~~~~~~~~~~~~~~~
**Question**: When are finality signatures needed?

**Answer**: Finality signatures are confirmations from validators that they have executed the transaction. Exchanges should be asserting finality by collecting the weight of two-thirds of transaction signatures. If an exchange runs a read-only node, it can collect these finality signatures from its node. Otherwise, the exchange must assert finality by collecting finality signatures and have proper monitoring infrastructure to prevent a Byzantine attack.

Suppose an exchange connects to someone else's node RPC to send transactions to the network. In this case, the node is considered high risk, and the exchange must assert finality by checking to see how many validators have run the transactions in the network.

deploy_hash vs. transfer_hash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**Question**: How is a deploy_hash different than a transfer_hash?

**Answer**: Essentially, there is no difference between a `deploy_hash` and a `transfer_hash` since they are both deploy transactions. However, the platform is labeling the subset of deploys which are transfers, to filter transfers from other types of deploys. In other words, a `transfer_hash` is a native transfer, while a `deploy_hash` is another kind of deploy.

account-hex vs. account-hash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**Question**: Should a customer see the account-hex or the account-hash?

**Answer**: Exchange customers or end-users only need to see the `account-hex`. They do not need to know the `account_hash`. The `account_hash` is needed in the backend to verify transactions. Store the `account-hash` to query and monitor the account. Customers do not need to know this value, so to simplify their experience, we recommend storing both values and displaying only the `account-hex`.

Example Deploy
~~~~~~~~~~~~~~
**Question**: Can you provide an example of a deploy?

**Answer**: You can find a *testDeploy* reference in `GitHub <https://github.com/casper-ecosystem/casper-client-sdk/blob/master/test/lib/DeployUtil.test.ts#L5>`_.

Operating with Keys
~~~~~~~~~~~~~~~~~~~
**Question**: How should we work with the PEM keys?

**Answer**: The `Keys API <https://casper-ecosystem.github.io/casper-client-sdk/modules/_lib_keys_.html>`_ provides methods for `Ed25519` and `Secp256K1` keys. Also, review the tests in `GitHub <https://github.com/casper-ecosystem/casper-client-sdk/blob/master/test/lib/Keys.test.ts#L39>`_ and the `Working with Keys <https://docs.casperlabs.io/en/latest/dapp-dev-guide/keys.html>`_ documentation.




CasperLabs makes available the following resources for you to connect and get support where you can:


* Connect live with members of our Engineering Team on our `Discord Channel <https://discordapp.com/invite/mpZ9AYD>`_ available to support you with the progress of your projects.
* Join the `CasperLabs Community Forum <https://forums.casperlabs.io/>`_ that includes Technical discussions on using the CasperLabs features, obtain support, and pose questions to the CasperLabs core development team.
* Subscribe to CasperLabs Official `Telegram channel <https://t.me/CasperLabs>`_ for general information and update notifications about our platform.

If you have issues and bugs related to CasperLabs maintained smart contracts, you can `file an issue on our main GitHub repository <https://github.com/CasperLabs/CasperLabs/issues/new>`_\ , or `whichever repository the issue is related to <https://github.com/CasperLabs>`_.

Otherwise, if you...


* have questions that are not issues,
* need technical support,
* want to give feedback, or suggestions for improvement,
* or participate in a bounty,

you can use our `Jira Service Desk <https://casperlabs.atlassian.net/servicedesk>`_.
