---
title: Policies
layout: website-normal
---

Policies perform the active management enabled by Brooklyn.
They can subscribe to entity sensors and be triggered by them (or they can run periodically,
or be triggered by external systems).

<!---
TODO, clarify below, members of what?
-->
Policies can add subscriptions to sensors on any entity. Normally a policy will subscribe to its
associated entity, to the child entities, and/or to the members of a "group" entity.

Common uses of a policy include the following:

*	perform calculations,
*	look up other values,
*	invoke effectors  (management policies) or,
*	cause the entity associated with the policy to emit sensor values (enricher policies).

Entities can have zero or more ``Policy`` instances attached to them.


Off-the-Shelf Policies
----------------------

Policies are highly reusable as their inputs, thresholds and targets are customizable.

### Management Policies

#### AutoScaler Policy

- org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy

Increases or decreases the size of a Resizable entity based on an aggregate sensor value, the current size of the entity, and customized high/low watermarks.

An AutoScaler policy can take any sensor as a metric, have its watermarks tuned live, and target any resizable entity - be it an application server managing how many instances it handles, or a tier managing global capacity.

e.g. if the average request per second across a cluster of Tomcat servers goes over the high watermark, it will resize the cluster to bring the average back to within the watermarks.

{% highlight yaml %}
brooklyn.policies:
- type: org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy
  brooklyn.config:
    metric: webapp.reqs.perSec.perNode
    metricUpperBound: 3
    metricLowerBound: 1
    resizeUpStabilizationDelay: 2s
    resizeDownStabilizationDelay: 1m
    maxPoolSize: 3

{% endhighlight %}

#### ServiceRestarter

- org.apache.brooklyn.policy.ha.ServiceRestarter

