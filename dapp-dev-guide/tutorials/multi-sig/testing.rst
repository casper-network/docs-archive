Testing your Client
===================

You will now test your client using `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_, and you will interact with your local blockchain.

Prerequisites
^^^^^^^^^^^^^
* You have completed all the previous sections, and your local network is up and running using the `nctl <https://github.com/CasperLabs/casper-node/tree/master/utils/nctl>`_ tool.
* Install `yarn <https://yarnpkg.com/getting-started>`_ if you do not have it on your machine.

Commands
^^^^^^^^

Clone this `GitHub repository <https://github.com/CasperLabs/clarity>`_, which contains two useful tools that you will need for testing:

* An event store that runs as a local webserver
* An event handler that processes a stream of events from the blockchain

You do not need to follow the entire README file in the above repository. The instructions below are sufficient for this tutorial.

.. code-block:: bash

    $ git clone https://github.com/CasperLabs/clarity

Navigate to the root of the clarity directory and run:

.. code-block:: bash

    $ yarn install
    $ yarn build

Clarity contains an event store, which you will use as a data source in your testing. The event store receives data from the node and saves it in a SQL database.

Open a new terminal tab and start the event store by running these commands:

.. code-block:: bash

    $ cd packages/event_store
    $ rm developement_sqlite.db    // Removes old SQL data
    $ npm run start-web-server     // Starts the event store

Open another terminal tab and start processing the event stream:

.. code-block:: bash

    $ npm run start-event-handler  // Starts the event processing

Navigate to your ``/keys-manager/client`` folder and run the ``keys-manager.js`` using ``node``. Your WASM file's path is relative to the ``client`` folder, so you need to run the file from here.

.. code-block:: bash

    $ node src/keys-manager.js

If the code works, the beginning of the output will look like this:

.. image:: ../../../assets/tutorials/multisig/output_begin.png
  :alt: An image of the beginning of the keys-manager output.

You can match the rest of the output against the expected output described in the previous section.

Congratulations! You have completed the tutorial.

You can now employ a similar strategy to set up your account using multiple keys.

We offer some additional examples of account management in the next section.