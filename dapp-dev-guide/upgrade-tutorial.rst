.. role:: raw-html-m2r(raw)
   :format: html


Smart Contract Upgrade Tutorial
==========================

This tutorial shows you how to upgrade smart contracts.  

A great feature that smart contracts have is that,
when a bug is found in the source code we can fix  
the bug and upgrade the running smart contract.  

Using the smartcontract libraries, it's pretty simple to upgrade a contract. 
All we need to deploy a new version of our contract and overwrite our old functions with  
new functions. 



Upgrade   
------------   
In order to upgrade a smart contract we need two things:   
first we need the contract to allow itself to be upgraded.   
This is done by implementing an upgrade function to the 
smart contract. If an upgrade function is not added, then the  
contract stays immutable and we're not able to     
change or modify it further down the road.    
 

Lets start by creating a function our contract can use to upgrade itself with:

.. code-block:: rust

	#[no_mangle]
	pub extern "C" fn upgrade_me() {
	    let installer_package: ContractPackageHash = runtime::get_named_arg("installer_package");
	    let contract_package: ContractPackageHash = get_key(CONTRACT_PACKAGE);
	 
	    runtime::call_versioned_contract(installer_package, None, "install", runtime_args! {
		"contract_package" => contract_package,
	    })
	}



Then we want to add it to our entry points in our call function  


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

Now we can got a contract that has the ability to be upgraded with new features and functions:

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


So when you write your smart contract be sure to add an upgrade function and make sure you save and safeguard the   
access token you used in the first place.


External links:    
------------   
https://github.com/CasperLabs/casper-node/tree/master/smart_contracts/contracts/test/local-state-stored-upgraded   
https://github.com/CasperLabs/casper-node/tree/master/smart_contracts/contracts/test/local-state-stored-upgrader   
https://docs.rs/casperlabs-contract/0.6.1/casperlabs_contract/contract_api/storage/fn.add_contract_version.html
https://github.com/CasperLabs/casper-node/tree/master/smart_contracts   


If your looking for more documented sample code, Check out the [contract-upgrade-example](https://github.com/casper-ecosystem/contract-upgrade-example) repository.

