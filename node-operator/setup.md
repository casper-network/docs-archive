Basic Node Setup
================

## Obtain the node software

You can choose to build from source. If you opt to do this, please ensure that the correct software version (tag) is used. You will also need to obtain the 4 system wasm contracts which are distributed with the debian package. Wasm compilation is non-deterministic, so for those building from source, the wasm system contracts will need to use pre-built wasm files. Otherwise the genesis hash will be different for the system and it will experience protocol level faults. 

The recommended way is to obtain released packages using debian installers. Installing the debian package will automatically configure the system into a working state if a config.toml does not exist yet.  If keys are generated in ‘/etc/casper/validator_keys/’, the system can be started with no manual configuration.

If you have installed a version of the node before, plese uninstall the older version.  Please also clear out any old state. There is a script `delete_local_db.sh` in `/casper-node` which removes local state in `/var/lib/casper/casper-node`.

If you have run versions prior to 1.5.0, you may have local state in `/root/.local/share/casper-node` which should be deleted.

Depending on your system, you may need to use either `dpkg' or 'apt'

```bash
apt install dnsutils

sudo dpkg -i casper-node_1.5.0_amd64.deb 
```
or 
```bash
sudo apt install casper-node_1.5.0_amd64.deb 
```
This will install both the node and the client.  Configuration files are located in `etc/casper`, and an example config.toml is present as `/etc/casper/config-example.toml`.


## Create Keys

The Rust client generates keys via the `keygen` command.  The process generates 2 pem files and 1 text file.
To learn about options for generating keys, include `--help` when running the `keygen` command.

```bash
casper-client keygen <PATH_FOR_NEW_KEYS>
```

## Set up the Node Configuration

Once you have the node system installed, you have to create the configuration for the node software to run.  Each node should be configured separately. The software provides an example configuration file that can be used as a template. Create `/etc/casper/config.toml` from `/etc/casper/config-example.toml`  If you installed the node system from the provided debian package, a valid `/etc/casper/config.toml` is automatically generated during the installation. If `/etc/casper/config.toml` already exists, the file is saved as `/etc/casper/config.toml.new`. The following sections describe portions of the node config.toml and how to complete these sections.

### Obtain the ChainSpec

The Casper node creates the genesis block locally on the system by consuming 2 files. 
chainspec.toml and accounts.csv. The chainspec.toml file sets up a series of configuration options for the blockchain, and the accounts.csv lists the starting balances for the network.
Depending on which network the node is joining, a different set of source files will be needed.  The files have to match exactly (have the same checksums) in order for the nodes to connect (have the same Genesis block)

This is done automatically during installation of the debian package. However, if you need to update these files, they are run using the `casper` user with a script in `/etc/casper`.

This script will pull the latest files for the chainspec from the release branch and verify their md5 checksums.
```bash
sudo -u casper /etc/casper/pull_genesis.sh
```
### Trusted Hash for Synchronizing
The Casper network is a permissionless, proof of stake network - which implies that validators can come and go from the network.  The implication is that, after a point in time, historical data could have less security if it is retrieved from ‘any node’ on the network.  Therefore, the process for joining the network has to be from a trusted source, a bonded validator.  The system will start from the hash from a recent block and then work backwards from that block to obtain the deploys and finalized blocks from the linear block store.  Here is the process to get the trusted hash:

* Find a list of trusted validators.  
* Query the status endpoint of a trusted validator
* Obtain the hash of a block from the status endpoint.
* Update the config.toml for the node to include the trusted hash. There is a field dedicated to this in the file. 
* Ensure that your storage directory is clear.  For the time being, the system requires an empty starting state in order to synchronize.  

### Logs
 Configure whether you want text or JSON

### Secret Keys
Provide the path to the secret keys for the node.

### Networking & Gossiping
The node requires a publicly accessible IP address.  We do not recommend NAT at this time. Specify the public IP address of the node. Default values are specified in the file, if you want to change them: 
* Specify the port that will be used for status  & deploys
* Specify the port used for networking 
* Known_addresses - these are the bootstrap nodes. No need to change these.

### Save the Config Toml
Save your changes to the file.



