Casper Signer User Guide
==========================

1.  Introduction
-----------------

The Casper Signer allows you to safely access your Casper Token (CSPR) wallet. The CSPR wallet can be used to transfer CSPR tokens to another user, delegate stake, or ungelegate stake. The Casper Signer can be used for more than one CSPR account and all the accounts are securely stored in a vault, which is a mechanism to protect online information with a password. You set a password for the vault while creating a Casper Signer account. To login using Casper Signer, you must download and install the CasperLabs Signer extension for your browser. The following sections take you through the process of downloading and signing in to the Casper Signer.


1.1 Installing the CasperLabs Signer Extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To install the CaperLabs Signer extension, follow these steps:
    
    *Note*: Alternatively, you can use this link to download the `CasperLabs Signer <https://chrome.google.com/webstore/detail/casperlabs-signer/djhndpllfiibmcdbnmaaahkhchcoijce>`_ extension and skip to `Step 4`.  


    1. Navigate to the CSPR mainnet https://cspr.live/, using Chrome or a Chromium-based browser like Brave.
    2. Click the **Sign in** option on the top-right corner of the screen. The Casper Signer is displayed.
    3. In the Casper Signer, click the **Download Signer** button. A new window with the Chrome extension is displayed.
    4. On the CasperLabs Signer extension page, click the **Add to Chrome** button. A pop-up will let you know the permissions required. To approve the extension access, click **Add extension**. The CasperLabs Signer extension is now added to your browser.


1.2 Logging in to the Casper Signer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To log in to the Casper Signer, you must create a vault and import or create accounts. To create a vault, follow these steps: 

1. Next to the address bar of your browser, you will find the extensions icon. Click the extensions icon |extension| and select CasperLabs Signer from the list. 

    .. |extension| image:: ../assets/tutorials/signer/ext-icon.png
        :width: 35

    a. If you are logging in for the first time, a pop-up window to create a new vault will appear. 
    b. On the New Vault pop-up window, enter a password for your vault, confirm the password, and click **CREATE VAULT**. This vault safeguards your Casper accounts, so make sure you use a strong password and keep the password safe.

2. If you have already created a password for your vault, the Unlock Vault pop-up window is displayed. Enter your password and click **UNLOCK**. 

3. You can now import an account or create a new one.

    a. If you don’t have any existing cryptographic keys, you must create a new account. For more information on creating a new account, see `Creating an Account <signer-guide.html#id1>`_.
    b. If you have a set of keys for your account, you can just import the secret key in the Casper Signer. For more information on importing an existing account, see `Importing an Account <signer-guide.html#id2>`_.

    Figure 1: Casper Signer Home (when you have no existing accounts)
        .. figure:: ../assets/tutorials/signer/first-home.png
            :width: 250
            :class: float-left
         
2.  Creating an Account
------------------------

The Casper Signer allows you to create an account and generates a set of keys based on your chosen encryption algorithm. The Casper Network supports these two algorithms:

    *   Ed25519 is fast and provides a high level of security with foolproof session keys, among other features. It is the default algorithm used while creating new accounts.
    *   Secp256k1 is an efficient encryption algorithm, also used by Bitcoin and Ethereum. If you would like to derive Ethereum or Bitcoin keys in the future using your private key, or you are planning to use your account with Ledger, then choose the Secp256k1 algorithm.

To learn more about cryptographic keys, see `Working with Cryptographic Keys <https://docs.casperlabs.io/en/latest/dapp-dev-guide/keys.html>`_.

To create an account, do the following:

    1.	On the Casper Signer home (as shown in *Figure 1*), click **CREATE ACCOUNT**. The Create Account fields are displayed.
    2.	Enter a name for the account and select the algorithm to generate the keys. The Public Key field is auto-populated.
    3.  Click **CREATE** to create your account. 

        a.	To return to the Casper Signer home, click the home icon |home| on the top-left corner of the pop-up window. Here, you can see the number of accounts in your wallet and the name of the account that is currently active.

        .. |home| image:: ../assets/tutorials/signer/home-icon.png
            :width: 25

    .. note::

        It is highly recommended that you download and save your account keys in a safe location (preferably offline). This will allow you to recover your account in case you lose access to your vault. For more information on how to download your cryptographic keys, see `Download Active Keys <signer-guide.html#id3>`_.

3.	Importing an Account
-------------------------

The Casper Signer allows you to add your existing keys to the Signer wallet. You need to have the secret key for the account you wish to import.
To import an account, do the following:

    1.	On the Casper Signer home (as shown in *Figure 1*), click **IMPORT ACCOUNT**. The Import from Secret Key File option is displayed.
    2.  Click **UPLOAD**, browse and select the secret key you wish to add to your wallet.
    3.	Enter a name for the imported account and click **IMPORT**. Your secret key is now imported into the Casper Signer.
    
        a.	To return to the Casper Signer home, click the home icon |home| on the top-left corner of the pop-up window. Here, you can see the number of accounts in your wallet and the name of the account that is currently active.

4.	Managing an Account
------------------------

