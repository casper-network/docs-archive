Contract Examples
=================

You can access our repository of contract examples [here](https://github.com/CasperLabs/CasperLabs/tree/dev/execution-engine/contracts/examples)

bonding-call
------------
[**bonding-call**](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/contracts/examples/bonding-call/src/lib.rs)

Accepts bonding amount (of type `U512`) as first argument.
Issues bonding request to the PoS contract.


[bonding-call](https://docs.rs/casperlabs-contract-ffi/0.21.0/casperlabs_contract_ffi/all.html)

>[**counter-call contract](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/contracts/examples/bonding-call/src/lib.rs)

Implementation of smart contract that increments previously deployed counter.

### Call Counter Build

Build the `wasm` file using `make` in the `execution-engine` directory.
```
$ make build-contract/counter-call
```

### Call Counter Deploy

Deploy the counter call smart contract.
```
$ casperlabs-client --host $HOST deploy \
    --private-key $PRIVATE_KEY_PATH \
    --payment-amount 10000000 \
    --session $COUNTER_CALL_WASM
```

### Call Counter Check counter's value

Query global state to check counter's value.
```
$ casperlabs-client --host $HOST query-state \
    --block-hash $BLOCK_HASH \
    --type address \
    --key $PUBLIC_KEY \
    --path "counter/count"
```

### counter call Rust Crates
[counter-call](https://docs.rs/casperlabs-contract-ffi/0.21.0/casperlabs_contract_ffi/all.html) 


counter define
--------------
> [**counter define contract example**](https://github.com/CasperLabs/CasperLabs/blob/dev/execution-engine/contracts/examples/counter-define/src/lib.rs)

create map of references for stored contract

### counter define deploy counter

Implementation of URef-based counter.

The deployement of this session code, creates new named key `counter`, that points to the deployed smart contract. The `counter` smart contract will have one named key called `count`, that points to the actual integer value, that is the counter.

The `counter` smart contract exposes two methods:
- `inc`, that increments the `count` value by one;
- `get`, that returns the value of `count`.


### counter define Build

Build the `wasm` file using `make` in the `execution-engine` directory.

`$ make build-contract/counter-define`

### counter define deploy

### deploy the counter smart contract.


**counter define deploy example**

```shell
$ casperlabs-client --host $HOST deploy \
    --private-key $PRIVATE_KEY_PATH \
    --payment-amount 10000000 \
    --session $COUNTER_DEFINE_WASM
```

### counter define check  counter's value

Query global state to check counter's value.
**conter define check counter's value example**

```shell
$ casperlabs-client --host $HOST query-state \`
    `--block-hash $BLOCK_HASH \`
    `--type address \`
    `--key $PUBLIC_KEY \`
    `--path "counter/count"`
```


[erc20-smart-contract](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/erc20-smart-contract)

[erc20-logic contract example](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/erc20-logic)
## About erc20-logic
EE internal errors will be mapped to the appropriate string message to return to Node via an `UpgradeDeployError` message.

[hello-name-call contract example](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/hello-name-call)

[hello-name-define](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/hello-name-define)

[mailing-list-call](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/mailing-list-call)

[mailing-list-define](https://github.com/CasperLabs/CasperLabs/tree/master/execution-engine/contracts/examples/mailing-list-call)

