---
title: Logging
layout: website-normal
---

Brooklyn uses the SLF4J logging facade, which allows use of many popular frameworks including `logback`, 
`java.util.logging` and `log4j`.

The convention for log levels is as follows:

* `ERROR` and above:  exceptional situations which indicate that something has unexpectedly failed or
some other problem has occurred which the user is expected to attend to
* `WARN`:  exceptional situations which the user may which to know about but which do not necessarily indicate failure or require a response.
* `INFO`:  a synopsis of activity, but which should not generate large volumes of events nor overwhelm a human observer.
* `DEBUG`:  detail of activity which might merit closer inspection under certain circumstances.
* `TRACE` and lower: detail of activity which is not normally of interest, but which might merit closer inspection under certain circumstances including sensitive information (e.g. secrets) that should not be exposed in higher lover levels. A configuration example for TRACE level is present in the log configuration file, but is commented because of security concerns.  

Loggers follow the ``package.ClassName`` naming standard.  

The default logging is to write INFO+ messages to `brooklyn.info.log`, 
and DEBUG+ to `brooklyn.debug.log`. Each is a rolling log file, 
where the past 10 files will be kept. INFO level, and above, messages
will be logged to the karaf console. Use the `log:` commands in the 
karaf client, e.g. `log:tail`, to read these messages.


## Using Logback through OSGi Pax Logging

In the OSGi based Apache Brooklyn logging is configured from ops4j pax logging.

