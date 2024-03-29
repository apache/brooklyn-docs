---
title: Nested and Custom Workflow
layout: website-normal
---

The `type: workflow` can be used to create new step types and save them to the Brooklyn type registry.
New step types can be used in the same way as the [standard step types](steps/).
This allows common workflow logic to be saved and re-used as steps in other workflow.
The usual properties of steps -- inputs, outputs, error handling -- are all supported,
and it supports defining parameters and even custom shorthand templates.

This step type can also be used directly within a workflow to run a "nested workflow",
for instance to structure code and to isolate a sequence of steps
or to apply `on-error` behavior to a group of steps.

Nested and custom workflows are not permitted to access data from their containing workflow;
instead, they accept an `input` block like other steps.

This type permits all the [common step properties](common.md) and all the [workflow settings properties](settings.md),
plus a few others, `target`, `concurrency`, `parameters`, and `shorthand` as described below.


### Basic Usage in a Workflow

When used in a workflow, the nested workflow should be defined as a list in the `steps` key.
An `input` section can also be defined to pass data from the outer workflow to the nested workflow.

For example:

```
- log This is about to run a nested workflow
- let x=1
- let y=2
- type: workflow
  input:
    x: ${x}
  steps:
    - log This is a nested workflow, able to see x=${x} from input but not y from the output workflow.
  on-error:
    # error handler which runs if the nested workflow fails (i.e. if any step therein fails and does not correct it) 
```

### Loops and Parallelization

The `workflow` type can also be used to run a sequence of steps on multiple targets.
If given a `target` value, Brooklyn will run the workflow against that target or targets,
as follows:

* If the target is a managed entity, e.g. `$brooklyn:entity("some-child")`, the nested workflow
  will run in the scope of that entity. It will be visible in the UI under that entity,
  and references to sensors and effectors will be aginst that entity.
* If the target is any value which resolves to a list, it will be run against every entry in the list,
  with the variable expression `${target}` available in the sub-workflow to refer to the relevant entry
* If the target is `children` or `members` it will run against each entity in the relevant list
* If the target is of the form `M..N` for integers `M` and `N` it will run for all integers in that range,
  inclusive (so the string `1..4` is equivalent to the list `[1,2,3,4]`)

The scratch variables `target` and `target_index` are available referring to to the specific target
and its 0-indexed position. These names can be overridden with the `target_var_name` and `target_index_var_name` keys. 

Where a list is supplied, the result of the step is the list collecting the output of each sub-workflow.

If a `condition` is supplied when a list is being used, 
that `condition` is applied to each entry in the list.
The `workflow` step itself will always appear to run, but might have 0 nested workflows,
and in that case will return the empty list.
If the condition is intended to block the list from being evaluated,
and should be evaluated in the containing workflow's scope,
consider using a `subworkflow` with the outer condition containing the `workflow`.
An example of this is included below, using `service.isUp` with `children`.

### Associated Step Types

The `foreach` type is a simplified variant of `workflow` when recursing over a list,
taking the same arguments as `workflow` but supporting a shorthand syntax where
the `target_var_name` and `target` can be specified as in `foreach VAR_NAME in TARGET`.
A single step can be supplied as `do STEP` at the end;
either that or `steps` is required (but not both), 
and that step or those steps are run for all items in the target list. 

The `subworkflow` type is another simplified variant that does not allow any target
(so no recursing over a list and no concurrency), and which -- unlike the other workflow step types --
shares variables with the calling workflow. All variables from the immediate containing workflow
can be accessed and updated in a `subworkflow`, and new variables defined in the `subworkflow`
are subsequently available in the outer workflow. The `steps` are required/
A `name` is frequently given for readability, as are `condition` or `on-error` entries
to apply a condition or error-handler to the block of steps.
If no step type is defined, but `steps` are defined, this `subworkflow` step type is assumed.

The `if` type acts like `subworkflow` but allows specifying a condition in shorthand.


#### Example

```
- foreach x in 1..3 do return ${x}
```

