# Release Criteria and Testing

## Release Criteria

1. Duration:
   * The system must meet the below criteria for a period of 4 weeks. The duration re-starts whenever a defect that meets the defect criteria \(listed below\) is patched on the nodes in scope.
   * The first duration starts with feature complete.
2. Load:
   * While in test net, an average of 10,000 transactions must be processed per day for the Duration.
   * These transactions can come from any origin.
3. Scope:
   * The root chain only.
4. Stability:
   * The test net must remain up, without any interruptions to service for the entire Duration. The system must accept new bonding requests during this time.
5. Defects:
   * No ‘Very High’ or ‘High’ \(see definition below\) bugs can be filed against the system for the Duration
6. Features & Fixes
   * The system is feature complete.
   * The version of the software that is running for the Duration has no more than 2 new pull requests within it. Those pull requests are bug fixes only.

**Definition of a Very High or High defect:**

* Any issue that causes a consensus failure, or nodes fail to add blocks to the blockdag.
* Any issue that adversely affects the performance of the network.
* Any issue related to security.
* Any issue that causes a node to crash.