See: [Logging - OSGi based Apache Brooklyn](../dev/tips/logging.html#osgi-based-apache-brooklyn) <br/>
[https://ops4j1.jira.com/wiki/display/paxlogging/Configuration](https://ops4j1.jira.com/wiki/display/paxlogging/Configuration)

## Standard Configuration

A `org.ops4j.pax.logging.cfg` file is included in the `etc/` directly of the Brooklyn distro;
this is read by `brooklyn` at launch time. Changes to the logging configuration,
such as new appenders or different log levels, can be made directly in this file.

Karaf logging is highly configurable. For example enable the sift appender to log to separate log files for
each bundle as described here: [Advanced configuration](https://karaf.apache.org/manual/latest/#_advanced_configuration)

Using the default configuration the log entries are reported in UTC time. If you want the logging to be reported using the server local time you can replace the `log4j2.pattern` removing the UTC flag and the Z suffix: 
```properties
log4j2.pattern = %d{ISO8601} %X{task.id}-%X{entity.ids} %-5.5p %3X{bundle.id} %c{1.} [%.16t] %m%n
```

## Advanced Configuration

The default `logback.xml` file references a collection of other log configuration files
included in the Brooklyn jars. It is necessary to understand the source structure
in the [logback-includes]({{ site.brooklyn.url.git }}/logging/logback-includes) project.

For example, to change the debug log inclusions, create a folder `brooklyn` under `conf`
and create a file `logback-debug.xml` based on the
[brooklyn/logback-debug.xml]({{ site.brooklyn.url.git }}/logging/logback-includes/src/main/resources/brooklyn/logback-debug.xml)
from that project.

A full explanation of logging in karaf is available [here](https://karaf.apache.org/manual/latest/#_log).


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


## Logging Aggregators

Integration with systems like Logstash and Splunk is possible using standard log4j configuration.
Log4j can be configured to write to syslog using the SyslogAppender
which can then [feed its logs to Logstash](http://www.logstash.net/docs/1.4.2/inputs/syslog).


## Logbook

The logbook offers the possibility to query and view logs in the UI. By default, logs are stored in files as per configuration
in `etc/org.ops4j.pax.logging.cfg`. The logbook can be configured against different log aggregation sources by setting the
`brooklyn.logbook.logStore` parameter in `brooklyn.cfg`, and depending which backend is used, other parameters.

For example to use the local log files written by Apache Brooklyn in a production environment, assuming `/var/logs`, 
you could configure:

        brooklyn.logbook.logStore=org.apache.brooklyn.util.core.logbook.file.FileLogStore
        brooklyn.logbook.fileLogStore.path=/var/logs/brooklyn/brooklyn.debug.log

The default mode is to use the local log file in `data/log/` relative to the launch directory.

The `FileLogStore` implementation is not compatible with multiline logs, only the first line will be print.

In production environments where log data is desired to be retained, Apache Brooklyn supports Elasticsearch backends.
This can be a dedicated ES environment for use by Apache Brooklyn or a shared/managed ES facility that handles many logs,
or -- for lightweight usage -- a simple local ES server running on the same instance as Apache Brooklyn.
As with any log storage requirement, the sizing, scaling, backup and maintenance of the logging environment 
requires careful attention. Elasticsearch includes numerous options to configure these, with one suggested configuration
outlined in more detail below.

By default, only users with the `root`, `powerUser`, or an explicit `logViewer` entitlement are able to see log info through Apache Brooklyn.

The Logbook UI widget can be found throughout the product: 
in the About section, where all logs can be viewed;
on the App Inspector Entity Summary view, and
on the App Inspector Activity view, where logs filtered by entity ID and activity ID respectively are shown.


### Suggested Elasticsearch Setup

[OpenSearch (OpenDistro for Elasticsearch)](https://opendistro.github.io/for-elasticsearch) is an Apache-licensed open-source 
backend that works well with Apache Brooklyn, with this configuration in `brooklyn.cfg`:

        brooklyn.logbook.logStore=org.apache.brooklyn.util.core.logbook.opensearch.OpenSearchLogStore
        brooklyn.logbook.openSearchLogStore.host=https://localhost:9200
        brooklyn.logbook.openSearchLogStore.index=brooklyn
        brooklyn.logbook.openSearchLogStore.user=admin
        brooklyn.logbook.openSearchLogStore.password=admin
        brooklyn.logbook.openSearchLogStore.verifySsl=false


#### Routing Logs to Elastic Search

There are many solutions to routing log messages from Apache Brooklyn to Elasticsearch, either plugging in to the log4j subsystem
or routing the log files from disk. [Fluentd](https://www.fluentd.org/download), with the following configuration in `td-agent.conf`, 
is a good simple way to forward content added to the info and debug log files:

```
<source>
  @type tail
  @id input_tail_brooklyn_info
  @log_level info
  <parse>
    @type multiline
    format_firstline /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/
    format1 /^(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z) (?<taskId>\S+)?-(?<entityIds>\S+)? (?<level>\w{4} |\w{5})\W{1,4}(?<bundleId>\d{1,3}) (?<class>(?:\S\.)*\S*) \[(?<threadName>\S+)\] (?<message>.*)/
    time_format %Y-%m-%dT%H:%M:%S,%L
  </parse>
  path /var/logs/brooklyn/brooklyn.info.log
  pos_file /var/log/td-agent/brooklyn.info.log.pos
  tag brooklyn.info
</source>

<source>
  @type tail
  @id input_tail_brooklyn_debug
  @log_level debug
  <parse>
    @type multiline
    format_firstline /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/
    format1 /^(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z) (?<taskId>\S+)?-(?<entityIds>\S+)? (?<level>\w{4} |\w{5})\W{1,4}(?<bundleId>\d{1,3}) (?<class>(?:\S\.)*\S*) \[(?<threadName>\S+)\] (?<message>.*)/
    time_format %Y-%m-%dT%H:%M:%S,%L
  </parse>
  path /var/logs/brooklyn/brooklyn.debug.log
  pos_file /var/log/td-agent/brooklyn.debug.log.pos
  tag brooklyn.debug
</source>

<filter brooklyn.debug>
  @type grep
  regexp1 level DEBUG
</filter>

<match brooklyn.*>
  @type elasticsearch
  hosts https://localhost:9200
  user admin
  password admin
  ssl_verify false
  logstash_format false
  index_name brooklyn
</match>
```

The filter block is needed for only picking up the `debug` log level from the debug source, as the `info` and upper
levels are already present in the info file.

#### Sizing and Rotating Logs

Keeping log data obviously consumes disk storage, and serving the data requires memory.
The log levels in Apache Brooklyn can be configured on a fine-grained log-category basis,
and different levels and categories can be routed to different indexes with different
retention policies.

When designing your strategy for maintaining logs, some good rules of thumb are:

* Allocate 4 GB RAM for a production ES instance plus 2 GB RAM for every TB of log data that is searchable
* Consider a small number of tiers with different retention policies,
  e.g. INFO and selected DEBUG messages (logins) to one index,
  and all other DEBUG and lower messages sent to another index
* Consider using rolling indices on a nightly or weekly basis, and an auto-close job and/or an auto-delete job to keep memory and disk usage at a steady state;
  for example the INFO and selected DEBUG messages might go to an index which rotates weekly and is deleted or moved to cold storage after two years,
  whereas DEBUG and lower messages might rotate daily and be deleted after a week
* The amount of log data can vary depending how Apache Brooklyn is used, so monitor usage to get a feel for what is
  maintainable, and put in place notifications if disk and/or memory usage become high
* Review the logs and turn off unnecessary categories

Instructions and links to assist with this are below.


#### Index partitioning

It’s possible to configure Fluentd for sending the information to an index using an index name generated using datetime markers.
This example will create and send the data to a new index every day:

```
<match brooklyn.*>
  @type elasticsearch
  hosts https://localhost:9200
  user admin
  password admin
  ssl_verify false

  include_timestamp true
  index_name ${tag}-%Y.%m.%d
  flush_interval 5s
  <buffer tag, time>
    timekey 60 # chunks per hours ("3600" also available)
    flush_interval 5s
  </buffer>
</match>
```

Apache Brooklyn can be configured to use an index _pattern_ for querying, eg:
```properties
    brooklyn.logbook.openSearchLogStore.index = brooklyn*
```

#### Index lifecycle management

Policies also allow handling the lifecycle of the indexes.
For example, to delete debug indexes after a period of time based on the index naming pattern used in this page:

```
{
  "policy": {
    "description": "Delete workflow",
    "default_state": "new",
    "schema_version": 1,
    "states": [
      {
        "name": "new",
        "transitions": [
          {
            "state_name": "delete",
            "conditions": {
              "min_index_age": "60d"
            }
          }
        ]
      },
      {
        "name": "delete",
        "actions": [
          {
            "delete": {}
          }
        ]
      }
    ],
    "ism_template": {
        "index_patterns": ["brooklyn.debug*"],
        "priority": 100
      }
  }
}
```

With these building blocks, and others linked below, you can configure the retention policy that suits your environment, 
balancing the trade-off between data availability and resource usage.



## For More Information

The following resources may be useful when configuring logging:

* The [logback-includes]({{ site.brooklyn.url.git }}/usage/logback-includes) project
* [Brooklyn Developer Guide](/guide/dev/tips/logging.html) logging tips
* The [Logback Project](http://logback.qos.ch/) home page
* [Brooklyn Developer Guide]({{book.path.docs}}/dev/tips/logging.md) logging tips
* [OPS4J Pax Logging](https://ops4j1.jira.com/wiki/display/paxlogging/Configuration)
* [Elasticsearch Best Practices](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/best_practices.html)
* [Elasticsearch Memory Usage](https://www.elastic.co/blog/significantly-decrease-your-elasticsearch-heap-memory-usage)
* [OpenSearch Index Management](https://opensearch.org/docs/im-plugin/ism/index/) and [policies](https://opensearch.org/docs/im-plugin/ism/policies/)

