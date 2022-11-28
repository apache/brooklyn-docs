---
title: Workflow Settings
layout: website-normal
---

Wherever workflows are defined, such as in [effectors, sensors and policies](defining.md) and
in [nested workflow](nested-workflow.md), there are a number of properties which can be defined.
The most common of these, `input`, `output`, and `parameters` are described in the sections above.
Some of the common properties permitted on [steps](common.md) also apply to workflow definitions,
including `condition`, `timeout`, and `on-error`.

This rest of this section describes the remaining properties for more advanced use cases 
including mutex locking and resilient workflows with replay points.


## Locks and Mutual Exclusion Behavior

In some cases, it is important to ensure that the same workflow does not run concurrently 
with itself, or more generally to assign a mutual exclusion "mutex" lock to make sure
that at most one executing instance from a group can run at any point in time.

This can be done in Apache Brooklyn by specifying `lock: LOCK-NAME` on the workflow.
The lock is scoped to the entity, and means that if a workflow instance running at the entity
enters this block, it acquires that "lock",
and no other workflow instance at the entity can enter that block
until the first one exits the block and releases the lock.
Workflow instances at the entity that seek to `lock` the same `LOCK-NAME`
will block until the lock becomes available.

For example to ensure that `start` and `stop` do not run simultaneously, we could write:

```
brooklyn.initializers:
- type: workflow-effector
  name: start
  lock: start-stop
  steps:
    - ...
- type: workflow-effector
  name: stop
  lock: start-stop
  steps:
    - ...
```

If `stop` is run while `start` is still running, or a second `start` is run,
they will not run until the first `start` completes and releases the lock.
An operator with appropriate access permissions could also manually cancel the `start`.
Details of why the effector is blocked are shown in the UI and available via the API,
as part of the workflow data.


### Example: Thread-Safe Package Management

Locks can also be used in workflow steps saved as registered types.
A good example where this is useful is when working with on-box package managers,
most of which do not allow concurrent operation.
For instance, an `apt-get` workflow step might use a lock
to ensure that multiple parallel effectors do not try to `apt-get`
on a server at the same time:

```
id: apt-get
type: workflow
lock: apt
shorthand: ${package}
parameters:
  package:
    description: package(s) to install
steps:
- type: workflow
  lock: apt-package-management
  steps:
    - ssh sudo apt-get install -y ${package}
```

A workflow can then do `apt-get iputils-ping` as a step and Brooklyn will
ensure it interacts nicely with any other workflow at the same entity.


### Advanced Implementation Details

Brooklyn guarantees that if a workflow is interrupted by server shutdown,
it will resume with that lock after startup, so it works well with `replayable: automatically`
described below.
Brookilyn does not guarantee that waiters will acquire the lock in the same order
they requested the lock, although this behavior can be constructed using a sensor that
acts as a queue.

Any `on-error` handler on the workflow with `lock` will run with the lock still acquired.

Any `timeout` period starts once the lock is acquired.

Internally, the lock is acquired by setting a sensor `lock-...` 
equal to the `${workflow.id}`, where `...` is the `LOCK-NAME`.
If a different workflow ID is indicated, the workflow will block.
The sensor will always be cleared after the workflow with the `lock` 
completes.

Thus if a workflow needs to test whether it can acquire the lock,
it can do exactly what the internal lock mechanism does:
set that sensor to its `${workflow.id}` 
with a `require` condition testing that it is blank or already held. 
This technique can also be used to specify a timeout on the lock
with a `retry`.

This can also be used to force-clear a lock, to allow another workflow to run,
either interactively using "Run workflow" in the App Inspector,
saying `clear-sensor lock-LOCK-NAME`, or as below if the lock isn't available after 1 minute.

These techniques are all illustrated in the following example:

```
- step: set-sensor lock-checking-first-example = ${workflow.id}
  require:
    any:
      - when: absent
      - equals: ${workflow.id}
        # allowing = ${workflow.id} is recommended in the edge case where the workflow is interrupted 
        # in the split-second between setting the sensor and moving to the next step;
        # a "replay-resuming" as described below will proceed in case this step has already run
  on-error:
    # retry every 10 milliseconds for up to 1 minute
    - step: retry backoff 10ms timeout 1m
      on-error: goto lock-not-available
- type: workflow
  lock: checking-first-example
  steps:
    - log we got the lock
    # ... other steps to be performed while holding the lock
# other steps to be performed after clearing the lock
  next: end
  
- id: lock-not-available
  step: log Lock not available after one minute, force-clearing it and continuing
- clear-sensor lock-checking-first-example
- goto start
```


