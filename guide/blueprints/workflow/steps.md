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

**Output return value**: the output from the previous step, or null if this is the first step


### clear-sensor

Clears the value of a sensor on an entity.

**Shorthand**: `clear-sensor [TYPE] SENSOR_NAME`

**Input parameters**:
* `sensor`: a string being the sensor name or a map containing the `name` and 
  optionally the `entity` where the sensor should be cleared (defaulting to the entity where the workflow is running)

**Output return value**: the output from the previous step, or null if this is the first step


### clear-workflow-variable

Clears the value of a workflow internal variable.

**Shorthand**: `clear-workflow-variable [TYPE] VARIABLE_NAME`

**Input parameters**:
* `variable`: a string being the workflow variable name or a map containing the `name`
  of the workflow variable which should be cleared

**Output return value**: the output from the previous step, or null if this is the first step


### container

Runs a container with optional command and environment variables.

**Shorthand**: `container IMAGE [ COMMAND ]`

**Input parameters**:
* `image`: the image to run
* Optionally a command to pass to the image, at most one of:
  * `command`: a command or script as a string, to pass to bash to be run
  * `commands`: a list of commands to pass to bash to be run
  * `raw-command`: a list containing the base executable in the first entry and any arguments as additional entries
* `env`: a map of string keys with values whose JSON is taken and passed to the command be executed
* `exit-code`: the word `any`, a number, or a predicate DSL expression (e.g. `less-than: 32`)
  to require of the exit status code from the command, defaulting to `0`
* `pull-policy`: one of `IfNotPresent`, `Always`, or `Never`, whether to pull the image before running;
  defaults to `IfNotPresent`

**Output return value**:
* `stdout`
* `stderr`
* `exit_code`


### http

Sends an HTTPS (or HTTP) request and returns the response content and code.

**Shorthand**: `http ENDPOINT`

**Input parameters**:
* `endpoint`: the URL to connect to, optionally omitting the protocol and slash prefix if `https://` is intended
  (e.g. just the host and any path); per URL standard any unusual characters such as query parameters should be URL-encoded,
  so if e.g. passing parameters containing spaces, `params` should be used instead of `host/path?param=${value}`
* `query`: a map of query parameters to URL encode and add to the URL
* `body`: an object to be serialized and sent as the body (or just set as body if it is an array of bytes)
* `charset`: the character set to use to convert between byte arrays and strings for the request body and response content;
  not applied if `body` is already a byte array, and not applied to the `content_bytes` output;
  defaults to the system default
* `status-code`: the word `any`, a number, or a predicate DSL expression to require of the response status code,
  defaulting to `{ less-than: 400, greater-than-or-equal-to: 200 }`
* `headers`: a map of header key-values to set on the request
* `method`: the HTTP method for the request, defaulting to `get`
* `username` and `password`: credentials to set on the request, e.g. for Basic auth
  (other auth schemes can be implemented using `headers`)

**Output return value**:
* `status_code`: integer status code, e.g. 200
* `headers`: a map of header keys to a _list_ of values for that header on the response (as multiple values are permitted) 
* `content`: the content, converted to a string using `charset`
* `content_bytes`: the content, as a raw byte array
* `duration`: how long the request took


### invoke-effector

Invokes an effector.

**Shorthand**: `invoke-effector EFFECTOR`

**Input parameters**:
* `effector`: the name of the effector to invoke
* `entity`: optional entity or entity ID where the effector should be invoked
* `args`: map of argument names to values to pass to the effector

**Output return value**: the returned object from the invoked effector


### let

An alias for `set-workflow-variable`.

**Shorthand**: `let [ "trimmed" ] [ TYPE ] VARIABLE_NAME = VALUE`


### log

Logs a message.

**Shorthand**: `log MESSAGE`

**Input parameters**:
* `message`: the message to be logged

**Output return value**: the output from the previous step, or null if this is the first step


### no-op

Does nothing. It is mainly useful when setting a `next` point to jump to,
optionally with a `condition`.

**Shorthand**: `no-op`

**Input parameters**: _none_

**Output return value**: the output from the previous step, or null if this is the first step


### return

Returns an indicated value and specifies that the workflow should end,
essentially equivalent to `{ type: no-op, output: VALUE, next: end }`.

**Shorthand**: `return VALUE`

**Input parameters**:
* `value`: the value to return

**Output return value**: the value indicated 


### set-config

Sets the value of a config key on an entity.

