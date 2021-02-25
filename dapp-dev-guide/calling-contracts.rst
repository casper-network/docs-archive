
Blockchain Contracts
====================

The most efficient way to use blockchain is to store (install) your contract on the system and then call it.  This section outlines the steps to do this.

Installing a Smart Contract
---------------------------

The Contracts DSL provides all the necessary boilerplate code that is needed to install a contract.
The ``#[casperlabs_contract]`` macro sets up the contract name so it can be called using the name in subsequent deploys. 
Deploy the smart contract through the ``put-deploy`` command and send in the compiled wasm as ``--session code``.

Calling a Contract by Name & Entry Point
----------------------------------------

To call a contract by its' name use the ``session-name`` option. The Contracts DSL makes it possible to create entry points in the contract, which can then be invoked in the contract via the entry point. The ``#[casperlabs_method]`` macro sets up the entry point name. 

.. code-block:: bash

   casper-client put-deploy --session-name <NAME> --session-entry-point <FUNCTION_NAME>

Calling a Contract by Hash & Entry Point
----------------------------------------

After deploying a contract and querying global state, a contract's hash can be used to call it in a new deploy. An entry point is required when calling a contract by its' hash. 

.. code-block:: bash

   casper-client put-deploy  --session-hash <HEX STRING> --session-entry-point <FUNCTION_NAME>
