---
title: Clusters, Specs, and Composition
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

What if you want multiple machines? One way is just to repeat the `- type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess` block,
but there's another way which will keep your powder [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself):

{% highlight yaml %}
{% readj example_yaml/cluster-vm.yaml %}
{% endhighlight %}

Here we've composed the previous blueprint introducing some new important concepts, the `DynamicCluster`
the `$brooklyn` DSL, and the "entity-spec".  Let's unpack these. 

## Dynamic Cluster

The `DynamicCluster` creates a set of homogeneous instances.
At design-time, you specify an initial size and the specification for the entity it should create.
At runtime you can restart and stop these instances as a group (on the `DynamicCluster`) or refer to them
individually. You can resize the cluster, attach enrichers which aggregate sensors across the cluster, 
and attach policies which, for example, replace failed members or resize the cluster dynamically.

The specification is defined in the `dynamiccluster.memberspec` key.  As you can see it looks very much like the
previous blueprint, with one extra line.  Entries in the blueprint which start with `$brooklyn:`
refer to the Brooklyn DSL and allow a small amount of logic to be embedded
(if there's a lot of logic, it's recommended to write a blueprint YAML plugin or write the blueprint itself
as a plugin, in Java or a JVM-supported language).  

In this case we want to indicate that the parameter to `dynamiccluster.memberspec` is an entity specification
(`EntitySpec` in the underlying type system); the `entitySpec` DSL command will do this for us.
The example above thus gives us 5 VMs identical to the one we created in the previous section.

### Configuration

The following configuration keys can be specified for dynamic cluster:

| Config Key                                | Default  | Description                                                        |
|-------------------------------------------|-------------|-----------------------------------------------------------------|
| dynamiccluster.restartMode                |             | How this cluster should handle restarts; by default it is disallowed, but this key can specify a different mode. Modes supported by dynamic cluster are 'off', 'sequential', or 'parallel'. However subclasses can define their own modes or may ignore this. |
| dynamiccluster.quarantineFailedEntities   | true        | If true, will quarantine entities that fail to start; if false, will get rid of them (i.e. delete them) |
| dynamiccluster.quarantineFilter           |             | Quarantine the failed nodes that pass this filter (given the exception thrown by the node). Default is those that did not fail with NoMachinesAvailableException (Config ignored if quarantineFailedEntities is false) |
| cluster.initial.quorumSize                | -1          | Initial cluster quorum size - number of initial nodes that must have been successfully started to report success (if < 0, then use value of INITIAL_SIZE) |
| dynamiccluster.memberspec                 |             | Entity spec for creating new cluster members                    |
| dynamiccluster.firstmemberspec            |             | Entity spec for creating the first member of the cluster (if unset, will use the member spec for all) |
| dynamiccluster.removalstrategy            |             | strategy for deciding what to remove when down-sizing           |
| dynamiccluster.customChildFlags           |             | Additional flags to be passed to children when they are being created |
| dynamiccluster.zone.enable                | false       | Whether to use availability zones, or just deploy everything into the generic location |
| dynamiccluster.zone.failureDetector       |             | Zone failure detector                                           |
| dynamiccluster.zone.placementStrategy     | BalancingNodePlacementStrategy | Node placement strategy                      |
| dynamiccluster.availabilityZones          |             | availability zones to use (if non-null, overrides other configuration) |
| dynamiccluster.numAvailabilityZones       |             | number of availability zones to use (will attempt to auto-discover this number) |
| cluster.member.id                         |             | The unique ID number (sequential) of a member of a cluster      |
| cluster.initial.size                      | 1           | Initial cluster size                                            |
| start.timeout                             |             | Time to wait (after members' start() effectors return) for SERVICE_UP before failing (default is not to wait) |
| cluster.max.size                          | 2147483647  | Size after which it will throw InsufficientCapacityException    |
| dynamiccluster.maxConcurrentChildCommands | 0           | *Beta* The maximum number of effector invocations that will be made on children at once (e.g. start, stop, restart). Any value null or less than or equal to zero means invocations are unbounded |
| UP_QUORUM_CHECK                           | QuorumChecks.atLeastOne() | Up check, applied by default to members, requiring at least one present and up |
| RUNNING_QUORUM_CHECK                      | QuorumChecks.all()        | Problems check from children actual states (lifecycle), applied by default to members and children, not checking upness, but requiring by default that none are on-fire |


### Effectors

Dynamic cluster has a set of effectors which allow it's members to be manipulated, these are detailed below.

| Effector Name | Parameters  | Description                                                     |
|---------------|-------------|-----------------------------------------------------------------|
| replaceMember | memberId    | Replaces a specific member of the cluster given by it's ID      |
| resize        | desiredSize | Resizes the cluster to a `desiredSize`                          |
| resizeByDelta | delta       | Resizes the cluster by a `delta`                                |

Note that resizing of a cluster is limited by `cluster.max.size` and 0.

When increasing the size of a cluster to larger than the `cluster.max.size`, if there is any headroom between the cluster and `cluster.max.size`, the resize call will resize the cluster to `cluster.max.size`.
Any calls to increase the size of the cluster when it is already at `cluster.max.size` will result in an `InsufficientCapacityException`. Note that the new size of the cluster is returned by the resize effector calls.

### Sensors

A set of sensors are defined for dynamic cluster to feed back information on its status. These are:

| Sensor Name                       | Description                                                     |
|-----------------------------------|-----------------------------------------------------------------|
| group.members                     | Members of the group                                            |
| dynamiccluster.entityQuarantined  | Entity failed to start, and has been quarantined                |
| dynamiccluster.quarantineGroup    | Group of quarantined entities that failed to start              |
| dynamiccluster.subLocations       | Locations for each availability zone to use                     |
| dynamiccluster.failedSubLocations | Sub locations that seem to have failed                          |
| cluster.one_and_all.members.up    | True if the cluster is running, there is at least one member, and all members are service.isUp |

### Policies

Dynamic cluster has a set of policies which can auto-replace and resize the members as well as determine primary nodes and other
higher level actions. These policies are detailed on the [clusters and policies](clusters-and-policies.html) page.