## Resilience: Replaying and Retention/Expiry

Workflows have a small number of settings that determine how Brooklyn handles workflow metadata.  
These allow workflow details to be accessible via the API and in the UI (in addition to whatever 
is persisted in the logs) and optionally for a user to "replay" a workflow.  These are:

* **retention**: for how long after completion should details of workflow steps, input, and output be kept 
  for inspection or manual replaying
* **idempotent** (for steps):  is a step safe to re-run if it is interrupted or fails, if true implying it
  can be recovered by replaying resuming at that step
* **replayable**: from where can a retained workflow be safely replayed, such as replaying from the start 
  or from other defined explicitly defined replay points

### Common Replay Settings

Most of the time, there are just a few tweaks to `idempotent` and `replayable` needed to let Apache Brooklyn 
do the right thing to replay correctly.  These simple settings are covered first.  The other settings, 
including changing the retention, are intended for advanced use cases only.

Brooklyn workflows are designed so that most steps are automatically "idempotent":  they can safely be run multiple
times in a row, and so long as the last run is successful, the workflow can proceed. This means if a workflow is
interrupted or fails, it is safe to attempt a recovery by replaying resuming at that step. This can be used for
transient problems (e.g. a flaky network) or where an operator corrects a problem (e.g. fixes the network). It means
uncertainty about whether the step completed or not can be ignored, and the step re-run if in doubt. Instructions such
as "sleep", "set-config", or "wait for sensor X to be true" are obviously idempotent; it also applies to `let` because
Brooklyn records a copy of the value of workflow variables on entry to each step and will restore them on a replay.

However, for some step types, it is impossible for Brooklyn to infer whether they are idempotent:  this applies to 
"external" steps such as `http` and `ssh`, and some `invoke-effector` steps.
It can also be the case that even where individual steps are idempotent, a
sequence of steps is not. In either of these cases the workflow author should give instructions to Brooklyn about how
to "replay".

There are two common ways for an author to let Apache Brooklyn know how to replay:

* individual steps that are idempotent but not obviously so can be marked explicitly as such with **`idempotent: yes`**; 
  for example a read-only http or container command

* explicit "replayable waypoints" can be set with a step **`workflow replayable from here`** to indicate the workflow can be
  replayed from that point, either manually or automatically; if any step is not idempotent, a "replay resuming" request
  will replay from the last such waypoint; this might be a `retry` step in the workflow, on failover with
  a `replayable: automatically` instruction, or a manual request from an operator; if waypoints are defined, operators
  will also have the option to select a waypoint to replay from

An example of a non-idempotent step is a container which calls `aws ec2 run-instances`; this might fail after the
command has been received by AWS, but before the response is received by Brooklyn, and simply re-running it in this case
would cause further new instances to be created. The solution for this situation is to have a sequence of steps which
creates a unique identifier for the request (setting this as a tag), then scans to discover any instances with a
matching tag, calling `run-instances` only if none are found, and then to wait on the instances just created or
discovered. An author can specify `replayable from here` just after the unique identifier is created, so if the workflow
is subsequently interrupted on `run-instances` it will replay from the discovery.

This is also an example where a sequence of individually idempotent steps is not altogether idempotent; 
once a unique identifier has been used in a subsequent step, it would be invalid to create a new unique identifier. 
Defining the replay point immediately after this step is a good solution, because Brooklyn's "replay resuming" 
will only ever run from the last executed step if that step is idempotent, or from the last explicit `replayable from here` point. 
(Alternatively the unique identifier step
could use `${entity.id}` rather than something random, or store the random value in a sensor with a `require`
instruction there to ensure it is only ever created once per entity.)

Where an external step is known to be idempotent -- such as a `describe-instances` step that does the discovery, or any
read-only step -- the step can be marked `idempotent: yes` and Brooklyn will support replay resuming at that step.  (
However here, and often, this is unnecessary, if the nearest "replay point" is good enough.)

The internal steps `workflow` and `invoke-effector` are by default considered idempotent 
if Brooklyn can tell they are running nested workflows at idempotent step. 
All other internal steps are idempotent.
Actions such as `deploy-application` use special techniques internally to guarantee idempotency.

In some cases, it can be convenient to indicate default replayable/idempotency instructions when defining a workflow. As
part of any workflow definition, such as `workflow-effector` or a nested `type: workflow` step, the
entry `idempotent: all` indicates that all external steps in the workflow are idempotent; `replayable: automatically`
indicates that an automatic `on-error` handler should resume any workflow interrupted by a Brooklyn server restart or
failover; and `replayable: from start` indicates that the start of the workflow is a replay point.

