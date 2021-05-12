TypeScript/JavaScript SDK
=========================

The `TypeScript/JavaScript SDK <https://casper-ecosystem.github.io/casper-client-sdk/>`_ allows developers to interact with the Casper Network using TypeScript or JavaScript. This page covers different examples of using the SDK.

Installation
^^^^^^^^^^^^
To install this library using Node.js, run the following command:

.. code-block:: bash

    npm install casper-client-sdk --save

Tests
^^^^^
You can find basic examples for how to use this library in the ``test`` directory. To run the tests, use this command:

.. code-block:: bash

    npm run test

Usage Examples
^^^^^^^^^^^^^^
Here we outline a few of the essential tasks you can accomplish with the JavaScript SDK:

# Generating account keys to sign your deploys
# Sending a transfer

Generating Account Keys
~~~~~~~~~~~~~~~~~~~~~~~

This example shows you how to use the SDK to generate account keys to sign your deploy. After generating the keys, you can create an account on https://testnet.cspr.live/ and upload the key stored in the file ``casper_keys/<account-address>_public.pem``.

.. code-block:: javascript

    const fs = require("fs");
    const path = require("path");
    const { Keys } = require("casper-client-sdk");
    const createAccountKeys = () => {
    
        // generate new keys
        const edKeyPair = Keys.Ed25519.new();
        const { publicKey, privateKey } = edKeyPair;
        
        // get account-address from public key
        const accountAddress = publicKey.toAccountHex();
        
        // Get account-hash (Uint8Array) from public key
        const accountHash = publicKey.toAccountHash();
        
        // store keys as PEM files
        const publicKeyInPem = edKeyPair.exportPublicKeyInPem();
        const privateKeyInPem = edKeyPair.exportPrivateKeyInPem();
        const folder = path.join("./", "casper_keys");
        if (!fs.existsSync(folder)) {
            const tempDir = fs.mkdirSync(folder);
        }
        fs.writeFileSync(folder + "/" + accountAddress + "_public.pem", publicKeyInPem);
        fs.writeFileSync(folder + "/" + accountAddress + "_private.pem", privateKeyInPem);
        return accountAddress;
        };
        const newAccountAddress = createAccountKeys();
    
    });


Sending a Transfer
~~~~~~~~~~~~~~~~~~

This code block shows you how to define and send a transfer on the Casper Network. Replace the ``account-address`` in the code below with the sender's account address.

The ``sendTransfer`` function below will return ``transfer-hash`` which you can check on https://testnet.cspr.live/.  can be than checked on cspr.live

.. code-block:: javascript

    const fs = require("fs");
    const path = require("path");
    const axios = require("axios");
    const casperClientSDK = require("casper-client-sdk");
    const { Keys, CasperClient, PublicKey, DeployUtil } = require("casper-client-sdk");
    const RPC_API = 'http://159.65.203.12:7777/rpc';
    const STATUS_API = 'http://159.65.203.12:8888';
    const sendTransfer = async ({ from, to, amount }) => {
    const casperClient = new CasperClient(RPC_API);
    const folder = path.join('./', 'casper_keys');

    // read keys from structure created in #Generating keys
    const signKeyPair = Keys.Ed25519.parseKeyFiles(
        folder + '/' + from + '_public.pem',
        folder + '/' + from + '_private.pem'
        );
    
    // networkName can be taken from the status api
    const response = await axios.get(STATUS_API + "/status");
    let networkName = null;
    if (response.status == 200) {
        networkName = response.data.chainspec_name;
    }

    // for native-transfers payment price is fixed
    const paymentAmount = 10000000000;
    
    // transfer_id field in the request to tag the transaction and to correlate it to your back-end storage
    const id = 187821;
    
    // gas price for native transfers can be set to 1
    const gasPrice = 1;
    
    // time that the Deploy will remain valid for, in milliseconds, the default value is 1800000, which is 30 minutes
    const ttl = 1800000;
    let deployParams = new DeployUtil.DeployParams(
        signKeyPair.publicKey,
        networkName,
        ttl
    );
    
    // we create public key from account-address (in fact it is hex representation of public-key with added prefix)
    const toPublicKey = PublicKey.fromHex(to);
    const session = DeployUtil.ExecutableDeployItem.newTransfer(
        amount,
        toPublicKey,
        null,
        id
    );
    const payment = DeployUtil.standardPayment(paymentAmount);
    const deploy = DeployUtil.makeDeploy(deployParams, session, payment);
    const signedDeploy = DeployUtil.signDeploy(deploy, signKeyPair);
   
    // we are sending the signed deploy 
    return await casperClient.putDeploy(signedDeploy);
    };


    sendTransfer(
    {
        // Put here the account-address of account that is a sender. Note that it needs to have balance greater than 2.5CSPR
        from: "<account-address>",
        // Put here the account-address of the receiver account. In fact this account dont need to exist, if key is proper, it will be created when deploy will be send.
        to: "<account-address>",
        // Minimal amount is 2.5CSPR so 2.5 * 10000 (1CSPR = 10.000 motes)
        amount: 25000000000,
    }
    );

**Note**: At any moment you can serialize the deploy from this example to JSON to accomplish whatever you want (store it, send it etc). 

Here is the code you can use to serialize the deploy:

.. code-block:: javascript

    const jsonFromDeploy = DeployUtil.deployToJson(signedDeploy);
    

Then, you can reconstruct the deploy object using this function: 

.. code-block:: javascript

    const deployFromJson = DeployUtil.deployFromJson(jsonFromDeploy);