---
title: Off-the-Shelf Policies
---

Policies are highly reusable as their inputs, thresholds and targets are customizable.
Config key details for each policy can be found in the Catalog in the Brooklyn UI.


### HA/DR and Scaling Policies

#### AutoScaler Policy

- org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy

Increases or decreases the size of a Resizable entity based on an aggregate sensor value, the current size of the entity, and customized high/low watermarks.

An AutoScaler policy can take any sensor as a metric, have its watermarks tuned live, and target any resizable entity - be it an application server managing how many instances it handles, or a tier managing global capacity.

e.g. if the average request per second across a cluster of Tomcat servers goes over the high watermark, it will resize the cluster to bring the average back to within the watermarks.

```yaml
brooklyn.policies:
- type: org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy
  brooklyn.config:
    metric: webapp.reqs.perSec.perNode
    metricUpperBound: 3
    metricLowerBound: 1
    resizeUpStabilizationDelay: 2s
    resizeDownStabilizationDelay: 1m
    maxPoolSize: 3

```


#### ServiceRestarter Policy

- org.apache.brooklyn.policy.ha.ServiceRestarter

Attaches to a SoftwareProcess or to anything Startable which emits `ha.entityFailed` on failure
(or other configurable sensor), and invokes `restart` on that failure. 
If there is a subsequent failure within a configurable time interval or if the restart fails, 
this gives up and emits `ha.entityFailed.restart` for other policies to act upon or for manual intervention.

```yaml
brooklyn.policies:
- type: org.apache.brooklyn.policy.ha.ServiceRestarter
  brooklyn.config:
    failOnRecurringFailuresInThisDuration: 5m
```

Typically this is used in conjunction with the ServiceFailureDetector enricher to emit the trigger sensor.
The [introduction to policies]({{book.path.docs}}/start/policies.md) shows a worked 
example of these working together.


#### ServiceReplacer Policy

- org.apache.brooklyn.policy.ha.ServiceReplacer

The ServiceReplacer attaches to a DynamicCluster and replaces a failed member in response to 
`ha.entityFailed` (or other configurable sensor) as typically emitted by the ServiceFailureDetector enricher.  
The [introduction to policies]({{book.path.docs}}/start/policies.md) shows a worked 
example of this policy in use.


#### ServiceFailureDetector Enricher

- org.apache.brooklyn.policy.ha.ServiceFailureDetector

The ServiceFailureDetector enricher detects problems and fires an `ha.entityFailed` (or other configurable sensor)
for use by ServiceRestarter and ServiceReplacer.
The [introduction to policies]({{book.path.docs}}/start/policies.md) shows a worked 
example of this in use.


#### SshMachineFailureDetector Policy

- org.apache.brooklyn.policy.ha.SshMachineFailureDetector

The SshMachineFailureDetector is an HA policy for monitoring an SshMachine, emitting an event if the connection is lost/restored.


#### ConnectionFailureDetector Policy

- org.apache.brooklyn.policy.ha.ConnectionFailureDetector

The ConnectionFailureDetector is an HA policy for monitoring an HTTP connection, emitting an event if the connection is lost/restored.


### Primary Election / Failover Policies

{% include '_elect-primary-policies.md' %}


### Optimization Policies

#### PeriodicEffector Policy

- org.apache.brooklyn.policy.action.PeriodicEffectorPolicy

The `PeriodicEffectorPolicy` calls an effector with a set of arguments at a specified time and date. The policy monitors the 
sensor configured by `start.sensor` and will only start when this is set to `true`. The default sensor checked is `service.isUp`, 
so that the policy will not execute the effector until the entity is started. The following example calls a `resize` effector 
to resize a cluster up to 10 members at 8am and then down to 1 member at 6pm.

    - type: org.apache.brooklyn.policy.action.PeriodicEffectorPolicy
      brooklyn.config:
        effector: resize
        args:
          desiredSize: 10
        period: 1 day
        time: 08:00:00
    - type: org.apache.brooklyn.policy.action.PeriodicEffectorPolicy
      brooklyn.config:
        effector: resize
        args:
          desiredSize: 1
        period: 1 day
        time: 18:00:00

#### ScheduledEffector Policy

- org.apache.brooklyn.policy.action.ScheduledEffectorPolicy

The `ScheduledEffectorPolicy` calls an effector at a specific time. The policy monitors the sensor configured by `start.sensor` 
and will only execute the effector at the specified time if this is set to `true`.

There are two modes of operation, one based solely on policy configuration where the effector will execute at the time set 
using the `time` key or after the duration set using the `wait` key, or by monitoring sensors. The policy monitors the 
`scheduler.invoke.now` sensor and will execute the effector immediately when its value changes to `true`. 
When the `scheduler.invoke.at` sensor changes, it will set a time in the future when the effector should be executed.

The following example calls a `backup` effector every night at midnight.

    - type: org.apache.brooklyn.policy.action.ScheduledEffectorPolicy
      brooklyn.config:
        effector: backup
        time: 00:00:00

#### FollowTheSun Policy

- org.apache.brooklyn.policy.followthesun.FollowTheSunPolicy

The FollowTheSunPolicy is for moving work around to follow the demand.  The work can be any Movable entity.  This currently available in yaml blueprints.


#### LoadBalancing Policy

- org.apache.brooklyn.policy.loadbalancing.LoadBalancingPolicy

The LoadBalancingPolicy is attached to a pool of "containers", each of which can host one or more migratable "items".  The policy monitors the workrates of the items and effects migrations in an attempt to ensure that the containers are all sufficiently utilized without any of them being overloaded.


### Lifecycle and User Management Policies


#### StopAfterDuration Policy

- org.apache.brooklyn.policy.action.StopAfterDurationPolicy

The StopAfterDurationPolicy can be used to limit the lifetime of an entity.  After a configure time period expires the entity will be stopped.


#### ConditionalSuspend Policy

- org.apache.brooklyn.policy.ha.ConditionalSuspendPolicy

The ConditionalSuspendPolicy will suspend and resume a target policy based on configured suspend and resume sensors.


#### CreateUser Policy

- org.apache.brooklyn.policy.jclouds.os.CreateUserPolicy

The CreateUserPolicy Attaches to an Entity and monitors for the addition of a location to that entity, the policy then adds a new user to the VM with a randomly generated password, with the SSH connection details set on the entity as the createuser.vm.user.credentials sensor.


#### AdvertiseWinRMLogin Policy

- org.apache.brooklyn.location.winrm.WinRmMachineLocation

This is similar to the CreateUserPolicy.  It will monitor the addition of WinRmMachineLocation to an entity and then create a sensor advertising the administrative user's credentials.
