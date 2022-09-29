---
title: Variables and Expressions
layout: website-normal
---

Steps can take input and return output, as do the containing workflows in most cases.
In workflow, Apache Brooklyn supports an interpolation expression syntax to access these values.
You can also use the Brooklyn DSL, but in most cases the interpolation syntax is more convenient.

For example, you can write:

```
- log Starting workflow: ${workflow.name}
- let integer x = 1
- id: log
  s:  log Step ${x}
- let x = ${x} + 1
  next: log
  condition:
    target: ${x}
    less-than: 3
```

This will output a series of log messages such as:

```
Starting workflow: my-workflow
Step 1
Step 2
Step 3
```


### Workflow Variables

The above illustration showed how `let x = <VALUE>` can be used to set a workflow variable
and `${x}` or `"Step ${x}"` will resolve it.  This is the simplest example of an interpolation expression.
There is a large set of information available through these expressions, described below.

Workflow variables, using `let`, have some additional behaviors described further below,
permitting for example the evaluation of `${x} + 1` and the specification that it should be an `integer`.


### Workflow Contextual Information

The interpolated reference `${workflow.<KEY>}` can be used to access workflow information, where `<KEY>` can be:

* `name` - returns the name of the current workflow
* `task_id` - returns the ID of the current corresponding Brooklyn task which acts as a unique identifier for the instance of the workflow
* `link` - a link in the UI to this instance of workflow
* `input` - the map of input parameters
* `output` - the output object or map
* `error` - if there is an error in scope
* `current_step.<KEY>` - info on the current step, where `<KEY>` can be any of the above (and the returned data is specific to the current step)
* `previous_step.<KEY>` - info on the previously invoked step, as above
* `step.<ID>.<KEY>` - info on the last invocation of the step with declared `id` matching `<ID>`, as above
* `var.<VAR>` - return the value of `<VAR>` which should be a workflow-scoped variable (set with `let`) 

In the step contexts, the following is also supported:

* `step_id` -- the declared `id` of the step
* `step_index` -- the index of the current step in the workflow definition, starting at 0
  (note that for convenience in the UI, step task display names will include the index starting at 1)

Where an item returns a map (such as `input` and usually `output`), a further `.<KEY>` can be used to
access the `<KEY>` entry within that map.
Similarly where an item returns a list, `[<INDEX>]` can be used to access the element at that index (starting at 0).


### Entity Contextual Information

The interpolated reference `${entity.<KEY>}` can be used to access information about the entity where the
workflow is running, where `<KEY>` can be:

* `name` - returns the value of the config key `<KEY>` 
* `id` - returns the value of the config key `<KEY>` 
* `config.<KEY>` - returns the value of the config key `<KEY>` 
* `sensor.<KEY>` - returns the value of the sensor key `<KEY>` 
* `attributeWhenReady.<KEY>` - returns the value of the sensor key `<KEY>` once it is ready (available and truthy), for use with the `wait` step
* `parent.<KEY>` - returns the value of `<KEY>` per any of the above in the context of the application 
* `application.<KEY>` - returns the value of `<KEY>` per any of the above in the context of the application


### Simple Expressions for Input, Output, and Variable

Where `${<VAR>}` is supplied, assuming it doesn't match one of the models above, the following search order is used:

* `${workflow.current_step.output.<VAR>}` 
* `${workflow.current_step.input.<VAR>}` 
* `${workflow.previous_step.output.<VAR>}` 
* `${workflow.var.<VAR>}`
* `${workflow.input.<VAR>}`


Thus `${x}` will be matched against the current step first, then outputs from the previous step,
and then workflow vars and inputs. It will be an error if `x` is not defined in any of those scopes.
(The `output` of the `current_step` is only defined when processing an explicit `output` block defined on a step.)  

Note that the `workflow` and `entity` models take priority over workflow variables,
so it is a bad idea to call a workflow variable `workflow`, as an attempt to evaluate
`${workflow}` refers to the model above which is not a valid result for an expression.
(You could still access such a variable, using `${workflow.var.workflow}`.)


### Evaluation for `let` and `wait`

It is an error if a variable not available or is null, including access to a sensor which has not yet been published.

You can cause workflow to block until a sensor becomes available using the `wait` step.

