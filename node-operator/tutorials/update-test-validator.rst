Updating an Existing Node
==========================

This tutorial shows you how to update an already installed Delta Testnet validator node on Ubuntu 20.04. Do not execute the commands below as *root* because *sudo* is included where it is required. 

Determining the Node Version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set an environment variable defining the version of the node package you want to set up. For `1.0.0`, use `1_0_0`:

.. code::

    CASPER_VERSION=1_0_0

Updating the Software
^^^^^^^^^^^^^^^^^^^^^

Stop the Node
~~~~~~~~~~~~~
Stop the node if it is running and remove old packages and configuration:

.. code::

        
    sudo systemctl stop casper-node
    sudo systemctl stop casper-node-launcher

    cd ~
    sudo apt remove -y casper-node 
    sudo apt remove -y casper-client 
    sudo apt remove -y casper-node-launcher

    # Clean up old genesis file location
    sudo rm /etc/casper/config.*
    sudo rm /etc/casper/accounts.csv 
    sudo rm /etc/casper/chainspec.toml 
    sudo rm /etc/casper/validation.md5

Install the New Software
~~~~~~~~~~~~~~~~~~~~~~~~

.. code::

    
    curl -JLO https://bintray.com/casperlabs/debian/download_file?file_path=casper-node-launcher_0.2.0-0_amd64.deb
    curl -JLO https://bintray.com/casperlabs/debian/download_file?file_path=casper-client_0.7.6-0_amd64.deb
    sudo apt install -y ./casper-client_0.7.6-0_amd64.deb ./casper-node-launcher_0.2.0-0_amd64.deb


Configuring and Running the Node
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Configure the Node
~~~~~~~~~~~~~~~~~~

.. code::

    cd /etc/casper
    sudo -u casper ./pull_casper_node_version.sh $CASPER_VERSION


Get a Known Validator IP
~~~~~~~~~~~~~~~~~~~~~~~~

First, get a known validator IP. We'll use it multiple times later in the process.

.. code::

    
    KNOWN_ADDRESSES=$(cat /etc/casper/$CASPER_VERSION/config.toml | grep known_addresses)
    KNOWN_VALIDATOR_IPS=$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$KNOWN_ADDRESSES")
    IFS=' ' read -r KNOWN_VALIDATOR_IP _REST <<< "$KNOWN_VALIDATOR_IPS"

    echo $KNOWN_VALIDATOR_IP


After running the commands above, the **$KNOWN_VALIDATOR_IP** variable will contain the IP address of a known validator.

Set a Trusted Hash
~~~~~~~~~~~~~~~~~~
Get the trusted hash from the network:

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


Monitor the Node Status
~~~~~~~~~~~~~~~~~~~~~~~

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


#. Wait for node to catch up

    Before you do anything, such as trying to bond as a validator or perform any RPC calls, make sure your node has fully 
    caught up with the network. You can recognize this by log entries that tell you that joining has finished, and that the
    RPC and REST servers have started:

    .. code::

        
        {"timestamp":"Feb 09 02:28:35.577","level":"INFO","fields":{"message":"finished joining"},"target":"casper_node::cli"}
        {"timestamp":"Feb 09 02:28:35.578","level":"INFO","fields":{"message":"started JSON-RPC server","address":"0.0.0.0:7777"},"target":"casper_node::components::rpc_server::http_server"}
        {"timestamp":"Feb 09 02:28:35.578","level":"INFO","fields":{"message":"started REST server","address":"0.0.0.0:8888"},"target":"casper_node::components::rest_server::http_server"}


Re-building the Contracts
^^^^^^^^^^^^^^^^^^^^^^^^^ 
Re-build the smart contracts required to bond to the network.

#. Get casper-node

    If you don't have it yet, clone the ``casper-node``:

    .. code::

        cd ~
        git clone https://github.com/CasperLabs/casper-node

#. Go to the directory with casper-node sources

    .. code::

        cd ~/casper-node

#. Pull the latest changes

    .. code::

        git fetch

#. Checkout the release branch

    .. code::

        git checkout release-0.7.6

#. Remove previous builds

    .. code::

        make clean


#. Build the contracts

    .. code::

        make setup-rs && make build-client-contracts -j

Funding your Account
^^^^^^^^^^^^^^^^^^^^
To fund an account, visit the `Faucet <https://clarity.casperlabs.io/#/faucet>`_ page. Select the account you want to fund and hit *Request Tokens*. Wait until the request transaction succeeds.

Bonding to the Network
^^^^^^^^^^^^^^^^^^^^^^
Once you ensure that your node is running correctly and is visible to others, proceed to bond.

Check your balance
~~~~~~~~~~~~~~~~~~~
Check your balance to ensure you have funds to bond. To get the balance, you need to perform the following three query commands:

#. Get the state root hash (this has to be performed for each balance check because the hash changes with time): 

    .. code::

        casper-client get-state-root-hash --node-address http://127.0.0.1:7777 | jq -r

#. Get the main purse associated with your account:

    .. code::

        casper-client query-state --node-address http://127.0.0.1:7777 --key <PUBLIC_KEY_HEX> --state-root-hash <STATE_ROOT_HASH> | jq -r


#. Get the main purse balance:

    .. code::

        casper-client get-balance --node-address http://127.0.0.1:7777 --purse-uref <PURSE_UREF> --state-root-hash <STATE_ROOT_HASH> | jq -r


    If you followed the installation steps from this document you can run the following script to check the balance:

    .. code::
        
        PUBLIC_KEY_HEX=$(cat /etc/casper/validator_keys/public_key_hex)
        STATE_ROOT_HASH=$(casper-client get-state-root-hash --node-address http://127.0.0.1:7777 | jq -r '.result | .state_root_hash')
        PURSE_UREF=$(casper-client query-state --node-address http://127.0.0.1:7777 --key "$PUBLIC_KEY_HEX" --state-root-hash "$STATE_ROOT_HASH" | jq -r '.result | .stored_value | .Account | .main_purse')
        casper-client get-balance --node-address http://127.0.0.1:7777 --purse-uref "$PURSE_UREF" --state-root-hash "$STATE_ROOT_HASH" | jq -r '.result | .balance_value'


Send a Bonding Request
~~~~~~~~~~~~~~~~~~~~~~
To bond to the network as a validator you need to submit your bid using ``casper-client``:

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

If you followed the installation steps from this document you can run the following script to bond. It substitutes the public key hex value for you and sends recommended argument values:

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
To determine if your bid was accepted, query the auction by executing the following command:

.. code::

    casper-client get-auction-info --node-address http://127.0.0.1:7777


The bid should appear among the returned **bids**. If the public key associated with a bid appears in the **validator_weights** structure for an era, then the account is bonded in that era.