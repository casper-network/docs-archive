
Setting up a Node
=================

This document describes the components and processes needed to set up a node on the Casper Network. For a quick-start guide, follow the `Casper How-To Guides <https://docs.cspr.community/>`_ or the video tutorial below. In addition, we recommend reviewing the documentation below to understand how a Casper node is structured and how it functions.
  
Video Tutorial
^^^^^^^^^^^^^^

To get started with a brief video, the following tutorial walks through setting up a validator node on the *casper-test* network using Ubuntu 20.04. This video tutorial complements this documentation, as you will be able to see the expected commands and output. 

.. raw:: html 

   <iframe width="560" height="315" src="https://www.youtube.com/embed?v=BN6C4C1T_TY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Prerequisites
^^^^^^^^^^^^^
#. Add the Casper repository to *apt* in Ubuntu using these commands:
   
.. code-block:: bash

    echo "deb https://repo.casperlabs.io/releases" bionic main | sudo tee -a /etc/apt/sources.list.d/casper.list
    curl -O https://repo.casperlabs.io/casper-repo-pubkey.asc
    sudo apt-key add casper-repo-pubkey.asc
    sudo apt update

Installing the Node
^^^^^^^^^^^^^^^^^^^
To install the Casper node software, you need to install the ``casper-node-launcher`` and the ``casper-client`` with these commands:

.. code-block:: bash

   sudo apt install casper-node-launcher -y
   sudo apt install casper-client -y
   
   
Casper Node Launcher
~~~~~~~~~~~~~~~~~~~~
The ``casper-node-launcher`` is a binary which runs and upgrades the *casper-node* of the Casper Network. The source code is available here: https://github.com/casper-network/casper-node-launcher.

On startup, the launcher either tries to read its previously cached state from disk, or assumes a fresh start. On a fresh start, the launcher searches for the lowest installed version of *casper-node* and starts running it in validator mode.

The installation of the ``casper-node-launcher`` creates the Casper user and the necessary directory structures. It also sets up a *systemd* unit and *logrotate*.

Client Installation
~~~~~~~~~~~~~~~~~~~

A Rust client called ``casper-client`` needs to be installed from https://crates.io/crates/casper-client.

Run the command below to install the Casper client on most flavors of Linux.

.. code-block:: bash

    sudo apt install casper-client -y

The Casper client can print out `help` information, which provides an up-to-date list of supported commands. 

.. code-block:: bash

    casper-client --help

For each command, you can also use `help` to get the up-to-date arguments and descriptions:

.. code-block:: bash

    casper-client <command> --help


File Locations
^^^^^^^^^^^^^^

This section describes the directories and files the ``casper-node-launcher`` Debian install creates, needed for running ``casper-node`` versions and performing upgrades.

A *casper* user and *casper* group is created during install and used to run the software.

Each version of the ``casper-node`` install is located based on the semantic version with underscores. For example, version *1.0.3* would be represented by a directory named ``1_0_3``. This convention applies to both binary and configuration file locations. We will represent versioning with ``[m_n_p]`` below, representing the major, minor, patch of a semantic version.

**Note**: multiple versioned folders will exist on a system when upgrades are setup.

The installation of ``casper-node-launcher``, ``casper-node``, and ``casper-client`` software is relatively simple, but the process accomplishes many things behind the scenes. This section describes the installation process and where the files are stored.

Two main folders are relevant for our software: ``/etc/casper`` and ``/var/lib/casper``.

The following is the state of the filesystem after installing the ``casper-client`` and ``casper-node-launcher`` Debian packages, and also after running the script */etc/casper/pull_casper_node_version.sh*.

``/usr/bin``
~~~~~~~~~~~~~
The default location for executables from the Debian package install is ``/usr/bin``.

* ``casper-client`` - A client for interacting with the Casper network
* ``casper-node-launcher`` - The launcher application which starts the ``casper-node`` as a child process

``/etc/casper``
~~~~~~~~~~~~~~~
This is the default location for configuration files. It can be overwritten with the ``CASPER_CONFIG_DIR`` environment variable. The paths in this document assume the default configuration file location of ``/etc/casper``. The data is organized as follows:

* **delete_local_db.sh** - Removes `*.lmdb*` from ``/var/lib/casper/casper-node``
    
* **pull_casper_node_version.sh** <protocol_version> <network_name> - Pulls ``bin.tar.gz`` and ``config.tar.gz`` from `genesis.casperlabs.io <http://genesis.casperlabs.io/>`_ for a protocol package; decompresses them into ``/var/lib/bin/<protocol_version>`` and ``/etc/casper/<protocol_version>``, and removes the *\*.tar.gz* files

* **config_from_example.sh** <protocol_version> - Gets external an IP to replace and create the *config.toml* from *config-example.toml*

* **casper-node-launcher-state.toml** - This is the local state for the ``casper-node-launcher`` and it is created during the first run

* ``validator_keys`` - The default location for node keys.

    * **README.md** - Instructions on how to create validator keys using the ``casper-client``
    * **secret_key.pem** - ``casper-client keygen`` creates this file or it is manually copied here
    * **public_key.pem** - ``casper-client keygen`` creates this file or it is manually copied here
    * **public_key_hex** - ``casper-client keygen`` creates this file or it is manually copied here

* ``1_0_0`` - created with *pull_casper_node_version.sh 1_0_0 <network_name>* for genesis files

    * **accounts.toml** - Contains the genesis validators and delegators
    * **chainspec.toml** - Contains the genesis state with the *activation_point* as a timestamp
    * **config-example.toml** - Example for creating a *config.toml* file
    * **config.toml** - Created by a node operator manually or by running *config_from_example.sh 1_0_0*

