---
title: Workflow Steps
layout: website-normal
---


### clear-config

Clears the value of a config key on an entity.

**Shorthand**: `clear-config [TYPE] CONFIG_KEY_NAME`

**Input parameters**:
* `config`: a string being the config key name or a map containing the `name` and
  optionally the `entity` where the config should be set (defaulting to the entity where the workflow is running)

**Output return value**: the previous value of the cleared config key


### clear-sensor

Clears the value of a sensor on an entity.

**Shorthand**: `clear-sensor [TYPE] SENSOR_NAME`

**Input parameters**:
* `sensor`: a string being the sensor name or a map containing the `name` and 
  optionally the `entity` where the sensor should be cleared (defaulting to the entity where the workflow is running)

**Output return value**: the previous value of the cleared sensor


### clear-workflow-variable

Clears the value of a workflow internal variable. The step `let` is an alias for this.

**Shorthand**: `clear-workflow-variable [TYPE] VARIABLE_NAME`

**Input parameters**:
* `variable`: a string being the workflow variable name or a map containing the `name`
  of the workflow variable which should be cleareed

**Output return value**: the previous value of the cleared workflow variable


### let

An alias for `set-workflow-variable`.

**Shorthand**: `let [TYPE] VARIABLE_NAME = VALUE`


### log

Logs a message.

**Shorthand**: `log MESSAGE`

**Input parameters**:
* `message`: the message to be logged

**Output return value**: the output from the previous step, or null if this is the first step


### set-config

Sets the value of a config key on an entity.

**Shorthand**: `set-config [TYPE] CONFIG_KEY_NAME = VALUE`

**Input parameters**:
* `config`: a string being the config key name or a map containing the `name` and
  optionally the `type` (defaulting to the declared type of the config key, if present, or to `Object`)
  and/or the `entity` where the config should be set (defaulting to the entity where the workflow is running)
* `value`: the value to set

**Output return value**: the value set for this config


### set-sensor

Sets the value of a sensor on an entity.

**Shorthand**: `set-sensor [TYPE] SENSOR_NAME = VALUE`

**Input parameters**:
* `sensor`: a string being the sensor name or a map containing the `name` and
  optionally the `type` (defaulting to the declared type of the sensor, if present, or to `Object`) 
  and/or the `entity` where the sensor should be set (defaulting to the entity where the workflow is running)
* `value`: the value to set

**Output return value**: the value set for this sensor


### set-workflow-variable

Sets the value of a workflow internal variable. The step `let` is an alias for this.

**Shorthand**: `set-workflow-variable [TYPE] VARIABLE_NAME = VALUE`

**Input parameters**:
* `variable`: a string being the workflow variable name or a map containing the `name` and optionally the `type`
  to coerce (needed e.g. if you want to set a bean registered type, or in shorthand to set an `integer`)
* `value`: the value to set

**Output return value**: the value set for this workflow variable


### sleep

Causes execution to pause for a specified duration.

**Shorthand**: `sleep DURATION`

**Input parameters**:
* `duration`: how long to sleep for, e.g. `5s` for 5 seconds

**Output return value**: the output from the previous step, or null if this is the first step


### no-op

The `no-op` step does nothing. It is mainly useful when setting a `next` point to jump to,
optionally with a `condition`.

**Shorthand**: `no-op`

**Input parameters**: _none_

**Output return value**: the output from the previous step, or null if this is the first step
