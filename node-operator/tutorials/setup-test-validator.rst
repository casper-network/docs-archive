Setting up a Node on Testnet
============================

This tutorial shows you how to set up a Delta Testnet validator node from scratch on Ubuntu 20.04. Do not execute the commands below as *root* because *sudo* is included where it is required. 

Installing the Software
^^^^^^^^^^^^^^^^^^^^^^^

Pre-requisites
~~~~~~~~~~~~~~

The node uses **dig** to get an external IP for auto-configuration during the installation process. Thus, you will need to install **dnsutils**.

.. code::

    sudo apt install dnsutils


Install Helpers
~~~~~~~~~~~~~~~

We will use **jq** to process JSON responses from the API later in the process.

.. code::

    sudo apt install jq


Install the Casper Node Launcher
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code::

    curl -JLO https://bintray.com/casperlabs/debian/download_file?file_path=casper-node-launcher_0.3.2-0_amd64.deb
    curl -JLO https://bintray.com/casperlabs/debian/download_file?file_path=casper-client_0.9.4-0_amd64.deb
    sudo apt install -y ./casper-client_0.9.4-0_amd64.deb ./casper-node-launcher_0.3.2-0_amd64.deb


Building the Required Contracts 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Next, build the smart contracts required to bond to the network.

Pre-requisites
~~~~~~~~~~~~~~
Install the pre-requisites for building smart contracts:

.. code::

    sudo apt purge --auto-remove cmake
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
    sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main'   
    sudo apt update
    sudo apt install cmake

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    sudo apt install libssl-dev
    sudo apt install pkg-config
    sudo apt install build-essential


Build the Smart Contracts
~~~~~~~~~~~~~~~~~~~~~~~~~

#. Clone the Casper node source code

    Go to your home directory and clone the ``casper-node`` repository. Later, we will use this path to the smart contracts in our bonding request.

    .. code::
    
        cd ~

        git clone https://github.com/CasperLabs/casper-node

        cd casper-node/


#. Checkout the release branch

    .. code::
    
        git checkout release-0.7.6

#. Build the contracts

    .. code::
    
        make setup-rs
        make build-client-contracts -j


Funding Your Account 
^^^^^^^^^^^^^^^^^^^^^

Generate your Keys
~~~~~~~~~~~~~~~~~~

#. Navigate to the default key directory:

    .. code::
    
        cd /etc/casper/validator_keys
 
#. Execute the following command to generate the keys:

    .. code::
    
        sudo casper-client keygen .

    It will create three files in the ```/etc/casper/validator_keys``` directory:

    - **secret_key.pem** - This is your private key. Never share it with anyone. Save it somewhere securely, offline.
    - **public_key.pem** - This is your public key. 
    - **public_key_hex** - This is a hexadecimal representation of your public key; copy it to your machine to create an account.

#. Save your keys to a safe place. 

Create an Account
~~~~~~~~~~~~~~~~~
Go to `Clarity <https://clarity.casperlabs.io/#/accounts>`_ and login using your Github or Google account. Click the *Import Key* button and select the file containing the hex representation of your public key -- the **public_key_hex** file. Give it a name and click *Save*.  

Fund your Account
~~~~~~~~~~~~~~~~~
To fund an account, visit the `Faucet <https://clarity.casperlabs.io/#/faucet>`_ page. Select the account you want to fund and select *Request Tokens*. Wait until the request transaction succeeds.

Configuring and Running the Node
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set up the Node Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code::
 
    cd /etc/casper
    sudo -u casper ./pull_casper_node_version.sh $CASPER_VERSION

Get a Known Validator IP
~~~~~~~~~~~~~~~~~~~~~~~~~

Let's get a known validator IP first. We'll use it multiple times later in the process.

.. code::
 
    KNOWN_ADDRESSES=$(cat /etc/casper/$CASPER_VERSION/config.toml | grep known_addresses)
    KNOWN_VALIDATOR_IPS=$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$KNOWN_ADDRESSES")
    IFS=' ' read -r KNOWN_VALIDATOR_IP _REST <<< "$KNOWN_VALIDATOR_IPS"

    echo $KNOWN_VALIDATOR_IP

After running the commands above, the ```$KNOWN_VALIDATOR_IP``` variable will contain the IP address of a known validator.

Get a Trusted Hash
~~~~~~~~~~~~~~~~~~
Get the trusted hash from the network for the known validator:

.. code::
 
    # Get trusted_hash into config.toml
    sudo sed -i "/trusted_hash =/c\trusted_hash = '$(curl -s $KNOWN_VALIDATOR_IP:8888/status | jq -r .last_added_block_info.hash | tr -d '\n')'" /etc/casper/$CASPER_VERSION/config.toml


Start the Node
~~~~~~~~~~~~~~

.. code::
 
    
    sudo logrotate -f /etc/logrotate.d/casper-node
    sudo /etc/casper/delete_local_db.sh; sleep 1
    sudo systemctl start casper-node-launcher
    systemctl status casper-node-launcher

Monitor the Node
~~~~~~~~~~~~~~~~~

#. Check the node log

    .. code::
    
        sudo tail -fn100 /var/log/casper/casper-node.log /var/log/casper/casper-node.stderr.log


#. Check if a known validator sees your node among peers

    .. code::
    
        curl -s http://$KNOWN_VALIDATOR_IP:8888/status | jq .peers

    You should see your IP address on the list.

#. Check the node status

    .. code::
    
        curl -s http://127.0.0.1:8888/status


