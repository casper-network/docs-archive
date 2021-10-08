.. role:: raw-html-m2r(raw)
   :format: html


Use Casper signer in Dapp
===============================

This tutorial shows you how to connect the `Casper signer wallet <https://chrome.google.com/webstore/detail/casperlabs-signer/djhndpllfiibmcdbnmaaahkhchcoijce>`_ to your website show the balance of the account and send a transaction.

Step 1. Install casper-js-sdk and vitas to run mini webserver
-------------------------------------------------------------

First, install `Vite <https://vitejs.dev/guide/>`_, vita is a frontend build tool that helps to bundle a javascript library and start a webserver.

Run the npm command to init vita and configure to javascript.

.. code-block:: bash

   npm init vite@latest

#. Project name: ... tutorial
#. Select a framework: » vanilla
#. Select a variant: » vanilla

Go to the main folder and 
install vita necessary dependencies and install `Casper-js-sdk <https://github.com/casper-ecosystem/casper-js-sdk>`_ , it's will necessary later to connect to the Casper node to retrieve information from blockchain and send transactions. 

.. code-block:: bash

	cd tutorial
	npm install
	npm install casper-js-sdk@next --save
	npm run dev


Step 2. Create minimal UI to interact with Casper signer  
--------------------------------------------------------

Open the index.html in the main folder, write the HTML code to create the buttons and the places where information will display, and the inputs to send transactions. 

.. code:: html

	<div id="app">

	<!-- The button to connect your website into Casper signer wallet. -->
	<button id="btnConnect" >Connect</button>

	<!-- The button to disconnect your website into Casper signer wallet -->
	<button id="btnDisconnect" >Disconnect</button>

	<!-- The place where the public key will display. -->
	<h1 id="textAddress">PublicKeyHex </h1>

	<!-- The place where Balance will display. -->
	<h1 id="textBalance">Balance </h1>
	<h1>Transer</h1>

	<!-- The amount to send in the transaction. -->
	<!-- Minimal amount is 2.5CSPR so 2.5 * 10000 (1CSPR = 10.000 motes)  -->
	<label for="Amount">Amount - min amount 25000000000</label>
	<input id="Amount" type="number">

	<!-- The address that will receive the coins. -->
	<label for="Recipient">Recipient</label>
	<input id="Recipient" type="text">

	<!--The button that when clicked will send the transaction. -->
	<button id="btnSend" >Send</button>

	<!--The address of your transaction. -->
	<h1 id="tx"></h1>
	</div>

.. image:: ../../assets/tutorials/casper-signer-html.png
  :alt: Image showing successful nctl output.

| 

After writing the HTML, open de main.js and write the code to import Casper-js-sdk to create client and services it will necessary to get account balance and send transaction.

.. code-block:: javascript

	import {CasperClient,CasperServiceByJsonRPC, CLPublicKey,DeployUtil } from "casper-js-sdk";

	//Create Casper client and service to interact with Casper node.
	const apiUrl = '<your casper node>';
	const casperService = new CasperServiceByJsonRPC(apiUrl);
	const casperClient = new CasperClient(apiUrl);



Step 3. Implement the connect button and disconnect
---------------------------------------------------

How do we have the UI and imported the library in main.js it's time to start to interact with casper signer wallet, first will create the connect function for the button.

.. code-block:: javascript

	const btnConnect = document.getElementById("btnConnect");
	btnConnect.addEventListener("click", async () => {
		window.casperlabsHelper.requestConnection();
	})

When clicking on the connect button the wallet will show a pop-up asking if you want to connect this site into the wallet.

.. image:: ../../assets/tutorials/casper-connect.png
  :alt: Image showing successful nctl output.

| 

It's possible to connect to the wallet  is also possible to disconnect with this function.

.. code-block:: javascript

	const btnDisconnect = document.getElementById("btnDisconnect");
	btnDisconnect.addEventListener("click", () => {
		window.casperlabsHelper.disconnectFromSite();
	})

