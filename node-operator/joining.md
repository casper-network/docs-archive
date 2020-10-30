Joining a Running Network
===========================

The Casper network is permissionless, enabling new validators to join the network and provide additional security to the system. This page will outline 
the sequence of recommended steps to spin up a validating node and successfully join an existing network. 

## Step 1: Provision Hardware
Visit the Hardware section and provision your node hardware.

## Step 2: Set Up the Node
Visit the Setup section in this guide and configure the software on your node.

## Step 3: Fund your Keys for Bonding
Obtain token to bond your node on to the network & to pay for the bonding transaction.

## Step 4: Send the Bonding Request
Before your start your node, it's necessary for you to send a bonding request first. Consensus only sends messages to bonded nodes at this time.
Visit the bonding section of this guide for detailed steps on how to do this.

## Step 5: Update the Trusted Hash
The node's `config.toml` needs to be updated with a recent trusted hash. Visit a `/status` endpoint of a validating node to obtain a fresh trusted block hash.
```bash
curl http://<IP_ADDRESS>:<PORT>/status
```
Default port is usually `7777`  Retrieve thhe `last_added_block_info:` hash.

## Step 5: Start the Node
Once the node has been added to the list of validators for an upcoming era, it's time to start the node.  The deb package installs a casper-node service for
systemd. Start the node with:

```bash
sudo systemctl start casper-node
```

For more information visit [Github](https://github.com/CasperLabs/casper-node/blob/release-1.5.0/resources/production/README.md)

## Step 6: Confirm the Node Proposes Blocks
Once the node catches up to the current era, and it is part of the `era-validators` structure in the auction contract, it will propose a block when
selected as leader.  Look for the node's public key as `proposer` for a new block in the `/status` endpoint.

**Note: While the node is synchronizing, the `/status` endpoint is NOT available. 