The above loop will return `[1,2,3]` and proceed to the next step.

```
# foreach, nested workflow
- step: foreach x in 1..3
  steps:
  - let x = ${x} + 1
  - return ${x}
```

The above loop will return `[2,3,4]` and proceed to the next step.
It is the same as the previous except it is supplying multiple steps
to run on each iteration.
Note that the assignment to `${x}` does not side-effect the loop,
and nor is it available to the outer workflow, when using `foreach` or `workflow`.
Use `${output}` to access the result,
and see the `reducing` section below.

```
# subworkflow
- let x = 1
- steps:
  - let x = ${x} + 1
  - return ${x}
- let x = Not run, but if it were it could access ${x}
```

The above implicit lightweight subworkflow _does_ run in the parent workflow's context,
so it will access and update the same instance of `${x}`,
and it will `return` from the workflow, not running the next step.

```
# if
- let x = 1
- if ${x} == 1 then let x = ${x} + 1
- return ${x}
```

The above `if` step can access and update outer variables, like `subworkflow`, providing a convenient shorthand for simple conditions and steps. It is functionally identical to this:

```
- let x = 1
- condition:
    target: ${x}
    equals: 1
  steps:
  - let x = ${x} + 1
- return ${x}
```



### Reducing

Each nested workflow runs in its own scope and does not share workflow variables with the parent,
apart from values specified as `input`, or with other iterations of a loop.
Where it is desired to share variables across iterations, the key `reducing` can be supplied,
giving a map of variable names to be shared and their initial values.

When `reducing`, the indicated variables are available as scratch workflow variables in the calling workflow.

This cannot be used with `subworkflow`, as all variables are considered reduced in a `subworkflow`,
and it cannot be used with `concurrency` as that risks race conditions in updating the reduced variables.
(You can use `inputs` with both to provide new local variables.)


#### Example

```
- step: foreach x in 1..3 do let sum = ${sum} + ${x}
  reducing:
    sum: 0
```

The above loop will return `6`.


### Concurrency

By default nested workflows with list targets run sequentially over the entries,
but this can be varied by setting `concurrency`.
The following values are allowed:

* a number to indicate the maximum number of simultaneous executions (with `1` being the default, for no concurrency)
* the string `unlimited` to allow all to run in parallel
* a negative number to indicate all but a certain number
* a percentage to indicate a percentage of the targets
* the string `min(...)` or `max(...)`, where `...` is a comma separated list of valid values

This concisely allows complicated -- but important in the real world -- logic such as 
`max(1, min(50%, -10))` to express running concurrently over up to half if more than twenty, otherwise all but 10, 
and always allowing 1.
This might be used for example to upgrade a cluster in situ, leaving the larger of 10 instances or half the cluster alone, if possible.  
If the concurrency expression evaluates to 0, or to a negative number whose absolute value is larger than the number of values, the step will fail before executing, to ensure that if e.g. "-10" is specified when there are fewer than 10 items in the target list, the workflow does not run.  (Use "max(1, -10)" to allow it to run 1 at a time if there are 10 or fewer.)

Note: Concurrency cannot be specified when `reducing`.

#### Example

This example invokes an effector on all children which are `service.isUp`,
running in batches of up to 5 but not more than a third of the children at once:

```
- type: workflow
  target: children
  concurrency: max(1, min(33%, 5))
  condition:
    sensor: service.isUp
    equals: true
  steps:
    - invoke-effector effector-on-children
```

As noted above, the `condition` here is evaluated on each child.
To have it evaluated on the parent context instead, you can write:

```
- condition:
    sensor: service.isUp
    equals: true
  steps:
  - type: workflow
    target: children
    concurrency: max(1, min(33%, 5))
    steps:
    - invoke-effector effector-on-children
```

### Defining Custom Workflow Steps

This type can be used to define new step types and add them as new types in the type registry.
The definition must specify the `steps`, and may in addition specify:

* `parameters`: a map of parameters accepted by the workflow, with the key the parameter name,
  and the value map possibly empty or providing optional `type` (default `string`), `defaultValue` (default none),
  `required` (default `false`), `description` (default none), and/or `constraints`
