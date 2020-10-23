# Calling Contracts

The most efficient way to use blockchain is to store (install) your contract on the system and then call it.  This section outlines the steps to do this.

## Installing a Smart Contract

The Contracts DSL provides all the necessary boilerplate code that is needed to install a contract.

The `#[casperlabs_contract]` macro sets up the contract name so it can be called using the name in subsequent deploys.

## Calling a Contract by Name

To call a contract by its' name use the `session-name` option

```bash
casper-client put-deploy --session-name <NAME>
```

## Calling a Contract by Hash

After deploying a contract and querying global state, a contract's hash can be used to call it in a new deploy.  Reference the querying section

```bash
casper-client put-deploy  --session-hash <HEX STRING>
```

## Using Entry Points

When using the Contracts DSL it is possible to create entry points in the contract, and then invoke specific functions in the contract via the entry point.
The `#[casperlabs_method]` macro sets up the entry point name.  

