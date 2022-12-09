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
  step:  log The value for x is now ${x}
- let x = ${x} + 1
  next: log
  condition:
    target: ${x}
    less-than: 3
```

This will output a series of log messages such as:

```
Starting workflow: my-workflow
The value for x is now 1
The value for x is now 2
The value for x is now 3
```


### Workflow Variables

The above illustration showed how `let x = <VALUE>` can be used to set a workflow variable
and `${x}` or `"The value for x is now ${x}"` will resolve it.  
This is the simplest example of an interpolation expression.
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
* `error_handler.<KEY>` - info on the current error handler, as above, if in an on-error step
* `step.<ID>.<KEY>` - info on the last invocation of the step with declared `id` matching `<ID>`, as above
* `var.<VAR>` - return the value of `<VAR>` which should be a workflow-scoped variable (set with `let`) 
* `util.<UTIL>` - access a utility pseudo-variable, either `random` for a random between 0 and 1,
  `now` for milliseconds since 1970, `now_iso` for ISO 8601 date string, `now_nice` or `now_stamp` for a human readable date format

In the step contexts, the following is also supported after `workflow.`:

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


### Output Access

The token `${output}` refers to the nearest output in scope:
in a step's `output:` block, it refers to the default output from a step, thus
`output: ${output.stdout}` can be used on a `container` step to change the output from being the default map including `stdout`
to being just the `stdout` (alternatively just `${stdout}` can be used, per the next section).
With a nested workflow running over a list, e.g. of children, `output: ${output[0]}`
can be used to refer to the output from the first element in the list.
If used in a step _prior_ to the resolution of an `output` block, such as in the inputs,
it refers to the output from the previous step.
If used in the `output` block of a workflow, it refers to the default output of the workflow
which is the output of the last step.


### Simple Expressions for Input, Output, and Variable

Where `${<VAR>}` is supplied, assuming it doesn't match one of the models above, the following search order is used:

* `${workflow.error_handler.output.<VAR>}` (only in an on-error block)
* `${workflow.error_handler.input.<VAR>}` (only in an on-error block)
* `${workflow.current_step.output.<VAR>}` (only set when evaluating `output` for a step, pointing at default output of the step)
* `${workflow.current_step.input.<VAR>}` 
* `${workflow.previous_step.output.<VAR>}` 
* `${workflow.var.<VAR>}`
* `${workflow.input.<VAR>}`

Thus `${x}` will be matched against the current step first, then outputs from the previous step,
and then workflow vars and inputs. It will be an error if `x` is not defined in any of those scopes.
(The `output` of the `current_step` is only defined when processing an explicit `output` block defined on a step,
and the `error_handler` is only defined when running in an `on-error` step.)

Note that the `workflow`, `entity`, and `output` models take priority over workflow variables,
so it is a bad idea to call a workflow variable `workflow`, as an attempt to evaluate
`${workflow}` refers to the model above which is not a valid result for an expression.
(You could still access such a variable, using `${workflow.var.workflow}`.)

When populating a `<VAR>` for use in the scopes above, it might not make sense to include the previous scopes;
in these cases resolution starts at the appropriate scope.
For example when resolving a step's input, the step's output is not considered.
Furthermore when resolving a step's input, it is permitted to reference other input so long as there is no recursive reference,
and it is permitted to reference the variable being set, from a parent scope, but other local or recursive references are not permitted.
This only applies in very specific edge cases, and so can generally be ignored.
If resolution behavior is ever surprising, it is recommended to use the full syntax including scope (prefixed by `workflow.`).



### Arithmetic and Idempotency

The `let` step allows mathematical operations, such as:

```
- let x = ${x} * 3 + 1
```

The spaces around the operations are required, and this is the only place arithmetic is supported.
Any other usage, such as `set-sensor disallowed = ${x} + 1` or `let x = ${x}+1` will result in strings.
It is recommended to explicitly specify a mathematical type, `integer` or `double` to trigger an error
because the string `3+1` will not be coercible to an integer.

The reason `let` is the only place operations is allowed is because Brooklyn is able to restore local variables
if a workflow is replayed from that step.
This ensures that most steps are individually idempotent,
so if interrupted at the step can be safely resumed from that step.

For example, if the following were allowed:

```
- set-sensor count = ${entity.sensor.count} + 1   # NOT supported
```

if it were interrupted, Brooklyn would have no way of knowing whether
the sensor `count` contains the old value or the new value,
and a replay might cause it to be incremented twice.
The following sequence of steps (which is permitted) can always safely be replayed from any interrupted state:

```
- let integer count_local = ${entity.sensor.count} ?? 0",
- let count_local = ${count_local} + 1
- set_sensor count = ${count_local}
```

Where workflows need to be resumed on interruption or might replay steps to recover from other errors,
idempotency is an important part of reliable workflow design.
External actions such as `http` and `container` are not guaranteed to be idempotent,
and neither are some `invoke-effector` calls, so care must be taken here for workflows to be replayable.
Good practice and the settings available for resilient workflows are covered in [Workflow Settings](settings.md).


### Unavailable Variables and the `let` Nullish Check

To guard against mistakes in variable names or state, workflow execution will typically throw an error if
a referenced variable is unavailable or null, including access to a sensor which has not yet been published.
There are three exceptions:

* the `let` step supports the "nullish coalescing" operator `??` for this case, as described below below
* the `wait` step or `transform ... | wait` will block until a value becomes available,
  such as using `${entity.attributeWhenReady.SENSOR_NAME}`.
* `condition` entries can reference a null or unavailable value in the `target`,
  and check for absence using `when: absent_or_null`

Where it is necessary to consider "nullish" values -- variables which are either null or not yet available --
the "nullish coalescing" operator `??` can be used within `let` statements:

```
- let x = ${entity.sensor.does_not_exist} ?? "unset"
```

This will set `x = unset`, assuming there is no sensor `does_not_exist` (or if that sensor is `null`).

A limited number of other operations is also permitted in `let`,
namely the basic mathematical operands `+`, `-`, `*`, and `/` for integers and doubles, 
and the modulo operator `%` for integers giving the remainder.
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


### Interpolating Objects and Strings

Shorthand form is designed primarily for simple strings as the data. To pass more complex objects or control
the quotes, longhand form (map) is recommended, and it may be helpful to convert complex objects to strings
in a previous step using e.g. `let string map_s = ${map}`.

It is possible to embed strings with spaces, quotes, and complex types as shorthand, but care must be taken
and if doing this, it is helpful to understand the parsing process.
Shorthand will normally groups things using quotation marks, single or double, provided the quoted string is surrounded
by whitespace or an end-of-line, and will remove these outermost quotes and standardize whitespace not in the quotes.
Thus it is technically possible to set a workflow variable `a b` using
`let "a b" = 1`, although it is not recommended, and because the expression syntax doesn't allow spaces,
there is no way to access such a variable!
The one case where quotes are not stripped by the shorthand processor is when the step's
final argument accepts multiple words, such as after the `=` in `set-sensor` or `ssh <command>`;
if the final multi-word groups argument is one entire quoted string, it is unwrapped,
but otherwise its quotes are respected.  This allows `ssh bash -c 'echo hi'` to pass the quotes,
and also allows it to be written `ssh 'bash -c "echo hi"'` or `ssh 'bash -c \'echo hi\''`,
with the outer quotes removed.
The syntax is optimized to be as intuitive as possible in common cases,
although it does get complicated at the margins; for example `log "hello world"` prints `hello world` (quotes unwrapped) but 
`log "hello" "world"` prints `"hello" "world"` (quotes preserved).
If in doubt, you can always write `log "\"hello\" \"world\""` or `log '"hello" "world"'`.
It is suggested to follow the examples and do testing, use longhand, and review these notes only 
if particularly interested or uncertain about quotes.

Variable expansion occurs whenever `${var}` is used, expanding to the value of `var` as described above.
If matching a shorthand variable on its own, then the type of the value is preserved,
but if embedded in a larger word, simple values (numbers and booleans) will be converted to strings
but complex types will give an error, as will null or absent variables.
Thus if we run `let integer val = 1` then `set-sensor s1 = val is ${val}` or `set-sensor s1 = "val is ${val}"`,
the string `val is 1` will be set as the sensor `s1`; however `set-sensor s1 = ${val}` will emit the integer `1`.
If `val` is a map, then the last form will preserve the map, but the other two, including it in `val is ${val}`,
will throw an error.

It can be helpful to use the `let` command to coerce data to the write format in a new variable
or to handle potentially unset values; for example `let json string val_json = ${val}` to create a string
`val_json` representing the JSON encoding of `val`, or even `"let map x = { a: 1 }"` for simple unambiguous map expressions,
where the string `{ a: 1 }` is converted to a map, but noting that YAML requires any string with `:` to be quoted in its entirety,
and the YAML parse will unwrap it before passing to the shorthand processor.
The longhand form, e.g. `{ step: "let x", value: { a: 1 } }`, can be used for potentially ambiguous values or for clarity.

The `let` step has some special behavior. It can accept `yaml` and, when converting to complex types,
will strip everything before a `---` document separator.  Thus a script can have any output, so long as it
ends with `---\n` followed the YAML to read in, then `let yaml fancy-bean = ${stdout}` will convert it to
a registered type `fancy-bean`. It will be an error if `stdout` is not coercible to `fancy-bean`.

Another special behavior of `let` is that its `value` is reprocessed, supporting arithmetic as described elsewhere,
and also unwrapping quoted words in the value (removing quotes) _without_ evaluating expressions within them.
This is the only way to embed `${...}` expressions in a value, and can simplify other places where quotation marks
and spaces are needed. Thus given the steps:

```
- let msg = "${person}" is ${person}
- log ${msg}
```

Brooklyn will log `${person} is { name: "Bob", age: 42 }`.

It is also possible to use longhand syntax `{ type: set-sensor, sensor: x, value: value }` 
or a hybrid syntax `{ step: set-sensor x, value: value }`, 
which can be useful for complex types and bypassing the shorthand processor's unquoting strategy,
but in this case note that YAML processing will unwrap quotes.


### Advanced Details

If unusual behaviour is encountered with encoding and resolving expressions, a few simple tips can often help:

* Use the longhand (map) format for steps if using complex types or strings
* Use `let` with coercion, trim, and YAML/JSON options for fine-grained control and visibility of the output
* Remember thay YAML parsing will also remove strings; where quotes need to be included, the YAML `|` marker,
  followed by the content on the following line, is a good pattern

In rare cases it can be useful to understand some of the advanced nuances. These are described below.

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
