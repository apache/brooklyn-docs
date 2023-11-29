---
title: Common Step Properties
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
`step` (or `s` or `shorthand`). The type must be included as the first word, and the `type` key must not be used.

```
steps:
- step: ssh echo today is `DATE`
  condition:
    target: ${scratch.skip_date}
    not: { equals: true }
```

Care should be taken when using `:` in a step with shorthand.  YAML will parse it as a map if it is not quoted in YAML. However at runtime, if the step looks like it came from an accidental colon causing a map, it will be reverted to a string with the colon re-introduced, so you can write steps with shorthand `- log Your name is: ${name}`. 

All steps support a number of common properties, described below.

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

- step: ssh echo today is `date`
  name: Doing SSH
  next: end

- id: skipping-ssh-date
  name: Not doing SSH
  step: log skipping ssh date command
```


### Conditions

The previous example shows the use of conditions, as mentioned as one of the properties common to all steps.  
This makes use of the recent "[Predicate DSL](https://github.com/apache/brooklyn-docs/blob/master/guide/blueprints/yaml-reference.md#predicate-dsl)" conditions framework .

It is normally necessary to supply a `target`, unless one of the entity-specific target keys (e.g. `sensor` or `config`)
is used.  The target and arguments here can use the [workflow expression syntax](variables.md).  

The condition is evaluated when the step is about to run, and if the condition is not satisfied, 
the workflow moves to the following step in the sequence, or ends if that was the last step.
Apart from `name` and `id` above, if a step's `condition` is unmet,
the other properties set on a step are ignored.


### Jumping with "Next" or "Goto"

The common property `next` allows overriding the workflow sequencing, 
indicating that a different step should be gone to next.
This does not apply if a step's condition is not satisfied, as noted at the end of the previous section.

The value of the `next` property should be the ID of the step to go to
or one of the following reserved words:

* `start`: return to the start of the workflow
* `end`: exit the workflow (or if in a block where this doesn't make sense, such as `retry`, go to the last executed step)
* `exit`: if in an error handler, exit that error handler

The `goto` step type is equivalent to the `no-op` step with `next` set,
as a simpler idiom for controlling workflow flow.
While `goto` is "considered harmful" in many programming environments,
for declarative workflow it is fairly common, because it can simplify what
might otherwise involve multiple nested workflows.
That said, the confusion that `goto` can cause should be kept in mind,
and its availability not abused:  in particular where a task can be better done
in a proper high-level programming language, consider putting that program 
into a container and calling it from your workflow.


### Input and Output

Most steps take input parameters and return output. 
Many step-specific input parameters can be set in the shorthand, but not all.
All input parameters can be specified in an `input` block.
It is also possible to customize the output from a step using an `output` block.
For example:

```
- step: let target = aws
  condition:
    target: location
    tag: aws
  next: picked-target
- step: let target = azure
  condition:
    target: location
    tag: azure
  next: picked-target
- input:
    location_name: ${entity.location.name}
  step: log Unrecognized cloud ${location_name}, using default
  output:
    cloud: default
  next: end
- id: picked-target
  step: log Picked target ${target}
  output:
    cloud: ${target}
```

The above will return an output map containing a key `cloud` and a value of either `azure`, `aws`, or `default`.
In addition, a custom `input` variable is passed to the third step.
(This is not the simplest way to write this logic, but it illustrates the concepts.)

This example also shows the expression syntax. More on inputs, outputs, variables, and expressions
is covered [here](variables.md). 


### Timeout

Any step and/or an entire workflow can define a `timeout: <duration>`,
where the `<duration>` is of the form `1 day` or `1h 30m`.
If the step or workflow where this is present takes longer than this duration,
it will be interrupted and will throw a `TimeoutException`.


### Error Handling with `on-error`

Errors on a step and/or a workflow can use the `on-error: <handler>` property to determine how
and error should be handled.  The `<handler>` can be:

* a single step as a string, for instance `on-error: retry`, or to prevent infinite loops
  and introduce exponential backoff `on-error: retry limit 4 backoff 5s increasing 2x`

* a single step as a map, possibly with a condition; if the condition is not met,
  the error is rethrown; for example:

  ```
  - step: ssh systemctl restart my-service
    on-error:
      step: goto my-service-restart-error
      condition:
        target: ${exit_code}
        greater-than: 0
  ```

  If the `ssh` command returns an `exit_code` greater than zero (which the `ssh` step treats as an error) 
  this will go to the step with `id: my-service-restart-error`.
  Any other error, such as network connectivity, will be rethrown and could be addressed by a workflow-level
  `on-error` or could cause the workflow to fail.

* a list of steps, some or all with conditions and some or all with `next` indicated, as follows:

The list of steps will run sequentially, applying conditions to each.
The target of conditions in an error handler is the error itself, so
the DSL `error-cause` predicate can be used, for example
`error-cause: { java-instance-of: TimeoutException }` or
`error-cause: { glob: "*server timeout*" }`.

The error handler will complete and be considered to have handled the error at the first step
where the condition is satisfied and which indicates a `next` step (either a `goto` or `retry` step, or `next` property).
and subsequent steps in the error handler will not run.
If all steps have conditions and none are met, the error handler will rethrow the error,
but otherwise, if one or more steps run and none of them throw errors or indicate a `next`,
it will consider the error to be handled and go to the next step in the non-error-handler workflow.
Where the handler combines non-conditional statements (such as `log`) with conditions,
all expected terminal conditions should indicate a `next`; to avoid confusion it is not recommended that
the last step be a condition that might not apply. Consider adding a final step
`fail rethrow message None of the error handler conditions were met` to make sure the handler does not
accidentally succeed because a `log` step was run, when none of the "real" conditions applied.

The `next` target `exit` can be used in an error handler to indicate to go to the next step in the containing
workflow sequence. Nested error handlers are permitted, and `exit` will return to the containing error handler
without indicating that it should exit. Any other `next` target from a nested workflow jumps out of all nested
error handlers and goes to that target in the non-error-handler workflow.

Error handlers run in the same context as the original workflow, not a new context as nested workflow does,
but with some restrictions. This has some significant benefits but also some things in special cases which
might require care:

* You can read and write workflow variables within error handlers
* You can set the `output` for use in the outer workflow
* Error handlers are not persisted; any replay will revert to the outer step or earlier
* ID's are not permitted in error handlers; any `next` refers to the containing workflow
* The workflow UI does not show error handling steps; their activity can only be seen in the tasks view
  and in the logs


### Workflow Settings

There are a few other settings allowed on all or some steps which configure workflow behavior.
These are `replayable`, `idempotent`,  and `retention`,
and are described under [Workflow Settings](settings.md).

