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
  bytes host = 2;
  uint32 protocol_port = 3;
  uint32 discovery_port = 4;
}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## Discovery API

{% code-tabs %}
{% code-tabs-item title="discovery.proto" %}
```javascript
syntax = "proto3";

import "common.proto";

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

service DiscoveryService {
  rpc Ping (PingRequest) returns (PingResponse) {}
  rpc Lookup (LookupRequest) returns (LookupResponse) {}
}

```
{% endcode-tabs-item %}
{% endcode-tabs %}

