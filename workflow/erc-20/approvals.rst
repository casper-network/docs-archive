Approvals
==========


Transfer 10 tokens from an allowance of only 5
-----------------------------------------------

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --chain-name integration-test \
    --secret-key ~/casper/ibm_demo/user_b/secret_key.pem \
    --session-hash hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180 \
    --session-entry-point "transfer_from" \
    --session-arg "owner:key='account-hash-303c0f8208220fe9a4de40e1ada1d35fdd6c678877908f01fddb2a56502d67fd'" \
    --session-arg "recipient:key='account-hash-f32a2abc55316dc85a446a1c548674e03757974aaaf86e8b7d29947ae148eeca'" \
    --session-arg "amount:u256='10'" \
    --payment-amount "10000000000" 

Since we know that the allowance value is less than 10, we expect the deploy to fail.

.. note::
    
    Here is an example of a `deploy failure due to overspending an allowance <https://integration.cspr.live/deploy/7a692917b91e1485f500966f3884bb0917006725505fec1ce3aed2a13ec692df>`__.


Additional transfer_from of the remainder 5 tokens
---------------------------------------------------

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --chain-name integration-test \
    --secret-key ~/casper/ibm_demo/user_b/secret_key.pem \
    --session-hash hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180 \
    --session-entry-point "transfer_from" \
    --session-arg "owner:key='account-hash-303c0f8208220fe9a4de40e1ada1d35fdd6c678877908f01fddb2a56502d67fd'" \
    --session-arg "recipient:key='account-hash-f32a2abc55316dc85a446a1c548674e03757974aaaf86e8b7d29947ae148eeca'" \
    --session-arg "amount:u256='5'" \
    --payment-amount "10000000000"

|
**Invoking `balance_of` for user D**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_balance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "address:key='account-hash-f32a2abc55316dc85a446a1c548674e03757974aaaf86e8b7d29947ae148eeca'" \
    --chain-name integration-test \
    --payment-amount 1000000000

.. code-block::

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash d068439dc1f62e330a15e008e5e926e777fd3599baed4ece508d482c50bd263b


.. image:: images/invokeBalanceOfuserD.png

|
**Invoking `allowance` for B’s tokens of A**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_allowance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "owner:key='account-hash-303c0f8208220fe9a4de40e1ada1d35fdd6c678877908f01fddb2a56502d67fd'" \
    --session-arg "spender:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'"


.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash e863633b47b0689033744855739009b45a8654dadd4ed723f527fd38157a1d92


.. image:: images/invokeAllowanceBsTokenforA.png
|
Approving C to spend 10 of B’s ERC-20 tokens
--------------------------------------------

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --chain-name integration-test \
    --secret-key ~/casper/ibm_demo/user_b/secret_key.pem \
    --session-hash hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180 \
    --session-entry-point "approve" \
    --session-arg "spender:key='account-hash-89422a0f291a83496e644cf02d2e3f9d6cbc5f7c877b6ba9f4ddfab8a84c2670'" \
    --session-arg "amount:u256='10'" \
    --payment-amount "10000000000"


**Invoking `allowance` to check C’s allowance**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_allowance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "owner:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'" \
    --session-arg "spender:key='account-hash-89422a0f291a83496e644cf02d2e3f9d6cbc5f7c877b6ba9f4ddfab8a84c2670'" \
    --chain-name integration-test \
    --payment-amount 10000000000


.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash e9f069c2c03b18f86c15fec54286ac66ece368ac36d9d28024d0cd6cfc93fcf5

.. image:: images/invokingToCheckCsAllowance.png

|

Transfer_from C’s allowance to D
---------------------------------

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --chain-name integration-test \
    --secret-key ~/casper/ibm_demo/user_c/secret_key.pem \
    --session-hash hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180 \
    --session-entry-point "transfer_from" \
    --session-arg "owner:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'" \
    --session-arg "recipient:key='account-hash-f32a2abc55316dc85a446a1c548674e03757974aaaf86e8b7d29947ae148eeca'" \
    --session-arg "amount:u256='5'" \
    --payment-amount "10000000000"

