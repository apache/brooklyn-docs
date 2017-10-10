---
layout: website-normal
title: "Troubleshooting: Monitoring Memory Usage"
toc: /guide/toc.json
---
# {{ page.title }}

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


## Problem Indicators and Resolutions

Two things that *do* normally indicate a problem with memory are:

* `OutOfMemoryError` exceptions being thrown
* Memory usage high *and* CPU high, where the CPU is spent doing full garbage collection

One possible cause is the JVM doing a poorly-selected GC strategy,
as described in [Oracle Java bug 6912889](http://bugs.java.com/bugdatabase/view_bug.do?bug_id=6912889).
This can be confirmed by running the "analyzing soft reference usage" technique below;
memory should shrink dramatically then increase until the problem recurs.
This can be fixed by passing `-XX:SoftRefLRUPolicyMSPerMB=1` to the JVM,
as described in [Brooklyn issue 375](https://issues.apache.org/jira/browse/BROOKLYN-375).

Other common JVM options include `-Xms256m -Xmx1g`
(depending on JVM provider and version) to set the right balance of memory allocation.
In some cases a larger `-Xmx` value may simply be the fix
(but this should not be the case unless many or large blueprints are being used).

If the problem is not with soft references but with real memory usage,
the culprit is likely a memory leak, typically in blueprint design.
An early warning of this situation is the "soft-reference maybe retention" level decreasing.
In these situations, follow the steps as described below for "Investigating Leaks".


## Analyzing Soft Reference Usage

If you are concerned about memory usage, or doing evaluation on test environments, 
the following method (in the Groovy console) can be invoked to force the system to
reclaim as much memory as possible, including *all* soft references:

    org.apache.brooklyn.util.javalang.MemoryUsageTracker.forceClearSoftReferences()

In good situations, memory usage should return to a small level.  
This call can be disruptive to the system however so use with care.

The above method can also be configured to run automatically when memory usage 
is detected to hit a certain level.  That can be useful if external policies are
being used to warn on high memory usage, and you want to keep some headroom.
Many JVM authorities discourage interfering with its garbage collector, however,
so use with care and study the particular JVM you are using.
See the class `BrooklynGarbageCollector` for more information.


## Investigating Leaks

If a memory leak is found, the first place to look should be the WARN/ERROR logs.
Many common causes of leaks, including as runaway tasks and cyclic dependent configuration,
will show their own log errors prior to the memory error.

You should also note the task counts in the `brooklyn gc` messages described above,
and if there are an exceptional number of tasks or tasks are not clearing,
other log messages will describe what is happening, and the in-product task
view can indicate issues. 

Sometimes slow leaks can occur if blueprints do not clean up entities or locations.
These can be diagnosed by noting the number of files written to the persistence location,
if persistence is being used.  Deploying then destroying a blueprint should not leave
anything behind in the persistence directory.

Where problems have been encountered in the past, we have resolved them and/or
worked to improve logging and early identification.
Please report any issues so that we can improve this further.
In many cases we can also give advice on what other log `grep` patterns can be useful.


### Standard Java Techniques

Useful standard Java techniques for tracking memory leaks include:

* `jstack <pid>` to see what tasks are running
* `jmap -histo:live <pid>` to see what objects are using memory (see below)
* Memory profilers such as VisualVM or Eclipse MAT, either connected to a running system or
  against a heap dump generated on an OOME

More information is available on [the Oracle Java web site](https://docs.oracle.com/javase/7/docs/webnotes/tsg/TSG-VM/html/memleaks.html).

Note that some of the above techniques will often include soft and weak references that are irrelevant
to the problem (and will be cleared on an OOME). Objects that may be cached in that way include:

* `BasicConfigKey` (used for the web server and many blueprints)
* `DslComponent` and `*Task` (used for Brooklyn activities and dependent configuration)
* `jclouds` items including `ImageImpl` (to cache data on cloud service providers)

On the other hand any of the above may also indicate a leak.
Taking snapshots after a `forceClearSoftReferences()` (above) invocation and comparing those
is one technique to filter out noise.  Another is to wait until there is an OOME
and look just after, because that will clear all non-essential data from memory.
(The `forceClearSoftReferences()` actually works by triggering an OOME, in as safe 
a way as possible.)

If leaked items are found, a profiler will normally let you see their content
and walk backwards along their references to find out why they are being retained.


### Summary of Techniques

The following sequence of techniques is a common approach to investigating and fixing memory issues:

* Note the log lines about `brooklyn gc`, including memory and tasks
* Do not assume high memory usage alone is an error, as soft reference caches are deliberate; 
  use `forceClearSoftReferences()` to clear these
* Note any WARN/ERROR messages in the log
* Tune JVM memory allocation and GC
* Look for leaking locations or references by creating then destroying a blueprint
* Use standard JVM profilers
* Inform the Apache Brooklyn community


