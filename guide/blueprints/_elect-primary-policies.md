
There are a collection of policies, enrichers, and effectors to assist with common
failover scenarios and more generally anything which requires the election and re-election of a primary member.

These can be used for:

* Nominating one child among many to be noted as a primary via a sensor (simply add the `ElectPrimaryPolicy`)
* Allowing preferences for such children to be specified  (via `ha.primary.weight`)
* Causing the primary to change if the current primary goes down or away
* Causing `promote` and `demote` effectors to be invoked on the appropriate nodes when the primary is elected/changed
  (with the parent reset to `STARTING` while this occurs)
* Mirroring sensors and optionally effectors from the primary to the parent

A simple example is as follows, deploying two `item` entities with one designated as primary
and its `main.uri` sensor published at the root. If "Preferred Item" fails, "Failover Item"
will be become the primary. Any `demote` effector on "Preferred Item" and any `promote` effector
on "Failover Item" will be invoked on failover.

```
brooklyn.policies:
- type: org.apache.brooklyn.policy.ha.ElectPrimaryPolicy
  brooklyn.config:
    # `best` will cause failback to occur automatically when possible; could use `failover` instead
    primary.selection.mode: best
    propagate.primary.sensors: [ main.uri ]

brooklyn.enrichers:
- # this enricher will cause the parent to report as failed if there is no primary
  type: org.apache.brooklyn.policy.ha.PrimaryRunningEnricher

services:
- type: item
  name: Preferred Item
  brooklyn.config:
    ha.primary.weight: 1
- type: item
  name: Failover Item
```


#### ElectPrimary Policy

- org.apache.brooklyn.policy.ha.ElectPrimaryPolicy

The ElectPrimaryPolicy acts to keep exactly one of its children or members as primary, promoting and demoting them when required.

A simple use case is where we have two children, call them North and South, and we wish for North to be primary.  If North fails, however, we want to promote and fail over to South.  This can be done by:

* adding this policy at the parent
* setting `ha.primary.weight` on North
* optionally defining `promote` on North and South (if action is required there to promote it)
* observing the `primary` sensor to see which is primary
* optionally setting `propagate.primary.sensor: main.uri` to publish `main.uri` from whichever of North or South is active
* optionally setting `primary.selection.mode: best` to switch back to North if it comes back online

The policy works by listening for service-up changes in the target pool (children or members) and listening for `ha.primary.weight` sensor values from those elements.  On any change, it invokes an effector to perform the primary election.  By default, the effector invoked is `electPrimary`, but this can be changed with the `primary.election.effector` config key.  If this effector does not exist, the policy will add a default behaviour using `ElectPrimaryEffector`.  Details of the election are described in that effector, but to summarize, it will find an appropriate primary from the target pool and publish a sensor indicating who the new primary is.  Optionally it can invoke `promote` and `demote` on the relevant entities.

All the `primary.*` parameters accepted by that effector can be defined on the policy and will be passed to the effector, along with an `event` parameter indicating the sensor which triggered the election.

The policy also accepts a `propagate.primary.sensors` list of strings or sensors.
If present, this will add the `PropagatePrimaryEnricher` enricher with those sensors set to
be propagated (but not effectors).
For more sophisticated configuration, that enricher can be added and configured directly instead.  

If no `quorum.up` or `quorum.running` is set on the entity, both will be set to a constant 1.


#### ElectPrimary Effector

- org.apache.brooklyn.policy.ha.ElectPrimaryEffector

This effector will scan candidates among children or members to determine which should be noted as "primary".  
The primary is selected from service-up candidates based on a numeric weight as a sensor or config on the candidates 
(`ha.primary.weight`, unless overridden), with higher weights being preferred and negative indicating not permitted.  
In the case of ties, or a new candidate emerging with a weight higher than a current healthy primary, 
behaviour can be configured with `primary.selection.mode`.

If there is a primary and it is unchanged, the effector will end.

If a new primary is detected, the effector will:

* set the local entity to the STARTING state

* clear any "primary-election" problem

* publish the new primary in a sensor called `primary` (or the sensor set in `primary.sensor.name`)

* set service up true

* cancel any other ongoing promote calls, and if there is an ongoing demote call on the entity being promoted, cancel that also

* in parallel

    * invoke `promote` (or the effector called `primary.promote.effector.name`) on the local entity or the entity being promoted
    
    * invoke `demote` (or the effector called `primary.promote.effector.name`) on the local entity or the entity being demoted, if an entity is being demoted
    
* set the local entity to the RUNNING state


If no primary can be found, the effector will:

* add a "primary-election" problem so that service state logic, if applicable, will know that the entity is unhealthy

* demote any old primary

* set service up false

* if the local entity is expected to be RUNNING, it will set actual state to ON_FIRE

* if the local entity has no expectation, it will set actual state to STOPPED


More details of behaviour in edge conditions can be seen and set via the parameters on this effector.

* `primary.target.mode`:  where should the policy look for primary candidates; one of 'children', 'members', or 'auto' (members if it has members and no children)

* `primary.selection.mode`:  under what circumstances should the primary change:  `failover` to change only if an existing primary is unhealthy, `best` to change so one with the highest weight is always selected, or `strict` to act as `best` but fail if several advertise the highest weight (for use when the weight sensor is updated by the nodes and should tell us unambiguously who was elected)

* `primary.stopped.wait.timeout`:  if the highest-ranking primary is stopped (but not failed), the effector will wait this long for it to be starting before picking a less highly-weighted primary; default 3s, typically long enough to avoid races where multiple children are started concurrently but they complete extremely quickly and one completes before a better one starts

* `primary.starting.wait.timeout`:  if the highest-ranking primary is starting, the effector will wait this long for it to be running before picking a less highly-weighted primary (or in the case of `strict` before failing if there are ties); default 5m, typically long enough to avoid races where multiple children are started and a sub-optimal one comes online before the best one

* `primary.sensor.name`:  name to publish, defaulting to `primary`

* `primary.weight.name`:  config key or sensor to scan from candidate nodes to determine who should be primary

* `primary.promote.effector.name`: effector to invoke on promotion, default `promote` and with no error if not present (but if set explicitly it will cause an error if not present)

* `primary.demote.effector.name`: effector to invoke on demotion, default `demote` and with no error if not present (but if set explicitly it will cause an error if not present)


#### PrimaryRunning Enricher

- org.apache.brooklyn.policy.ha.PrimaryRunningEnricher

This adds service not-up and problems entries if the primary is not running, 
so that the parent will only be up/healthy if there is a healthy primary.


#### PropagatePrimary Enricher

- org.apache.brooklyn.policy.ha.PropagatePrimaryEnricher

This allows sensors and effectors from the primary to be available at the parent.
This takes the same config as `Propagator`, as well as `propagate.effectors` (true or false)
for whether effectors should be propagated.