Step 4. Get public key and balance of the account
-------------------------------------------------

In the previous part, you learned how to connect to the wallet, in this part, you will learn how to get connected account information.

Let's write the function to get the basic information about your account, like public key and balance.

.. code-block:: javascript

	async function AccountInformation(){
		const isConnected = await window.casperlabsHelper.isConnected()
		if(isConnected){
			const publicKey = await window.casperlabsHelper.getActivePublicKey();
			textAddress.textContent += publicKey;

			const latestBlock = await casperService.getLatestBlockInfo();
			const root = await casperService.getStateRootHash(latestBlock.block.hash);

			const balanceUref = await casperService.getAccountBalanceUrefByPublicKey(
				root, 
				CLPublicKey.fromHex(publicKey)
				)

			//account balance from the last block
			const balance = await casperService.getAccountBalance(
				latestBlock.block.header.state_root_hash,
				balanceUref
			);
			textBalance.textContent = `PublicKeyHex ${balance.toString()}`;
		}
	}


add the AccountInformation() function inside the btnConnect to display the information when connecting into an account

.. code-block:: javascript
	const btnConnect = document.getElementById("btnConnect");
	btnConnect.addEventListener("click", async () => {
	window.casperlabsHelper.requestConnection();
		await AccountInformation();
	})

The result should be like this 

.. image:: ../../assets/tutorials/casper-signer-balance.png
  :alt: Image showing successful nctl output.

| 

Step 5. Sign and send a transcation
-----------------------------------
With a connect wallet on your website is possible to sign a transaction, the Casper signer will not send the transaction only sign the transaction using your account keys, your app will need to send the transaction after the wallet sign it.

.. code-block:: javascript

	async function sendTransaction(){
	// get address to send from input.
	const to = document.getElementById("Recipient").value;
	// get amount to send from input.
	const amount = document.getElementById("Amount").value
	// For native-transfers the payment price is fixed.
	const paymentAmount = 10000000000;

	// transfer_id field in the request to tag the transaction and to correlate it to your back-end storage.
	const id = 287821;

	// gasPrice for native transfers can be set to 1.
	const gasPrice = 1;

	// Time that the deploy will remain valid for, in milliseconds
	// The default value is 1800000 ms (30 minutes).
	const ttl = 1800000;
	const publicKeyHex = await window.casperlabsHelper.getActivePublicKey();
	const publicKey = CLPublicKey.fromHex(publicKeyHex)

	let deployParams = new DeployUtil.DeployParams(publicKey,"casper-test",gasPrice,ttl );
	
	// We create a public key from account-address (it is the hex representation of the public-key with an added prefix).
	const toPublicKey = CLPublicKey.fromHex(to);

	const session = DeployUtil.ExecutableDeployItem.newTransfer( amount,toPublicKey,null,id);
	
	const payment = DeployUtil.standardPayment(paymentAmount);
	const deploy = DeployUtil.makeDeploy(deployParams, session, payment);
	
	// Turn your transaction data to format JSON
	const json = DeployUtil.deployToJson(deploy)
	
	// Sign transcation using casper-signer.
	const signature = await window.casperlabsHelper.sign(json,publicKeyHex,to)
	const deployObject = DeployUtil.deployFromJson(signature)
	
	// Here we are sending the signed deploy.
	const signed = await casperClient.putDeploy(deployObject.val);
	
	// Display transaction address
	const tx = document.getElementById("tx")
	tx.textContent = `tx: ${signed}`
	}

	const btnSend = document.getElementById("btnSend")
	btnSend.addEventListener("click",async () => await sendTransaction())


.. image:: ../../assets/tutorials/casper-transcation-sign.png
  :alt: Image showing Casper signer pop-up with  

| 


External links
--------------

* `Vita js guide <https://vitejs.dev/guide/>`_
* `Casper-js-sdk source code <https://github.com/casper-ecosystem/casper-js-sdk>`_
* `Casper signer guide <https://docs.cspr.community/docs/user-guides/SignerGuide.html>`_