Attaches to a SoftwareProcess (or anything Startable, emitting ENTITY_FAILED or other configurable sensor), and invokes restart on failure; if there is a subsequent failure within a configurable time interval, or if the restart fails, this gives up and emits {@link #ENTITY_RESTART_FAILED}

{% highlight yaml %}
brooklyn.policies:
- type: org.apache.brooklyn.policy.ha.ServiceRestarter
  brooklyn.config:
    failOnRecurringFailuresInThisDuration: 5m
{% endhighlight %}

#### StopAfterDuration Policy

- org.apache.brooklyn.policy.action.StopAfterDurationPolicy

The StopAfterDurationPolicy can be used to limit the lifetime of an entity.  After a configure time period expires the entity will be stopped.

#### CreateUser Policy

- org.apache.brooklyn.policy.jclouds.os.CreateUserPolicy

The CreateUserPolicy Attaches to an Entity and monitors for the addition of a location to that entity, the policy then adds a new user to the VM with a randomly generated password, with the SSH connection details set on the entity as the createuser.vm.user.credentials sensor.

#### AdvertiseWinRMLogin Policy

- org.apache.brooklyn.location.winrm.WinRmMachineLocation

This is similar to the CreateUserPolicy.  It will monitor the addition of WinRmMachineLocation to an entity and then create a sensor advertising the administrative user's credentials.

#### SshMachineFailureDetector

- org.apache.brooklyn.policy.ha.SshMachineFailureDetector

The SshMachineFailureDetector is an HA policy for monitoring an SshMachine, emitting an event if the connection is lost/restored.

#### ConnectionFailureDetector

- org.apache.brooklyn.policy.ha.ConnectionFailureDetector

The ConnectionFailureDetector is an HA policy for monitoring an http connection, emitting an event if the connection is lost/restored.

#### ServiceReplacer

- org.apache.brooklyn.policy.ha.ServiceReplacer

The ServiceReplacer attaches to a DynamicCluster and replaces a failed member in response to HASensors.ENTITY_FAILED or other sensor.  The [introduction to policies](../) shows a worked example of the ServiceReplacer policy in user.

#### FollowTheSun Policy

- org.apache.brooklyn.policy.followthesun.FollowTheSunPolicy

The FollowTheSunPolicy is for moving work around to follow the demand.  The work can be any Movable entity.  This currently available in yaml blueprints.

#### ConditionalSuspend Policy

- org.apache.brooklyn.policy.ha.ConditionalSuspendPolicy

The ConditionalSuspendPolicy will suspend and resume a target policy based on configured suspend and resume sensors.

#### LoadBalancing Policy

- org.apache.brooklyn.policy.loadbalancing.LoadBalancingPolicy

The LoadBalancingPolicy is attached to a pool of "containers", each of which can host one or more migratable "items".  The policy monitors the workrates of the items and effects migrations in an attempt to ensure that the containers are all sufficiently utilized without any of them being overloaded.


Writing a Policy
----------------

### Your First Policy

Policies perform the active management enabled by Brooklyn.
Each policy instance is associated with an entity,
and at runtime it will typically subscribe to sensors on that entity or children,
performing some computation and optionally actions when a subscribed sensor event occurs.
This action might be invoking an effector or emitting a new sensor,
depending the desired behavior is.

Writing a policy is straightforward.
Simply extend [``AbstractPolicy``](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/policy/AbstractPolicy.html),
overriding the [``setEntity``](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/objs/AbstractEntityAdjunct.html#setEntity-org.apache.brooklyn.api.entity.EntityLocal-) method to supply any subscriptions desired:

{% highlight java %}
    @Override
    public void setEntity(EntityLocal entity) {
        super.setEntity(entity)
        subscribe(entity, TARGET_SENSOR, this)
    }
{% endhighlight %}

and supply the computation and/or activity desired whenever that event occurs:

{% highlight java %}
    @Override
    public void onEvent(SensorEvent<Integer> event) {
        int val = event.getValue()
        if (val % 2 == 1)
            entity.sayYoureOdd();
    }
{% endhighlight %}


You'll want to do more complicated things, no doubt,
like access other entities, perform multiple subscriptions,
and emit other sensors -- and you can.
See the best practices below and source code for some commonly used policies and enrichers,
such as ``AutoScalerPolicy`` and ``RollingMeanEnricher``.

One rule of thumb, to close on:
try to keep policies simple, and compose them together at runtime;
for instance, if a complex computation triggers an action,
define one **enricher** policy to aggregate other sensors and emit a new sensor,
then write a second policy to perform that action.


### Best Practice

The following recommendations should be considered when designing policies:

#### Management should take place as "low" as possible in the hierarchy
*   place management responsibility in policies at the entity, as much as possible ideally management should take run as a policy on the relevant entity

*   place escalated management responsibility at the parent entity. Where this is impractical, perhaps because two aspects of an entity are best handled in two different places, ensure that the separation of responsibilities is documented and there is a group membership relationship between secondary/aspect managers.


#### Policies should be small and composable

e.g. one policy which takes a sensor and emits a different, enriched sensor, and a second policy which responds to the enriched sensor of the first     (e.g. a policy detects a process is maxed out and emits a TOO_HOT sensor; a second policy responds to this by scaling up the VM where it is running, requesting more CPU)

#### Where a policy cannot resolve a situation at an entity, the issue should be escalated to a manager with a compatible policy.

Typically escalation will go to the entity parent, and then cascade up.
e.g. if the earlier VM CPU cannot be increased, the TOO_HOT event may go to the parent, a cluster entity, which attempts to balance. If the cluster cannot balance, then to another policy which attempts to scale out the cluster, and should the cluster be unable to scale, to a third policy which emits TOO_HOT for the cluster.

#### Management escalation should be carefully designed so that policies are not incompatible

Order policies carefully, and mark sensors as "handled" (or potentially "swallow" them locally), so that subsequent policies and parent entities do not take superfluous (or contradictory) corrective action.

### Implementation Classes

Extend [`AbstractPolicy`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/policy/AbstractPolicy.html), or override an existing policy.
