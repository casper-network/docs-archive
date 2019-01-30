# gRPC Interfaces

## Common Types

{% code-tabs %}
{% code-tabs-item title="common.proto" %}
```javascript
syntax = "proto3";

message Node {
    bytes id = 1;
    string host = 2;
    uint32 protocol_port = 3;
    uint32 discovery_port = 4;
}

// Generic message for transferring a stream of data that wouldn't fit into single gRPC messages.
message Chunk {
    // Alternating between a header and subsequent chunks of data.
    oneof content {
        Header header = 1
        bytes data = 2;
    }

    Header {
        // Use the content_length to sanity check the size of the data in the chunks that follow.
        uint32 content_length = 1;
        // Indicate if compression was used on the data. e.g. lz4
        string compression_algorithm = 2;
    }
}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## Consensus Types

{% code-tabs %}
{% code-tabs-item title="consensus.proto" %}
```javascript
syntax = "proto3";

message Signature {
    // One of the supported algorithms: ed25519, secp256k1
    string sig_algorithm = 1; 
    bytes sig = 2; 
}

message Deploy {
    int64 timestamp = 1;
    bytes session_code = 2;
    bytes payment_code = 3;
    uint64 gas_price = 4;
    uint64 nonce = 5;
    // Signature over hash(timestamp, hash(session_code), hash(payment_code), nonce, gas_price) where hash is blake2b256.
    Signature signature = 6; 
    bytes account_public_key = 7; 
}

message BlockSummary {
    // Hash of the header.
    bytes block_hash = 1;
    Block.Header header = 2;
    // Signature over block_hash.
    Signature signature = 3;
}

message Block {
    bytes block_hash = 1;
    Header header = 2;
    Body body = 3;
    Signature signature = 4;

    message Header {
        repeated bytes parent_hashes = 1;
        repeated Justification justifications = 2;
        GlobalState state = 3;
        bytes deploys_hash = 4;
        int64 timestamp = 5;
        uint64 version = 6;
        uint32 deploy_count = 7;
        string shard_id = 8;
        uint32 validator_block_seq_num = 9;
        bytes validator_public_key = 10;
    }

    message Body {
        GlobalState state = 1;
        repeated ProcessedDeploy deploys = 2;
    }

    message Justification {
        bytes validator_public_key = 1;
        bytes latest_block_hash = 2;
    }

    message ProcessedDeploy {
        Deploy deploy = 1;
        double cost = 2;
        bool is_error = 3;
        string error_message = 4;
    }

    message GlobalState {
        // May not correspond to a particular block if there are multiple parents.
        bytes pre_state_hash = 1;
        bytes post_state_hash = 2;
        // Included in header so lightweight nodes can follow the consensus.
        repeated Bond bonds = 3;
    }
}

message Bond {
    bytes validator_public_key = 1;
    int64 stake = 2;
}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## Kademlia API

{% code-tabs %}
{% code-tabs-item title="kademlia.proto" %}
```javascript
syntax = "proto3";

import "common.proto";

service KademliaService {
    rpc Ping(PingRequest) returns (PingResponse) {}
    rpc Lookup(LookupRequest) returns (LookupResponse) {}
}

message PingRequest {
    Node sender = 1;
}

message PingResponse {}

message LookupRequest {
    bytes  id = 1;
    Node sender = 2;
}

message LookupResponse {
    repeated Node nodes = 1;
}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## Deployment API

{% code-tabs %}
{% code-tabs-item title="deployment.proto" %}
```javascript
syntax = "proto3";

import "common.proto";
import "consensus.proto";

service DeployService {
    rpc Deploy(DeployRequest) returns (DeployResponse) {}
}

message DeployRequest {
    Deploy deploy = 1;
}

message DeployResponse {}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## Gossiping API

{% code-tabs %}
{% code-tabs-item title="gossiping.proto" %}
```javascript
syntax = "proto3";

import "common.proto";
import "consensus.proto";

service GossipService {
    rpc NewBlocks(NewBlocksRequest) returns (NewBlocksResponse);
    rpc StreamAncestorBlockSummaries(StreamAncestorBlockSummariesRequest) returns (stream BlockSummary);
    rpc StreamDagTipBlockSummaries(StreamDagTipSummariesRequest) returns (stream BlockSummary);
    rpc BatchGetBlockSummaries(BatchGetBlockSummariesRequest) returns (BatchGetBlockSummariesResponse);
    rpc GetBlockChunked(GetBlockChunkedRequest) returns (stream Chunk);
}

message NewBlocksRequest {
    Node sender = 1;
    repeated bytes block_hashes = 2;
}

message NewBlocksResponse {
    bool is_new = 1;
}

message BatchGetBlockSummariesRequest {
    repeatead bytes block_hashes = 1;
}

message BatchGetBlockSummariesResponse {
    repeated block_summaries = 1;
}

message StreamAncestorBlockSummariesRequest {
    repeated bytes target_block_hashes = 1;
    repeated bytes known_block_hashes = 2;
    uint32 max_depth = 3;
}

message StreamDagTipBlockSummariesRequest {
}

message GetBlockChunkedRequest {
    bytes block_hashe = 1;
    uint32 chunk_size = 2;
    repeated string accepted_compression_algorithms = 3;
}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

