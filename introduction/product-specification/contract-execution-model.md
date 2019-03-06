# Contract Execution Model

In the CasperLabs system all contract execution occurs on a virtual machine implementing the WebAssembly instruction set ("Wasm"). This has the following benefits:
* Guarantees consistent contract execution results and cost when contracts are executed on different nodes which may differ in version, operating system, and CPU instruction set. Note that the Wasm code emitted by different compilers may result in different gas cost for the same source code.
* Enables low-overhead interaction between contracts written in different languages
Wasm is becoming an industry standard instruction set: It is supported by all major browsers and has a large and growing ecosystem of compilers for various languages, virtual machine implementations, and tool support.

The Wasm spec requires that source compiled to Wasm be packaged as a Wasm "module" which can be directly submitted to a VM for execution. All contracts in the CasperLabs system are stored as Wasm modules – the corresponding source code is not stored and not seen by the system. The functions in the system library are accessed via the Foreign Function Interface of the VM. Compiling contract source to a Wasm module must be handled outside the decentralized computer.

The details of the Wasm instruction set and module format are beyond the scope of this document – more information can be found at webassembly.org.

Being an active component of the decentralized computer requires operators to run nodes that execute contracts and maintain persistent state, which in turn requires operators to incur capital and operating expenses. Therefore the CasperLabs system is designed to compensate operators for performing these functions. Each instruction in the Wasm instruction set, and each function in the system library, is assigned a fixed cost denominated in units of "gas". Gas is a measure of the relative amount of compute and storage resources expended by the decentralized computer to perform some operation. The gas cost of executing a contract is the sum of the cost of all dynamic Wasm instructions executed plus the sum of the cost of all dynamic system function calls. A market mechanism will be used to dynamically map of a unit of gas to one or more currencies.

dApp components initiate execution of a contract by sending a "deploy" message to a node. A simplified view of the lifecycle of a deploy is depicted in Figure 3. The contract whose execution is being requested is called the "session contract" and is packaged in a session module in the deploy message. The deploy message also contains an account identifier and a payment module in which a payment contract is packaged. The purpose of the payment contract is to produce the funds necessary to pay for the execution of all contracts activated by this deploy including the cost of the payment contract itself.

When a deploy is ready for execution, the payment contract is executed first. At some point during execution payment contracts are required to call a special "Proof of Stake (POS) contract" to perform the actual payment transaction. The POS contract will be discussed in more detail below. At the time the payment contract completes, if node software has not detected the activation of the POS contract, any state changes made by the payment contract are undone and the deploy is terminated. Payment contracts have access to the persistent variables of the account specified in the deploy message. Typically the execution cost of a deploy is paid from the purse of this account but this need not be the case – payment contracts may contain arbitrary logic for producing the needed funds.

![Figure 4: KV Store API](wpFig4simpleDeploy.png)

Executing contracts incurs a cost and this applies to the payment contract as well. At the start of deploy execution, node software supplies a "loan" to subsidize payment contract execution. The size of this loan is a system parameter. The system maintains the running total cost of executing the payment contract and if this cost exceeds the amount of the loan, its execution is halted, any state changes are undone, and the deploy is terminated. The cost of executing the payment contract is deducted from the amount the payment contract passes to the POS contract and any remaining funds are used to pay for executing the session contract.

Payment contracts may perform the same actions as any other contract (e.g. call other contracts, create new contracts, etc.) however, in order to limit abuse, the loan amount is limited so it is advisable that payment contracts do the minimum required to transfer funds to the POS contract.

After the payment contract completes (having called the POS contract), the session contract is executed. This contract may call zero or more contracts currently in persistent storage, create new contracts (which are stored in persistent storage and can be immediately executed), and access account persistent variables. The system maintains the running total cost of executing the session contract and if this cost exceeds remaining funds, its execution is halted, any state changes are undone, and the deploy is terminated.

Deploy execution ends when the session contract returns.

Deploys have serial execution semantics. The payment and session contracts are executed serially in that order and there is a single locus of control within both the payment and session contracts themselves.

Having separate payment and session contracts allows payment logic to be decoupled from dApp logic. The market may coalesce on certain common payment contracts and having them separate allows re-use across multiple dApps.

The deploy message also has a signature field covering the entire message to detect errors or tampering during transmission. generated using private key of account owner and hash of message; also used for authentication

The payment and session contracts have the following unique characteristics:
* They cannot be passed arguments
* They are transient, i.e. they only exist in the deploy message and are not stored in persistent storage
* They have direct access to the persistent variables of the account specified in the deploy message, including the ability to create new account persistent variables and the ability to pass these variables to any contract they call.

Unlike accounts, contracts are not identified by a public key but with a value returned from (hash of) derived from the account identifier (public key) in the deploy containing the contract that created the new contract, (account nonce in that deploy), and a counter of the number of new contracts created so far during the execution of the deploy. this hash is what’s returned by store_function()
