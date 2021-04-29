Calling Contracts
=================

The most efficient way to use blockchain is to store (install) your contract on the system and then call it. This section outlines the steps to do this.

Installing a Smart Contract
---------------------------

First, set up the contract name so you can call it using the name in subsequent deploys. The following code sample uses ``sample_contract`` as the contract name.

.. code-block:: rust

   let contract_hash = storage::add_contract_version(contract_package_hash, 
                                                     entry_points, 
                                                     Default::default());
   runtime::put_key("sample_contract", contract_hash.into());
 
   runtime::call_contract::<()>(contract_hash, "store_hello_world", {
      let mut named_args = RuntimeArgs::new();
      named_args.insert("s", s);
      named_args.insert("a", a);
      named_args
   });

Next, deploy the smart contract using the ``put-deploy`` command and send in the compiled wasm as ``--session code``.

Calling a Contract by Name & Entry Point
----------------------------------------

To call a contract by its name, run the ``put-deploy`` command using the ``session-name`` option:

.. code-block:: bash

   casper-client put-deploy --session-name <NAME> --session-entry-point <FUNCTION_NAME>

It is possible to create entry points in the contract, which you can invoke while the contract lives on the blockchain. The following code shows you an example entry point:

.. code-block:: rust

   #[no_mangle]
   pub extern "C" fn store_u64() {
      read_and_store::<u64>();
   }

   fn read_and_store<T: CLTyped + FromBytes + ToBytes>() {
      let name: String = runtime::get_named_arg("name");
      let value: T = runtime::get_named_arg("value");
      set_key(name.as_str(), value);
   }


Calling a Contract by Hash and Entry Point
----------------------------------------

After deploying a contract and querying the global state, you can use a contract's hash to call it in a new deploy. An entry point is required when calling a contract by its hash. 

.. code-block:: bash

   casper-client put-deploy  --session-hash <HEX STRING> --session-entry-point <FUNCTION_NAME>