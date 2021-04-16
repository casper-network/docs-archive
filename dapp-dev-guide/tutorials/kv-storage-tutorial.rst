.. role:: raw-html-m2r(raw)
   :format: html

..
    TODO: re-write this tutorial without DSL. Include it back in the tutorials folder.

Key Value Storage Tutorial
==========================

This tutorial walks through how to design a simple contract that creates a key that stores a CLType value. 
This example will show you how to store a u64, string, account hash, or U512 value.\ :raw-html-m2r:`<br>`
The code is available in the `Casper Ecosystem GitHub <https://github.com/casper-ecosystem/kv-storage-contract>`_.  `Get Started in GitPod <https://gitpod.io/#https://github.com/casper-ecosystem/kv-storage-contract>`_

This tutorial will also provide some insight into how to use the Casperlabs smart contract DSL and how contract headers work.

The Contract
------------

Lets start by understanding the structure of the contract itself. Here we create a contract using the ``casperlabs_contract`` macro and name it ``kvstorage_contract``.
This is the name under which the contract package will be stored. The next macro we see is the ``casperlabs_constructor``\ , 
since the a key-value contract is slightly stateless in nature, initialization is not required. 
However, because ``casperlabs_constructor`` is a required element, we simply create an empty function.

.. code-block:: rust


   #[casperlabs_contract]
   mod kvstorage_contract {

       #[casperlabs_constructor]
       fn init() {}

       #[casperlabs_method]
       fn store_u64(name: String, value: u64) {
           set_key(name.as_str(), value);
       }

       #[casperlabs_method]
       fn get_u64(name: String) -> u64 {
           key(name.as_str())
       }

       #[casperlabs_method]
       fn get_string(name: String) -> String {
           key(name.as_str())
       }

       #[casperlabs_method]
       fn store_u512(name: String, value: U512) {
           set_key(name.as_str(), value);
       }

       #[casperlabs_method]
       fn store_string(name: String, value: String) {
           set_key(name.as_str(), value);
       }

       #[casperlabs_method]
       fn store_account_hash(name: String, value: AccountHash) {
           set_key(name.as_str(), value);
       }

       fn key<T: FromBytes + CLTyped>(name: &str) -> T {
           let key = runtime::get_key(name)
               .unwrap_or_revert()
               .try_into()
               .unwrap_or_revert();
           storage::read(key).unwrap_or_revert().unwrap_or_revert()
       }

       fn set_key<T: ToBytes + CLTyped>(name: &str, value: T) {
           match runtime::get_key(name) {
               Some(key) => {
                   let key_ref = key.try_into().unwrap_or_revert();
                   storage::write(key_ref, value);
               }
               None => {
                   let key = storage::new_uref(value).into();
                   runtime::put_key(name, key);
               }
           }
       }
   }

Testing the Contract
--------------------

The CasperLabs Contracts SDK supports local testing of smart contracts. This tutorial will cover how to test the u64 key-value function. 
This can be easily adapted it for other types also.

In order to test the contract, the value must be stored, and the contract has to be deployed.
Here is some sample code for these steps:

.. code-block:: rust

   impl KVstorageContract{
      pub fn deploy() -> Self {

          // build the test context with the account for the deploy

           let mut context = TestContextBuilder::new()
               .with_account(TEST_ACCOUNT, U512::from(128_000_000))
               .build();

          // specify the session code & build the deploy         
           let session_code = Code::from("contract.wasm");
           let session = SessionBuilder::new(session_code, runtime_args! {})
               .with_address(TEST_ACCOUNT)
               .with_authorization_keys(&[TEST_ACCOUNT])
               .build();
           context.run(session);
           let kvstorage_hash = Self::contract_hash(&context, KV_STORAGE_HASH);
           Self {
               context,
               kvstorage_hash,
           }
       }

       // query the contract hash after the deploy is complete

       pub fn contract_hash(context: &TestContext, name: &str) -> Hash {
           context
               .query(TEST_ACCOUNT, &[name])
               .unwrap_or_else(|_| panic!("{} contract not found", name))
               .into_t()
               .unwrap_or_else(|_| panic!("{} is not a type Contract.", name))
       }

       // store the u_64 value in the global state

       pub fn call_store_u64(&mut self, name: String, value: u64) {
           let code = Code::Hash(self.kvstorage_hash, "store_u64".to_string());
           let args = runtime_args! {
               "name" => name,
               "value" => value,
           };
           let session = SessionBuilder::new(code, args)
               .with_address(TEST_ACCOUNT)
               .with_authorization_keys(&[TEST_ACCOUNT])
               .build();
           self.context.run(session);
       }
   }

Write Unit Tests
^^^^^^^^^^^^^^^^

