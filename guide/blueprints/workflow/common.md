---
title: Common Workflow Properties
layout: website-normal
---

### Shorthand and Longhand Syntax

Where possible, and in most examples so far, we've used the "shorthand" syntax for steps
which uses a string template to make it easy to write workflow steps:

```
steps:
- ssh echo today is `DATE`
- http http://some-rest-api/
- container my/container command
- set-sensor the-output = ssh says ${1.stdout}, http ${2.data}, container ${3.stdout}
```

This always starts with the type name, and the remainder is parsed according to a template
defined by that step type.

Internally, steps are maps with multiple inputs and properties,
and the shorthand syntax makes it possible to set the most common ones.
For `ssh` this is the command to run; for `container` an image; for `http` a URL; and for `set-xxx` 
an expression of the form `key=value`.

It is always possible to write the longhand map syntax, and if using inputs or properties
which aren't supported in the shorthand template (such as the `condition` property described below),
the longhand map syntax is required:

```
steps:
- type: ssh
  input:
    command: echo today is `DATE`
  condition:
    target: ${skip_date}
    not: { equals: true }
- ...
```

Shorthand can be combined as part of a map by providing the step shorthand string in a key
`s` (or `shorthand`). The type must be included as the first word, and the `type` key must not be used.

```
steps:
- s: ssh echo today is `DATE`
  condition:
    target: ${scratch.skip_date}
    not: { equals: true }
```

All steps support a number of common properties, described below.


### Conditions

The previous example shows the use of conditions, as mentioned as one of the properties common to all steps.  
This makes use of the recent "Predicate DSL" conditions framework 
(https://github.com/apache/brooklyn-docs/blob/master/guide/blueprints/yaml-reference.md#predicate-dsl).

It is normally necessary to supply a `target`, unless one of the entity-specific target keys (e.g. `sensor` or `config`)
is used.  The target and arguments here can use the [workflow expression syntax](variables.md).  

The condition is evaluated when the step is about to run, and if the condition is not satisfied, 
the workflow moves to the following step in the sequence, or ends if that was the last step.
(The `next` keyword, described next, is _not_ considered.) 

### Jumping with "Next"

The common property `next` allows overriding the workflow sequencing, indicating that a different step should 
be gone to next.

These can be used with the step type `no-op` to create "if x then goto" behavior, so as an alternative to the 
condition on the ssh step in the previous section, one could write:

```
steps:
- type: no-op
  next: end
  condition:
    target: ${scratch.skip_date}
    equals: true
- ssh echo today is `date`
```

The special `next` target `end` can be used to indicate that a workflow should complete and not proceed to any further steps.  
This avoids the need to introduce an unnecessary last step simply to have a jump target, 
e.g. `{ id: very-end, type: no-op }`.  Similarly `next: start` will go to the start again.


### Explicit IDs and Name

Steps can define an explicit ID for use with `next`, for correlation in the UI, 
and to be able to reference the output or input from a specific step using the [workflow expression syntax](variables.md).
They can also include a `name` used in the UI.

```
steps:
- type: no-op
  next: skipping-ssh-date
  condition:
    target: ${scratch.skip_date}
    equals: true

- s: ssh echo today is `date`
  name: Doing SSH
  next: end

- id: skipping-ssh-date
  name: Not doing SSH
  s: log skipping ssh date command
```


### Input and Output

Most steps take input parameters and return output. 
Many step-specific input parameters can be set in the shorthand, but not all.
All input parameters can be specified in an `input` block.
It is also possible to customize the output from a step using an `output` block.
For example:

```
- s: let target = aws
  condition:
    target: location
    tag: aws
  next: picked-target
- s: let target = azure
  condition:
    target: location
    tag: azure
  next: picked-target
- input:
    location_name: ${entity.location.name}
  s: log Unrecognized cloud ${location_name}, using default
  output:
    cloud: default
  next: end
- id: picked-target
  s: log Picked target ${target}
  output:
    cloud: ${target}
```

The above will return an output map containing a key `cloud` and a value of either `azure`, `aws`, or `default`.
In addition, a custom `input` variable is passed to the third step.
(This is not the simplest way to write this logic, but it illustrates the concepts.)

This example also shows the expression syntax. More on inputs, outputs, variables, and expressions
is covered [here](variables.md). 


### TODO Other keys

timeout, on-error, retry (or new section)
- timeout implement for workflow steps
- on-error implement for workflow steps


- first matching on-error block applies, usually applied a condition, must apply a step (e.g. retry), and
  can apply output or next which replaces that defined by the original step
- 
- on-error not permitted to have id or replayable mode; the error step remains the replay target;
- where error handlers use nested workflow, these are not persisted or replayable

- ui support for error handlers (deferred, see notes in WorkflowErrorHandling)
 


TODO also include this in defining:

If interrupted, steps are replayed, so care must be taken for actions which are not idempotent,
i.e. if an individual step is replayed we should be wary if they cause a different result.
For example, if the following were allowed:

```
- set-sensor count = ${entity.sensor.count} + 1   # NOT supported
```

if it were interrupted, Brooklyn would have no way of knowing whether
the sensor `count` contains the old value or the new value.
For this reason, arithmetic operations are permitted only in `let`,
and because workflow variables are stored per step,
we ensure that the arithmetic is idempotent, so either of these can be
safely replayed from the point where they are interrupted
(in addition to handling the case where the sensor is not yet published):

```
- let integer count_local = ${entity.sensor.count} + 1 ?? 1",
- set_sensor count = ${count_local}
```

or

```
- let integer count_local = ${entity.sensor.count} ?? 0",
- let count_local = ${count_local} + 1
- set_sensor count = ${count_local}
```
