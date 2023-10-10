---
title: Defining Workflow
layout: website-normal
---

Let's start by discussing _why_ workflow is introduced and where it can and should be used.

The Apache Brooklyn Workflow is designed to make it easy to describe behaviour of entities, effectors, sensors, and policies in blueprints.
It has the sophistication of a programming language including [conditions, loops, and error-handling](common.md) and [variables](variables.md),
but more important are the [steps](steps/) which delegate to other systems,
such as containers or SSH or HTTP endpoints.
Complex programming logic will typically be done in another system, such as a container;
but where effectors and sensors need to interact with Brooklyn, such as reading and setting sensors, or invoking effectors,
it is often simplest to do that directly in the blueprint.

Workflow in a blueprint has the benefit of being transparent to users and having the Brooklyn context easily available.
It also has the advantage that Brooklyn will retry in certain situations.
However it has the disadvantage that, although we've tried to make it as easy as we can for people to write,
you are still writing code in YAML rather than in a first-class programming language.

The following are places that workflow can be used.


### Effectors

An effector can be defined using workflow and added to an entity as follows:

```
- type: some-entity
  brooklyn.initializers:
  - type: workflow-effector
    brooklyn.config:
      name: say-hi-and-publish-sensor
      steps:
        - log Hi
        - set-sensor boolean said_hi = true
```

This initializer will define the effector `say-hi-and-publish-sensor`
which uses workflow to do just that.  The config to define the effector is:

* `name`: the name of the effector to define (required)
* `parameters`: an optional map of parameters to advertise for the effector,
  keyed by the parameter name against the definition as a map including optionally 
  `type`, `description`, and `defaultValue`; see [nested workflow](nested-workflow.md) for more details

To define the workflow, this requires:

* `steps`: to supply the list of steps defining the workflow (required)

And the following optional common configuration keys are supported,
with the same semantics as for individual steps as described under [Common Step Properties](common.md):

* `condition`: an optional condition on the effector which if set and evaluating to false,
  prevents the effector workflow from running; this does _not_ support interpolated variables

* `input`: a map of keys to values to make accessible in the workflow, in addition to effector `parameters`

* `output`: defines the output of the workflow, often referring to workflow [variables](variables.md) or
  the output of the last step in the workflow

* other [common step properties](common.md) such as `timeout`, `on-error`, and `next`
* other [workflow settings properties](settings.md) such as `lock`, `retention`, `replayable`, and `idempotent`


### Sensors

A sensor feed to use a workflow to compute a sensor value based on triggers and/or a schedule
can be defined as follows:

```
- type: some-entity
  brooklyn.initializers:
  - type: workflow-sensor
    brooklyn.config:
      sensor: count-how-often-other_sensor-is-published
      triggers:
        - other_sensor
      steps:
        - let integer x = ${entity.sensor.x} + 1 ?? 0
        - return ${x}
```

This initializer will add the sensor to the entity's type signature,
then run the indicated workflow, periodically and/or on sensors,
and set the return value as the value of the sensor.
The config to define the sensor feed is:

* `sensor`: (required) a string specifying the sensor name or map with keys `name` (required) being the sensor name
  and optionally `type` being a type to record for the sensor
* `triggers`: a list of sensors which should trigger this when published, each entry declared either as the string name
  if on the local entity, or a map of `sensor` containing the name and `entity` containing the entity or entity ID
  where the sensor should be listened for, or if just a single local sensor, that sensor name supplied as a string
* `period`: whether the feed should run periodically
* `skip_initial_run`: by default sensors and policies will run when created (if any `condition` is met); 
  this can be set `true` to prevent that,
  ensuring it is only run after the initial `period` or when one of the `triggers` fires

In addition to defining the `sensor` name, at least one of `triggers` or `period` must be supplied.
The `steps` must also be defined, as per `workflow-effector` above,
and the same common configuration is supported.


### Policies

A policy to to run a workflow based on triggers and/or a schedule can be defined as follows:

```
- type: some-entity
  brooklyn.policies:
  - type: workflow-policy
    brooklyn.config:
      name: invoke-effector-other_sensor-is-published
      triggers:
      - other_sensor
      steps:
        - invoke-effector some_effector
```

This initializer will add the policy to the entity's defined management adjuncts,
then run the indicated workflow, periodically and/or on sensors.
The config to define the policy feed is:

* `name`: the name for the policy (recommended)
* `triggers` and/or `period`: per `workflow-sensor` above (at least one required)

The `steps` must also be defined, as per above,
and the same common configuration is supported.


### Initializer

A workflow can be made to run when an entity is created using a `workflow-initializer`.
This can do any custom entity setup, including the above tasks using `add-policy` or `apply-initializer` steps,
as follows:

