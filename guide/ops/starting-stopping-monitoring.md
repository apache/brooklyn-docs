---
title: Starting, Stopping and Monitoring
layout: website-normal
---
# {{ page.title }}

**NOTE:** This document is for information on starting an Apache Brooklyn
Server.  For information on using the Brooklyn Client CLI to access an already
running Brooklyn Server, refer to [Client CLI Reference](cli/index.html).

## Packages for RHEL/CentOS and Ubuntu

If you are using the `.rpm` or `.deb` package of Apache Brooklyn, then Brooklyn
will integrate with your OS service management. Commands such as
`service brooklyn start` will work as expected, and Brooklyn's PID file will be
stored in the normal location for your OS, such as `/var/run/brooklyn.pid`.


## Platform-independent distributions

The platform-independent distributions are packaged in `.tar.gz` and `.zip`
files.


### Starting

To launch Brooklyn, from the directory where Brooklyn is unpacked, run:

```bash
% bin/start
```

With no configuration, this will launch the Brooklyn web console and REST API on [`http://localhost:8081/`](http://localhost:8081/),
listening on all network interfaces. No credentials are required by default. It is strongly
recommended to [configure security](configuration/).

See the [Server CLI Reference](server-cli-reference.html) for more information
about the Brooklyn server process.


### Stopping

To stop Brooklyn, from the directory where Brooklyn is unpacked, run:

For example:

```bash
% bin/stop
{% endhighlight bash %}


## Monitoring

For `.tar.gz` and `.zip` distributions of Brooklyn, the Brooklyn startup script
will create a file name `pid_java` at the root of the Brooklyn directory, which
contains the PID of the last Brooklyn process to be started. You can examine
this file to discover the PID, and then test that the process is still running.
`.rpm` and `.deb` distributions of Brooklyn will use the normal mechanism that
your OS uses, such as writing to `/var/run/brooklyn.pid`.

This should lead to a fairly straightforward integration with many monitoring
tools - the monitoring tool can discover the expected PID, and can execute the
start or stop commands shown above as necessary.

For example, here is a fragment of a `monitrc` file as used by
[Monit](https://mmonit.com/monit/), for a Brooklyn `.tar.gz` distribution
unpacked and installed at `/opt/apache-brooklyn`:

```text
check process apachebrooklyn with pidfile /opt/apache-brooklyn/pid_java
    start program = "/bin/bash -c '/opt/apache-brooklyn/bin/brooklyn launch --persist auto & disown'" with timeout 10 seconds
    stop  program = "/bin/bash -c 'kill $( cat /opt/apache-brooklyn/pid_java )'"
```

In addition to monitoring the Brooklyn process itself, you will almost certainly
want to monitor resource usage of Brooklyn. In particular, please see the
[Requirements](requirements.html#disk-space) section for a discussion on Brooklyn's disk
space requirements.