**Shorthand**: `set-config [TYPE] CONFIG_KEY_NAME = VALUE`

**Input parameters**:
* `config`: a string being the config key name or a map containing the `name` and
  optionally the `type` (defaulting to the declared type of the config key, if present, or to `Object`)
  and/or the `entity` where the config should be set (defaulting to the entity where the workflow is running)
* `value`: the value to set

**Output return value**: the output from the previous step, or null if this is the first step


### set-sensor

Sets the value of a sensor on an entity.

**Shorthand**: `set-sensor [TYPE] SENSOR_NAME = VALUE`

**Input parameters**:
* `sensor`: a string being the sensor name or a map containing the `name` and
  optionally the `type` (defaulting to the declared type of the sensor, if present, or to `Object`) 
  and/or the `entity` where the sensor should be set (defaulting to the entity where the workflow is running)
* `value`: the value to set

**Output return value**: the output from the previous step, or null if this is the first step


### set-workflow-variable

Sets the value of a workflow internal variable. The step `let` is an alias for this.

**Shorthand**: `set-workflow-variable ["trimmed"] [TYPE] VARIABLE_NAME = VALUE`

**Input parameters**:
* `variable`: a string being the workflow variable name or a map containing the `name` and optionally the `type`
  to coerce (needed e.g. if you want to set a bean registered type, or in shorthand to set an `integer`)
* `value`: the value to set, with some limited evaluation as described [here](variables.md)
* `trim`: whether the value, if a string, should be trimmed after evaluation and prior to setting, as described [here](variables.md);
  this can be set from shorthand if the first word after the step type is `trimmed`

**Output return value**: the output from the previous step, or null if this is the first step


### sleep

Causes execution to pause for a specified duration.

**Shorthand**: `sleep DURATION`

**Input parameters**:
* `duration`: how long to sleep for, e.g. `5s` for 5 seconds

**Output return value**: the output from the previous step, or null if this is the first step


### ssh

Runs a command over ssh.

**Shorthand**: `ssh COMMAND`

**Input parameters**:
* `command`: the command to run
* `env`: a map of string keys with values whose JSON is taken and passed to the command be executed
* `exit-code`: the word `any`, a number, or a predicate DSL expression (e.g. `less-than: 32`)
  to require of the exit status code from the command, defaulting to `0`

[//]: # (* `endpoint`: an alternative endpoint &#40;format TODO&#41;; typically this is omitted and the SSH machine location of the entity is the target)
[//]: # (* `key`: a private key to use for the connection to the endpoint &#40;TODO, again typically embedded in the SSH machine location of the entity&#41;)

**Output return value**:
* `stdout`
* `stderr`
* `exit_code`


### winrm

Runs a command over winrm.

**Shorthand**: `winrm COMMAND`

**Input parameters**:
* `command`: the command to run
* `env`: a map of string keys with values whose JSON is taken and passed to the command be executed
* `exit-code`: the word `any`, a number, or a predicate DSL expression (e.g. `less-than: 32`)
  to require of the exit status code from the command, defaulting to `0`

[//]: # (* `endpoint`: an alternative endpoint &#40;format TODO&#41;; typically this is omitted and the SSH machine location of the entity is the target)
[//]: # (* `key`: a private key to use for the connection to the endpoint &#40;TODO, again typically embedded in the SSH machine location of the entity&#41;)

**Output return value**:
* `stdout`
* `stderr`
* `exit_code`


### wait

Waits for a value which might not yet be resolved, or a task which might not have finished,
optionally setting the value or the task's result to a workflow variable.

**Shorthand**: `wait [ [TYPE] VARIABLE_NAME = ] [MODE] VALUE`

**Input parameters**:
* `variable`: a string being the workflow variable name or a map containing the `name` and optionally the `type`
  to coerce (needed e.g. if you want to set a bean registered type, or in shorthand to set an `integer`)
* `mode`: either `expression` (the default) or `task` to treat value as a task or task ID
* `value`: the expression to wait on and optionally set

**Output return value**: the value once available if a `variable` is not being set,
or if a variable is being set either the output from the previous step or null if this is the first step


### workflow

Runs nested workflow, optionally over an indicated target.
This step type is described in more detail [here](nested-workflow.md).

**Shorthand**: not supported

**Input parameters**:
* `steps`: a list of steps to run, run in a separate context
* `target`: an optional target specifier (see below)

**Output return value**: the output from the last step in the nested workflow