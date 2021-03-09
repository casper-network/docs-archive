
Basic Node Setup
================

Casper Node Launcher
--------------------

The node software is run from the ``casper-node-launcher`` package. This can be installed with a Debian package which also
creates the casper user, creates directory structures and sets up a systemd unit and logrotate.

The casper-node-launcher Debian package can be obtained from https://bintray.com/casperlabs/debian/casper-node-launcher.

This can also be build from source from https://github.com/CasperLabs/casper-node-launcher.  However, all of the setup
and pull of casper-node releases will be manual.

File Locations
^^^^^^^^^^^^^^

This will describe the locations crated by the casper-node-launcher Debian install or needed for running casper-node versions
and performing upgrades.

A ``casper`` user and ``casper`` group is created during install and used to run the software.

Each version of the casper-node install is located based on the semantic version with underscores.  For example: a version
of ``1.0.3`` would be represented by a directory named ``1_0_3``.  This will apply to both binary and configuration file
locations.  We will represent this with ``[m_n_p]`` below, representing for major, minor, patch of semantic version.

Note: multiple version folders will exist on a system when upgrades are setup to happen.

The casper-node-launcher is installed in ``/usr/bin/casper-node-launcher``
This is the launcher application which will start casper-node as a child process.

``/etc/casper`` is the default location for configuration files.  This can be overwritten with the ``CASPER_CONFIG_DIR``
environment variable.  The paths below assume the default of ``/etc/casper``.

``/etc/casper/casper-node-launcher.state.toml`` is the launcher’s cached state.

``/etc/casper/[m_n_p]`` stores config files for ``casper-node`` of the associated version.  This will hold ``config.toml``,
``chainspec.toml``, and ``accounts.csv`` (optional after first version).

``/etc/casper/validator_keys/`` is the default location for node keys. A ``README.md`` in this directory indicates how
to create keys using the ``casper-client``.

``/var/lib/casper`` is the location for larger and variable data for the casper-node.

``/var/lib/casper/casper-node`` is the location for where casper-node stores local .lmdb files.

``/var/lib/casper/bin`` is the location for storing the versions of ``casper-node`` executables.
This location can be overwritten with the ``CASPER_BIN_DIR`` environment variable.
The path below assume the default of ``/var/lib/casper/bin``

``/var/lib/casper/bin/[m_n_p]/casper-node`` is where the given version of casper-node executable lives and is run from
the casper-node-launcher.

Upgrade Operation
^^^^^^^^^^^^^^^^^

The ``chainspec.toml`` contains a section to indicate what era the given ``casper-node`` version should start running.

.. code-block::

    [protocol.activation_point]
    # This protocol version becomes active at the start of this era.
    era_id = 0

At every block finalization, the ``casper-node`` looks for newly configured versions.  When a new version is configured,
the running node will look at future era_id in the ``chainspec.toml`` file.  This will be the era before where the current
casper-node will cleanly shut down.

The ``casper-node-launcher`` will detect a clean exit 0 condition and start the next version ``casper-node``.

You can choose to build from source. If you opt to do this, please ensure that the correct software version (tag) is used.

Node Version Installation
^^^^^^^^^^^^^^^^^^^^^^^^^

Included with ``casper-node-launcher`` debian package are two scripts to help with installing ``casper-node`` versions.

``/etc/casper/pull_casper_node_version.sh`` will pull ``bin.tar.gz`` and ``config.tar.gz`` from genesis.casperlabs.io.

This is invoked with the release version in undrescore format such as:

.. code-block:: bash

    sudo -u casper /etc/casper/pull_casper_node_version.sh 1_0_2

This will create ``/var/lib/casper/bin/1_0_2/`` and expand the ``bin.tar.gz`` containing at a minimun ``casper-node``.

This will create ``/etc/casper/1_0_2/`` and expand the ``config.tar.gz`` containing ``chainspec.toml``, ``config-example.toml``,
and possibly ``accounts.csv`` and other files.

This will remove the arcive files and run ``/etc/casper/config_from_example.sh 1_0_2`` to create a
``config.toml`` from the ``config-example.toml``.

Client Installation
^^^^^^^^^^^^^^^^^^^

The ``casper-client`` can be installed from https://bintray.com/casperlabs/debian/casper-client.  Download and install
the correct version using ``sudo apt install``.

Create Keys
^^^^^^^^^^^

The Rust client generates keys via the ``keygen`` command.  The process generates 2 pem files and 1 text file.
To learn about options for generating keys, include ``--help`` when running the ``keygen`` command.

.. code-block:: bash

   sudo casper-client keygen /etc/casper/validator_keys

More about keys and key generation can be found in ``/etc/casper/validator_keys/README.md`` if ``casper-node-lancher``
was installed from the debian package.

Config File
-----------

One ``config.toml`` file will need to exist for each ``casper-node`` version installed.  It should be located in the
``/etc/casper/[m_n_p]/`` directory where ``m_n_p`` is the current semantic version.  This can be created from ``config-example.toml`` by
using ``/etc/casper/config_from_example.sh [m_n_p]`` where ``[m_n_p]`` is replaced current version with underscores.

Below are some fields you may find in the ``config.toml`` that you may want or need to adjust.

Trusted Hash for Synchronizing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Casper network is a permissionless, proof of stake network - which implies that validators can come and go from the network.  The implication is that, after a point in time, historical data could have less security if it is retrieved from ‘any node’ on the network.  Therefore, the process for joining the network has to be from a trusted source, a bonded validator.  The system will start from the hash from a recent block and then work backwards from that block to obtain the deploys and finalized blocks from the linear block store.  Here is the process to get the trusted hash:

* Find a list of trusted validators.  
* Query the status endpoint of a trusted validator ( http://[validator_id]:8888/status )
* Obtain the hash of a block from the status endpoint.
* Update the ``config.toml`` for the node to include the trusted hash. There is a field dedicated to this near the top of the file.

Secret Keys
^^^^^^^^^^^

Provide the path to the secret keys for the node.  This is set to ``etc/casper/validator_keys/`` by default.

Networking & Gossiping
^^^^^^^^^^^^^^^^^^^^^^

The node requires a publicly accessible IP address.  We do not recommend NAT at this time. Specify the public IP address of the node.
If you use the ``config_from_example.sh`` external services are called to find your IP and this is inserted into the created ``config.toml``.

Default values are specified in the file, if you want to change them:

* Specify the port that will be used for status  & deploys
* Specify the port used for networking 
* Known_addresses - these are the bootstrap nodes. No need to change these.
