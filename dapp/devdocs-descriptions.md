<<<<<<< HEAD
## Dev Docs Descriptions 
=======
## Dev Docs Descriptions
>>>>>>> 845f1392099a60fe0027c996c20af0edaf064cd0

| Document                | Description                                                  | Location                                                     |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| BUILD.md                | Instructions to Build the node<br />- client<br />- execution engine <br />server<br /><br />Mint and POS Contracts<br /> | CasperLabs/docs                                              |
| CONTRACTS.md            | Instructions to deploying contracts<br />- Example contracts<br />- Create Clarity Account<br />- Add Coins to account using faucet<br />- Deploy <br />- Observe   <!--QUERYING--> | CasperLabs/docs                                              |
| DEVNET.md               | Quick Start for creating and using an account <br />- create an account<br />-check the balance of an account (install the CL client<br />- Deploy code<br /><br />- Bond a node connecting the CL network so that you can use the CL client with a local node and deploy code, propose blocks on devnet<br />Unbonding for stopping a bonded validator | CasperLabs/docs                                              |
| DIAGRAMS.md             | Deploys life cycle                                           | CasperLabs/docs                                              |
| INSTALL.md              | check public repositories with prebuilt binaries<br />Download and Install from debian and rpm repository | CasperLabs/docs                                              |
| KEYS.md                 | key sets for different functions<br />generate Node and Validator keys<br />Use Docker to generate keys<br />Use OpeemSSL and eccak-256sum to <br />Generate Account Keys<br />for dApp devs using Docker/OpenSSL<br /> | CasperLabs/docs                                              |
| NODE.md                 | Running the CasperLabs Node<br />Build <br />From binaries<br />From source<br />Running a validator on the CasperLabs Network<br />Running a single Node in standalone mode for testing<br />[Running a Simulated Network](CasperLabs/hack/docker/README.md) | CasperLabs/docs                                              |
| QUERYING.md             | Querying the CasperLabs Platform<br />- gRPC<br />- Scala client<br />- State Query API<br /><br />Visualizing the DAG state (and details of a block)<br />- Python CL client library<br />- Python CLI<br />- GraphQL API | CasperLabs/docs                                              |
| Deploys_processing.png  |                                                              | CasperLabs/docs                                              |
| Node network simulation | <br />The idea is to create many nodes with commands<br />- Build docker images<br />- Build contract-examples<br />- Requirements<br />docker-compose, openssl, SHA3SUM<br />- Set up a network<br />- Cleanup the network<br />- Signing Deploys<br />- Deploy WASM (TLS)<br />- Monitoring<br />- metrics<br />-Visualizing the DAG<br />- Execute GraphQL Queries<br />- Network Effects<br />- Shutting down the network<br />- Long Runnint Tests (LRT) | [CasperLabs](https://github.com/CasperLabs/CasperLabs)/[hack](https://github.com/CasperLabs/CasperLabs/tree/dev/hack)/[docker](https://github.com/CasperLabs/CasperLabs/tree/dev/hack/docker)/**README.md** |
| USAGE                   | This (work in progress) document provides a detailed description of the APIs and libraries needed to write smart contracts in Rust and run them on a CasperLabs node. | [CasperLabs](https://github.com/CasperLabs/CasperLabs)/[hack](https://github.com/CasperLabs/CasperLabs/tree/dev/hack)/**USAGE.md** |
| CasperLabs/hack         |                                                              | [CasperLabs](https://github.com/CasperLabs/CasperLabs)/[hack](https://github.com/CasperLabs/CasperLabs/tree/dev/hack)/**docker**/ |