The main menu of the Casper Signer allows you to perform various functions, such as switching between accounts, managing keys, viewing connected sites, downloading active keys, setting the timeout for your Signer session, and locking your vault. The main menu icon |main-icon| is located at the top-right corner of the Casper Signer window. 

    Figure 2: Casper Signer Main Menu
        .. figure:: ../assets/tutorials/signer/main-menu.png
            :width: 250
            :class: float-left


4.1 Switching Active Accounts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The main menu displays the names of all the accounts registered with the Casper Signer wallet. To select an account as the current active account, click the account name. A check-mark appears in front of the account name. This indicates that the account is active. As an example, in *Figure 2*, account *GSTest12345* is the active account.

4.2	Key Management
~~~~~~~~~~~~~~~~~~~

Key management allows you to manage the keys added to your Signer wallet. You can rename the keys, delete a key, view the account information (public key hex and the account hash) and download the keys (public key, public key hex, and the secret key) for each account. 

To view the various functions available, on the main menu, select **Key Management**. The list of keys available are displayed along with the icons to manage keys. 

        Figure 3: Key Management
            .. figure:: ../assets/tutorials/signer/key_mgnt.png
                :width: 200
                :class: float-left  

    *   To rename an account, click the edit icon next to the account name, enter the new name and click **UPDATE**.
    *   To delete an account, click the delete icon next to the account name. A Remove Account notification pops-up. To approve the deletion, enter the password to your vault and click REMOVE.
    *   To view the account information, such as the public key and the account hash, click the key-shaped icon. 
    *   To download a copy of the account keys, click the down arrow icon. A set of three keys, the public key, public key hex, and the secret key are downloaded to your computer.

4.3 Connected Sites
~~~~~~~~~~~~~~~~~~~~

This feature allows you to view all the websites and decentralized applications (dApps) that are connected with the Casper Signer. You can disconnect or delete the websites from Casper Signer using the icons next to the name of each site. 

4.3.1	Connecting to websites and dApps
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can use the Casper Signer to connect to various websites and dApps. 

To connect to a website or dApp, do the following:

    1.  Navigate to the website or dApp that is integrated with the Signer. 
    2.  Log in to your Signer, for more details see `Logging in to the Casper Signer <signer-guide.html#logging-in-to-the-casper-signer>`_. 
    3.  Click the main menu icon |main-icon| to open the main menu and select **Connected Sites**. The current website is displayed in the list of connected sites. 
    4.  To connect to a site, click the connect icon next to the name of the website.

        Figure 4: Connected Sites
            .. figure:: ../assets/tutorials/signer/connect-site.png
                :width: 200
                :class: float-left

**Note**: If the website is not integrated with the Casper Signer, the roll-over text displays the message ‘This site is not integrated with the Signer’.

4.4 Download Active Keys
~~~~~~~~~~~~~~~~~~~~~~~~~

This feature allows you to download the set of cryptographic keys from your active account. 
To download the set of keys for the selected active account, click the main menu icon |main-icon| and select **Download Active Keys**.

.. |main-icon| image:: ../assets/tutorials/signer/main-icon.png
    :width: 25

4.5	Timeout
~~~~~~~~~~~~

This feature allows you to set the idle time limit for the Signer vault to automatically lock itself. Once the vault is locked, you must enter your password again to unlock the vault.

4.6	Lock
~~~~~~~~~

This feature allows you to lock your vault. You must enter your vault password again to unlock the vault.

5.	Resetting the Vault
------------------------
   
Once you have created a password for the vault, every time you access it, you will see a **Reset Vault?** link below the UNLOCK button. You can click this link to delete all your CSPR accounts from the vault. If you have downloaded your account keys, you can create a new vault password and import the keys to your account to recover all the transactions.   

6. 	Viewing Account Details
----------------------------

You can view your account details, such as, the public key, account hash, CSPR token balance, and the transaction history.

To view your account information, do the following:

    1.	On the CSPR home page, click the option in the top-right corner of the screen that displays a few digits of your public key. A menu with your public key is displayed.
    2.	To view your account details for the displayed public key, click **View Account**.

7.	Accessing the CSPR Wallet from cspr.live
---------------------------------------------

Once you are logged in to the Casper Signer, you can access the wallet for each account registered in the Signer. For more information on how to log in to the Signer, see `Logging in to the Casper Signer <signer-guide.html#logging-in-to-the-casper-signer>`_.

Alternatively, you can follow these steps to log in to your Signer/CSPR wallet:

    1.	Navigate to the CSPR Mainnet https://cspr.live/.
    2.	Click the **Sign in** option on the top-right corner of the screen. The Casper Signer is displayed.
    3.	In the Casper Signer, click the **Sign In** button. The Unlock Vault pop-up is displayed.
    4.	Enter your password and click **UNLOCK**. The Connection Request message is displayed. 
    5.	To continue with the connection, click **CONNECT**. The Approve Connection message appears.
    6.	To approve the connection, click **CONNECT**. You are now connected to the CSPR wallet. 

8.	Logging out of the Casper Signer
-------------------------------------

To logout from the Signer, do the following:

    1.	On the CSPR home page, click the option in the top-right corner of the screen that displays a few digits of your public key. A menu with your public key is displayed.
    2.	Click **Logout**. You will be logged out of your vault.

