---
description: >-
  Protobuf definitions of gRPC services the nodes have to implement to
  participate in the protocol.
---

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

message PingResponse {
}

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

