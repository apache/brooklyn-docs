---
section: Logbook
section_type: inline
section_position: 3
---

# Logbook

The logbook offers the possibility to query and view logs in the UI. By default, logs are stored in files as per configuration
in `etc/org.ops4j.pax.logging.cfg`. The logbook can be configured against different log aggregation sources by setting the
`brooklyn.logbook.logStore` parameter in `brooklyn.cfg`, and depending which backend is used, other parameters.

For example to use the local log files written by Apache Brooklyn in a production environment, assuming `/var/logs`,
you could configure:
```properties
        brooklyn.logbook.logStore=org.apache.brooklyn.util.core.logbook.file.FileLogStore
        brooklyn.logbook.fileLogStore.path=/var/logs/brooklyn/brooklyn.debug.log
```

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
- in the **About** section, where all logs can be viewed
- on the App Inspector **Entity Summary** view
- on the App Inspector **Activity** view, where logs filtered by entity ID and activity ID respectively are shown
- on the **Debug Console**, below the controls and output


## Suggested Elasticsearch Setup

[OpenSearch (OpenDistro for Elasticsearch)](https://opendistro.github.io/for-elasticsearch) is an Apache-licensed open-source
backend that works well with Apache Brooklyn, with this configuration in `brooklyn.cfg`:
```properties
        brooklyn.logbook.logStore=org.apache.brooklyn.util.core.logbook.opensearch.OpenSearchLogStore
        brooklyn.logbook.openSearchLogStore.host=https://localhost:9200
        brooklyn.logbook.openSearchLogStore.index=brooklyn
        brooklyn.logbook.openSearchLogStore.user=admin
        brooklyn.logbook.openSearchLogStore.password=admin
        brooklyn.logbook.openSearchLogStore.verifySsl=false
```

### Routing Logs to Elasticsearch

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

### Sizing and Rotating Logs

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


### Index partitioning

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

### Index lifecycle management

Policies also allow handling the lifecycle of the indexes.
For example, to delete debug indexes after a period of time based on the index naming pattern used in this page:

```yaml
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


