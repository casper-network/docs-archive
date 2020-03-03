Deploying contracts
===================

How to structure your deployments
---------------------------------

<<<<<<< HEAD
You can Deploy contracts using our pre-built binaries or build from source. Both provide the casperLabs-client.  
=======
You can Deploy contracts using our pre-built binaries or build from source. Both provide the casperLabs-client.
>>>>>>> 845f1392099a60fe0027c996c20af0edaf064cd0

* [**Using binaries**](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#using-binaries-recommended) (recommended):

    Make sure you have rustup installed and the casperlabs package, which contains casperlabs-client.

* [**Building from source**](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#building-from-source)

    Make sure you have rustup installed and you can build the casperlabs-client from [source]() . If you build from source, you will need to add the build directories to your PATH.

    Or, you can run the client commands from the root directory of the repo, using explicit paths to the binaries.


Features of the deployment interface
------------------------------------

[CasperLabs Clarity](https://clarity.casperlabs.io/#/)

CasperLabs Client Deploying Contracts [CONTRACTS.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md)


How do I know my contract deployed successfully?
------------------------------------------------

### View deploys in [Clarity](https://clarity.casperlabs.io/#/deploys)
Navigate to your account in Clarity and select the deploys tab where you can se a detailed view of your deploy with a hash, timestamp, amd result.

### View deploys in CL Client

You will find a step-by-step set of instructions and examples including basic and advanced features to deploy contracts in our [CONTRACTS.md](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/CONTRACTS.md#deploying-contracts).

Prior knowledge about permissions and execution semantics is recommended and can be found in our Techspec [here](https://github.com/CasperLabs/techspec/blob/master/implementation/accounts.rst).


Deploying to DevNet
-------------------

A quick start includes a simple set of instructions for getting started on the CasperLabs devnet [here](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/docs/DEVNET.md#deploying-code).

Note: More advanced users may wish to take other approaches to some of the steps listed.





