# Breaking Changes

### Definition

A breaking change is a change that will cause a hard fork to take place if all the validators do not accept the change. These kinds of changes will be subject to more governance rigor, and updates including any of these items will need to take effect at some fixed point in 'time'. How this will work on the CL Chain is still tbd, a design is still needed.

The following are considered breaking changes:

* Any change to the core protocol is a breaking change.
* Changes to message format when data is removed from the message schema.
* Changes to Wasm that adversely impacts the execution of smart contracts.
* Changes to accounting / costs for contract execution.

