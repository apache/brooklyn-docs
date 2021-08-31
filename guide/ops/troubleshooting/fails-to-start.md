---
layout: website-normal
title: "Brooklyn Fails to Start"
toc: /guide/toc.json
---

If Apache Brooklyn does not start, or starts with errors, the problem is usually easy to resolve.
The first place to look is the [logs](/guide/ops/logging.html):  `grep` for the first `ERROR`,
and sometimes look backwards for the first `WARN` message.

There are a handful of common causes.

## Memory

If there is not enough memory available either on the system or for the software, it will have problems.
This may manifest itself as the process being killed, e.g. if the OS does not have enough memory
(and there will usually be a message in the system log, e.g. `/var/log/syslog`);
or some modules failing to load with an `OutOfMemoryException` in the log.

If either of these occurs, you can assign additional memory if available on your system 
by editing the files in `bin/`, such as `JAVA_MAX_MEM` in `setenv` (or `setenv.bat` on Windows),
or by running Apache Brooklyn on a system with more memory.


## Rebind Errors

It is possible to get the persistent state into an incompatible state, where Apache Brooklyn
cannot load its previous state. In this case it fails fast so as not to corrupt the state further.
In addition, a backup of the persistent state will be written to the `backups/` folder in
the persistent state directory.

The log files contain detailed information about what is unable to be loaded and why;
some causes include:

* A type that is deployed is no longer available, e.g. because a `SNAPSHOT` bundle was installed,
  say with a type `X`, the type `X` is used in an active deployment, and then the bundle
  was either uninstalled or a new version installed at the same version (for `SNAPSHOT` or forced)
  that did not contain the type in use (`X`)

* A deployment did not correctly clean up and leaked resources;
  this will happen only with Java entities or adjuncts that are incorrectly unmanaged

* A dependency is unavailable, possibly because it was added via the `dropins/` folder or
  is not installed in the Brooklyn instance being started

There are some good practices which can help avoid these errors:

* Avoid the use of `SNAPSHOT` bundles in production (and do not `force` install bundles)
* If `SNAPSHOT` bundles are updated in an incompatible way in a dev environment (eg blueprint name change), 
  take care to remove pre-existing incompatible deployments 
* When upgrading or restarting Brooklyn, it is recommended to start a second instance as hot-standby first: 
  this will flag the issue that there is an existing deployment which cannot be re-read on a clean start, 
  and it can be removed from the primary Brooklyn

If a rebind problem does occur, all is not lost.  There are several ways that recovery can be achieved:

* Delete the incompatible persisted state item files indicated in the logs
  (or simply delete all the persisted state in a dev environment)
* Restore to a previous backup state (automatically written to the `backups/` folder with a datestamp)
* Tell Brooklyn to ignore a certain number of rebind errors with settings in `brooklyn.cfg`:
  * `rebind.failureMode.danglingRefs.minRequiredHealthy`: takes `QuorumCheck` syntax, consisting
    of points on a line, e.g. `[[0,0],[10,5],[20,14]]` to allow up to 1 failure for every 2 items up to 10 items
    (5 needed when 10 items are persisted, per the second point), then subsequently 1 failure for every additional 10 items deployed
    (14 needed when 20 items are persisted, per the third point)
  * `rebind.failureMode.rebind`: either `FAIL_FAST`, `FAIL_AT_END`, or `CONTINUE`, for how to treat serious rebind problems
    (default `FAIL_AT_END`)
  * Further options available as per the JavaDoc on `RebindManagerImpl` config keys
* When Brooklyn is stopped, remove the persisted state; then restart in a pristine environment, install any missing bundles,
  then import the offending persistent state via the UI (About) or REST API;
  alternatively in some cases it may be possible to add additional/missing bundles via the `dropins/` folder of Karaf 
  or using the `karaf` console (`bundle:install -s ...`)
* If the broken persisted state is critical, it is possible to edit them:  they are simply an XML model of the items
  using a lot of unique identifiers designed so that references can be easily found using `grep`
* Finally, if all else fails, open a support ticket:  there are a number of other advanced techniques available,
  such as specifying that types should be automatically renamed or migrated by new bundles ([see the Persistence section here](../upgrades/)).

It may also be useful to review the sections on [Persistence](../persistence/) and [HA](../high-availability/).




