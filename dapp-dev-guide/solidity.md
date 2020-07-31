# Caspiler - Solidity to Rust Transpiler

## tl;dr 
**Transpile Solidity to Rust and access the cool features of Casper!**

## Smart Contracts at CasperLabs
The CasperLabs Virtual Machine requires Smart Contract to compile to WebAssembly.
So far we support two ecosystems that allow doing that: Rust and AssemblyScript.
As the AssemblyScript itself is still under heavy development, we focus mainly on the Rust toolchain. We have shipped many Rust tools, that make rapid Smart Contracts development possible. Yet, we are not seing CasperLabs as a competitor to other ecosystems, but rather complimentary project to the larger blockchain family. None of that would be possible without all of the lessons learned by the Ethereum community.

## Solidity
Without any doubts, the existence and simplicity of Solidity were one of the key factors behind the growth of the Ethereum. It resulted in the large group of Solidity developers for whom it's still the best tool for expressing their Smart Contract ideas. At CasperLabs we feel a strong connection with that (our) community and we came up with the value proposition: Solidity to Rust transpiler.

## Transpiler
Transpiling is a well known process of turning code written in one high-level language into another high-level language. At the moment the most popular example is the TypeScript to JavaScript transpiler. 

We have concluded that Solidity support is much easier and efficient to achieve by transpiling Solidity to Rust, that by compiling Solidity to WASM bytecode. This is why:
* Solidity features are easy to express in Rust, that is much richer language.
* The shape of CasperLabs DSL is similar to Solidity.
* The CasperLabs Rust toolchain is something we want to leverage, rather than coding it from scratch.
* The CasperLabs execution model is different than Ethereum's, therefore it's easier to translate it on the language level, that on the bytecode level.

## Solidity to Rust Migration
Having transpiler gives Smart Contract developers a powerful tool for the migration of the existing Solidity source code to Rust if they wish to use it.

## Simple Example
Let's see how the Solidity code is being transpiled to the CasperLabs Rust DSL.
There is almost one to one translation of the core components: `contract`, `constructor` and `method`. 

### Solidity
```Solidity
contract Storage {
     string value;

     constructor(string initValue) {
         value = initValue;
     }

     function getValue() public view returns (string) {
         return value;
     }

     function setValue(string newValue) public {
         value = newValue;
     }
}
```

### CasperLabs Rust DSL
```Rust
#[casperlabs_contract]
mod Storage {

    #[casperlabs_constructor]
    fn constructor(initValue: String) {
        let value: String = initValue;
        set_key("value", value);
    }

    #[casperlabs_method]
    fn getValue() {
        ret(get_key::<String>("value"));
    }

    #[casperlabs_method]
    fn setValue(newValue: String) {
        let value: String = newValue;
        set_key("value", value);
    }
}
```

## ERC20
It is possible to transpile a complex Smart Contracts like ERC20 Token.
Full example with tests can be found in this [GitHub repository](https://github.com/casper-ecosystem/erc20-solidity).

### Deploying to Testnet.
TODO
