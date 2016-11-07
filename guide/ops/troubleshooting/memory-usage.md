---
layout: website-normal
title: "Troubleshooting: Monitoring Memory Usage"
toc: /guide/toc.json
---

## Memory Usage

Brooklyn tries to keep in memory as much history of its activity as possible,
for displaying through the UI, so it is normal for it to consume as much memory
as it can.  It uses "soft references" so these objects will be cleared if needed,
but **it is not a sign of anything unusual if Brooklyn is using all its available memory**.

The number of active tasks, CPU usage, thread counts, and 
retention of soft reference objects are a much better indication of load.
This information can be found by looking in the log for lines containing
`brooklyn gc`, such as:

    2016-09-16 16:19:43,337 DEBUG o.a.b.c.m.i.BrooklynGarbageCollector [brooklyn-gc]: brooklyn gc (before) - using 910 MB / 3.76 GB memory; 98% soft-reference maybe retention (of 362); 35 threads; tasks: 0 active, 2 unfinished; 31 remembered, 1013 total submitted) 

The soft-reference figure is indicative, but the lower this is, the more
the JVM has decided to get rid of items that were desired to be kept but optional.
It only tracks some soft-references (those wrapped in `Maybe`),
and of course if there are many many such items the JVM will have to get rid
of some, so a lower figure does not necessarily mean a problem.
Typically however if there's no `OutOfMemoryError` (OOME) reported,
there's no problem.

If you are concerned about memory usage, or doing evaluation on test environments, 
the following method (in the Groovy console) can be invoked to force the system to
reclaim as much memory as possible, including *all* soft references:

    org.apache.brooklyn.util.javalang.MemoryUsageTracker.forceClearSoftReferences()

If things are happy usage should return to a small level.  This is quite disruptive
to the system however so use with care.

The above method can also be configured to run automatically when memory usage 
is detected to hit a certain level.  That can be useful if external policies are
being used to warn on high memory usage, and you want to keep some headroom.
Many JVM references discourage interfering with its garbage collector, however,
so use with care and study the particular JVM you are using.
See the class `BrooklynGarbageCollector` for more information.


## Investigation of Memory Leaks

Design problems of course can cause memory leaks, and due to the nature of the
soft references these can be difficult to notice until they are advanced.
If the "soft-reference maybe retention" starts to decrease, that can be
an early warning.

Common problems such as runaway tasks and cyclic dependent configuration will often
show their own log errors, so also look for these if there is a performance or memory problem.

You should also note the task counts in the `brooklyn gc` messages described above,
and if there are an exceptional number of tasks or tasks are not clearing,
other log messages will describe what is happening, and the in-product task
view can indicate issues.  `jstack` can also be useful if it is a task problem.

Sometimes slow leaks can occur if blueprints do not clean up entities or locations.
These can be diagnosed by noting the number of files written to the persistence location,
if persistence is being used.  Deploying then destroying a blueprint should not leave
anything behind in the persistence directory.

More subtle problems can occur and these can be more difficult to pin down.
Where these have been encountered, we have tried to improve logging and early identification,
so please do ask what other log `grep` patterns can be useful in certain situations.
And if you find issues, let us know so we can add them to what we monitor.

If there's a problem you really can't solve, a memory profiler such as VisualVM or Eclipse MAT 
is the standard way to investigate.  If a heap dump was generated on the OOME
(most JVMs can be configured to generate that), 
the profiler can load it and investigate the state of the system.
These can also connect to running systems and be used to investigate instances and growth.

Monitoring these systems while live can be difficult because
it will often include many soft and weak references that mask the
source of a leak.  Common such items include:

* `BasicConfigKey` (used for the web server and many blueprints)
* `DslComponent` and `*Task` (used for Brooklyn activities and dependent configuration)
* `jclouds` items including `ImageImpl` (to cache data on cloud service providers)

On the other hand any of the above may also indicate a leak.
Taking snapshots after a `forceClearSoftReferences()` (above) invocation and comparing those
is one technique to filter out noise.  Another is to wait until there is an OOME
and look just after, because that will clear all non-essential data from memory.
(The `forceClearSoftReferences()` actually works by triggering an OOME, in as safe 
a way as possible.)

If leaked items are found, the profiler will normally let you see their content
and walk backwards along their references to find out why they are being retained.

