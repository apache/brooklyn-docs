---
title: Defining Workflow
layout: website-normal
---

Let's start by discussing _why_ workflow is introduced and where it can and should be used.

The Apache Brooklyn Workflow is designed to make it easy to describe behaviour of effectors, sensors, and policies in blueprints.
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
  keyed by the parameter name against the definition as a map including optionally `type`, `description`, and `defaultValue`

To define the workflow, this requires:

* `steps`: to supply the list of steps defining the workflow (required)

And the following optional [common](command.md) configuration keys are supported with the same semantics as for individual steps:

* `condition`: an optional condition on the effector which if set and evaluating to false,
  prevents the effector workflow from running; this does _not_ support interpolated variables
* `input`: a map of keys to values to make accessible in the workflow, in addition to effector `parameters`

TODO on-error, timeout, retry


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


### Workflow Software Process Entities

Entities that run software or another machine-based process can be defined using workflow for the
install, customize, launch, check-running, and stop phases.
These entities will provision a machine if required (e.g. if given a cloud or machine provisioning
location, rather than a machine), and use the same latches and pre/post phase on-box commands,
but for the key phases it will take a `workflow` object including at minimum `steps`.

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
- type: org.apache.brooklyn.entity.software.base.WorkflowSoftwareProcess
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