#. Wait for the node to catch up

    Before you do anything, such as trying to bond as a validator or perform any RPC calls, make sure your node has fully caught up with the network. You can recognize this by log entries that tell you that joining has finished and that the RPC and REST servers have started:

    .. code::
    
        {"timestamp":"Feb 09 02:28:35.577","level":"INFO","fields":{"message":"finished joining"},"target":"casper_node::cli"}
        {"timestamp":"Feb 09 02:28:35.578","level":"INFO","fields":{"message":"started JSON-RPC server","address":"0.0.0.0:7777"},"target":"casper_node::components::rpc_server::http_server"}
        {"timestamp":"Feb 09 02:28:35.578","level":"INFO","fields":{"message":"started REST server","address":"0.0.0.0:8888"},"target":"casper_node::components::rest_server::http_server"}


Bonding to the Network
^^^^^^^^^^^^^^^^^^^^^^
Once you ensure that your node is running correctly and is visible to others, proceed to bond.

Check your Balance
~~~~~~~~~~~~~~~~~~~
Check your balance to ensure you have funds to bond. To get the balance, we need to perform the following three query commands:

#. Get the state root hash (this has to be performed for each balance check because the hash changes with time): 

    .. code::
        
        casper-client get-state-root-hash --node-address http://127.0.0.1:7777 | jq -r

#. Get the main purse associated with your account:

    .. code::
        
        casper-client query-state --node-address http://127.0.0.1:7777 --key <PUBLIC_KEY_HEX> --state-root-hash <STATE_ROOT_HASH> | jq -r

#. Get the main purse balance:

    .. code::
        
        casper-client get-balance --node-address http://127.0.0.1:7777 --purse-uref <PURSE_UREF> --state-root-hash <STATE_ROOT_HASH> | jq -r

    If you followed the installation steps from this document, you can run the following script to check the balance:

    .. code::
    
        PUBLIC_KEY_HEX=$(cat /etc/casper/validator_keys/public_key_hex)
        STATE_ROOT_HASH=$(casper-client get-state-root-hash --node-address http://127.0.0.1:7777 | jq -r '.result | .state_root_hash')
        PURSE_UREF=$(casper-client query-state --node-address http://127.0.0.1:7777 --key "$PUBLIC_KEY_HEX" --state-root-hash "$STATE_ROOT_HASH" | jq -r '.result | .stored_value | .Account | .main_purse')
        casper-client get-balance --node-address http://127.0.0.1:7777 --purse-uref "$PURSE_UREF" --state-root-hash "$STATE_ROOT_HASH" | jq -r '.result | .balance_value'


Sending a Bonding Request
~~~~~~~~~~~~~~~~~~~~~~~~~
To bond to the network as a validator you need to submit your bid using the ``casper-client``:

.. code::

    casper-client put-deploy \
            --chain-name "<CHAIN_NAME>" \
            --node-address "http://127.0.0.1:7777/" \
            --secret-key "/etc/casper/validator_keys/secret_key.pem" \
            --session-path "$HOME/casper-node/target/wasm32-unknown-unknown/release/add_bid.wasm" \
            --payment-amount 1000000000 \
            --gas-price=1 \
            --session-arg=public_key:"public_key='<PUBLIC_KEY_HEX>'" \
            --session-arg=amount:"u512='9000000000000000'" \
            --session-arg=delegation_rate:"u64='10'"

Where:

- **amount** - This is the amount that is being bid. If the bid wins, this will be the validator’s initial bond amount. The recommended bid amount is 90% of your faucet balance.  This is 900,000 CSPR  or 9000000000000000 motes as an argument to the add_bid contract deploy. 
- **delegation_rate** - The percentage of rewards that the validator retains from delegators that delegate their tokens to the node.

Replace:

- **<CHAIN_NAME>** with the chain name you are joining
- **<PUBLIC_KEY_HEX>** with the hex representation of your public key 

Note the **deploy_hash** returned in the response to query its status later.

If you followed the installation steps from this document, you can run the following script to bond. It substitutes the public key hex value for you and sends the recommended argument values:

.. code::
 
    PUBLIC_KEY_HEX=$(cat /etc/casper/validator_keys/public_key_hex)
    CHAIN_NAME=$(curl -s http://127.0.0.1:8888/status | jq -r '.chainspec_name')

    casper-client put-deploy \
        --chain-name "$CHAIN_NAME" \
        --node-address "http://127.0.0.1:7777/" \
        --secret-key "/etc/casper/validator_keys/secret_key.pem" \
        --session-path "$HOME/casper-node/target/wasm32-unknown-unknown/release/add_bid.wasm" \
        --payment-amount 1000000000 \
        --gas-price=1 \
        --session-arg=public_key:"public_key='$PUBLIC_KEY_HEX'" \
        --session-arg=amount:"u512='9000000000000000'" \
        --session-arg=delegation_rate:"u64='10'"


Check your Bonding Request
~~~~~~~~~~~~~~~~~~~~~~~~~~
Sending a transaction to the network does not mean that the transaction is processed successfully. It is important to check to see that the contract executed properly:

.. code::
 
    casper-client get-deploy --node-address http://127.0.0.1:7777 <DEPLOY_HASH> | jq .result.execution_results


Replace **<DEPLOY_HASH>** with the deploy hash of the transaction you want to check.

Check your Bid
~~~~~~~~~~~~~~
To determine if the bid was accepted, execute the following command to query the auction information and look for your bid:

.. code::
 
    casper-client get-auction-info --node-address http://127.0.0.1:7777


The bid should appear among the returned **bids**. If the public key associated with a bid appears in the **validator_weights** structure for an era, then the account is bonded in that era.