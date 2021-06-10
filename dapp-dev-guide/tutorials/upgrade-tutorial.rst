.. role:: raw-html-m2r(raw)
   :format: html


Smart Contract Upgrade Tutorial
===============================

This tutorial shows you how to upgrade smart contracts. Casper contracts are upgradeable, making it easy for contract authors to add features and fix bugs in smart contracts.

The process of upgrading a smart contract is simple. All you need is to deploy a new version of the contract and overwrite the old functions with new ones. 

Here are specific examples of how to implement the upgrade functionality.

Step 1. Deploy the initial contract.
-------------------------------------------------

.. code-block:: rust

    /// Original getter function that returns to the caller that this contract is "first"
    #[no_mangle]
    pub extern "C" fn get_message() {
        runtime::ret(CLValue::from_t(String::from("first")).unwrap_or_revert());
    }

    #[no_mangle]
    pub extern "C" fn call() {
        // Introduce a singular, public "get_message" entry point.
        let mut entry_points = EntryPoints::new();
        entry_points.add_entry_point(EntryPoint::new(
            "get_message",
            vec![],
            CLType::String,
            EntryPointAccess::Public,
            EntryPointType::Contract,
        ));

        // Introduce the contract itself to the account, and save it's package hash and access token
        // to the account's storage as "messenger_package_hash" and "messanger_access_token" respectively.
        let _ = storage::new_contract(
            entry_points,
            None,
            Some("messenger_package_hash".to_string()),
            Some("messanger_access_token".to_string()),
        );
    }

Step 2. Upgrade the contract.
-------------------------------------------------

.. code-block:: rust

    /// Upgraded version of the version getter fuction, returning "second" proving,
    /// that the contract has gained and upgraded version.
    #[no_mangle]
    pub extern "C" fn get_message() {
        runtime::ret(CLValue::from_t("second".to_string()).unwrap_or_revert());
    }

    #[no_mangle]
    pub extern "C" fn call() {
        // Add entrypoint that will overwrite the one in the original contract
        let mut entry_points = EntryPoints::new();
        entry_points.add_entry_point(EntryPoint::new(
            "get_message",
            vec![],
            CLType::String,
            EntryPointAccess::Public,
            EntryPointType::Contract,
        ));

        // Get the package hash of the originally deployed contract.
        let messanger_package_hash: ContractPackageHash = runtime::get_key("messenger_package_hash")
            .unwrap_or_revert()
            .into_hash()
            .unwrap()
            .into();

        // Overwrite the original contract with the new entry points. This works
        // because the original code stored the required access token into the accounts storage.
        let _ = storage::add_contract_version(messanger_package_hash, entry_points, Default::default());
    }

Step 3. Test
-------------------------------------------------

The testing scenario looks like that.

.. code-block:: rust

    #[test]
    fn test_simple_upgrade() {
        // Setup test context
        let mut upgrade_test = ContractUpgrader::setup();
        // Introduce the original contract to the test system.
        upgrade_test.deploy_contract("messanger_v1_install.wasm");
        // Check for version 1 of the contract in the system.
        upgrade_test.assert_msg("first");

        // Deploy upgrader that overwrites the original contract.
        upgrade_test.deploy_contract("messanger_v2_upgrade.wasm");
        // Check whether the contract has been changed to version 2.
        upgrade_test.assert_msg("second");
    }

External links
--------------

* `Full example <https://github.com/casper-ecosystem/contract-upgrade-example>`_
* `API details for add_contract_version <https://docs.rs/casper-contract/latest/casper_contract/contract_api/storage/fn.add_contract_version.html>`_