Thus by default, most steps will allow a manual "replay resuming" picking up at the step that was last run. However
without a `retry replay` step (such as in an error handler), this will not happen automatically, and some steps,
external ones (which are often the ones most likely to fail), cannot safely permit a "replay resuming" and so require
extra attention. The following is a summary of the common settings used:

* as a step
  * **`workflow replayable from here`** to indicate that a step is a valid replay point,
    with the option of appending the word **`only`** at the end to clear other replay points
* on a step
  * **`idempotent: yes`** to indicate that if the workflow is interrupted or fails at that step, it can be resumed at that step (only needed for external steps which are not automatically inferrable as idempotent)
    when defining a workflow
  * **`replayable: from start`** to indicate that the start of the workflow is a valid replay point
  * **`replayable: automatically`** to indicate that on an unhandled Brooklyn failover (DanglingWorkflowException), the workflow should attempt to "replay resuming", either from the last executed step if it is resumable, or from the last replay point
  * **`idempotent: all`** to indicate that all steps are idempotent and if interrupted there, the workflow can resume there,
    unless explicitly indicated otherwise
    (by default steps such as `http` and `container` are not; only internal steps known to be safely re-runnable are resumable)

Finally, it is worth elaborating the differences between the three types of retry behavior, as described on the `retry` step:

* A "replay resuming" attempts to resume flow at the last incomplete executed step. If that step is idempotent, it is
  replayed with special arguments to resume where it left off:  this means skipping any `condition` check, using the
  workflow variables as at that point, using any previous resolved values for input, and if the step launched
  sub-workflows (such as `workflow` or `switch`, or an `invoke-effector` calling directly to a workflow effector), those
  sub-workflows are resumed if possible. If the step is not idempotent, it attempts to "replay from" the last replayable
  step, which might be the same step, but the condition and inputs will be re-evaluated. If there is no last replayable
  step, it will fail.

* A "replay from" looks at a given step to see if it is replayable, and if not, searches the flow backwards until it
  finds one. If there are none, or it cannot backtrack, it will fail. If it finds one, execution replays from that step,
  using the workflow variables as they were at that point, but re-checking any condition, re-evaluating inputs, and
  re-creating any sub-workflows.

* A `retry` step can specify `replay` and/or a `next` step. If a `next` step is specified without `replay`, it will do a
  simple `goto` to that step and so will use the most recent value of workflow variables. In all other cases it will do
  some form of replay:  if `replay` with `next` is specified, it will replay from that point, with `last` an alias for
  the last replay point and `end` an alias for replay resuming; if `replay` is specified without `next`, it will replay
  from the last replay point; if neither `next` nor `replay` is specified, it will replay resuming where that makes
  sense (in an error handler) and otherwise replay from `last`. In all cases, `retry` options including `limit`
  and `backoff` are respected.

Only `replay` is permitted through the API or UI, either "from" a specific step, from "start", from the "last"
replayable step, or resuming from the "end". Users with suitable entitlement also have the ability to `force` a replay
from a given step or `resuming`, which will proceed irrespective of the `idempotent` or `replayable` status of the step.


#### Example: Mutex Atomic Increment

Consider an atomic increment:

```
- let x = ${entity.sensor.count}
- step: let x = ${x} + 1
  replayable: from here only
- set-sensor count = ${x}
```

If this is interrupted on step 3 after setting the sensor, a replay from start will
retrieve the new sensor value and increment it again. By saying `here only` on step two,
we remove all previous workflow points and ensure the workflow is only ever replayed
from the one safe place.

The above assumes no other instances of workflow might use the sensor;
if two workflows run concurrently they both might get the same initial value of `count`,
so the result would be a single increment.
Wrapping this in a workflow with a `lock` block as described above will prevent this problem,
with Apache Brooklyn ensuring that on interruption the workflow with the lock
is replayed first. Again we need to set a replay point before the incremented value is written,
and for good measure we put a replay point after the sensor is updated.

```
- type: workflow
  lock: single-entry-workflow-incrementing-count
  replayable: from start
  steps:
    # ... various steps
    - let x = ${entity.sensor.count} ?? 0
    - step: let x = ${x} + 1
      replayable: from here only       # do not allow replays from the start
    - set-sensor count = ${x}
    - workflow replayable from here    # could say only, but previous replay point also okay
    # ... various steps
  on-error:
    - retry limit 2 in 5s              # allow it to retry replaying on any error
                                       # (if we just wanted Brooklyn server failover errors to recover,
                                       # we could have said `replayable: automatically from start`)
```


### Advanced:  Replay/Resume Settings

