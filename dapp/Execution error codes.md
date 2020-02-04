

## Execution error codes - a listing and description of each error code DRAFT table

Note: ~~see if this should be included with the publishing of the Rust doc~~



See Source [Error](https://docs.rs/casperlabs-contract-ffi/0.22.0/src/casperlabs_contract_ffi/contract_api/error.rs.html#56-138) for definitions

| ub enum Error {<br/>    <br/>}      |      |
| ----------------------------------- | ---- |
| None,<br/>    MissingArgument,<br/> |      |
| InvalidArgument,<br/>               |      |
| Deserialize,<br/>                   |      |
| Read,<br/>                          |      |
| ValueNotFound,<br/>                 |      |
| ContractNotFound,<br/>              |      |
| GetKey,<br/>                        |      |
| UnexpectedKeyVariant,<br/>          |      |
| UnexpectedValueVariant,<br/>        |      |
| UnexpectedContractRefVariant,<br/>  |      |
| InvalidPurseName,<br/>              |      |
| InvalidPurse,<br/>                  |      |
| UpgradeContractAtURef,<br/>         |      |
| Transfer,<br/>                      |      |
| NoAccessRights,<br/>                |      |
| ValueConversion,<br/>               |      |
| CLTypeMismatch,<br/>                |      |
| EarlyEndOfStream,<br/>              |      |
| FormattingError,<br/>               |      |
| LeftOverBytes,<br/>                 |      |
| OutOfMemoryError,<br/>              |      |
| MaxKeysLimit,<br/>                  |      |
| DuplicateKey,<br/>                  |      |
| PermissionDenied,<br/>              |      |
| MissingKey,<br/>                    |      |
| ThresholdViolation,<br/>            |      |
| KeyManagementThresholdError,<br/>   |      |
| DeploymentThresholdError,<br/>      |      |
| PermissionDeniedError,<br/>         |      |
| InsufficientTotalWeight,<br/>       |      |
| InvalidSystemContract,<br/>         |      |
| PurseNotCreated,<br/>               |      |
| Unhandled,<br/>                     |      |
| BufferTooSmall,<br/>                |      |
| HostBufferEmpty,<br/>               |      |
| HostBufferFull,<br/>                |      |
| Mint(u8),<br/>                      |      |
| ProofOfStake(u8),<br/>              |      |
| User(u16),                          |      |
