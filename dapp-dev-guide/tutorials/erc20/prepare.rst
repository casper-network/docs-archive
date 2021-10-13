
Preparation
===========

First clone the contract from GitHub: 

.. code-block:: bash

   $ git clone https://github.com/casper-ecosystem/erc20 && cd erc20


Prepare your environment with the following command:

.. code-block:: bash

   $ make prepare

If your environment is setup correctly, you will see this output:

.. code-block:: bash

   rustup target add wasm32-unknown-unknown
   info: component 'rust-std' for target 'wasm32-unknown-unknown' is up to date

If you do not see this message, check `the Getting Started guide <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_.

Next, compile your contract and run the contract unit tests.

.. code-block:: bash

   $ make build-contracts
   $ make test
