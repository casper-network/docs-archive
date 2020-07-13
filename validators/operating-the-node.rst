Operating the Node
------------------

CasperLabs will start the bootstrap node and share the information about bootstrap node, chainspec and round exponent on github. This information would be needed to join the Testnet.

Start the node as per the instructions using the information provided above. Note: make sure you run the execution engine before starting the node.

If your nodes starts up correctly you will observe blocks being downloaded.

You can curl the status port of your node for more information. Typically this is at port 40403 unless you have configured a different port:

.. code:: None

    curl https://localhost:40403/status

The output appears as JSON, you can make the output more readable by piping it to JSON query:

.. code:: None

    curl https://localhost:40403/status | jq


Check the status port to check that your node is synchronizing properly. You can check the last finalized block against Clarity to confirm this.

Observe `CLarity <https://testnet-explorer.casperlabs.io/#/>`_ and monitor the network.

Participate in the Zug 500 activities and earn rewards.


Restarting the node
~~~~~~~~~~~~~~~~~~~

If you need to restart your node, make sure you delete your ``.casperlabs`` directory. **Have a backup of your TLS keys, or specify a different location when you set them up.**

To shut down the node, use ``Ctrl-C``.