* ``m_n_p`` - *0* to *N* upgrade packages

    * **chainspec.toml** - Contains the *activation_point* as the Era ID int
    * **config-example.toml** - Example for creating a *config.toml* file
    * **config.toml** - Created by a node operator manually or by running *config_from_example.sh <protocol_version>*

``/var/lib/casper``
~~~~~~~~~~~~~~~~~~~
This is the location for larger and variable data for the ``casper-node``, organized in the following directories and files:

    * ``bin`` - The location for storing the versions of ``casper-node`` executables. This location can be overwritten with the ``CASPER_BIN_DIR`` environment variable. The paths in this document assume the default of ``/var/lib/casper/bin``.
  
        * ``1_0_0`` - Created with *pull_casper_node_version.sh 1_0_0 <network_name>* for binaries
  
            * ``casper-node`` - Defaults to the Ubuntu 18.04 compatible binary
            * **README.md** - Information about the repository location and the Git hash used for compilation to allow a rebuild on other platforms
  
        * ``m_n_p`` - *0* to *N* upgrade packages for binaries using *pull_casper_node_version.sh 1_0_0 <network_name>* 
  
            * ``casper-node`` -  This is where the given version of the ``casper-node`` executable lives and is run from the ``casper-node-launcher``.
            * **README.md**

    * ``casper-node`` - Local data store and the largest user of disc space 
  
        * **data.lmdb** - Global state of the chain
        * **data.lmbd-lock**
        * **storage.lmdb** - Blocks, deploys, and everything else
        * **storage.lmdb-lock**
        * **unit_\*** - The node creates one of these files per era


Upgrading the Node
^^^^^^^^^^^^^^^^^^

The ``chainspec.toml`` contains a section indicating what era the given ``casper-node`` version should start running.

.. code-block::

    [protocol.activation_point]
    # This protocol version becomes active at the start of this era.
    era_id = 0

At every block finalization, the ``casper-node`` looks for newly configured versions.  When a new version is configured, the running node looks at the future era_id in the ``chainspec.toml`` file.  This will be the era before where the current ``casper-node`` will cleanly shut down.

The ``casper-node-launcher`` will detect a clean exit 0 condition and start the next version of the ``casper-node``.

If you choose to build `from source <https://github.com/casper-network/casper-node-launcher>`_, please ensure that the correct software version (tag) is used.

Installing Specific Node Versions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Included with the ``casper-node-launcher`` package are two scripts to help with installing ``casper-node`` versions.

``/etc/casper/pull_casper_node_version.sh`` will pull ``bin.tar.gz`` and ``config.tar.gz`` from genesis.casperlabs.io.

This is invoked with the release version in underscore format such as:

.. code-block:: bash

    sudo -u casper /etc/casper/pull_casper_node_version.sh 1_0_2

This will create ``/var/lib/casper/bin/1_0_2/`` and expand the ``bin.tar.gz`` containing at a minimun ``casper-node``.

This will create ``/etc/casper/1_0_2/`` and expand the ``config.tar.gz`` containing ``chainspec.toml``, ``config-example.toml``,
and possibly ``accounts.csv`` and other files.

This will remove the arcive files and run ``/etc/casper/config_from_example.sh 1_0_2`` to create a
``config.toml`` from the ``config-example.toml``.


Creating Keys
^^^^^^^^^^^^^

The Rust client generates keys via the ``keygen`` command.  The process generates two *.pem* files and one *text* file.

To learn about options for generating keys, include ``--help`` when running the ``keygen`` command.

.. code-block:: bash

   sudo casper-client keygen /etc/casper/validator_keys

More about keys and key generation can be found in the ``/etc/casper/validator_keys/README.md`` if the ``casper-node-lancher`` was installed using *apt* in Ubuntu.


Configuring the Node
^^^^^^^^^^^^^^^^^^^^

A ``config.toml`` file needs to exist for each `casper-node` version installed.  This configuration file should be located in the ``/etc/casper/[m_n_p]/`` directory, where `m_n_p` is the current semantic version.  The ``config.toml`` can be created from ``config-example.toml`` generated by running the following script. Replace ``[m_n_p]`` with the current version, using underscores:

.. code-block:: bash

   /etc/casper/config_from_example.sh [m_n_p]

Below are some fields you may find in the ``config.toml`` you may need to adjust.


Trusted Hash for Synchronizing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Casper Network is a permissionless, Proof-of-Stake network, which implies that validators can come and go from the network.  The implication is that, after a point in time, historical data could have less security if it is retrieved from ‘any node’ on the network. Therefore, joining the network has to be from a trusted source, a bonded validator. The system will start from the hash from a recent block and then work backward from that block to obtain the deploys and finalized blocks from the linear block store. Here is the process to get the trusted hash:

* Find a list of trusted validators  
* Query the status endpoint of a trusted validator ( http://[validator_id]:8888/status )
* Obtain the hash of a block from the status endpoint
* Update the ``config.toml`` for the node to include the trusted hash. There is a field dedicated to this near the top of the file


Secret Keys
~~~~~~~~~~~

Provide the path to the secret keys for the node.  This is set to ``etc/casper/validator_keys/`` by default.


Networking & Gossiping
~~~~~~~~~~~~~~~~~~~~~~

The node requires a publicly accessible IP address.  We do not recommend NAT at this time. Specify the public IP address of the node. If you use the ``config_from_example.sh``, external services are called to find your IP, and this is inserted into the ``config.toml`` generated.


Ports and Known Addresses
~~~~~~~~~~~~~~~~~~~~~~~~~

You can update the following default port values specified in the ``config.toml`` file:

* Specify the port that will be used for status & deploys
* Specify the port used for networking 

**Note**: known_addresses specify the bootstrap nodes, and there is no need to change these addresses.