There are additional options for `idempotent` and `replayable` useful in special cases, and the `retention` can be
configured. As noted above, this section and the next can be skipped on first reading and returned to if there are
complicated replay or retention needs.

* **`idempotent`**
  * when defining a workflow, as `idempotent: <value>`
    * **`all`**: means that all external steps in this workflow will be resumable unless explicitly declared otherwise (
      by default, per below, external steps are not resumable); this includes steps in explicit sub-workflows (where the
      workflow definition has a `workflow` with `steps`) but not sub-workflows which are references (effectors or
      registered workflow types)
  * on a step as a key, as `idempotent: <value>`
    * **`yes`**:  the step is idempotent and the workflow can replay resuming at this step if interrupted there
    * **`no`**: the step is not idempotent and should not resumed at this step; if interrupted there, replay resuming
      will start from the previous replay point
    * **`default`** (the default):  `no` for `fail` (because there is no point in resuming from a `fail` step), `no` for
      external steps (eg http, ssh) except where the surrounding workflow definition is `all`, computed based on the
      state of sub-workflows if at a workflow step, and `yes` otherwise

* `replayable`
  * when defining a workflow, as `replayable: <value>`
    * **`enabled`** (the default):  is is permitted to replay resuming wherever the workflow fails on idempotent steps
      or where there are explicit replay points
    * **`disabled`**:  it is not permitted for callers to replay the workflow, whether operator-driven or automatic;
      resumable steps and replay points in the workflow are not externally visible (but may still be used by replays
      triggered within the workflow)
    * **`from start`**:  the workflow start is a replay point
    * **`automatically`**: indicates that on an unhandled Brooklyn failover (DanglingWorkflowException), the workflow
      should attempt to replay resuming; implies `enabled`, can be combined with `from start`
  * as a step, as `workflow replayable <value>` (or `{ type: workflow, replayable: <value> }`)
    * **`reset`**:  to invalidate all previous replay points in the workflow
    * **`from here`**:  this step is a valid replay point; on workflow failure, any "retry replay" or "resumable:
      automatically" handler will replay from this point if the workflow is non-resumable; operators will have the
      option to replay from this point
    * **`from here only`**:  like a `reset` followed by a `from here`
  * on a step, as a key
    * **`from here`** or `from here only`:  as for `workflow replayable`
  * on workflow step with sub-steps, as a key
    * any of the key values for defining a workflow, with their semantics applied to the nested workflow(s)
      only (`replayable: disabled` is equivalent to `idempotent: no` and will override an `idempotent: yes` there)
    * any of the key values for a step, with semantics applied to the containing workflow


# Advanced:  Retention Settings

Apache Brooklyn stores details of workflows as part of its persistence while a workflow is executing and for a
configurable period of time after completion. This allows workflows to be resumed even in the case of a Brooklyn server
restart or failover, and it allows operators to manually explore or replay workflows for as long as they are retained.

If needed, it is possible to specify that a workflow should be kept for a period of time (including `forever`) or up to
a maximum number of invocations. The specification can also refer to the loosest ("max") or tightest ("min") of a list
of values. This can be set as part of a workflow's definition, where some workflows are more interesting than others,
and/or as part of a workflow step, if the retention period should be changed depending how far the workflow progresses.

Where not explicitly set, a system-wide retention default is used. This can be configured in `brooklyn.properties` using
the key `workflow.retention.default`. If no supplied, Brooklyn defaults to `3`, meaning it will keep the three most
recent invocations of a workflow, with no time limit, and

Workflow retention is done on a per-entity basis based by default on a hash of the workflow name. Typically workflow
definitions for effectors, sensors, and policies all get unique names for that definition, so the retention applies
separately to each of the different defined workflows on an entity. However each definition typically assigns the same
name to each instance, so any retention count limit applies to completed runs in that group of workflows.
Thus `any(2, 24h)` on an effector will keep all runs for 24 hours but only the 2 most recent completed invocations for
longer, in addition to ongoing instances.

A custom `hash` can be specified for a workflow to use a key different to the name. This can be used to apply the
retention limit to instances across multiple workflow definitions, for instance if only the last 2 of any start, stop,
or restart command should be kept, the instruction `retention: 2 hash start-stop` can be included in the definition for
each of the start, stop, and restart workflows. This can also be used to specify that a workflow might go into different
retention classes depending where it is in its execution; if workflow failures should be kept for longer, the `fail`
step might say `retention: forever hash ${workflow-name} failed`, causing the workflow to be retained with a different
hash ("<name> failed") and for it to apply a different period ("forever") when it checks expiry on that hash.