|
**Invoking `balance_of` for user A**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_balance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "address:key='account-hash-303c0f8208220fe9a4de40e1ada1d35fdd6c678877908f01fddb2a56502d67fd'" \
    --chain-name integration-test \
    --payment-amount 1000000000

.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash eb506808fe0749364163fea646c3f4ef35bb55363ea849da219badcd6ba3ee80

.. image:: images/invokingBalanceOfuserA.png

|

**Invoking `balance_of` for user B**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_balance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "address:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'" \
    --chain-name integration-test \
    --payment-amount 1000000000


.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash 0ce2c4991543758337a38d1d8f7fe56a42616b95ec93b17aec35a6f03b5e389c

.. image:: images/invokingBalanceOfuserB.png

|

**Invoking `balance_of` for user C**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_balance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "address:key='account-hash-89422a0f291a83496e644cf02d2e3f9d6cbc5f7c877b6ba9f4ddfab8a84c2670'" \
    --chain-name integration-test \
    --payment-amount 1000000000

.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash 215c50c0e86950cb91bd8e1045315c1129bbaa02d4e49e00bed60130c4dfa69c

.. image:: images/invokingBalanceOfuserC1.png

|

**Invoking `balance_of` for user D**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_balance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "address:key='account-hash-f32a2abc55316dc85a446a1c548674e03757974aaaf86e8b7d29947ae148eeca'" \
    --chain-name integration-test \
    --payment-amount 1000000000


.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash 4e8b0de303f834cb7c61bef148046e3de4446903bd15a395c9c37a6d96efe8c6

.. image:: images/invokingBalanceOfuserD.png

|

**Invoking `allowance` to check C’s allowance**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_allowance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "owner:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'" \
    --session-arg "spender:key='account-hash-89422a0f291a83496e644cf02d2e3f9d6cbc5f7c877b6ba9f4ddfab8a84c2670'" \
    --chain-name integration-test \
    --payment-amount 10000000000

.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash d6d4d3e59017dfc21e2c9a8e235e2a2b3a446284a066a1f1f6704559fbb35a66

.. image:: images/invokingAlToCheckCsAllowance.png

|

**Failure to overspend C's allowance**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --chain-name integration-test --secret-key ~/casper/ibm_demo/user_c/secret_key.pem \
    --session-hash hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180 \
    --session-entry-point "transfer_from" \
    --session-arg "owner:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'" \
    --session-arg "recipient:key='account-hash-f32a2abc55316dc85a446a1c548674e03757974aaaf86e8b7d29947ae148eeca'" \
    --session-arg "amount:u256='10'" \
    --payment-amount "10000000000"

.. note::
    
    Here is an example of a `failure to overspend C's allowance <https://integration.cspr.live/deploy/db50ac05fe63561669b9d73c28b66fcb5a341048d5d13b1b2759b557396fd5d2>`__.

|

**Invoking `allowance` to check C’s allowance**

.. code-block:: bash

    casper-client put-deploy -n http://3.143.158.19:7777 \
    --secret-key ~/casper/ibm_demo/user_a/secret_key.pem \
    --session-package-name "erc20_test_call" \
    --session-entry-point "check_allowance_of" \
    --session-arg "token_contract:account_hash='account-hash-b568f50a64acc8bbe43462ffe243849a88111060b228dacb8f08d42e26985180'" \
    --session-arg "owner:key='account-hash-9f81014b9c7406c531ebf0477132283f4eb59143d7903a2fae54358b26cea44b'" \
    --session-arg "spender:key='account-hash-89422a0f291a83496e644cf02d2e3f9d6cbc5f7c877b6ba9f4ddfab8a84c2670'" \
    --chain-name integration-test \
    --payment-amount 10000000000

.. code-block:: bash

    casper-client query-state -n http://3.143.158.19:7777 \
    --key uref-56efe683287668bab985d472b877b018ad24a960aafadb48ebc5217737b45c85-007 \
    --state-root-hash be29754920f158f093c1daac780fba37bed06c751f256a43fcdc7b5b2775e487

.. image:: images/invokingToCheckCsAllowance3.png

|