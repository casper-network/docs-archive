
Prepare
=======

First clone the contract from GitHub: 

.. code-block:: bash

$ git clone http://github.com/CasperLabs/erc20.git


Ensure that you have pre-requisites installed. 

.. code-block:: bash

$ make prepare


If your environment is correct, you will see:

.. code-block:: bash

rustup target add wasm32-unknown-unknown
info: component 'rust-std' for target 'wasm32-unknown-unknown' is up to date

If you do not see this message, check build prequisites at:ref:`/dapp-dev-guide/setup-of-rust-contract-sdk.rst`



Verify your setup by compiling ``contract`` crate and executing ``cargo test`` on ``tests`` crate.

.. code-block:: bash

   $ cargo build --release -p contract 
   $ cargo test -p tests
