How to Stake your CSPR
======================

1. Introduction
^^^^^^^^^^^^^^^
Casper and other Proof-of-Stake protocols allow token holders to earn rewards and participate in the protocol through a mechanism called **staking**. This tutorial shows you how to stake your Casper tokens with a validator on the network. This process is also called **delegation**. We will use these terms interchangeably in this guide, but we will explain the technical difference for clarity.

This video guide covers the process at a high level, but we recommend following the written tutorial to go through the process step by step.

.. raw:: html 

    <iframe width="560" height="315" src="https://www.youtube.com/embed/4C7L5lS284c" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
|

**Staking**

Node operators stake their own tokens to earn the eligibility to propose and approve blocks on the network. For this reason, we also refer to them as validators. They also run and maintain servers connected to the Casper Network. With these actions, node operators enable the Proof-of-Stake aspect of the network. This process is different from mining tokens. Validators thus earn rewards for participating and for securing the network.

**Delegating**

You can also participate in the protocol to earn rewards without maintaining a Casper node (a server that stores a copy of the blockchain). To accomplish this, you can delegate or allocate your CSPR tokens to a chosen node operator on the network. The node operator will retain a commission, which is a percentage of the rewards generated from your staked tokens. By participating in the protocol this way, you help improve the network's decentralization and security and earn rewards in return. The base annual reward rate is currently 8% of the total supply.

This tutorial will show you how to earn rewards by delegating your Casper tokens. We will also cover the steps to undelegate your tokens at the end of the tutorial.


1. Staking Overview
^^^^^^^^^^^^^^^^^^^
Staking the process by which node operators participate in the blockchain network. It is important to understand the fundamentals of staking because when you delegate your tokens to a validator, they will be staking those tokens on your behalf. Here are a few common topics related to staking, but we encourage you to do your own research.

**Slashing**

Presently Casper does not slash if a node operator equivocates or misbehaves. If a node equivocates, other validators will ignore its messages, and the node will become inactive.

**Commission**

Node operators (also known as validators) define a commission they take to provide staking services. This commission is a percentage of the rewards node operators take for their services.

**Rewards**

Validators receive rewards, proportional to their stake, for participating in the network. Delegators receive a portion of the validator's rewards, proportional to what they staked, minus the validator's commission (or delegation rate).

**Validator Selection**

As a prospective delegator, you need to select a validating node that you can trust. Please do your due diligence before you stake your tokens with a validator.


3. Creating your Wallet with the CasperLabs Signer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To stake tokens, you need access to a wallet with CSPR tokens. At the moment, you can use the `CasperLabs Signer <https://chrome.google.com/webstore/detail/casperlabs-signer/djhndpllfiibmcdbnmaaahkhchcoijce>`_ tool. The Signer acts as your CSPR wallet, keeping your accounts secure and helping you perform actions like staking, un-staking, or sending tokens to another account. Please follow `the Signer Guide <https://docs.cspr.community/docs/user-guides/SignerGuide.html>`_ for additional details on how to set up this tool.

You can create, store, and use one or more CSPR accounts with your Signer wallet. A password protects all accounts in what we call a **vault**.

3.1 Signing in to the CasperLabs Signer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you are new or have logged out of the Signer, you can log in with these steps:

