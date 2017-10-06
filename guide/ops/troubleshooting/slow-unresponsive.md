---
layout: website-normal
title: Brooklyn Slow or Unresponsive
toc: /guide/toc.json
---

There are many possible causes for a Brooklyn server becoming slow or unresponsive. This guide 
describes some possible reasons, and some commands and tools that can help diagnose the problem.

Possible reasons include:

* CPU is max'ed out
* Memory usage is extremely high
* SSH'ing is very slow due (e.g. due to lack of entropy)
* Out of disk space

See [Brooklyn Requirements]({{ book.path.guide }}/ops/requirements.html) for details of server 
requirements.


## Machine Diagnostics

The following commands will collect OS-level diagnostics about the machine, and about the Brooklyn 
process. The commands below assume use of CentOS 6.x. Minor adjustments may be required for
other platforms.


#### OS and Machine Details

To display system information, run:

```bash
uname -a
```

To show details of the CPU and memory available to the machine, run:

```bash
cat /proc/cpuinfo
cat /proc/meminfo
```


#### User Limits

To display information about user limits, run the command below (while logged in as the same user
who runs Brooklyn):

```bash
ulimit -a
```

If Brooklyn is run as a different user (e.g. with user name "adalovelace"), then instead run:

```bash
ulimit -a -u adalovelace
```

Of particular interest is the limit for "open files".

See [Increase System Resource Limits]({{ book.path.guide }}/ops/troubleshooting/increase-system-resource-limits.html) 
for more information.


#### Disk Space

The command below will list the disk size for each partition, including the amount used and 
available. If the Brooklyn base directory, persistence directory or logging directory are close 
to 0% available, this can cause serious problems:

```bash
df -h
```


#### CPU and Memory Usage

To view the CPU and memory usage of all processes, and of the machine as a whole, one can use the 
`top` command. This runs interactively, updating every few seconds. To collect the output once 
(e.g. to share diagnostic information in a bug report), run:
 
```bash
top -n 1 -b > top.txt
```


#### File and Network Usage

To count the number of open files for the Brooklyn process (which includes open socket connections):

```bash
BROOKLYN_HOME=/home/users/brooklyn/apache-brooklyn-0.9.0-bin
BROOKLYN_PID=$(cat $BROOKLYN_HOME/pid_java)
lsof -p $BROOKLYN_PID | wc -l
```

