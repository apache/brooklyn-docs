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

###  Enrichers

#### Transformer

- org.apache.brooklyn.enricher.stock.Transformer

Transforms attributes of an entity.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Transformer
  brooklyn.config:
    enricher.sourceSensor: $brooklyn:sensor("urls.tcp.string")
    enricher.targetSensor: $brooklyn:sensor("urls.tcp.withBrackets")
    enricher.targetValue: $brooklyn:formatString("[%s]", $brooklyn:attributeWhenReady("urls.tcp.string"))
{% endhighlight %}

#### Propagator

- org.apache.brooklyn.enricher.stock.Propagator

Use propagator to duplicate one sensor as another, giving the supplied sensor mapping.
The other use of Propagator is where you specify a producer (using `$brooklyn:entity(...)` as below)
from which to take sensors; in that mode you can specify `propagate` as a list of sensors whose names are unchanged,
instead of (or in addition to) this map

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Propagator
  brooklyn.config:
    producer: $brooklyn:entity("cluster")
- type: org.apache.brooklyn.enricher.stock.Propagator
  brooklyn.config:
    sensorMapping:
      $brooklyn:sensor("url"): $brooklyn:sensor("org.apache.brooklyn.core.entity.Attributes", "main.uri")
{% endhighlight %}

####	Custom Aggregating

- org.apache.brooklyn.enricher.stock.Aggregator

Aggregates multiple sensor values (usually across a tier, esp. a cluster) and performs a supplied aggregation method to them to return an aggregate figure, e.g. sum, mean, median, etc.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Aggregator
  brooklyn.config:
    enricher.sourceSensor: $brooklyn:sensor("webapp.reqs.perSec.windowed")
    enricher.targetSensor: $brooklyn:sensor("webapp.reqs.perSec.perNode")
    enricher.aggregating.fromMembers: true
    transformation: average
{% endhighlight %}

#### Joiner

- org.apache.brooklyn.enricher.stock.Joiner

Joins a sensor whose output is a list into a single item joined by a separator.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Joiner
  brooklyn.config:
    enricher.sourceSensor: $brooklyn:sensor("urls.tcp.list")
    enricher.targetSensor: $brooklyn:sensor("urls.tcp.string")
    uniqueTag: urls.quoted.string
{% endhighlight %}

####	Delta Enricher

- org.apache.brooklyn.policy.enricher.Delta Enricher

Converts absolute sensor values into a delta.

####	Time-weighted Delta

- org.apache.brooklyn.enricher.stock.YamlTimeWeightedDeltaEnricher

Converts absolute sensor values into a delta/second.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.YamlTimeWeightedDeltaEnricher
  brooklyn.config:
    enricher.sourceSensor: reqs.count
    enricher.targetSensor: reqs.per_sec
    enricher.delta.period: 1s
{% endhighlight %}

####	Rolling Mean

- org.apache.brooklyn.policy.enricher.RollingMeanEnricher

Converts the last *N* sensor values into a mean.

####	Rolling Time-window Mean

- org.apache.brooklyn.policy.enricher.RollingTimeWindowMeanEnricher

Converts the last *N* seconds of sensor values into a weighted mean.

#### Http Latency Detector

- org.apache.brooklyn.policy.enricher.RollingTimeWindowMeanEnricher.HttpLatencyDetector

An Enricher which computes latency in accessing a URL.

#### Combiner

- org.apache.brooklyn.enricher.stock.Combiner

Can be used to combine the values of sensors.  This enricher should be instantiated using Enrichers.buider.combining(..).
This enricher is only available in Java blueprints and cannot be used in YAML.

#### Note On Enricher Producers

If an entity needs an enricher whose source sensor (`enricher.sourceSensor`) belongs to another entity, then the enricher
configuration must include an `enricher.producer` key referring to the other entity.

For example, if we consider the Transfomer from above, suppose that `enricher.sourceSensor: $brooklyn:sensor("urls.tcp.list")`
is actually a sensor on a different entity called `load.balancer`. In this case, we would need to supply an
`enricher.producer` value.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Transformer
  brooklyn.config:
    enricher.producer: $brooklyn:entity("load.balancer")
    enricher.sourceSensor: $brooklyn:sensor("urls.tcp.string")
    enricher.targetSensor: $brooklyn:sensor("urls.tcp.withBrackets")
    enricher.targetValue: |
      $brooklyn:formatString("[%s]", $brooklyn:attributeWhenReady("urls.tcp.string"))
{% endhighlight %}

It is important to note that the value supplied to `enricher.producer` must be immediately resolvable. While it would be valid
DSL syntax to write:

{% highlight yaml %}
enricher.producer: brooklyn:entity($brooklyn:attributeWhenReady("load.balancer.entity"))
{% endhighlight %}

(assuming the `load.balancer.entity` sensor returns a Brooklyn entity), this will not function properly because `enricher.producer`
will unsuccessfully attempt to get the supplied entity immediately.

Next: Writing a Policy
---------------------------

To write a policy, see the section on [Writing a Policy]({{ site.path.guide }}/java/policy.html).