Where it is necessary to allow a null value or a potentially unavilable variable,
the "nullish coalescing" operator `??` can be used within `let` statements:

```
- let x = ${entity.sensor.does_not_exist} ?? "unset"
```

This will set `x = unset`, assuming there is no sensor `does_not_exist` (or if that sensor is `null`).

A limited number of other operations is also permitted in `let`,
namely the basic mathematical operands `+`, `-`, `*`, and `/`.
These are evaluated in usual mathematical order.
Parentheses are not supported.

The `let` step also supports a `trim` property (or keyword `trimmed` as the first word after the step type)
to indicate that if the value is a string, it should be "trimmed" before setting into the variable.
This supports two types of trimming: if a `type` is specified, the value is scanned for `---` on a line by itself
and that token is used as a "document separator", and only the last document is considered;
if no `type` is specified, the value has leading and trailing whitespace removed.
The former is primarily intended for YAML processing from a script which might include unwanted output prior 
to the outputting the YAML intended to set in the variable: the script can do `echo ---` before the
output which is wanted.


### Edge Cases

#### Interpolating Objects and Strings

Normally, expressions must either be the only content for an input or must be trivially convertable to a string 
(such as a string or number).
If we say `log "Hi ${person}"`, if `person` is something complex such as a map, the expression will return an error.
If we say `let x = ${person}`, because the expression is the only content for the value,
the trivial-to-string rule does not apply, and `x` will be whatever type `person` is.
If we say `let map x = ${name}`, then there will be an error if `person` is not a map (or coercible to a map).
Similarly if we say `let fancy-bean x = ${person}`, then `person` will be coerced to the registered type `fancy-bean`;
thus if `fancy-bean` refers to a Java class with fields `String name` and `Integer age`, 
and if we got a YAML string `{ name: Bob, age: 42 }` for `person`, 
then `x` would be an instance of that class. 

There is one other special rule about `let`; it tokenizes its `value` into words respecting spaces and quotes
before it evaluates them, any tokens which are quoted will be unescaped but _not_ evaluated as expressions,
and other tokens are evaluated individually as expressions and then coerced to strings if necessary
(if there are multiple tokens).
This allows embedding literal quotation marks, multiple spaces, and `${...}` literals into variables.
Thus given the steps:

```
- let msg = "${person}" is ${person}
- log ${msg}
```

Brooklyn will log `"${person}" is { name: "Bob", age: 42 }`.

#### Quotes and Whitespaces

Continuing from the above, because YAML and shorthand process quotes prior to passing the data to the step,
the treatment of quoted expressions can be subtle. For example, consider:

```
- type: let
  variable: x
  value: "1 + 1"
```

In YAML, this is identical to the above with `value: 1 + 1` passed,
so the `let` step does not know it was supplied in quotes, and so it will evaluate it as `2`.
You can pass instead `value: \"1 + 1\"` and `let` will get a quoted string which it will unquote
and set `x` to be `1 + 1`.
If using the shorthand, as noted above, quotes are preserved for the `value` to `let`,
so as one would expect, `let x = 1 + 1` sets `x` to `2` whereas `let x = "1 + 1"` and `let x = 1 "+" 1` set `1 + 1`. 


#### Freemarker Templates

Apache Brooklyn currently uses the Freemarker templating language to evaluate expressions.

Freemarker has many advanced behaviors, but it is recommended not to rely on those, and instead again to use
the advanced functionality of `let`, in case the templating engine is changed in future.

Some specific items to note about the templating language as used:

* Entries of maps and lists can be accessed using a dot- or bracket- qualified index, e.g. `${map.key}` or `list[index]`
* Nested variables are not supported, e.g. `${list[${index}]}` or `${${varname}}`
* Spaces should not be used inside interpolated expressions `${...}`

In rare cases the use of Freemarker may cause unexpected processing behavior of parameters, 
normally where an intended literal expression is interpreted by Freemarker.
This can happen, for example, if sending an `ssh` or `container` containing a `${VAR}` expression intended to be
processed by the shell rather than by Brooklyn.
It is recommended in these situations to use the behavior of `let`, 
where quoted expressions are not interpreted by Freemarker,
e.g. `let script = "echo var is ${VAR}"` or `let script = echo var is "${VAR}"`, followed by `ssh ${script}`.
