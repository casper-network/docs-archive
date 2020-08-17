# Casperlabs Key Value Storage Tutorial

This tutorial walks through how to design a simple contract that creates a key that stores a CLType value. 
This example will show you how to store a u64, string, account hash, or U512 value.

Additionally, this tutorial will also provide some insight into how to use the Casperlabs smart contract DSL and how contract headers work.

## The Contract
Lets start by understanding the structure of the contract itself. Here we create a contract using the `casperlabs_contract` macro and name it `kvstorage_contract`.
This is the name under which the contract package will be stored. The next macro we see is the `casperlabs_constructor`, 
since the a key-value contract is slightly stateless in nature, initialization is not required. 
However, `casperlabs_constructor` is a required element, we simply create an empty function.

```rust

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
```

## Testing the Contract

The CasperLabs Contracts SDK supports local testing of smart contracts.  This tutorial will cover how to test the u64 key-value function. 
This can be easily adapted it for other types also.

In order to test the contract, the value must be stored, and the contract has to be deployed.
Here is some sample code for these steps:

```rust
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
```

### Write Unit Tests
With these functions in place, it' possible to start writing tests for the contract.

```rust
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
```
We can also write a test to check whether the value is updated

```
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
```

### Running Locally

It's possible to run the unit tests locally- if you have set up the contract using [cargo-casperlabs](https://crates.io/cargo-casperlabs).
The steps to set up the SDK are in the guide.

```bash
cargo test -p tests
```

## Deploying to the Testnet and Interacting with the Contract
There is a standalone python cli application that you can use for the kvstorage contract. 

**Note, that this client was designed specifically for this contract. **

TODO: Link the repo for this client.

### Deploy the Contract
The first step is actually to deploy the compiled wasm to the network, if you are using the python kv-client you must use the command `deploy_kv_storage_contract`. 
Once the contract is deployed, the client will retrieve the contract session hash as well as the blockhash where the contract is deployed.

```bash
python cli.py deploy_kv_storage_contract -f "29acb007dfa4f92fa5155cc2f3ae008b4ff234acf95b00c649e2eb77447f47ca" -p "../../kvkey.private.key" -c "../target/wasm32-unknown-unknown/release/contract.wasm" -b True

```

### Invoke an Entry Point & Set a value

Once the contract is deployed, we can create another deploy, which calls one of the entry points within the contract. 
To call an entry point, you must first know the name of the entry point and the session hash, which we retrieved from the previous step. 
The kv-client, has four distinct commands to set key-values for u64, String, U512 and AccountHash.

TODO: Need to know what this command returns.

```bash
python cli.py insert_u64 -f "29acb007dfa4f92fa5155cc2f3ae008b4ff234acf95b00c649e2eb77447f47ca" -p "../../kvkey.private.key" -s "0e82027493b88db434e85f82f6bcf48a30e0c1db15cf55fb87b73461b8aef20b" -k "test" -v 1 -b True
```


### Query the Contract On Chain
Contracts can be executed under different contexts.  In this example, 
when the contract is deployed, it runs in the context of a `Contract` and not a ` Session`. 
This means that all stored keys are not stored under the account hash, but within the context of the contract. 
Therefore when we query to retrieve the value under a key, we are actually querying 
`AccountHash/kvstorage_contract/<key-name>` and not just `AccountHash/<key-name>`. 

Reading a value is simple enough, after you insert a value, the command retrieves the block hash under which the value, is stored. 
Using that block hash, and the `read-key` command you can easily retrieve and value that was previously stored under a named key.


```bash
python cli.py read_key -bh "cb08a634c9bbea695fbd92e2ddbeec6fe6a374db807b36fea35077a9c1d720df" -p "29acb007dfa4f92fa5155cc2f3ae008b4ff234acf95b00c649e2eb77447f47ca" -k "test"

```

More information on the kv-client, is available via the `--help` command. There is detailed information on each of the commands available with the client. 

NOTE: The session hash is retrieved from the the chain by using a simple time delay, if processing the deploy takes longer than expected, 
it is likely that the kv-client will error out and not retrieve the session hash. 
In such cases, you can retrieve the session hash using the python casperlabs_client.

You must first find the block hash for the block that contains your deploy.
Once you have the requisite block hash, then you can use the python shell to retrieve the session hash

```bash
Import casperlabs_client
client = casperlabs_client.CasperLabsClient(‘deploy.casperlabs.io’, 40401)
Session_code = client.queryState(<block-hash>, <account-hash>, “kvstorage_contract_hash”,’address’)
Session_hash = session_code.cl_value.value.bytes_value.hex()
``` 