Formally, the syntax for `retention` is:

* when defining a workflow, as `retention: <value>`
* as a step, as `workflow retention <value>` (or `{ type: workflow, retention: <value> }`)

Permitted `<value>` expressions in either case are:

* a number, to indicate how many instances of a workflow should be kept
* a duration, to indicate for how long workflows should be kept
* `forever`, to never expire
* `context`, to use the previous retention values (often used together with `max`)
* `parent`, to use the value of any parent workflow or else the system default; this is the default for workflows,
  they inherit their parent workflow's retention if it is a nested workflow, otherwise it takes the system default
* `system`, to use the system default (from `brooklyn.properties`)
* `min(<value>, <value>, ...)` or `max(<value>, <value>, ...)` where `<value>` is any of the expressions on this line or above 
  (but not `disabled` or `hash`); in particular a `max` or a `min` or vice versa is useful, and also to refer to the `parent` value
  * `min` means completed workflow instances must only be retained if they meet all the constraints implied by
    the `<value>` arguments, i.e. `min(2, 3, 1h, 2h)` means only the most recent two instances need to be kept and only
    if it has been less than an hour since they completed
  * `max` means completed workflow instances must be retained if they meet any of the constraints implied by
    the `<value>` arguments, i.e. `max(2, 3, 1h, 2h)` means to keep the 3 most recent instances irrespective of when
    they run, and to keep all instances for up to two hours
* `disabled`, to prevent persistence of a workflow, causing less work for the system where workflows don't need to be
  stored; such workflows will not be replayable by an operator or recoverable on failover;
  this should not be used with workflows that acquire a `lock` unless the entity has special handlers to clear locks
* `hash <hash>` to change the retention key; useful if some instances of a workflow should be kept for a longer duration
  than others; unlike most values, this can be a `${...}` variable expression;
  this can optionally be preceded by any of the other <value> expressions listed


### Advanced Example

This defines an effector with idempotent workflow that can be replayed from most steps, and from the beginning if
failing on a step which isn't resumable, and details of the last 5 invocations will always be kept, and all invocations
in the past 24 hours will be kept:

```
brooklyn.initializers:
- type: workflow-effector
  retention: max(24h,5)
  replayable: yes
  steps:
    - ...
```

As a more interesting example, consider provisioning a VM where approval is needed and where unlike the `aws` case
above, tags cannot be used to make the actual call idempotent. The call to the actual provisioner needs to fail hard so
an operator can review it, but the rest of the workflow should be as robust as possible.  (Of course it is recommended
to try to make workflows idempotent, as discussed in this section, but in some cases that may be difficult.)
Specifically here, any cancellation or failure prior to sending the request might be uninteresting for operators and
fine for a user to replay; however once provisioning begins, all details should be kept, and the provisioning step
itself should not be replayable; finally once the machine details are known locally it is no longer important to keep
workflow details. In this case the workflow might look like:

```
type: workflow
retention: max(context,6h)   # keep all for at least 6h, and longer/more if parent or system workflow says so
replayable: from start       # allow replay from the start (until changed)
on-error:
- retry limit 10    # automatically replay on any error (unless no replay points)
  steps:

# get and wait for approval
- http approvals.acme.com/request/infrastructure/vm?<details_omitted>
- let request_id = ${content.request_id}
- id: wait_for_approval
  step: http approvals.acme.com/check?request_id=${request_id}
  # assume returns a map { completed: boolean, approved: boolean, details: string }
- step: retry from wait_for_approval limit 7d backoff 10s increasing 2x up to 5m
  condition:
    target: ${content.completed}
    when: falsy
- step: fail message Provisioning request denied by approvals system: ${content.details}
  # the 'fail' step type is not resumable so replay will not be permitted here,
  # but it would be allowed from the start, so we have to disable it
  replayable: reset
  condition:
    target: ${content.approved}
    not:
      equals: true

# now provision, don't allow replays and keep details for cleanup
- workflow replayable reset
- workflow retention forever
- http cloud.acme.com/provision/vm?<details_omitted>
# once the request is made we can allow replays again
# but continue to keep details for cleanup
- workflow replayable from here
- let provision_id = ${content.provision_id}
- http cloud.acme.com/check?provision_id=${provision_id}
  # assume returns a map with { completed: boolean, id: string, ip_address: string }
- step: retry limit 1h backoff 10s increasing 2x max 1m
  condition:
    target: ${content.completed}
    equals: false
- set-sensor vm_id = ${content.id}
- set-sensor ip_address = ${content.ip_address}

# finally restore default retention per parent or system, as details are now stored on the entity
- workflow retention parent
```

