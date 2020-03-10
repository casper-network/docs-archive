# GraphQL

The CasperLabs node software includes a GraphQL console which you can use to explore the schema and build queries with the help of auto-completion. A GraphQL query looks at the blockchain on a single node. It is important to know which network you are querying when using a GraphQL interface.

To query the blockchain on DevNet, navigate to: [CasperLabs Clarity](http://devnet-graphql.casperlabs.io:40403/graphql).


## Using GraphQL for Querying and Debugging Contracts

* View what graphs are available by clicking the DOCS and SCHEMA buttons on the right-hand side of the screen.

* Run a query, start typing "query" or "subscription" into the
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

* Press the "play" button in the middle of the tool screen to see the query response.

For further details on our GraphQL see our [source code](https://clarity.casperlabs.io/#/).


