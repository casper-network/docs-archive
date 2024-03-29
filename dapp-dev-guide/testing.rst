.. role:: raw-html-m2r(raw)
   :format: html


Testing Contracts
=================

As part of the Casper local Rust contract development environment we provide an in-memory virtual machine and `testing framework https://docs.rs/casper-engine-test-support/latest/casper_engine_test_support/>`_ you can run your contract against. A full node is not required for testing. The testing framework is designed to be used in the following way:


#. Initialize the system (context).
#. Deploy or call the smart contract.
#. Query the context for changes and assert the result data matches expected values.

It is also possible to create build scripts with this environment and set up continuous integration for contract code.\ :raw-html-m2r:`<br>`
This environment enables the testing of blockchain enabled systems from end to end.

The TestContext for Rust Contracts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A  TestContext provides a virtual machine instance. It should be a mutable object as its internal data will change with each deploy. It's also important to set an initial balance for the account to use for deploys, as the system requires a balance in order to create an account.

.. code-block:: rust

   const MY_ACCOUNT: [u8; 32] = [7u8; 32];

   let mut context = TestContextBuilder::new()
       .with_account(MY_ACCOUNT, U512::from(128_000_000))
       .build();

Account is type of ``[u8; 32]``. Balance is type of ``U512``.

Running the Rust Smart Contract
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before the contract can be deployed to the context, the request has to be prepared. A request is referred to as a Session. Each session call has 4 elements:


* A Wasm file path.
* A list of arguments.
* The account context for execution.
* The list of keys that authorize the call. 

Here is an example of a prepared request:

.. code-block:: rust

   let VALUE: &str = "hello world";
   let session_code = Code::from("contract.wasm");
   let session_args = runtime_args! {
       "value" => VALUE,
   };
   let session = SessionBuilder::new(session_code, session_args)
       .with_address(MY_ACCOUNT)
       .with_authorization_keys(&[MY_ACCOUNT])
       .build();
   context.run(session);

Executing ``run`` will panic if the code execution fails.

Query and Assert
^^^^^^^^^^^^^^^^

The smart contract creates a new value ``"hello world"`` under the key ``"special_value"``. Using the ``query`` function it's possible to extract this value from the global state of the blockchain.

.. code-block:: rust

   let KEY: &str = "special_value";
   let result_of_query: Result<Value, Error> = context.query(MY_ACCOUNT, &[KEY]);
   let returned_value = result_of_query.expect("should be a value");
   let expected_value = Value::from_t(VALUE.to_string()).expect("should construct Value");
   assert_eq!(expected_value, returned_value);

Note that the ``expected_value`` is a ``String`` type lifted to the ``Value`` type. It was also possible to map ``returned_value`` to the ``String`` type.

Final Test
^^^^^^^^^^

The code below is the simple test generated by `cargo-casper <https://crates.io/crates/cargo-casper>`_ (found in ``tests/src/integration_tests.rs`` of a project created by the tool).

.. code-block:: rust

   #[cfg(test)]
   mod tests {
       use casper_engine_test_support::{Code, Error, SessionBuilder, TestContextBuilder, Value};
       use casper_types::{RuntimeArgs, runtime_args, U512};

       const MY_ACCOUNT: [u8; 32] = [7u8; 32];
       // define KEY constant to match that in the contract
       const KEY: &str = "special_value";
       const VALUE: &str = "hello world";

       #[test]
       fn should_store_hello_world() {
           let mut context = TestContextBuilder::new()
               .with_account(MY_ACCOUNT, U512::from(128_000_000))
               .build();

           // The test framework checks for compiled Wasm files in '<current working dir>/wasm'.  Paths
           // relative to the current working dir (e.g. 'wasm/contract.wasm') can also be used, as can
           // absolute paths.
           let session_code = Code::from("contract.wasm");
           let session_args = runtime_args! {
               "value" => VALUE,
           };
           let session = SessionBuilder::new(session_code, session_args)
               .with_address(MY_ACCOUNT)
               .with_authorization_keys(&[MY_ACCOUNT])
               .build();

           let result_of_query: Result<Value, Error> = context.run(session).query(MY_ACCOUNT, &[KEY]);

           let returned_value = result_of_query.expect("should be a value");

           let expected_value = Value::from_t(VALUE.to_string()).expect("should construct Value");
           assert_eq!(expected_value, returned_value);
       }
   }

   fn main() {
       panic!("Execute \"cargo test\" to test the contract, not \"cargo run\".");
   }