* `shorthand`: a template, as described below
* `output`: an output map or value to be returned by the step, evaluated in the context of the nested workflow

When this type is used to define a new workflow step, the newly defined step does _not_ allow the
`steps` or any of the parameters listed above to be overridden.
Instead it accepts the parameters defined in the `parameters` key of the definition.
It also accepts the standard step keys such as `input`, `timeout` on `on-error`.
A user of the defined step type can also supply `output` which, as per other steps,
is evaluated in the context of the outer workflow, with visibility of the output from the current step.

When supplying a workflow in contexts where a `workflow` is already expected,
such as in a config key that takes a `workflow` (a Java `CustomWorkflowStep`),
it is not necessary to specify the `type: workflow`, and additionally, if the only things being set is `steps`, those steps can be provided as a list without the `steps` keyword.
Internally a _list_ will coerce to a `workflow` by interpreting the list as the steps.


#### Shorthand Template Syntax

A custom workflow step can define a `shorthand` template which permits a user
to use the workflow step as a string rather than a map, even with parameters.
The shorthand template syntax consists of a sequence of the following tokens:

* `${VAR}` - to set VAR, which should be of the regex [A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)*, 
  with dot separation used to set nested maps
* `${VAR...}` - as `${VAR}` but allowing it to match multiple words
* `"LITERAL"` - to expect the user to supply the exact token `LITERAL`;
  this should include spaces if spaces are required
* `[ <TOKENS> ]` - to indicate that a sequence of `<TOKENS>` is optional; 
  parsing is attempted first with this block, then without it

#### Example

A simple example to say hello is as follows:

```
id: greet
type: workflow
shorthand: ${name...} [ " with " ${greeting} ]
parameters:
  name:
    required: true
  greeting:
    defaultValue: Hello
steps:
- log ${greeting} ${name}
```

With this added as a registered type, workflows can write:

```
- type: greet
  input:
    name: Angela
```

The result will be the same as `log Hello Angela`.
The shorthand template spec also allows `greet Angela` for the same,
or exercising the optional block, `greet Zachary Jones with Howdy` to `log Howdy Zachary Jones`.

This is a trivial single-step example but shows the power of creating custom workflows,
especially with parameters and shorthand templates.
The [examples](examples/) and the [workflow settings](settings.md) include more realistic
illustrations of custom workflow steps.


#### Writing Workflow Steps in Java

The most common way to define custom workflow types is as workflow, using the primitives defined here,
and delegating to custom containers where the logic is best done in a higher-level programming language.
This avoids any language bias and the need to learn Brooklyn interfaces.
However it is supported to provide custom workflow step types as Java classes in a bundle.

To write a Java workflow step type, provide a class extending `WorkflowStepDefinition`,
providing implementations for the following methods:

```
Object doTaskBody(WorkflowStepInstanceExecutionContext context);
void populateFromShorthand(String value);
boolean isDefaultIdempotent();
```

The first of these does the work of the step, resolving inputs and accessing context as needed via `context`.
The second handles providing a custom shorthand, as described above;
it can call to a superclass method `populateFromShorthandTemplate(TEMPLATE, value)`
with the `TEMPLATE` for the class, if shorthand is to be supported.
Finally, the third returns whether the step is idempotent, that is if the custom step is interrupted,
can Brooklyn safely recover simply by rerunning it with the same inputs.
As described [here](settings.md), it is recommended to write the step so that it is idempotent if possible.

Once written, the class should be added to the Brooklyn Catalog, 
e.g. for a custom java step called `com.acme.YourJavaWorkflowStep` with shorthand name `your-step`,
create a `catalog.bom` such as the following, and `br catalog add catalog.bom`:

```
brooklyn.catalog:
  bundle: your-step-bundle
  version: "1.0.0-SNAPSHOT"
  items:
  - id: your-step
    format: java-type-name
    itemType: bean
    item:
      type: com.acme.YourJavaWorkflowStep
```
