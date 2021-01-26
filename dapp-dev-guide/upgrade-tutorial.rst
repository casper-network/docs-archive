.. role:: raw-html-m2r(raw)
   :format: html


Smart Contract Upgrade Tutorial
==========================

This tutorial shows you how to upgrade smart contracts.  

Casper contracts are upgradeable, making it easy for contract authors for add features and fix bugs in smart contracts.

The process of upgrading a smart contract is simple. All that needs to be done is to deploy a new version of the contract and overwrite the old functions with new ones.




Upgrade   
------------   

Upgrading smart contracts require 2 pieces:

1. An upgrade function needs to be present in the contract when the contract is *first deployed*. Without this, the contract is immutable, and cannot be changed in the future.
 

Let's start by creating a function our contract can use to upgrade itself with:

.. code-block:: rust

	#[no_mangle]
	pub extern "C" fn upgrade_me() {
	    let installer_package: ContractPackageHash = runtime::get_named_arg("installer_package");
	    let contract_package: ContractPackageHash = get_key(CONTRACT_PACKAGE);
	 
	    runtime::call_versioned_contract(installer_package, None, "install", runtime_args! {
		"contract_package" => contract_package,
	    })
	}


2, An entry point in the call function to the upgrade function. This enables the upgrade function to be invoked in the future.



.. code-block:: rust

	#[no_mangle]
	pub extern "C" fn call() {
	    let (contract_package, access_token) = storage::create_contract_package_at_hash();

	    let entry_points = {
		let mut entry_points = EntryPoints::new();
		let upgradefunction = EntryPoint::new(
		    "upgrade_me",
		    vec![],
		    CLType::Unit,
		    EntryPointAccess::Public,
		    EntryPointType::Contract,
		);
		entry_points.add_entry_point(upgradefunction);
	...
	    let mut named_keys = NamedKeys::new();
	    named_keys.insert(ACCESS_TOKEN.to_string(), access_token.into());
	    named_keys.insert(CONTRACT_PACKAGE.to_string(), storage::new_uref(contract_package).into());
	    let (new_contract_hash, _) = storage::add_contract_version(contract_package, entry_points, named_keys);

	    runtime::put_key(CONTRACT_NAME, new_contract_hash.into());
	    set_key(CONTRACT_PACKAGE, contract_package); // stores contract package hash under account's named key
	    set_key(CONTRACT_HASH, new_contract_hash);
	}


Now this contract can be upgraded with new features and functions:


.. code-block:: rust
	// Using the package hash and our access token, we're able to    
	// upgrade our contract with new features and a new functions   

	    let contract_package: ContractPackageHash = runtime::get_named_arg(ARG_CONTRACT_PACKAGE); // we need to get package hash of our first contract
	    let _access_token: URef = runtime::get_named_arg("accesstoken"); // our secret access token, we have defined in our first version

	    let entry_points = {
		let mut entry_points = EntryPoints::new();
		let gettext = EntryPoint::new(
		    METHOD_SET_TEXT,
		    vec![],
		    CLType::Unit,
		    EntryPointAccess::Public,
		    EntryPointType::Contract,
		);
		entry_points.add_entry_point(gettext);
		entry_points
	    };

	    // lets deploy the new version of our contract and replace the old functions with new once.   
	    let (_, _) = storage::add_contract_version(contract_package.into(), entry_points, Default::deault());   



The *storage::add_contract_version* function. This function will allow us to deploy a new version of our contract.  


Read more here: 
https://docs.rs/casperlabs-contract/0.6.1/casperlabs_contract/contract_api/storage/fn.add_contract_version.html


It is important to include the upgrade function and safeguard the access token from the first deployment of the contract. The access token will be needed for future upgrades.

External links:    
------------   
https://github.com/CasperLabs/casper-node/tree/master/smart_contracts/contracts/test/local-state-stored-upgraded   
https://github.com/CasperLabs/casper-node/tree/master/smart_contracts/contracts/test/local-state-stored-upgrader   
https://docs.rs/casperlabs-contract/0.6.1/casperlabs_contract/contract_api/storage/fn.add_contract_version.html
https://github.com/CasperLabs/casper-node/tree/master/smart_contracts   


For more documented sample code, Check out the [contract-upgrade-example](https://github.com/casper-ecosystem/contract-upgrade-example) repository.

