---
title: Nested and Custom Workflow
layout: website-normal
---

The `type: workflow` can be used to create new step types and save them to the Brooklyn type registry.
New step types can be used in the same way as the [standard step types](steps.md).
This allows common workflow logic to be saved and re-used as steps in other workflow.
The usual properties of steps -- inputs, outputs, error handling -- are all supported,
and it supports defining parameters and even custom shorthand templates.

This step type can also be used directly within a workflow to run a "nested workflow",
for instance to structure code and to isolate a sequence of steps
or to apply `on-error` behavior to a group of steps.

Nested and custom workflows are not permitted to access data from their containing workflow;
instead, they accept an `input` block like other steps.
When defining a new step type in the catalog, `parameters` and a `shorthand` template can be defined. 


### Basic Usage in a Workflow

When used in a workflow, the nested workflow should be defined as a list in the `steps` key.
An `input` section can also be defined to pass data from the outer workflow to the nested workflow.

For example:

```
- log This is about to run a nested workflow
- let x=1
- ley y=2
- type: workflow
  input:
    x: ${x}
  steps:
    - log This is a nested workflow, able to see x=${x} but not y from the output workflow.
  on-error:
    # error handler which runs if the nested workflow fails (i.e. if any step therein fails and does not correct it) 
```


### Defining Custom Workflow Steps

This type can be used to define new step types and add them as new types in the type registry.
The definition must specify the `steps`, and may in addition specify:

* `parameters`: a map of parameters accepted by the workflow, TODO link to config params
* `shorthand`: a template
* `output`: an output map or value to be returned by the step, evaluated in the context of the nested workflow

When this type is used to define a new workflow step, the newly defined step does _not_ allow the
`steps` or any of the parameters listed above to be overridden.
Instead it accepts the parameters defined in the `parameters` key of the definition.
It also accepts the standard step keys such as `input`, `timeout` on `on-error`.
A user of the defined step type can also supply `output` which, as per other steps,
is evaluated in the context of the outer workflow, with visibility of the output from the current step.

For example:

TODO


#### Shorthand Template

TODO

* Accepts a shorthand template, and converts it to a map of values,
* e.g. given template "[ ${sensor.type} ] ${sensor.name} \"=\" ${value}"
* and input "integer foo=3", this will return
* { sensor: { type: integer, name: foo }, value: 3 }.
*
* Expects space separated TOKEN where TOKEN is either:
*
* [ TOKEN ] - to indicate TOKEN is optional. parsing is attempted first with it, then without it.
* ${VAR} - to set VAR, which should be of the regex [A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)*, with dot separation used to set nested maps;
*   will match a quoted string if supplied, else up to the next literal if the next token is a literal, else the next work.
* "LITERAL" - to expect a literal expression. this should include spaces if spaces are required.