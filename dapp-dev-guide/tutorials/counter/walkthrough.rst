Tutorial Walkthrough
======================

Now that we have the basic commands squared away, we can begin the tutorial to deploy a contract application and use it on the network.

1. Clone the Contracts
------------------------

First, we will need to clone the repository to our local machine. The repo can be found here: https://github.com/casper-ecosystem/counter. If you explore the source code, you will see that there are two smart contracts:


1. **counter-define**
    a. Defines the **named keys** “counter” to reference the contract and associated variable “count”
    b. Provides a function to get the current count (**counter_get**)
    c. Provides a function to increment the current count (**counter_inc**)
2. **counter-call**
    a. Retrieves the counter-define contract, gets the current count value, increments it, and makes sure count was incremented by 1


2. Create a Local Network
---------------------------

After you have gotten familiar with the counter source code, we need to create a local blockchain network to which we can deploy the contract. If you successfully completed the NCTL guide, then you already have everything you need to get up and running. All you need to do is allocate the network assets and then start the network.

If you run the following line in your terminal, you should be able to spin up a network effortlessly (Note: If it fails for any reason, please refer back to the NCTL guide and make sure that all your packages are up to date):

.. code-block:: rust
    
    $ nctl-assets-setup && nctl-start


3. View the Network State
---------------------------

With a network up and running, you can use the casper-client query-state command to check the status of the network, but remember that we first need an account hash and the state-root-hash so that we can get the current “snapshot” moment. Once we have that information, we can check out what the network looks like.

As a summary, we need to use the following three commands:

1. ``nctl-view-faucet-account`` ⇒ get the account hash
2. ``casper-client get-state-root-hash`` ⇒ get the state root hash
3. ``casper-client query-state`` ⇒ get the network state

Let’s execute the commands in order. First, we need the faucet information:

.. code-block:: rust

    # Get the account-hash from the faucet account
    $ nctl-view-faucet-account


If NCTL is correctly up and running, this command should return quite a bit of information about the faucet account. Feel free to look through the records, but make note of the “account-hash” field and the “secret_key.pem” path because we will often use both.

Next, get the state root hash:

.. code-block:: rust

    # Get the state-root-hash
    $ casper-client get-state-root-hash --node-address http://localhost:40101

Notice that we are using localhost as the node server since the network is running on our local machine. Write down the state root hash that is returned, but keep in mind that this hash value will need to be updated every time we modify the network state. Finally, query the actual state:

.. code-block:: rust

    # Get the network state 
    $ casper-client query-state \
        --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] \
        --key [ACCOUNT_HASH]

Substitute the state root hash and account hash values you just retrieved into this command and execute it. Do not be surprised if you are a little underwhelmed when you see nothing really on the network. That is simply because we have not deployed anything to the network yet!

4. Deploy the Counter
-----------------------

The network ought to have nothing on it, as would be expected. Let us try deploying the counter-define contract to the chain. First, though, we need to compile it.

The makefile included in the repo makes compilation trivial. With these two commands, we can both build (in release mode) and test the contract before we deploy it. It will take a minute, so it might be a good time for a little break while your code compiles:

.. code-block:: rust

    $ make prepare # sets the WASM target
    $ make test    # builds the contracts and verifies them

With the compiled contract, we can call the ``casper-client put-deploy`` command to put the contract on the chain. Let’s give it a shot!

.. code-block:: rust

    $ casper-client put-deploy \
        --node-address http://localhost:40101 \
        --chain-name casper-net-1 \
        --secret-key [PATH_TO_YOUR_KEY]/secret_key.pem \
        --payment-amount 5000000000000 \
        --session-path ./counter/target/wasm32-unknown-unknown/release/counter-define.wasm

You will need to replace the ``[PATH_TO_YOUR_KEY]`` field with the actual path of where your secret key is stored. If you forgot to make note of it, it is one of the fields that gets returned when you call ``nctl-view-faucet-account``. The ``session-path`` argument should point to wherever you compiled counter-define.wasm on your computer. In the code snippet, I am showing you the default path if the counter folder is in the same directory.

Once you call this command, it will return a deploy hash to you. You can use this hash to verify that the deploy successfully took place:

.. code-block:: rust

    $ casper-client get-deploy \
        --node-address http://localhost:40101 [DEPLOY_HASH]

5. View the Updated Network State
-----------------------------------

Hopefully the deploy was successful, but is the named key visible on the chain now? We can call ``casper-client query-state`` to check it out!
**REMEMBER**, we must get the new state root hash since we just wrote a deploy to the chain! If you run these two commands, you should see that now there is a new counter named key on the chain!

