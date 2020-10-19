# Querying

The Casper node supports queries for users and developers to gain insights about transactions sent to the network. When sending a query it is important to note that the request will be routed to a single node in the network.  

This document will outline the query features of the rust `casper-client`


## Installing the client

The client is available as a rust crate.

```bash
cargo install casper-client
```

## Help

To see the list of commands available ask for `help`

```bash
casper-client --help
```

To see a list of options for a given command, append `--help` 
For example:

```bash
casper-client query-state --help
```

## Query Commands Available

There are several types of data that can be requested from a node. 

* Balance info.
* Block info.
* Deploy info.
* Contract info / Global state info





      __typename
      ... on Account {
        pubKey
        associatedKeys {
          pubKey
          weight
        }
        actionThreshold {
          deploymentThreshold
          keyManagementThreshold
        }
      }
    }
  }
}
```


Using the "COPY CURL" button will return the equivalent pure HTTP/JSON command.

* Press the "play" button in the middle of the tool screen to see the query response.

For further details on GraphQL check out [source code](https://clarity.casperlabs.io/#/).