1. Using Chrome or a Chromium-based browser like Brave, navigate to the block explorer on the mainnet (https://cspr.live/), and click on the **Sign-in** menu.
2. Download the `CasperLabs Signer extension <https://chrome.google.com/webstore/detail/casperlabs-signer/djhndpllfiibmcdbnmaaahkhchcoijce>`_.
3. You will need to create a vault that will safeguard your accounts with a password. In this step, we assume that you have not used the Signer before, so click **Reset Vault**.
4. Create a password for your new vault. Confirm the password, and then click **Create Vault**.
5. Write down and store your password in a secure location. **If you lose it, you will lose access to this wallet!**
6. Open the Signer extension and log into your vault.
7. Click on the hamburger menu icon to select from a range of options. Notice that the checkmark indicates the active account.
8. From this menu, you can perform essential management functions, such as editing accounts, deleting accounts, or viewing and downloading your keys.
9. You can also view websites and dApps to which your accounts are connected.
10. One essential function is the ability to download your keys and store them in a secure location. If you lose access to the vault, you can create a new vault with the downloaded files. Please do this as early as possible!

3.2 Creating a New Account
~~~~~~~~~~~~~~~~~~~~~~~~~~
If you are using the CasperLabs Signer for the first time, follow these steps to create an account and **download the account's keys**:

1. Click **Create Account** in the Signer.
2. Give your account a name. In this tutorial, we will use the name *My-CSPR*.
3. Select an Algorithm using the dropdown menu. Select *SECP256K1* unless you have a good reason not to do so.
4. Click **Create** to save your account.
5. **IMPORTANT: Download the key files for this account!** Click the hamburger icon and select the **Download Active Key** option.

.. image:: ../assets/tutorials/staking/3.2.5.1.png
    :width: 200
    :align: center 
|

6. Check that your browser downloaded the following three files:
   
  * Your secret key: **...\_secret\_key.pem**
  * Your public key: **...\_public\_key.pem**
  * A text file: **...\_public\_key\_hex.txt**

If you do not have these three files, you need to enable multiple downloads in your browser. It is crucial to proceed to the next step only if you have all of these files. This screenshot shows the files downloaded for an account called *My-CSPR*:

.. image:: ../assets/tutorials/staking/3.2.6.1.png
    :width: 300
    :align: center 
|

7. **IMPORTANT: Move these files to a secure OFFLINE location!** Do not store them on any device with a wifi connection. We recommend an offline USB or hard drive. Consider backing up these files in multiple locations in case one location becomes compromised.
8. If you lose the vault password you created, but still have the *secret_key.pem* file, you can import your account into a new vault, as shown in the next section.
9. **IMPORTANT: If you lose the secret_key.pem file and your vault password, you will lose access to that account and to the tokens stored in the account.**

3.3 Importing an Existing Account
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you already have your secret keys and would like to set up and use your wallet with your existing accounts, you can do so with the following steps. These steps also apply for users migrating from the outdated Clarity tool to `cspr.live <https://cspr.live/>`_.

1. Import your existing account by clicking the **IMPORT ACCOUNT** button.
2. Then, click on the **UPLOAD** button and select your secret key file (the file with the secret_key.pem extension).
3. Give your account a name and click on the **IMPORT** button to complete the import operation.
4. Repeat these steps for all the accounts you would like to import into your wallet.

.. image:: ../assets/tutorials/staking/3.3.4.1.png
    :width: 200
    :align: center 
|

Now that you have your CasperLabs Signer wallet, you can continue to connect to the mainnet blockchain.

4. Connecting to cspr.live
^^^^^^^^^^^^^^^^^^^^^^^^^^
Using the active account in the Signer tool, connect to the Casper blockchain by clicking on the **DISCONNECTED** button to toggle the connection.

.. image:: ../assets/tutorials/staking/4.1.png
    :width: 200
    :align: center 
|

Approve the connection by clicking the **CONNECT** button.

.. image:: ../assets/tutorials/staking/4.2.png
    :width: 200
    :align: center 
|

You are now in the block explorer and connected to the Casper blockchain using your active account!

Next, click on **View Account** in the top right corner.

.. image:: ../assets/tutorials/staking/4.3.png
    :width: 300
    :align: center 
|

You will see the following fields:

* The **Public Key** is the address of your Casper Mainnet account.
* The **Account Hash** is a 32-byte identifier derived from the public key. The platform uses it to verify transactions.
* The **Liquid Account Balance** represents the tokens you have for immediate use.
* The **Delegated Account Balance** represents your delegated tokens staked with validators on the network.
* You will also see **Total Rewards Received** on the account page.

.. image:: ../assets/tutorials/staking/4.4.png
    :width: 800
    :align: center 
|

If you wish, you can also explore the *Transfers*, *Deploys*, *Delegations*, and *Staking Rewards* tabs.

In this tutorial, we are interested in the *Delegations* tab, where you can see a list of validators to which you have delegated tokens and the amount you have delegated.

You will see details about your rewards in the *Staking Rewards* tab, such as the validator you have staked with and the amount you have received for each era.

.. image:: ../assets/tutorials/staking/4.5.png
|

**Delegation Fees**

It is important to know that the cost of the delegation process is approximately 3 CSPR. Ensure you have extra CSPR on your account apart from the amount you are delegating; otherwise, the transaction will fail. For example, if you want to delegate 1000 CSPR, you need to have at least 1003 CSPR in your account.

5. Funding your Account
^^^^^^^^^^^^^^^^^^^^^^^

**IMPORTANT NOTE:** If you want to send your CSPR coins from an exchange to this account, you need to copy the **Public Key** value. Use the quick copy button to the right of the public key address to copy it. Then set up a withdrawal request from the exchange using the public key.

The transfer from an exchange takes a few minutes. After your tokens arrive in your account, you can delegate them. This section demonstrates a withdrawal from the Coinlist exchange http://coinlist.co/ to the `Casper Mainnet on cspr.live <https://cspr.live/>`_.

5.1 Transfer CSPR from an Exchange
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you need to transfer your CSPR tokens from an exchange, you will need your **public key** from the account page. You can also find this key in the **public_key_hex** file, which you can download from the CasperLabs Signer.

If you already have funds in your Signer wallet, you can skip this section. If you are working with a different exchange, you need to contact that exchange directly.

1. Log into your https://coinlist.co/ account.
2. Go to the **Wallet** tab.

.. image:: ../assets/tutorials/staking/5.1.2.1.png
    :width: 200
    :align: center 
|

3. Click on the **CSPR** section.

.. image:: ../assets/tutorials/staking/5.1.3.1.png
    :width: 200
    :align: center 
|

4. Click on the **Withdraw** button.

.. image:: ../assets/tutorials/staking/5.1.4.1.png
|

5. Copy the **Public Key**. The screenshot below shows the account page on https://cspr.live/ and the field that you need to copy from that page.

.. image:: ../assets/tutorials/staking/5.1.5.1.png
|

6. Enter the **Public Key** in the **Recipient Address** field in the withdrawal request.

.. image:: ../assets/tutorials/staking/5.1.6.1.png
    :width: 400
    :align: center 
|

7. Enter 0 in the **Transfer ID** field or another value that is meaningful to you. **You MUST enter a value or the transfer will fail!**

8. Enter the CSPR amount you wish to transfer. **We recommend that you try these steps with a small amount of CSPR to verify you followed the steps correctly**. After one successful transfer, you will be more comfortable transferring larger amounts.

9. Click **Review**.

10. Submit your transfer request. Wait approximately 5 minutes, and then go to the https://cspr.live/ site to verify your transfer. On your account page, you should see that the **Liquid Account Balance** reflects the amount you have transferred.

Now you are ready to delegate your tokens.

6. Delegating Tokens
^^^^^^^^^^^^^^^^^^^^
You can access the delegation functionality in two ways.

**Option 1:** Click **Wallet** from the top navigation menu and then click **Delegate**.

.. image:: ../assets/tutorials/staking/6.1.png
    :width: 200
    :align: center 
|

**Option 2:** Click **Validators** from the top navigation menu. From the validators table, click on any validator to access their details. Once you find the validator to which you want to delegate tokens, click the **Delegate** button.

.. image:: ../assets/tutorials/staking/6.2.png
|

Then follow these instructions to delegate your tokens:

**Step 1 - Delegation Details**

1. Start by choosing the validator to which you want to delegate your tokens. You can search for one using the search box or paste their public key if you have a validator in mind.
2. Enter the amount of CSPR you would like to delegate.
3. Click **Next**.

.. image:: ../assets/tutorials/staking/6.3.png
    :width: 400
    :align: center 
|

**Step 2 - Confirm the Transaction**

1. Review the details of the transaction.
2. Enter the amount you want to delegate.
3. If everything is correct, click **Next**. If you wish to change something, you can return to the previous step by clicking **Back to step 1**.

.. image:: ../assets/tutorials/staking/6.4.png
|

**Step 3 - Sign the Transaction**

1. Click **Sign** with the CasperLabs Signer.

.. image:: ../assets/tutorials/staking/6.5.png
    :width: 400
    :align: center 
|

2. Once the Signer app window opens, **make sure that the Deploy hash in the Signer window matches the Deploy hash in https://cspr.live/ before continuing!**

.. image:: ../assets/tutorials/staking/6.6.png
|

3. Click **Sign** in the Signer window to sign and finalize the transaction. You have completed the delegation.

.. image:: ../assets/tutorials/staking/6.7.png
    :width: 400
    :align: center 
|

The delegation transaction initiates as soon as the corresponding deploy is signed. You can review the details and status of the deploy by clicking **Deploy Details**. Now that you have everything set up, subsequent delegation operations will be much easier.

7. Monitoring
^^^^^^^^^^^^^
We recommend that you check in on how your stake is performing. The following points are important to understand and will be helpful in maximizing your rewards.

If the validator you staked with decides to unbond, your stake will also be unbonded. Make sure that the validator you have selected is performing as per your expectations.

Validators have to win a staking auction by competing for a validator slot with prospective and current validators. This process is permissionless, meaning validators can join and leave the auction without restrictions, except for the unbonding wait period, which lasts 14 hours.

Staking rewards are delivered to your account after each era, which is currently set to 2 hours. Note that it may take up to 2 eras (4 hours) for the first reward to appear after delegation. The rewards are automatically added to your current stake on the corresponding validator. You may view them under the *Rewards* tab on your account details page on https://cspr.live/.

8. Undelegating Tokens
^^^^^^^^^^^^^^^^^^^^^^
If you want to undelegate your tokens, you can do so at any time. Note that the cost of the undelegation process is 0.5 CSPR. You can access the undelegate functionality in three ways.

**Option 1:** Click **Wallet** from the top navigation menu and then click **Undelegate Stake**.

.. image:: ../assets/tutorials/staking/8.1.png
    :width: 200
    :align: center 
|

**Option 2:** Click **Validators** from the top navigation menu. From the validators table, click on any validator to access its details. Once you find the validator you wish to undelegate from, click the **Undelegate Stake** button.

.. image:: ../assets/tutorials/staking/8.2.png
|

**Option 3:** Go to your account details by clicking your public key in the top navigation menu or clicking **View Account** from the expanded menu. Then click on the **Delegations** tab, and click on the **Undelegate** button next to the entry you want to undelegate.

.. image:: ../assets/tutorials/staking/8.3.png
|

Then follow these instructions to undelegate your tokens:

**Step 1 - Undelegation Details**

1. Start by choosing the validator from which you want to undelegate your tokens. If a validator is not already selected, you can search for one using the search box. The search box will automatically show you validators with which you have staked.

.. image:: ../assets/tutorials/staking/8.4.png
    :width: 400
    :align: center 
|

2. Enter the amount of Casper tokens you want to undelegate.
3. Click **Next**.

.. image:: ../assets/tutorials/staking/8.5.png
    :width: 400
    :align: center 
|

**Step 2 - Confirm the Transaction**

1. Review your transaction details.
2. If everything looks correct, click **Confirm** to undelegate the tokens. If you wish to change something, you can return to the previous step by clicking **Back to step 1**.

.. image:: ../assets/tutorials/staking/8.6.png
|

**Step 3 - Sign the Transaction**

1. Click **Sign** with the CasperLabs Signer.

.. image:: ../assets/tutorials/staking/8.7.png
    :width: 400
    :align: center 
|

2. Once the Signer app window opens, **make sure that the Deploy hash in the Signer window matches the Deploy hash in https://cspr.live/ before continuing**!

.. image:: ../assets/tutorials/staking/8.8.png
|

3. Click **Sign** in the Signer window to sign and finalize the transaction.

.. image:: ../assets/tutorials/staking/8.9.png
    :width: 400
    :align: center 
|

The stake undelegation initiates as soon as the corresponding deploy is signed. It may take 1-2 minutes for the undelegation details to become available. Please note that your undelegated tokens will appear in your account automatically after a 7-era delay, which is approximately 14 hours.

Conclusion
^^^^^^^^^^

By staking your tokens, you help secure the network and earn rewards in return. Thank you for your trust and participation!

You can find additional information on the `docs.cspr.community <https://docs.cspr.community/>`_ website.