To count (or view the number of "established" internet connections, run:

```bash
netstat -an | grep ESTABLISHED | wc -l
```


#### Linux Kernel Entropy

A lack of entropy can cause random number generation to be extremely slow. This can cause
tasks like ssh to also be extremely slow. See 
[linux kernel entropy]({{ book.path.guide }}/ops/troubleshooting/increase-entropy.html)
for details of how to work around this.


## Process Diagnostics

#### Thread and Memory Usage

To get memory and thread usage for the Brooklyn (Java) process, two useful tools are `jstack` 
and `jmap`. These require the "development kit" to also be installed 
(e.g. `yum install java-1.8.0-openjdk-devel`). Some useful commands are shown below:

```bash
BROOKLYN_HOME=/home/users/brooklyn/apache-brooklyn-0.9.0-bin
BROOKLYN_PID=$(cat $BROOKLYN_HOME/pid_java)

jstack $BROOKLYN_PID
jmap -histo:live $BROOKLYN_PID
jmap -heap $BROOKLYN_PID
```
 

#### Runnable Threads

The [jstack-active](https://github.com/apache/brooklyn-dist/blob/master/scripts/jstack-active.sh)
script is a convenient light-weight way to quickly see which threads of a running Brooklyn
server are attempting to consume the CPU. It filters the output of `jstack`, to show only the
"really-runnable" threads (as opposed to those that are blocked).

```bash
BROOKLYN_HOME=/home/users/brooklyn/apache-brooklyn-0.9.0-bin
BROOKLYN_PID=$(cat $BROOKLYN_HOME/pid_java)

curl -O https://raw.githubusercontent.com/apache/brooklyn-dist/master/scripts/jstack-active.sh

jstack-active $BROOKLYN_PID
```


#### Profiling

If an in-depth investigation of the CPU usage (and/or object creation) of a Brooklyn Server is
requiring, there are many profiling tools designed specifically for this purpose. These generally
require that the process be launched in such a way that a profiler can attach, which may not be
appropriate for a production server.


#### Remote Debugging

If the Brooklyn Server was originally run to allow a remote debugger to connect (strongly 
discouraged in production!), then this provides a convenient way to investigate why Brooklyn
is being slow or unresponsive. See the Debugging Tips in the 
tip [Debugging Remote Brooklyn]({{ book.path.guide }}/dev/tips/debugging-remote-brooklyn.html)
and the [IDE docs]({{ book.path.guide }}/dev/env/ide/) for more information.


## Log Files

Apache Brooklyn will by default create brooklyn.info.log and brooklyn.debug.log files. See the
[Logging]({{ book.path.guide }}/ops/logging.html) docs for more information.

The following are useful log messages to search for (e.g. using `grep`). Note the wording of
these messages (or their very presence) may change in future version of Brooklyn. 


#### Normal Logging

The lines below are commonly logged, and can be useful to search for when finding the start of a section of logging.

```text
2016-05-30 17:05:51,458 INFO  o.a.b.l.BrooklynWebServer [main]: Started Brooklyn console at http://127.0.0.1:8081/, running classpath://brooklyn.war
2016-05-30 17:06:04,098 INFO  o.a.b.c.m.h.HighAvailabilityManagerImpl [main]: Management node tF3GPvQ5 running as HA MASTER autodetected
2016-05-30 17:06:08,982 INFO  o.a.b.c.m.r.InitialFullRebindIteration [brooklyn-execmanager-rvpnFTeL-0]: Rebinding from /home/compose/compose-amp-state/brooklyn-persisted-state/data for master rvpnFTeL...
2016-05-30 17:06:11,105 INFO  o.a.b.c.m.r.RebindIteration [brooklyn-execmanager-rvpnFTeL-0]: Rebind complete (MASTER) in 2s: 19 apps, 54 entities, 50 locations, 46 policies, 704 enrichers, 0 feeds, 160 catalog items
```


#### Memory Usage

The debug log includes (every minute) a log statement about the memory usage and task activity. For example:

```text
2016-05-27 12:20:19,395 DEBUG o.a.b.c.m.i.BrooklynGarbageCollector [brooklyn-gc]: brooklyn gc (before) - using 328 MB / 496 MB memory (5.58 kB soft); 69 threads; storage: {datagrid={size=7, createCount=7}, refsMapSize=0, listsMapSize=0}; tasks: 10 active, 33 unfinished; 78 remembered, 1696906 total submitted)
2016-05-27 12:20:19,395 DEBUG o.a.b.c.m.i.BrooklynGarbageCollector [brooklyn-gc]: brooklyn gc (after) - using 328 MB / 496 MB memory (5.58 kB soft); 69 threads; storage: {datagrid={size=7, createCount=7}, refsMapSize=0, listsMapSize=0}; tasks: 10 active, 33 unfinished; 78 remembered, 1696906 total submitted)
```

These can be extremely useful if investigating a memory or thread leak, or to determine whether a 
surprisingly high number of tasks are being executed.


#### Subscriptions

One source of high CPU in Brooklyn is when a subscription (e.g. for a policy or enricher) is being 
triggered many times (i.e. handling many events). A log message like that below will be logged on 
every 1000 events handled by a given single subscription.

```text
2016-05-30 17:29:09,125 DEBUG o.a.b.c.m.i.LocalSubscriptionManager [brooklyn-execmanager-rvpnFTeL-8]: 1000 events for subscriber Subscription[SCFnav9g;CanopyComposeApp{id=gIeTwhU2}@gIeTwhU2:webapp.url]
```

If a subscription is handling a huge number of events, there are a couple of common reasons:
* first, it could be subscribing to too much activity - e.g. a wildcard subscription for all 
  events from all entities.
* second it could be an infinite loop (e.g. where an enricher responds to a sensor-changed event
  by setting that same sensor, thus triggering another sensor-changed event).


#### User Activity

All activity triggered by the REST API or web-console will be logged. Some examples are shown below:

```text
2016-05-19 17:52:30,150 INFO  o.a.b.r.r.ApplicationResource [brooklyn-jetty-server-8081-qtp1058726153-17473]: Launched from YAML: name: My Example App
location: aws-ec2:us-east-1
services:
- type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer

2016-05-30 14:46:19,516 DEBUG brooklyn.REST [brooklyn-jetty-server-8081-qtp1104967201-20881]: Request Tisj14 starting: POST /v1/applications/NiBy0v8Q/entities/NiBy0v8Q/expunge from 77.70.102.66
```


#### Entity Activity

If investigating the behaviour of a particular entity (e.g. on failure), it can be very useful to 
`grep` the info and debug log for the entity's id. For a software process, the debug log will 
include the stdout and stderr of all the commands executed by that entity.

It can also be very useful to search for all effector invocations, to see where the behaviour
has been triggered:

```text
2016-05-27 12:45:43,529 DEBUG o.a.b.c.m.i.EffectorUtils [brooklyn-execmanager-gvP7MuZF-14364]: Invoking effector stop on TomcatServerImpl{id=mPujYmPd}
```
