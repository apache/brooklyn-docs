---
layout: website-normal
title: Production Installation
---

To install Apache Brooklyn on a production server:

1. [Set up the prerequisites](#prerequisites)
1. [Download Apache Brooklyn](#download)
1. [Configuring brooklyn.cfg](#configuring-properties)
1. [Configuring Karaf Security](#configuring-karaf-security)
1. [Configuring default.catalog.bom](#configuring-catalog)
1. [Test the installation](#confirm)

This guide covers the basics. You may also wish to configure:

* [Logging]({{ book.path.guide }}/ops/logging.html)
* [Persistence](persistence/)
* [High availability](high-availability/)


### <a id="prerequisites"></a>Set up the Prerequisites

Check that the server meets the [requirements](requirements.html).
Then configure the server as follows:

* install Java JRE or JDK (version 8 or later)
* enable "Java Cryptography Extension" (already enabled out of the box of OpenJDK installs)
* install an [SSH key]({{ book.path.guide }}/locations/index.html#ssh-keys), if not available
* if the "localhost" location will be used, enable [passwordless ssh login]({{ book.path.guide }}/locations/index.html#ssh-keys)
* create a `~/.brooklyn` directory on the host with `$ mkdir ~/.brooklyn`
* check your `iptables` or other firewall service, making sure that incoming connections on port 8443 is not blocked
* check that the [linux kernel entropy]({{ book.path.guide }}/ops/troubleshooting/increase-entropy.html) is sufficient
* check that the [ulimit values]({{ book.path.guide }}/ops/troubleshooting/increase-system-resource-limits.html) are sufficiently high
* ensure external libraries are up-to-date, including `nss` for SSL. 
* ensure the time is continually accurate, ideally by running a service like the [ntp daemon](http://www.ntp.org/).


### <a id="download"></a>Download Apache Brooklyn

Download Brooklyn and obtain a binary build as described on [the download page]({{book.path.website}}/download/).

{% if 'SNAPSHOT' in book.brooklyn_version %}
Expand the `tar.gz` archive (note: as this is a -SNAPSHOT version, your filename will be slightly different):
{% else %}
Expand the `tar.gz` archive:
{% endif %}

{% if 'SNAPSHOT' in book.brooklyn_version %}
```bash
% tar -zxf apache-brooklyn-dist-{{ book.brooklyn-stable-version }}-timestamp-dist.tar.gz
```
{% else %}
```bash
% tar -zxf apache-brooklyn-{{ book.brooklyn-stable-version }}-dist.tar.gz
```
{% endif %}

This will create a `apache-brooklyn-{{ book.brooklyn-stable-version }}` folder.

Let's setup some paths for easy commands.

```bash
% cd apache-brooklyn-{{ book.brooklyn-stable-version }}
% BROOKLYN_DIR="$(pwd)"
% export PATH=$PATH:$BROOKLYN_DIR/bin/
```


### <a id="configuring-properties"></a>Configuring brooklyn.cfg

Set up `brooklyn.cfg` as described [here](brooklyn_cfg.html):

* Configure the users who should have access
* Turn on HTTPS
* Supply credentials for any pre-defined clouds

### <a id="configuring-karaf-security"></a>Configuring Karaf Security

Out of the box, Apache Brooklyn includes the default Karaf security configuration.
This configuration is used to manage connections to the ssh port of Karaf
(which is available to localhost connections only).
It is recommended that you update the credentials as detailed in the
[Karaf Security](https://karaf.apache.org/manual/latest/security#_users_groups_roles_and_passwords) page.

### <a id="configuring-catalog"></a>Configuring the Catalog

By default Brooklyn loads the catalog of available application components and services from 
`default.catalog.bom` on the classpath. The initial catalog is in `conf/brooklyn/` in the dist.
If you have a preferred catalog, simply replace that file.

[More information on the catalog is available here.](catalog/)


### <a id="confirm"></a>Confirm Installation

Launch Brooklyn in a disconnected session so it will remain running after you have logged out:

```bash
% nohup bin/brooklyn launch > /dev/null 2&>1 &
```

Apache Brooklyn should now be running on port 8081 (or other port if so specified).

To install on a different port edit config in `etc/org.ops4j.pax.web.cfg`.
