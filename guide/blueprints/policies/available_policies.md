---
title: Off-the-Shelf Policies
layout: website-normal
---

Policies are highly reusable as their inputs, thresholds and targets are customizable.
Config key details for each policy can be found in the Catalog in the Brooklyn UI.


### HA/DR and Scaling Policies

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


#### ServiceRestarter Policy

- org.apache.brooklyn.policy.ha.ServiceRestarter

Attaches to a SoftwareProcess or to anything Startable which emits `ha.entityFailed` on failure
(or other configurable sensor), and invokes `restart` on that failure. 
If there is a subsequent failure within a configurable time interval or if the restart fails, 
this gives up and emits `ha.entityFailed.restart` for other policies to act upon or for manual intervention.

{% highlight yaml %}
brooklyn.policies:
- type: org.apache.brooklyn.policy.ha.ServiceRestarter
  brooklyn.config:
    failOnRecurringFailuresInThisDuration: 5m
{% endhighlight %}

Typically this is used in conjunction with the ServiceFailureDetector enricher to emit the trigger sensor.
The [introduction to policies](/guide/start/policies.md) shows a worked 
example of these working together.


#### ServiceReplacer Policy

- org.apache.brooklyn.policy.ha.ServiceReplacer

The ServiceReplacer attaches to a DynamicCluster and replaces a failed member in response to 
`ha.entityFailed` (or other configurable sensor) as typically emitted by the ServiceFailureDetector enricher.  
The [introduction to policies](/guide/start/policies.md) shows a worked 
example of this policy in use.


#### ServiceFailureDetector Enricher

- org.apache.brooklyn.policy.ha.ServiceFailureDetector

The ServiceFailureDetector enricher detects problems and fires an `ha.entityFailed` (or other configurable sensor)
for use by ServiceRestarter and ServiceReplacer.
The [introduction to policies](/guide/start/policies.md) shows a worked 
example of this in use.


#### SshMachineFailureDetector Policy

- org.apache.brooklyn.policy.ha.SshMachineFailureDetector

The SshMachineFailureDetector is an HA policy for monitoring an SshMachine, emitting an event if the connection is lost/restored.


#### ConnectionFailureDetector Policy

- org.apache.brooklyn.policy.ha.ConnectionFailureDetector

The ConnectionFailureDetector is an HA policy for monitoring an HTTP connection, emitting an event if the connection is lost/restored.


### Primary Election / Failover Policies

{% include_relative _elect-primary-policies.md %}


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

### Synchronization Policies

#### nginx-multi-upstream-sync Policy

*nginx-multi-upstream-sync* policy is designed to be used in combination with `nginx-multi` type that allows to achieve blue-green deployment.
Here is an example:

1. Deploy cluster of apps version 1 with the following blueprint:

    ```yaml
    name: My Application
    services:
      - type: nginx-multi:1.1.0-SNAPSHOT
        id: my-nginx-multi
      - type: org.apache.brooklyn.entity.webapp.DynamicWebAppCluster
        id: my-app-cluster-v1
        name: App Cluster v1
        brooklyn.config:
          latch.launch: $brooklyn:component("my-nginx-multi").attributeWhenReady("service.isUp")
          dynamiccluster.quarantineFailedEntities: false
          dynamiccluster.memberspec:
            '$brooklyn:entitySpec':
              type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
              brooklyn.config:
                wars.root: https://repo1.maven.org/maven2/org/apache/brooklyn/example/brooklyn-example-hello-world-sql-webapp/0.8.0-incubating/brooklyn-example-hello-world-sql-webapp-0.8.0-incubating.war
        brooklyn.policies:
          - type: nginx-multi-upstream-sync
            brooklyn.config:
              group: $brooklyn:component("my-app-cluster-v1")
              sensorsToTrack:
                - service.isUp
              nginxNode: $brooklyn:component("my-nginx-multi")
              groupName: v1
    ```

2. Navigate to NGINX effectors and render routing for `v1.myapp.com` pointing to v1 app group. `v1.myapp.com` is an
   endpoint to test cluster of apps version 1.
    * logicalNme `v1`
    * hostName `v1.myapp.com`
    * groupName `v1`
3. Find IP address of the NGINX in sensors and map it to `v1.myapp.com` in `/etc/hosts` and load `v1.myapp.com` in the
   browser on the machine where `/etc/hosts` is modified to test version 1, e.g. `11.22.33.44 v1.myapp.com`.
4. Render routing for `myapp.com` pointing to v1 app group. `myapp.com` in this example is a production endpoint.
    * logicalNme `production`
    * hostName `myapp.com`
    * groupName `v1`
5. Map IP address of the NGINX to myapp.com in `/etc/hosts` and load `myapp.com` in the browser on the machine where
   `/etc/hosts` is modified to verify that production endpoint loads version 1.
6. Deploy cluster of apps version 2 alongside version 1 in the same application:

    ```yaml
    services:
      - type: org.apache.brooklyn.entity.webapp.DynamicWebAppCluster
        id: my-app-cluster-v2
        name: App Cluster v2
        brooklyn.config:
          latch.launch: $brooklyn:component("my-nginx-multi").attributeWhenReady("service.isUp")
          dynamiccluster.quarantineFailedEntities: false
          dynamiccluster.memberspec:
            '$brooklyn:entitySpec':
              type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
              brooklyn.config:
                wars.root: https://repo1.maven.org/maven2/org/apache/brooklyn/example/brooklyn-example-hello-world-sql-webapp/1.0.0/brooklyn-example-hello-world-sql-webapp-1.0.0.war
        brooklyn.policies:
          - type: nginx-multi-upstream-sync
            brooklyn.config:
              group: $brooklyn:component("my-app-cluster-v2")
              sensorsToTrack:
                - service.isUp
              nginxNode: $brooklyn:component("my-nginx-multi")
              groupName: v2
    ```

   ***Hint:*** add as a child to a deployed application.

7. Render routing for `v2.myapp.com` pointing to v2 app group. `v2.myapp.com` is an endpoint to test cluster of apps
   version 2.
    * logicalNme `v2`
    * hostName `v2.myapp.com`
    * groupName `v2`
8. Map IP address of the NGINX to `v2.myapp.com` in `/etc/hosts` and load `v2.myapp.com` in the browser on the machine
   where `/etc/hosts` is modified to test version 2.
9. Render routing for `myapp.com` pointing to v2 app group to switch the app version at production endpoint.
    * logicalNme `production`
    * hostName `myapp.com`
    * groupName `v2`
10. Refresh myapp.com in the browser on the machine where `/etc/hosts` is modified to verify that production endpoint
    loads version 2.
11. Try to resize cluster of app version 2 and see routing configuration updated in activities of nginx-multi node.

***Note***, `/etc/hosts` is used to simplify demonstration of the policy in a blue-green deployment.

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
