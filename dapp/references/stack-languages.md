# CasperLabs Stack languages

## WebAssembly[Multiple programming languages and WebAssembly](https://casperlabs.atlassian.net/wiki/spaces/~868180632/pages/142704644/Product+Positioning+for+DApp+Developers+Smart+Contracts )

We use [WebAssembly](https://webassembly.org/) (WASM) as our Virtual Machine (VM). It enables developers to write smart contracts in all the languages that compile to the WASM bytecode.

WebAssembly will be one the dominant technology of the near feature and great tool in everyday development. 

In general it enables you to write smart contracts in one of the languages you might know, see:

- https://github.com/appcypher/awesome-wasm-langs
- https://github.com/mbasso/awesome-wasm 

WASM is Highly supported by the development community. WASM will grow with useful features and cost-effective optimizations. 

Our smart contracts are intended to run only with our EE, so the way WASM is set up -- has function imports are capabilities you take from the environment your WASM is executing in that WASM does not do natively -- 

You would import from JS so you could interact with your DOM.

There is a standard being worked on for WASM as a systems bite code language, Standard imports for READING and Writing files. So CasperLabs has a set of function imports specific to our system. Reading and writing from a contracts local state, getting block time stamp with IO style operations specific to the CasperLabs enviroment it is running in.

WASM does supports architectural things you can do to make it more flexible. 

For Example:

**Tic Tac Toe smart contract** -- compiles to native binary (e.g. or to our blockchain and compiles to WASM to run on our blockchain,.

 Precisely different Input output natively on machine reading STDN and writing to console.

Whereas if it is compiled to WASM for the CL Blockchain reading from deploy arguments writing to the contract local state-- 

So, all the core logic is the same, the 

Recognizing WASM binary Isn't portable only insofar as io isn't portable, but you can isolate core logic that is io independent from the IO, so you can specify compilation targets. 



## Scala Client
## [Python Client](https://pypi.org/project/casperlabs-client/)

## CasperLabs smart contract libraries

Writing contracts in Rust and AssemblyScript makes it easier to get started with smart contract development because you can create a CI/CD pipeline with tests to verify that your contract is working properly.

## [Rust](https://www.rust-lang.org/)Rust libraries and the  Rust building tool - Cargo.

Rust applications run on X86- simply use a different compiler to run on X86. 

## AssemblyScript
AssemblyScript [See](https://docs.assemblyscript.org/) is a form of TypeScript you can run your smart contracts on an X86 machine. If you are working in a professional development organization, this enables you to use CI/CD and verify the behavior of your code using a [testing framework](.   ).