```
- type: some-entity
  brooklyn.initializers:
  - type: workflow-initializer
    brooklyn.config:
      name: initializer-to-say-hi-then-add-effector-and-sensor
      steps:
        - log Hi this workflow initializer will run at entity creation
        - step: add-policy
          blueprint:
            type: workflow-policy
            brooklyn.config:
              name: invoke-effector-other_sensor-is-published
              triggers:
              - other_sensor
              steps:
                - invoke-effector say-hi-and-publish-sensor
        - step: apply-initializer
          blueprint:
            type: workflow-effector
            brooklyn.config:
              name: say-hi-and-publish-sensor
              steps:
                - log Hi
                - set-sensor boolean said_hi = true
```

The `workflow-initializer` takes the same config as `workflow-effector` with the exception of `parameters`.


### Workflow Entities

New entities can be written to use workflow for their start and stop behavior by extending the 
type `workflow-entity`.  This requires a `start` and `stop` configuration to be supplied
defining the workflow for those steps.  Optionally `restart` can be supplied, which if omitted
will default to stopping then starting.

```
- type: workflow-entity
  brooklyn.config:
    start:
      steps:
        - log Starting up
    stop:
      steps:
        - log Stopping
```

The `workflow-entity` will automatically set the `service.isUp` and `service.state` sensors
based on invocation of `start` and `stop` and the success of the workflow.

It will also take into consideration the map sensors `service.problems` and `service.notUp.indicators`,
where any entry in the former will cause `service.state` to show as "on-fire" if it is meant to be running,
and any entry in the latter will cause `service.isUp` to become false (which will trigger an
entry in `service.problems` if it is meant to be running). Thus liveness and health checks can,
and often should, be added, such as in the following getting the `status_code` from the `main.uri`,
and setting a `service.problems` if it is unavailable:

```
- type: workflow-entity
  brooklyn.config:
    start:
      steps:
        - ... # start the service, e.g. using container or http call
        
        - clear-sensor status_code
        - set-sensor main.uri = ...  # get the URL from the previous; this will trigger sensor feed
        - step: wait ${entity.sensor.status_code}
          timeout: 5m
    stop:
      # omitted

  brooklyn.initializers:
  - type: workflow-sensor
    brooklyn.config:
      sensor: status_code
    period: 1m
    triggers:
      - main.uri
    steps:
      - step: http ${main.uri}
        on-error:
          - set-sensor service.problems['endpoint-live'] = ${error}
          - fail rethrow message Endpoint is not accessible
      - clear-sensor service.problems['endpoint-live']
      - return ${status_code}
```

The workflow entity does not automatically start or stop children.
If this is required, it should be part of the start/stop workflow, as follows:

```
- type: workflow-entity
  brooklyn.config:
    start:
      steps:
        - ... # start this
        # now start children
        - type: workflow
          target: children
          steps:
            - invoke-effector start
            
    stop:
      steps:
        # stop children first
        - type: workflow
          target: children
          steps:
            - invoke-effector stop
        - ... # then stop this
```


### Workflow Software Process Entities

Entities that run software or another machine-based process can also be defined,
relying on Apache Brooklyn to provision a machine if required, then 
using workflow for the install, customize, launch, check-running, and stop phases.
These entities will provision a machine if if given a cloud or machine provisioning
location, and use the same latches and pre/post phase on-box commands as the ofther `SoftwareProcess` entities,
but for the key phases it will take a `workflow` object as for `workflow-entity`.

The `steps` will often run `ssh` and possibly `set-sensor`, and
they can access the run dir and install dir using Freemarker 
`${entity.driver.installDir}` and `${entity.driver.runDir}`.
The `workflow` object can also define inputs and outputs for use locally,
and `on-error` handlers.

The `checkRunning.workflow` should return `true` or `false` to indicate whether
the software is running. Alternatively, by setting the entity config `usePidFile: true` 
and in the launch command writing the process id (PID) to `${entity.driver.pidFile}`,
Brooklyn's automatic PID detection can be used.

As an example:

```
- type: workflow-software-process
  brooklyn.config:
    install.workflow:
      steps:
        - ssh yum update
        - ssh yum install ...
    launch.workflow:
      steps:
        - let PORT = 4321
        - 'ssh { echo hello | nc -l ${PORT} & } ; echo $! > /tmp/brooklyn-nc.pid'
        - 'set-sensor main.uri = http://localhost:${PORT}/'
    checkRunning.workflow:
      steps:
        - step: ssh ps -p `cat /tmp/brooklyn-nc.pid`
          timeout: 10s
          on-error:
            - return false
        - return true
    stop.workflow:
      steps:
        - ssh kill -9 `cat /tmp/brooklyn-nc.pid`
```
