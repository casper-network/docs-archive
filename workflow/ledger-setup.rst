Ledger Setup
============

A Ledger Device is a hardware wallet that is considered one of the most secure ways to store your digital assets. Ledger uses an offline, or cold storage, method of generating private keys, making it a preferred method for many crypto users. This guide will help you to connect your Ledger device to the Casper web wallet (https://cspr.live). The Casper web wallet enables you to send and receive CSPR tokens.

If you need help, we're available on the following services:

* Twitter: https://twitter.com/Casper_Network 
* Discord: https://discord.com/invite/Q38s3Vh
* Telegram: https://t.me/casperblockchain


Requirements
^^^^^^^^^^^^

Before you begin
~~~~~~~~~~~~~~~~
1. You have initialized your Ledger Nano S/X.
2. You have installed the latest firmware on your Ledger Nano S/X.
3. Ledger Live is ready to use.
4. You have Google Chrome installed.

Install the Casper app on the Ledger device
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Open the Manager in Ledger Live.
2. Connect and unlock your Ledger device.
3. If asked, allow the manager on your device by pressing the right button.
4. Find Casper in the app catalog.
5. Click the Install button of the app.
6. An installation window appears.
7. Your device will display **Processing…**
8. The app installation is confirmed.

Use Ledger device with your Web wallet
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sign in
~~~~~~~
You can now use the Ledger device with Web wallet. Follow these steps:

1. Connect and unlock your Ledger device.
2. Open the Casper app on your Ledger device.
3. Go to `cspr.live/sign-in <https://cspr.live/sign-in>`_.
4. Click on **Connect** button in the **Ledger** section.
5. Click on **Connect to Ledger wallet** button.
6. Select an account you want to use.
7. Now, your Ledger device is connected to the web wallet.

View account details
~~~~~~~~~~~~~~~~~~~~
1. Go to `cspr.live <https://cspr.live>`_.
2. Click on the account address in the upper-right corner of the page.

.. image:: ../assets/tutorials/ledger/flow/3-view-account.png

3. Click on the **View account** button.

.. image:: ../assets/tutorials/ledger/flow/6-view-account-button.png

4. You're presented with a page displaying details about your account.

.. image:: ../assets/tutorials/ledger/flow/4-account-details.png



View account balance
~~~~~~~~~~~~~~~~~~~~
You can check your account balance from the Web wallet:

1. Follow the steps described in the **View account details** section.
2. On the **Liquid Account Balance** row, you will see your latest known account balance.


Receive tokens
~~~~~~~~~~~~~~
To receive tokens, you need to provide the sender with the public key of your account. To find it:

1. Open the account details page (see the **View account details** section).
2. Copy the public key found on the **Public Key** row.
3. Alternatively, click on the drop-down menu on your account address.

.. image:: ../assets/tutorials/ledger/flow/3-view-account.png

4. Click on the **Copy public key** button.
5. Share the public key with the sender.

Send tokens
~~~~~~~~~~~
1. Go to `cspr.live <https://cspr.live>`_.
2. Sign in with your Ledger device.
3. Click on **Wallet** and then **Transfer CSPR**.

.. image:: ../assets/tutorials/ledger/flow/5-transfer-wallet.png

4. Fill in the details for the transfer.

.. image:: ../assets/tutorials/ledger/cspr-live/1-transfer-details.png

5. Click **Next** button.
6. On the next page, click **Confirm and transfer**.

.. image:: ../assets/tutorials/ledger/cspr-live/2-transfer-confirm.png

7. On the **Sign transaction** page, click on the **Sign with Ledger** button.

.. image:: ../assets/tutorials/ledger/cspr-live/3-transfer-sign.png

8. Your Ledger hardware wallet will present you with transfer details. Verify the transfer details (txn hash, chain ID, source **account**, fee, target and amount).

**Verify the transaction on your Ledger device**

Press the right button on your Ledger Device to review the transaction details (Amount and Address) until you see **“Approve”**.

1. Verify the **txn hash** - make sure it matches the value displayed in the Web wallet on `cspr.live <https://cspr.live>`_.

.. image:: ../assets/tutorials/ledger/device/3-txn-1.jpg

The *txn hash* value continues on a second screen.

.. image:: ../assets/tutorials/ledger/device/4-txn-2.jpg

2. The next page displays transaction **type** - for CSPR transfers that will be **Token transfer**.

.. image:: ../assets/tutorials/ledger/device/5-type.jpg

3. Verify the **chain ID**, which identifies the network on which you want to send the transaction.

.. image:: ../assets/tutorials/ledger/device/7-chain.jpg

4. Verify the **account**, which is the public key of the account that initiated the transaction.

.. image:: ../assets/tutorials/ledger/device/8-account-1.jpg

The *account* value continues on a second screen.

.. image:: ../assets/tutorials/ledger/device/9-account-2.jpg

5. Verify the **fee**. For CSPR token transfers, that value should be constant and equal to 10 000 motes = 0.00001 CSPR.

.. image:: ../assets/tutorials/ledger/device/10-fee.jpg

6. Verify **target** - **NOTE** this **IS NOT** a public key of the recipient but the hash of that key. Compare the public key with the value in the Web wallet which shows you two fields for the recipient public key and target.".

.. image:: ../assets/tutorials/ledger/device/11-target-1.jpg

The *target* value continues on a second screen.

.. image:: ../assets/tutorials/ledger/device/12-target-2.jpg

7. Verify the **amount** you want to transfer.

.. image:: ../assets/tutorials/ledger/device/13-amount.jpg

8. If you approve the transaction, click both buttons on the Ledger device.

.. image:: ../assets/tutorials/ledger/device/15-approve.jpg

After approving the transaction with your Ledger hardware wallet, the `cspr.live <https://cspr.live>`_ Web wallet will display a **Transfer completed** page.

.. image:: ../assets/tutorials/ledger/cspr-live/4-transfer-completed.png

You can now check your account to see a list of all the completed transfers.