.. code-block:: rust

    # Get the NEW state-root-hash (SUPER IMPORTANT!)
    $ casper-client get-state-root-hash --node-address http://localhost:40101

    # Get the network state 
    $ casper-client query-state \
        --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] \
        --key [ACCOUNT_HASH]

We can actually dive further into the data stored on the chain using the query path argument or directly querying the deploy hash. Try these three following commands and notice that each one gives you a different level of detail:

.. code-block:: rust

    # Retrieving the specific counter contract details
    $ casper-client query-state --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] \
        --key [ACCOUNT_HASH] -q "counter"

    # Retrieving the specific counter variable details
    $ casper-client query-state --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] \
        --key [ACCOUNT_HASH] -q "counter/count"

    # Retrieving the specific deploy details
    $ casper-client query-state --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] --key deploy-[DEPLOY_HASH]

The first two commands are accessing the counter and count named keys, respectively, using the query path argument. The third command is using the deploy hash (the return value of ``put-deploy``) to query the state of that specific deploy only.

6. Increment the Counter
-----------------------------
We now have a counter on the chain and we verified everything is good. Now we want to increment it! We can do that by calling the entry-point ``counter_inc``, which was the function we had defined in the counter-define contract. You can call an entry-point in a deployed contract by using the put-deploy command as illustrated here:

.. code-block:: rust
    
    # Use the counter_inc function in the smart contract!
    $ casper-client put-deploy \
        --node-address http://localhost:40101 \
        --chain-name casper-net-1 \
        --secret-key [PATH_TO_YOUR_KEY]/secret_key.pem \
        --payment-amount 5000000000000 \
        --session-name "counter" \
        --session-entry-point "counter_inc"


Notice that this command is nearly identical to the command used to deploy the contract, but now instead of ``session-path`` pointing to the WASM binary, we have ``session-name`` and ``session-entry-point`` identifying the on-chain contract and its associated function to execute. There is no WASM file needed since the contract is already on the blockchain!


7. View the Updated Network State Again
----------------------------------------

After calling the entry-point above, theoretically the counter value should have been incremented by one, but how can we be sure of that? We can query the network again, but remember that we have to once again get a new state root hash! Let us check if the counter was actually incremented by just looking at the count with the query argument, since we are not concerned with the rest of the chain right now:

.. code-block:: rust

    # Get the NEW state-root-hash (SUPER IMPORTANT!)
    $ casper-client get-state-root-hash    --node-address http://localhost:40101

    # Get the network state, specifically for the count variable this time
    $ casper-client query-state --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] \
        --key [ACCOUNT_HASH] -q "counter/count"


You should be able to see the counter variable and observe its value has increased now!


8. Increment the Counter Again
-------------------------------

If you recall, we had a second contract named ``counter-call`` in the repository. This time around, we can see if we can increment the count using that second contract instead of the session entry-point we used above.

Keep in mind, this is another ``put-deploy`` call just like when we deployed the ``counter_define`` contract to the blockchain. The session-path is once again going to be different for you depending on where you compiled the contract. Try it out for yourself:

.. code-block:: rust

    # Use the separate counter-call smart contract!
    $ casper-client put-deploy \
        --node-address http://localhost:40101 \
        --chain-name casper-net-1 \
        --secret-key [PATH_TO_YOUR_KEY]/secret_key.pem \
        --payment-amount 5000000000000 \
        --session-path ./counter/target/wasm32-unknown-unknown/release/counter-call.wasm


9. View the Final Network State
---------------------------------

Before we wrap up this guide, let’s make sure that the second contract did in fact update the counter from the first contract! Just as before, we need a new state-root-hash and then we can query the network as we have grown accustomed to by now:

.. code-block:: rust

    # Get the NEW state-root-hash (SUPER IMPORTANT!)
    $ casper-client get-state-root-hash --node-address http://localhost:40101

    # Get the network state, specifically for the count variable this time
    $ casper-client query-state --node-address http://localhost:40101 \
        --state-root-hash [STATE_ROOT_HASH] 
        --key [ACCOUNT_HASH] -q "counter/count"


If all went according to plan, your counter should have gone from 0 to 1 before and now from 1 to 2 as you incremented it throughout this tutorial. Congratulations on building, deploying, and using a smart contract on your local test network! Now you are ready to build your own dApps and launch them onto the Casper blockchain.


Next Steps 
===========
That wraps up this module and, unfortunately, this brief course journey with you. We hope that you have gotten more familiar with development on the Casper network, and we are excited to enter this new decentralized world with you.

See you in the next course! Until then, join us on any of these platforms and let’s build the future together!

* Discord: https://discord.com/invite/Q38s3Vh
* Telegram: https://t.me/casperblockchain
* Twitter: https://twitter.com/Casper_Network
