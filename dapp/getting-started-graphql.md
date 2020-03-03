## GraphQL

GraphQL can be accessed in the following ways:
- Our GraphQL console located
  [CasperLabs Clarity](http://devnet-graphql.casperlabs.io:40403/graphql)
- This tool can also be accessed through our [Clarity self service portal](https://clarity.casperlabs.io/#/) for you
  to interact with the blockchain.

### Using GraphQL for Querying and Debugging contracts

[Execute GraphQL Queries](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/hack/docker#execute-graphql-queries)

The node includes a GraphQL console which you can use to explore the
schema and build queries with the help of auto-completion.

To access GraphQL with Docker, first make sure the top level docker
containers and the bootstrap container are started:

`make up node-0/up`.

Once that's done you can point your browser on [Clarity](http://localhost:40403/graphql)

1. View what's exposed by clicking the DOCS and SCHEMA buttons
   on the right-hand side of the screen.

2. Run a query, start typing "query" or "subscription" into the
   left-hand pane and see what the code completion offers up.

Note: The DOCS can be kept open on the right hand side to see what's
available and closed when you finished your query.


For example:

You can use the following query to see the top 5 ranks of the DAG:


```shell

query {
  dagSlice(depth: 5) {
    blockHash
    parentHashes
    deployCount
  }
}
```

You can use the "COPY CURL" button to see what an equivalent pure
HTTP/JSON command would be.

3. Press the "play" button in the middle of the tool screen to see the query response.

For further details on our GraphQl see our [source code](https://clarity.casperlabs.io/#/) and Docker
[README.md](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/hack/docker)



#### Using GQL To learn about the network

- Devnet
  - description of the network
  - purpose, objectives, and interests of the network
  - composition
  - the network
  - summary, conclusions - relations, synthesis

See Akosh demo February 25, 2020