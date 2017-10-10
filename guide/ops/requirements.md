---
title: Requirements
layout: website-normal
---
# {{ page.title }}

## Server Specification

The size of server required by Brooklyn depends on the amount of activity. This includes:

* the number of entities/VMs being managed
* the number of VMs being deployed concurrently
* the amount of management and monitoring required per entity

For dev/test or when there are only a handful of VMs being managed, a small VM is sufficient.
For example, an AWS m3.medium with one vCPU, 3.75GiB RAM and 4GB disk.

For larger production uses, a more appropriate machine spec would be two or more cores,
at least 8GB RAM and 100GB disk. The disk is just for logs, a small amount of persisted state, and
any binaries for custom blueprints/integrations.


### Disk Space

There are three main consumers of disk space:

* **Static files**: these are the Apache Brooklyn distribution with its own
  dependencies, OSGi bundles for custom blueprints and integrations installed to the `deploy/` directory,
  plus `data/` directory which is generated on first launch.
  Note that Brooklyn requires that Java is installed which
  you may have to consider when calculating disk space requirements.
* **Persisted state**: when using [Persistence](persistence/index.md) -- which
  is a prerequisite for [High Availability](high-availability/index.md) -- Brooklyn
  will save data to a store location. Items in the persisted state include
  metadata about the Brooklyn servers, catalog items, and metadata about all
  running applications and entities.
* **Log files**: Brooklyn writes info and debug log files. By default, these are
  written to the local filesystem. This can be reconfigured to set the
  destination and to increase or decrease the detail in the logs. See the
  [Logging](logging.md) section for more details.

The Apache Brooklyn distribution itself, when unpacked, consumes approximately
75MB of disk space. This includes everything needed to run Brooklyn except for a
Java VM. The space consumed by additional binaries for custom blueprints and
integrations is application-specific.

Persisted state, excluding catalog data, is relatively small, starting at
approximately 300KB for a clean, idle Brooklyn server. Deploying blueprints will
add to this - how much depends exactly on the entities involved and is therefore
application specific, but as a guideline, a 3-node Riak cluster adds
approximately 500KB to the persistence store.

Log data can be a large consumer of disk space. By default Brooklyn generates
two logfiles, one which logs notable information only, and another which logs at
a debug level. Each logfile rotates when it hits a size of 100MB; a maximum of
10 log files are retained for each type. The two logging streams combined,
therefore, can consume up to 2GB of disk space.

In the default configuration of Brooklyn's `.tar.gz` and `.zip` distributions,
logs are saved to the Brooklyn installation directory. You will most likely want
to [reconfigure Brooklyn's logging](logging.md) to save logs to a location
elsewhere. In the `.rpm` and `.deb` packaging, logging files will be located
under `/var/log`. You can further reconfiguring the logging detail level and log
rotation according to your organisation's policy.


## OS Requirements

Brooklyn is tested against CentOS (6 or later), RHEL (6 or later), Ubuntu (14.04 or later), OS X, and Windows.


## Software Requirements

Brooklyn requires Java 8 (JRE or JDK) or later.
OpenJDK is recommended. Brooklyn has also been tested on the Oracle JVM and IBM J9.


## Configuration Requirements

### Ports

The ports used by Brooklyn are:

* 8443 for https, to expose the web-console and REST api.
* 8081 for http, to expose the web-console and REST api.

Whether to use https rather than http is configurable using the CLI option `--https`; 
the port to use is configurable using the CLI option `--port <port>`.

To enable remote Brooklyn access, ensure these ports are open in the firewall.
For example, to open port 8443 in iptables, ues the command:

    /sbin/iptables -I INPUT -p TCP --dport 8443 -j ACCEPT


### Locale

Brooklyn expects a sensible set of locale information and time zones to be available;
without this, some time-and-date handling may be surprising.

Brooklyn parses and reports times according to the time zone set at the server.
If Brooklyn is targetting geographically distributed users, 
it is normally recommended that the server's time zone be set to UTC.


### User Setup

It is normally recommended that Brooklyn run as a non-root user with keys installed to `~/.ssh/id_rsa{,.pub}`. 


### Linux Kernel Entropy

Check that the [linux kernel entropy](troubleshooting/increase-entropy.md) is sufficient.


### System Resource Limits

Check that the [ulimit values](troubleshooting/increase-system-resource-limits.md) are sufficiently high.
