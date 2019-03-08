# Metrics

[A software metric is a standard of measure of a degree to which a software system or process possesses some property](https://en.wikipedia.org/wiki/Software_metric). The CasperLabs node software forms the basis for a complex distributed system. It is desirable that node operators manage, maintain, and tune their individual nodes for best reliability and efficiency. To do this, they require data on how various aspects of the node are functioning. Only by analyzing and visualizing this data can a node operator make educated decisions on how to deploy their software and hardware resources. This data is also useful in the development process as a profiling instrument, with which we can detect anomalies in different components of software, monitor system resource consumption etc.

## Required metrics

The list of required metrics exposed by the CasperLabs node software will be published in a future version of this specification.

## Recommended metrics

### Node resources

It is recommended to create metrics that will reflect the state of the node software in terms of resource usage. Usually, an operator or developer wants to be able to monitor the state of memory and CPU usage,

#### Memory

Depending on the platform used you might want to collect the following memory metrics:

* heap memory
* non-heap memory
* used memory
* max memory

#### CPU

To monitor CPU utilization and quickly respond to possible anomalies in the work we suggest to collect the following:

* CPU time used by the process in which node software lives
* amount of CPU load

#### Garbage Collector \(GC\)

If the used platform has a garbage collection mechanism to manage memory, we suggest collecting some of GC metrics for diagnostic purposes. These can be:

* Memory used by different memory pools
* Accumulated collection time in ms
* An elapsed time of the last GC in ms
* Total number of collections that have occurred

#### Threads

If some sort of multithreading involved it is highly recommended to collect the following metrics:

* Number of threads
* Number of daemon threads
* Peak number of threads
* Total number of started threads

### Node metrics

Some of the metrics are very specific to the node software, which does not diminish their importance. Here is a list of metrics that would be good to have:

* Number of currently connected peers
* A counter for connection attempts
* A counter for disconnects
* Number of Kademlia ping requests
* Number of Kademlia lookup requests
* A counter for block store "put" operation
* A counter for block store "get" operation
* Probably measurements of time taken for above and other operations

## Infrastructure

To provide an implementation of metrics system a node software developer may need following components: 1\) A toolkit which is able to capture metrics \([Kamon](https://kamon.io/) as an example\) 2\) A time series database to store captured metrics \([Prometheus](https://github.com/prometheus) as an example\) 3\) Visualization tool to display captured metrics in a nice way \([Grafana](https://grafana.com/) as an example\)

