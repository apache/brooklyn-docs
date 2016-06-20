---
title: Starting, Stopping and Monitoring
layout: website-normal
---

**NOTE:** This document is for information on starting an Apache Brooklyn
Server.  For information on using the Brooklyn Client CLI to access an already
running Brooklyn Server, refer to [Client CLI Reference](cli/index.html).


## Starting

To launch Brooklyn, from the directory where Brooklyn is unpacked, run:

{% highlight bash %}
% bin/brooklyn launch > /dev/null 2>&1 & disown
{% endhighlight %}

With no configuration, this will launch the Brooklyn web console and REST API on [`http://localhost:8081/`](http://localhost:8081/).
No password is set, but the server is listening only on the loopback network interface for security.
Once [security is configured](brooklyn_properties.html), Brooklyn will listen on all network interfaces by default.

See the [Server CLI Reference](server-cli-reference.html) for more information
about the Brooklyn server process.

The Brooklyn startup script will create a file name `pid_java` at the root of
the Brooklyn directory, which contains the PID of the last Brooklyn process to
be started.


## Stopping

To stop Brooklyn, simply send a `TERM` signal to the Brooklyn process. The PID
of the most recently run Brooklyn process can be found in the `pid_java` file at
the root of the Brooklyn directory.

For example:

{% highlight bash %}
% kill $( cat pid_java )
{% endhighlight bash %}


## Monitoring

As already mentioned, the Brooklyn startup script will create a file name
`pid_java` at the root of the Brooklyn directory, which contains the PID of the
last Brooklyn process to be started. You can examine this file to discover the
PID, and then test that the process is still running.

This should lead to a fairly straightforward integration with many monitoring
tools - the monitoring tool can discover the expected PID, and can execute the
start or stop commands shown above as necessary.

For example, here is a fragment of a `monitrc` file as used by [Monit](http://https://mmonit.com/monit/):

{% highlight text %}
check process apachebrooklyn with pidfile /opt/apache-brooklyn/pid_java
    start program = "/bin/bash -c '/opt/apache-brooklyn/bin/brooklyn launch & disown'" with timeout 10 seconds
    stop  program = "/bin/bash -c 'kill $( cat /opt/apache-brooklyn/pid_java )'"
{% endhighlight %}

In addition to monitoring the Brooklyn process itself, you will almost certainly
want to monitor resource usage of Brooklyn. In particular, please see the
[Requirements](requirements.html#disk-space) section for a discussion on Brooklyn's disk
space requirements.
