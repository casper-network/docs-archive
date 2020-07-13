Signing Up and Setting Up
-------------------------

CasperLabs is building a permissionless public blockchain. However, the first phase of the Testnet is only open to validators that have agreed to the terms and conditions. The process to sign up for the testnet is as follows:

- Create Account Keys using `CLarity <https://testnet-explorer.casperlabs.io/>`_ or the `CasperLabs Client <https://github.com/CasperLabs/CasperLabs/blob/master/docs/KEYS.md>`_.
- Save the public and private keys on the system that would be used to operate the node.  Please keep a backup of your private key secure.
- Fill out `this <https://forms.gle/A2Lkv4kHYN2dU3om6>`_ form to share your public key and also agree with our terms and conditions.

Installation
~~~~~~~~~~~~

Download the latest version software from `bintray <https://dl.bintray.com/casperlabs/>`_.
Our public repositories feature prebuilt Debian and RPM packages:

- Debian: https://dl.bintray.com/casperlabs/debian/

- RPM: https://dl.bintray.com/casperlabs/rpm/

To install from our Debian repository, run

.. code:: None

    echo "deb https://dl.bintray.com/casperlabs/debian /" | sudo tee -a /etc/apt/sources.list.d/casperlabs.list
    curl -o casperlabs-public.key.asc https://bintray.com/user/downloadSubjectPublicKey?username=casperlabs
    sudo apt-key add casperlabs-public.key.asc
    sudo apt update
    sudo apt install casperlabs

To install from our rpm repository, run

.. code:: None

    curl https://bintray.com/casperlabs/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-casperlabs-rpm.repo
    sudo yum install casperlabs


Expose the following ports:

* 40400: Intra node communication port for consensus.
* 40401: External GRPC for deployments
* 40403: For monitoring (GraphQL, Grafana etc)
* 40404: Intra node communication port for node discovery.

Finally, generate TLS certificates for the node using the instructions in :ref:`generate-keys`.
