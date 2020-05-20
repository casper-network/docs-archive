## Running a Validator Node

Pre-packaged binaries are published to [http://repo.casperlabs.io/casperlabs/repo](http://repo.casperlabs.io/casperlabs/repo). The following are an example of installing the node on Ubuntu.

### Prerequisites

* [OpenJDK](https://openjdk.java.net) Java Development Kit (JDK) or Runtime Environment (JRE), version 11. We recommend using the OpenJDK

```none
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt update
sudo apt install openjdk-11-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

Check that you have the right Java version:

```none
sudo update-alternatives --config java
```

You see the next output, we choose the `0th` selection here:
```none
There are 3 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                            Priority   Status
------------------------------------------------------------
  0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      auto mode
  1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      manual mode
  2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode
* 3            /usr/lib/jvm/java-8-oracle/jre/bin/java          1081      manual mode

Press <enter> to keep the current choice[*], or type selection number: 0
update-alternatives: using /usr/lib/jvm/java-11-openjdk-amd64/bin/java to provide /usr/bin/java (java) in auto mode
```

Print the Java version:
```none
java -version
```

The output should say we use the version 11:
```none
openjdk version "11.0.1" 2018-10-16
OpenJDK Runtime Environment (build 11.0.1+13-Ubuntu-3ubuntu116.04ppa1)
OpenJDK 64-Bit Server VM (build 11.0.1+13-Ubuntu-3ubuntu116.04ppa1, mixed mode, sharing)
```


### Installing from Debian packages

The node consists of an API component running in Java and an execution engine running the WASM code of the deploys. They have to be started separately at the moment and configured to talk to each other.

*NOTE: Users will need to update \[VERSION\] with the version the want. See:

```none
curl -sO http://repo.casperlabs.io/casperlabs/repo/master/casperlabs-node_[VERSION]_all.deb
curl -sO http://repo.casperlabs.io/casperlabs/repo/master/casperlabs-engine-grpc-server_[VERSION]_amd64.deb
sudo dpkg -i casperlabs-node_[VERSION]_all.deb
sudo dpkg -i casperlabs-engine-grpc-server_[VERSION]_amd64.deb
```

After these steps you should be able to run `casperlabs-node --help` and `casperlabs-engine-grpc-server --help`.


### Starting the execution engine

The execution engine runs as a separate process and isn't open to the network, it communicates with the node through a UNIX file socket. If you're using Windows it will have to run under Windows Subsystem for Linux (WSL).

The node will want to connect to this socket, so it's best to start the engine up front.

```none
mkdir casperlabs-node-data
casperlabs-engine-grpc-server casperlabs-node-data/.caspernode.sock
```

The next output should be printed:
```none
Server is listening on socket: casperlabs-node-data/.caspernode.sock
```

#### `--loglevel`

The execution engine supports an optional `--loglevel` command line argument following the mandatory socket argument,
which sets the log level for the execution engine.

```none
casperlabs-engine-grpc-server casperlabs-node-data/.caspernode.sock --loglevel=error
```

The log levels supported are:

```none
    --loglevel=
    fatal : critical problems that result in the execution engine crashing
    error : recoverable errors
    warning : unsuccessful but not erroneous activity
    info : normal, expected activity
    metric : execution durations, counts, and similar data points (verbose)
    debug : developer messages
```

The execution engine will log messages at the configured log level or above (thus, `error` will log errors and fatals but not warnings and below) to stdout.

If the `--loglevel` argument is not provided, the execution engine defaults to the `info` log level.

### Configuring networking

With the keys at hand you can start the node again, but this time configure it to be reachable on the network. [UPnP](https://casperlabs.atlassian.net/wiki/spaces/EN/pages/38928385/Node+Supported+Network+Configuration?atlOrigin=eyJpIjoiOTNmZjI2ZDllYmMxNGM1NmIwMzVjNmRlNTAyNzU2M2QiLCJwIjoiYyJ9) might be able to discover your public IP and open firewall rules in your router, or you may have to do it manually.

If you do it manually, you need to find out your externally visible IP address. You'll have to set this using the `--server-host <ip>` option so the node advertises itself at the right address.

The node will listen on multiple ports; the following are the default values, you don't need to specify them, but they're shown with the command line option you can use to override:
* `--server-port 40400`: Intra node communication port for consensus.
* `--grpc-port-external 40401`: Port to accept deploys on.
* `--grpc-port-internal 40402`: Port reserved for operator, to propose blocks for example.
* `--server-http-port 40403`: Port to use for HTTP services such as metrics and GraphQL.
* `--server-kademila-port 40404`: Intra node communication port for node discovery.

Further options include:
* `--grpc-use-tls`: Use TLS encryption on the API endpoints used for sending deploys and proposing blocks.

When the `--grpc-use-tls` option is turned on, the `casperlabs-client` needs the `--node-id` option set to the value of the Keccak256 hash of the public key of the node. This is the same value as `NODE_ID`, so as a validator this information can be given to other nodes as well as dApp developers.

An alternative way to obtain it is to use `openssl` to retrieve it from a remote host. The following script would pull the certificate from the local server and save it to a file:

```none
openssl s_client -showcerts -connect localhost:40401 </dev/null 2>/dev/null \
  | openssl x509 -outform PEM \
  > node.crt
```

### Configure auto-proposal

It is possible to call the `propose` command to manually trigger block creation but this is best reserved for demonstrational purposes. The recommended way to run a node at the moment is to turn on the simple auto-proposal feature that will try to create a block if a certain number of deploys have accumulated or the oldest has been sitting in the buffer for longer than a threshold:
* `--casper-auto-propose-enabled`
* `--casper-auto-propose-max-interval 5seconds`
* `--casper-auto-propose-max-count 10`


### Starting the node

We'll have use the same socket to start the node as the one we used with the execution engine.

You can start the node in two modes:
* `-s` puts it in standalone mode, which means it will generate a genesis block on its own
* Without `-s` you have to use the `--server-bootstrap` option and give it the address of another node to get the blocks from and to start discovering other nodes with. The address is in the form of `casperlabs://<bootstrap-node-id>@$<bootstrap-node-ip-address>?protocol=40400&discovery=40404`, but the ports can be different, based on what the operator of the node configured.

```none
casperlabs-node \
     --grpc-port 40401 \
     run \
     --server-data-dir casperlabs-node-data \
     --server-port 40400 \
     --server-kademlia-port 40404 \
     --server-bootstrap "<bootstrap-node-address>" \
     --server-host <external-ip-address> \
     --server-no-upnp \
     --tls-certificate node.certificate.pem \
     --tls-key secp256r1-private-pkcs8.pem \
     --casper-validator-private-key-path ed25519-private.pem \
     --casper-validator-public-key-path ed25519-public.pem \
     --grpc-socket casperlabs-node-data/.caspernode.sock \
     --casper-auto-propose-enabled
```


### Monitoring

You can add the `--metrics-prometheus` option in which case the node will collect metrics and make them available at `http://localhost:40403/metrics`. You can override that port with the `--server-http-port` option.

To see how an example of how to configure Prometheus and Grafana you can check out the [docker setup](docker/README.md#monitoring) or the [Prometheus docs](https://prometheus.io/docs/prometheus/latest/getting_started/).
