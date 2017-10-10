---
layout: website-normal
title: Production Installation
---
# {{ page.title }}

To install Apache Brooklyn on a production server:

1. [Set up the prerequisites](#set-up-the-prerequisites)
1. [Download Apache Brooklyn](#download-apache-brooklyn)
1. [Configuring brooklyn.cfg](#configuring-brooklyncfg)
1. [Configuring Karaf Security](#configuring-karaf-security)
1. [Configuring default.catalog.bom](#configuring-the-catalog)
1. [Test the installation](#confirm-installation)

This guide covers the basics. You may also wish to configure:

* [Logging](logging.md)
* [Persistence](persistence/index.md)
* [High availability](high-availability/index.md)


### Set up the Prerequisites

Check that the server meets the [requirements](requirements.md).
Then configure the server as follows:

* install Java JRE or JDK (version 8 or later)
* enable "Java Cryptography Extension" (already enabled out of the box of OpenJDK installs)
* install an [SSH key](../locations/index.md#ssh-keys), if not available
* if the "localhost" location will be used, enable [passwordless ssh login](../locations/index.md#ssh-keys)
* create a `~/.brooklyn` directory on the host with `$ mkdir ~/.brooklyn`
* check your `iptables` or other firewall service, making sure that incoming connections on port 8443 is not blocked
* check that the [linux kernel entropy](troubleshooting/increase-entropy.md) is sufficient
* check that the [ulimit values](troubleshooting/increase-system-resource-limits.md) are sufficiently high
* ensure external libraries are up-to-date, including `nss` for SSL. 
* ensure the time is continually accurate, ideally by running a service like the [ntp daemon](http://www.ntp.org/).


### Download Apache Brooklyn

Download Brooklyn and obtain a binary build as described on [the download page]({{book.path.website}}/download/).

{% if 'SNAPSHOT' in book.brooklyn_version %}
Expand the `tar.gz` archive (note: as this is a -SNAPSHOT version, your filename will be slightly different):
{% else %}
Expand the `tar.gz` archive:
{% endif %}

{% if 'SNAPSHOT' in book.brooklyn_version %}
```bash
% tar -zxf apache-brooklyn-dist-{{ book.brooklyn_version_stable }}-timestamp-dist.tar.gz
```
{% else %}
```bash
% tar -zxf apache-brooklyn-{{ book.brooklyn_version_stable }}-dist.tar.gz
```
{% endif %}

This will create a `apache-brooklyn-{{ book.brooklyn_version_stable }}` folder.

Let's setup some paths for easy commands.

```bash
% cd apache-brooklyn-{{ book.brooklyn_version_stable }}
% BROOKLYN_DIR="$(pwd)"
% export PATH=$PATH:$BROOKLYN_DIR/bin/
```


### Configuring brooklyn.cfg

Set up `brooklyn.cfg` as described [here](configuration/brooklyn_cfg.md):

* Configure the users who should have access
* Turn on HTTPS
* Supply credentials for any pre-defined clouds

### Configuring Karaf Security

Out of the box, Apache Brooklyn includes the default Karaf security configuration.
This configuration is used to manage connections to the ssh port of Karaf
(which is available to localhost connections only).
It is recommended that you update the credentials as detailed in the
[Karaf Security](https://karaf.apache.org/manual/latest/security#_users_groups_roles_and_passwords) page.

### Configuring the Catalog

By default Brooklyn loads the catalog of available application components and services from 
`default.catalog.bom` on the classpath. The initial catalog is in `conf/brooklyn/` in the dist.
If you have a preferred catalog, simply replace that file.

[More information on the catalog is available here.](../blueprints/catalog/index.md)


### Confirm Installation

Launch Brooklyn in a disconnected session so it will remain running after you have logged out:

```bash
% nohup bin/brooklyn launch > /dev/null 2&>1 &
```

Apache Brooklyn should now be running on port 8081 (or other port if so specified).

To install on a different port edit config in `etc/org.ops4j.pax.web.cfg`.
