
The source code shown in this tutorial is adapted from using the casperlabs solidity to rust transpilier. Previously, we would implement a separate ``logic`` crate to implement the ERC20 standard functionality. However, now with the new contract headers system, we can directly implement them into the ``contract`` crate.

ERC-20 Standard
---------------

The ERC-20 standard is defined in `an Ethereum Improvement Proposal (EIP) <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#>`_. Read it carefully, as it defines the methods we'll implement:


* balance_of
* transfer
* total_supply
* approve
* allowance
* transfer_from
* mint

Create a New Empty Smart Contract
---------------------------------

Rust development with Casper is easy with the Rust SDK. Create a new contract by following these `steps <https://docs.casperlabs.io/en/latest/dapp-dev-guide/setup-of-rust-contract-sdk.html>`_.

Include the Casper DSL
^^^^^^^^^^^^^^^^^^^^^^

Contract development is easier with the DSL.  Update the ``Cargo.toml`` with the DSL `package <https://docs.casperlabs.io/en/latest/dapp-dev-guide/contract-dsl/index.html>`_.  

Contract Initialization
-----------------------

When the contract is deployed it must be initialized with some values, this can be done with the help of the ``casperlabs_constructor``. This also initializes the balance with the starting token supply.

.. code-block:: rust

   #[casperlabs_constructor]
   fn constructor(tokenName: String, tokenSymbol: String, tokenTotalSupply: U256) {
       set_key("_name", tokenName);
       set_key("_symbol", tokenSymbol);
       let _decimals: u8 = 18;
       set_key("_decimals", _decimals);
       set_key(&new_key("_balances", runtime::get_caller()), tokenTotalSupply);
       let _totalSupply: U256 = tokenTotalSupply;
       set_key("_totalSupply", _totalSupply);
   }

We then also add a few helper functions to set, and retrieve values from keys. The ``[casperlabs_method]`` macro facilitates this. Notice that each of these helper functions reference each of the ``set_key`` definitions in the constructor.

.. code-block:: rust

   #[casperlabs_method]
   fn name() {
       ret(get_key::<String>("_name"));
   }

   #[casperlabs_method]
   fn symbol() {
       ret(get_key::<String>("_symbol"));
   }

   #[casperlabs_method]
   fn decimals() {
       ret(get_key::<u8>("_decimals"));
   }

   // write to storage
   fn get_key<T: FromBytes + CLTyped + Default>(name: &str) -> T {
       match runtime::get_key(name) {
           None => Default::default(),
           Some(value) => {
               let key = value.try_into().unwrap_or_revert();
               storage::read(key).unwrap_or_revert().unwrap_or_revert()
           }
       }
   }
   // write to storage
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

   fn new_key(a: &str, b: AccountHash) -> String {
       format!("{}_{}", a, b)
   }

Total Supply, Balance and Allowance
-----------------------------------

We are ready now to define first ERC-20 methods. Below is the implementation of ``balance_of``\ , ``total_supply`` and ``allowance``. These are read-only methods.

.. code-block:: rust

   #[casperlabs_method]
   fn totalSupply() {
       ret(get_key::<U256>("_totalSupply"));
   }

   #[casperlabs_method]
   fn totalSupply() {
       ret(get_key::<U256>("_totalSupply"));
   }

   #[casperlabs_method]
   fn allowance(owner: AccountHash, spender: AccountHash) -> U256 {
       let key = format!("_allowances_{}_{}", owner, spender);
       get_key::<U256>(&key)
   }

Transfer
--------

Finally we can implement ``transfer`` method, so it's possible to transfer tokens from ``sender`` address to ``recipient`` address. If the ``sender`` address has enough balance then tokens should be transferred to the ``recipient`` address.

.. code-block:: rust

   #[casperlabs_method]
   fn transfer(recipient: AccountHash, amount: U256) {
       _transfer(runtime::get_caller(), recipient, amount);
   }


   fn _transfer(sender: AccountHash, recipient: AccountHash, amount: U256) {
       let new_sender_balance: U256 = (get_key::<U256>(&new_key("_balances", sender)) - amount);
       set_key(&new_key("_balances", sender), new_sender_balance);
       let new_recipient_balance: U256 = (get_key::<U256>(&new_key("_balances", recipient)) + amount);
       set_key(&new_key("_balances", recipient), new_recipient_balance);
   }

Approve and Transfer From
-------------------------

The last missing functions are ``approve`` and ``transfer_from``. ``approve`` is used to allow another address to spend tokens on my behalf.

.. code-block:: rust

   #[casperlabs_method]
   fn approve(spender: AccountHash, amount: U256) {
       _approve(runtime::get_caller(), spender, amount);
   }

   fn _approve(owner: AccountHash, spender: AccountHash, amount: U256) {
       set_key(&new_key(&new_key("_allowances", owner), spender), amount);
   }

``transfer_from`` allows to spend approved amount of tokens.

.. code-block:: rust

   #[casperlabs_method]
   fn transferFrom(owner: AccountHash, recipient: AccountHash, amount: U256) {
       _transfer(owner, recipient, amount);
       _approve(
         owner,
         runtime::get_caller(),
         (get_key::<U256>(&new_key(
               &new_key("_allowances", owner),
               runtime::get_caller(),
               )) - amount),
          );
   }
