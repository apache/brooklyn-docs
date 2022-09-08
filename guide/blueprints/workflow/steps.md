---
title: Workflow Steps
layout: website-normal
---


### set-sensor

Shorthand: `set-sensor [TYPE] SENSOR_NAME = VALUE`

Arguments:
* `sensor`: a string being the sensor name or a map containing the `name` and
  optionally the `type` (defaulting to the declared type of the sensor, if present, or to `Object`) 
  and/or the `entity` where the sensor should be set (defaulting to the entity where the workflow is running)
* `value`: the value to set

The `sleep` step causes execution to pause for a specified duration.



### sleep

Shorthand: `sleep DURATION`

Arguments:
* `duration`: how long to sleep for, e.g. `5s` for 5 seconds

The `sleep` step causes execution to pause for a specified duration.



### no-op

Shorthand: `no-op`

Arguments:
* _none_

The `no-op` step does nothing. It is mainly useful when setting a `next` point to jump to,
optionally with a `condition`.

