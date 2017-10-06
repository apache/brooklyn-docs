---
title: Logging
layout: website-normal
---

Brooklyn uses the SLF4J logging facade, which allows use of many popular frameworks including `logback`, 
`java.util.logging` and `log4j`.

The convention for log levels is as follows:

* `ERROR` and above:  exceptional situations which indicate that something has unexpectedly failed or
some other problem has occured which the user is expected to attend to
* `WARN`:  exceptional situations which the user may which to know about but which do not necessarily indicate failure or require a response
* `INFO`:  a synopsis of activity, but which should not generate large volumes of events nor overwhelm a human observer
* `DEBUG` and lower:  detail of activity which is not normally of interest, but which might merit closer inspection under certain circumstances.

Loggers follow the ``package.ClassName`` naming standard.  


## Using Logback through OSGi Pax Logging

In the OSGi based Apache Brooklyn logging is configured from ops4j pax logging.

See: [Logging - OSGi based Apache Brooklyn](../dev/tips/logging.html#osgi-based-apache-brooklyn) <br/>
[https://ops4j1.jira.com/wiki/display/paxlogging/Configuration](https://ops4j1.jira.com/wiki/display/paxlogging/Configuration)


## Standard Configuration

A `logback.xml` file is included in the `conf/` directly of the Brooklyn distro;
this is read by `brooklyn` at launch time.  Changes to the logging configuration,
such as new appenders or different log levels, can be made directly in this file
or in a new file included from this.


## Advanced Configuration

The default `logback.xml` file references a collection of other log configuration files
included in the Brooklyn jars. It is necessary to understand the source structure
in the [logback-includes]({{ book.brooklyn.url.git }}/logging/logback-includes) project.

For example, to change the debug log inclusions, create a folder `brooklyn` under `conf`
and create a file `logback-debug.xml` based on the
[brooklyn/logback-debug.xml]({{ book.brooklyn.url.git }}/logging/logback-includes/src/main/resources/brooklyn/logback-debug.xml)
from that project.


## Log File Backup

*This sub-section is a work in progress; feedback from the community is extremely welcome.*

The default rolling log files can be backed up periodically, e.g. using a CRON job.

Note however that the rolling log file naming scheme will rename the historic zipped log files 
such that `brooklyn.debug-1.log.zip` is the most recent zipped log file. When the current
`brooklyn.debug.log` is to be zipped, the previous zip file will be renamed 
`brooklyn.debug-2.log.zip`. This renaming of files can make RSYNC or backups tricky.

An option is to covert/move the file to a name that includes the last-modified timestamp. 
For example (on mac):

    LOG_FILE=brooklyn.debug-1.log.zip
    TIMESTAMP=`stat -f '%Um' $LOG_FILE`
    mv $LOG_FILE /path/to/archive/brooklyn.debug-$TIMESTAMP.log.zip


## Logging aggregators

Integration with systems like Logstash and Splunk is possible using standard logback configuration.
Logback can be configured to [write to the syslog](http://logback.qos.ch/manual/appenders.html#SyslogAppender), 
which can then [feed its logs to Logstash](http://www.logstash.net/docs/1.4.2/inputs/syslog).


## For More Information

The following resources may be useful when configuring logging:

* The [logback-includes]({{ book.brooklyn.url.git }}/usage/logback-includes) project
* [Brooklyn Developer Guide]({{ book.path.guide }}/dev/tips/logging.html) logging tips
* The [Logback Project](http://logback.qos.ch/) home page
