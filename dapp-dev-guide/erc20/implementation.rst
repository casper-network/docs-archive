This tutorial reviews an implementation of the ERC20 standard for Casper.

ERC-20 Standard
---------------

The ERC-20 standard is defined in `an Ethereum Improvement Proposal (EIP) <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#>`_. Read it carefully, as it defines the methods we have implemented:


* balance_of
* transfer
* total_supply
* approve
* allowance
* transfer_from
* mint

Clone the Example Contract
---------------------------------

The example ERC20 is located in `GitHub <https://github.com/CasperLabs/erc20>`_.


Required Crates
---------------

This is a rust contract. In rust, the keyword ``use`` is like an ``include`` statement in C/C++. Casper contracts require a few crates (libaries) to be included.
They are:

* casperlabs_contract_macros: The Casper DSL that includes the boilerplate code needed for every contract
* contract: The Casper contract API for runtime and storage
* types: Thhe Casper contract type system

.. code-block:: rust

use alloc::{
    collections::{BTreeMap, BTreeSet},
    string::String,
};
use core::convert::TryInto;

use casperlabs_contract_macro::{casperlabs_constructor, casperlabs_contract, casperlabs_method};
use contract::{
    contract_api::{runtime, storage},
    unwrap_or_revert::UnwrapOrRevert,
};
use types::{
    account::AccountHash,
    bytesrepr::{FromBytes, ToBytes},
    contracts::{EntryPoint, EntryPointAccess, EntryPointType, EntryPoints},
    runtime_args, CLType, CLTyped, CLValue, Group, Parameter, RuntimeArgs, URef, U256,
};


Contract Initialization
-----------------------

When the contract is deployed it must be initialized with some values, this is done with the help of the ``casperlabs_contract`` and ``casperlabs_constructor`` macros. The contract is initialized with a name, symbol, decimals, starting balances and the starting token supply.

.. code-block:: rust

#[casperlabs_contract]
mod ERC20 {

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
 

We then also add a few helper functions to set, and retrieve values from the contract. The ``[casperlabs_method]`` macro facilitates this. Notice that each of these helper functions reference each of the ``set_key`` definitions in the constructor, and a generic ``get_key`` function to retrieve values is used.

.. code-block:: rust

  #[casperlabs_method]
    fn name() -> String {
        get_key("_name")
    }

    #[casperlabs_method]
    fn symbol() -> String {
        get_key("_symbol")
    }

    #[casperlabs_method]
    fn decimals() -> u8 {
        get_key("_decimals")
    }


Total Supply, Balance and Allowance
-----------------------------------

Here are some of the ERC-20 methods. Below is the implementation of ``balance_of``\ , ``total_supply`` and ``allowance``. The allowance method enables owners to 
specify an amount that can be spent by a spender account.

.. code-block:: rust

  #[casperlabs_method]
   fn totalSupply() {
       ret(get_key::<U256>("_totalSupply"));
   }  
  
  #[casperlabs_method]
    fn balance_of(account: AccountHash) -> U256 {
        get_key(&balance_key(&account))
    }
  
  
   #[casperlabs_method]
   fn allowance(owner: AccountHash, spender: AccountHash) -> U256 {
       let key = format!("_allowances_{}_{}", owner, spender);
       get_key::<U256>(&key)
   }
   

Transfer
--------

Here is the ``transfer`` method, which makes it possible to transfer tokens from ``sender`` address to ``recipient`` address. If the ``sender`` address has enough balance then tokens should be transferred to the ``recipient`` address.  The ``casperlabs_method`` macro creates an entry point for the method, which calls the
``_transfer`` method.

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
Here are the functions ``approve`` and ``transfer_from``. ``approve`` is used to allow another address to spend tokens on my behalf.
This is used when multiple keys are authorized to perform deployments from an account.

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
   
Put and Get Functions
---------------------
These functions are generic Casper storage write and read methods. Implement these one time for the contract and then call them as needed.

.. code-block:: rust

fn get_key<T: FromBytes + CLTyped + Default>(name: &str) -> T {
    match runtime::get_key(name) {
        None => Default::default(),
        Some(value) => {
            let key = value.try_into().unwrap_or_revert();
            storage::read(key).unwrap_or_revert().unwrap_or_revert()
        }
    }
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
   

Formatting Helper functions
---------------------------
These functions format the balances and account information from the internal representation into strings.

.. code-block:: rust

fn balance_key(account: &AccountHash) -> String {
    format!("_balances_{}", account)
}

fn allowance_key(owner: &AccountHash, sender: &AccountHash) -> String {
    format!("_allowances_{}_{}", owner, sender)
}