With these functions in place, it's possible to start writing tests for the contract.

.. code-block:: rust

   mod tests {
       #[test]
       fn should_store_u64() {
           const KEY_NAME: &str = "test_u64";
           let mut kv_storage = KVstorageContract::deploy();
           let name = String::from("test_u64");
           let value: u64 = 1;
           kv_storage.call_store_u64(name, value);
           let check: u64 = kv_storage.query_contract(&KEY_NAME).unwrap();
           assert_eq!(value, check);
       }

      // A test to check whether the value is updated
      #[test]
       fn should_update_u64() {
           const KEY_NAME: &str = "testu64";
           let mut kv_storage = KVstorageContract::deploy();
           let original_value: u64 = 1;
           let updated_value: u64 = 2;
           kv_storage.call_store_u64(KEY_NAME.to_string(), original_value);
           kv_storage.call_store_u64(KEY_NAME.to_string(), updated_value);
           let value: u64 = kv_storage.query_contract(&KEY_NAME).unwrap();
           assert_eq!(value, 2);
       }
   }

Running Locally
^^^^^^^^^^^^^^^

It's possible to run the unit tests locally- if you have set up the contract using `cargo-casperlabs <https://crates.io/cargo-casperlabs>`_.
The steps to set up the SDK are in the guide. 

.. code-block:: bash

   cargo test -p tests

Deploying to the Testnet and Interacting with the Contract
----------------------------------------------------------

When working with the testnet, create an account in `CLarity <https://clarity.casperlabs.io>`_ and fund it using the faucet. Download the private key and use the key to sign the deployment. It's possible to create keys using the rust client as well.

Deploy the Contract
^^^^^^^^^^^^^^^^^^^

After the contract has been compiled, it's time to deploy the compiled wasm to the network. This action installs the contract in the blockchain.
Once the contract is deployed, the client can retrieve the contract session hash as well as the blockhash where the contract is deployed.

```casper-client put-deploy --chain-name :raw-html-m2r:`<CHAIN-NAME>` --node-address http://\ :raw-html-m2r:`<HOST>`\ :\ :raw-html-m2r:`<PORT>` --secret-key /home/keys/secretkey.pem --session-path  $HOME/kv-storage-contract/target/wasm32-unknown-unknown/release/contract.wasm  --payment-amount 1000000000000

.. code-block::


   ### Query the Account & Get the Contract Hash
   The internal state of the blockchain is updated via a series of steps (blocks). All queries of a blockchain must include a `global state hash` which corresponds to the block hash / height of the blockchain.  Visit [Querying the State for the Address of a Contract](https://docs.casperlabs.io/en/latest/dapp-dev-guide/querying.html).


   ### Invoke an Entry Point & Set a value

   Once the contract is deployed, we can create another deploy, which calls one of the entry points within the contract. 
   To call an entry point, you must first know the name of the entry point or  the session hash, which we retrieved from the previous step. 
   The kv-client, has four distinct commands to set key-values for u64, String, U512 and AccountHash.

   ```bash
   casper-client put-deploy --session-name kvstorage_contract --session-entry-point store-string --session-arg=name:"string=`test`" --payment-amount 100000000000 --chain-name <CHAIN-NAME> --node-address http://<HOST>:<PORT> --secret-key /home/keys/secretkey.pem

If the deploy works, a response similar this will be returned:

.. code-block:: bash

   {"api_version":"1.0.0","deploy_hash":"8c3068850354c2788c1664ac6a275ee575c8823676b4308851b7b3e1fe4e3dcc"}

Query the Contract On Chain
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Contracts can be executed under different contexts. In this example, 
when the contract is deployed, it runs in the context of a ``Contract`` and not a ``Session``. 
This means that all stored keys are not stored under the account hash, but within the context of the contract. 
Therefore when we query to retrieve the value under a key, we are actually querying 
``AccountHash/kvstorage_contract/<key-name>`` and not just ``AccountHash/<key-name>``. 

You must first find the block hash for the block that contains your deploy.
Once you have the requisite block hash, then you can use ``casper-client`` to retrieve the session hash

Reading a value is simple enough, we obtain the block hash under which the value, is stored, and then\ :raw-html-m2r:`<br>`
using that block hash, and the ``query-state`` command you can easily retrieve and value that was stored under a named key.
Please reference the `Querying Section <https://docs.casperlabs.io/en/latest/dapp-dev-guide/querying.html>`_ for details.
An example global state query looks like this:

.. code-block:: bash

   casper-client query-state --node-address http://<HOST>:<PORT> -k <PUBLIC_KEY_AS_HEX> -g GLOBAL_STATE_HASH | jq -r
