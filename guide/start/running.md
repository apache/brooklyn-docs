---
title: Running Apache Brooklyn
title_in_menu: Running Apache Brooklyn
layout: website-normal
menu_parent: index.md
---
# {{ page.title }}

This guide will walk you through deploying an example 3-tier web application to a public cloud, and demonstrate the autoscaling capabilities of the Brooklyn platform.

Two methods of deployment are detailed in this tutorial, using virtualisation with Vagrant and an install in your own environment (such as your local machine or in your private/public cloud). 

The latter assumes that you have a [Java Runtime Environment (JRE)](https://www.java.com) installed (version 7 or later), as Brooklyn is Java under the covers. 

To get you up-and-running quickly, the Vagrant option will provision four compute nodes for you to deploy applications to. 

## Install Apache Brooklyn

{% method -%}

{% common -%}
{% if output.name == 'website' %}
**Hint:** in the top right of this page are buttons to select an operating system. Choose your operating system to see the most appropriate instructions here.
{% endif %}

{% sample lang="vagrant" -%}
### Installing with Vagrant

[Vagrant](https://www.vagrantup.com/) is a software package which automates the process of setting up virtual machines (VM) such as [Oracle VirtualBox](https://www.virtualbox.org). We recommend it as the easiest way of getting started with Apache Brooklyn.

Firstly, download and install:

 * [Vagrant](https://www.vagrantup.com/downloads.html)
 * [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 
{% if 'SNAPSHOT' in book.brooklyn_version %}
Then download the provided Apache Brooklyn vagrant configuration from
[here](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=brooklyn-vagrant&v={{book.brooklyn_version}}&c=dist&e=zip).
This archive contains everything you need to create an environment for use with this guide, providing an Apache Brooklyn instance and some blank VMs.

{% else %}

Then download the provided Apache Brooklyn vagrant configuration from
[here](https://www.apache.org/dyn/closer.lua?action=download&filename=brooklyn/apache-brooklyn-{{book.brooklyn_version}}/apache-brooklyn-{{book.brooklyn_version}}-vagrant.tar.gz).
This archive contains everything you need to create an environment for use with this guide, providing an Apache Brooklyn instance and some blank VMs.
{% endif %}

Extract the `tar.gz` archive and navigate into the expanded <code>apache-brooklyn-{{book.brooklyn_version}}-vagrant</code> folder {% if 'SNAPSHOT' in book.brooklyn_version %}(note: as this is a -SNAPSHOT version, your filename will be slightly different){% endif %}

<pre><code class="lang-sh">$ tar xvf apache-brooklyn-{{book.brooklyn_version}}-vagrant.tar.gz
$ cd apache-brooklyn-{{book.brooklyn_version}}-vagrant</code></pre>

{% sample lang="centos" -%}
### Installing on CentOS & Red Hat Enterprise Linux 7

{% if 'SNAPSHOT' in book.brooklyn_version %}<strong>Please note, an RPM is not available for snapshot builds</strong>{% endif %}

For Centos 7 and RHEL 7 users, the recommended way to install Apache Brooklyn on RPM-based Linux distributions is by using the RPM package. 

RPM is the de facto standard for packaging software on these Linux distributions and provides a mechanism for installing, upgrading and removing packages such as Apache Brooklyn. The RPM package contains all the necessary files associated with the Apache Brooklyn application. 

{% if 'SNAPSHOT' in book.brooklyn_version %}
This is a snapshot build and no RPM is available, please download [a different version]({{book.path.website}}/download/).
{% else %}
Download the Apache Brooklyn [RPM distribution](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn_version}}/apache-brooklyn-{{book.brooklyn_version}}-1.noarch.rpm).
{% endif %}

Once downloaded, run the following shell command as root:

<pre><code class="lang-sh">$ yum install apache-brooklyn-{{book.brooklyn_version}}-1.rpm</code></pre>

{% sample lang="ubuntu" -%}
### Installing on Ubuntu 7 Debian

For Ubuntu and Debian users, the recommended way to install Apache Brooklyn is to use the deb file. 

The deb file is the de facto standard for packaging software on these Linux distributions and provides a mechanism for installing, upgrading and removing packages such as Apache Brooklyn. The deb package contains all the necessary files associated with the Apache Brooklyn application. 

{% if 'SNAPSHOT' in book.brooklyn_version %}
Download the Apache Brooklyn [deb distribution](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=deb-packaging&v={{book.brooklyn_version}}&e=deb).
{% else %}
Download the Apache Brooklyn [deb distribution](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn_{{book.brooklyn_version}}_noarch.deb).
{% endif %}

Once downloaded, run the following shell command:

<pre><code class="lang-sh">$ sudo dpkg -i apache-brooklyn_{{book.brooklyn_version}}_noarch.deb</code></pre>

{% sample lang="osx" -%}
### Installing on other Linux distributions, OSX and other UNIX-like platforms

For Linux or OSX please download the Apache Brooklyn `tar.gz` archive from the [download]({{book.path.website}}/download/) section.

{% if 'SNAPSHOT' in book.brooklyn_version %}
Extract the `tar.gz` archive (note: as this is a -SNAPSHOT version, your filename will be slightly different):
{% else %}
Extract the `tar.gz` archive and navigate into the expanded <code class="lang-sh">apache-brooklyn-{{ book.brooklyn_version }}</code> folder.
{% endif %}

{% if 'SNAPSHOT' in book.brooklyn_version %}
<pre><code class="lang-sh">$ tar -zxf apache-brooklyn-dist-{{ book.brooklyn_version }}-timestamp-dist.tar.gz
$ cd apache-brooklyn-{{ book.brooklyn_version }}</code></pre>
{% else %}
<pre><code class="lang-sh">tar -zxf apache-brooklyn-{{ book.brooklyn_version }}-dist.tar.gz
$ cd apache-brooklyn-{{ book.brooklyn_version }}</code></pre>
{% endif %}


{% sample lang="windows" -%}
### Installing on Windows

For all versions of Microsoft Windows, please download the Apache Brooklyn zip file from [here]({{book.path.website}}/download/). 

Extract this zip file to a directory on your computer such as `c:\Program Files\brooklyn` where `c` is the letter of your operating system drive.

{% endmethod %}

By default, no authentication is required and the web-console will listen on all network interfaces.
For a production system, or if Apache Brooklyn is publicly reachable, it is strongly recommended 
to configure security. Documentation of configuration options include:
 
* [Security](../ops/configuration/brooklyn_cfg.md)
* [Persistence](../ops/persistence/index.md)
* [Cloud credentials](../locations/index.md)


## Launch Apache Brooklyn

{% method -%}

{% common -%}
**Important**: Before launching Apache Brooklyn, please check the `date` on the local machine.
Even several minutes before or after the actual time could cause problems.

{% sample lang="vagrant" -%}
### Launching in Vagrant

Now start Apache Brooklyn with the following command:

```bash
$ vagrant up brooklyn
```

You can see if Apache Brooklyn launched OK by viewing the log files with the command

```bash
$ vagrant ssh brooklyn --command 'sudo journalctl -n15 -f -u brooklyn'
```

{% sample lang="centos" -%}
### Launching on CentOS & Red Hat Enterprise Linux 7

Apache Brooklyn should now have been installed and be running as a system service. It can stopped and started with the standard systemctl commands:

```bash
$ systemctl start|stop|restart|status brooklyn
```

The application should then output its logs to `brooklyn.debug.log` and `brooklyn.info.log`, please refer to the [paths](../ops/paths.md) page for the locations of these.

{% sample lang="ubuntu" -%}
### Launching on Ubuntu & Debian

Apache Brooklyn should now have been installed and be running as a system service. It can be stopped and started with the standard service commands:

```bash
$ sudo service brooklyn start|stop|restart|status
```

The application should then output its logs to `brooklyn.debug.log` and `brooklyn.info.log`, please refer to the [paths](../ops/paths.md) page for the locations of these.

{% sample lang="osx" -%}
### Launching on other Linux distributions, OSX and other UNIX-like platforms

Now start Apache Brooklyn with the following command:

```bash
$ bin/start
```

The application should then output its log to `brooklyn.debug.log` and `brooklyn.info.log`, please refer to the [paths](../ops/paths.md) page for the locations of these.

{% sample lang="windows" -%}
### Launching on Windows

You can now start Apache Brooklyn by running `c:\Program Files\brooklyn\bin\start.bat`

The application should then output its log into the console and also `c:\Program Files\brooklyn\data\log\brooklyn.debug.log` and `c:\Program Files\brooklyn\data\log\brooklyn.info.log`

{% endmethod %}

## Control Apache Brooklyn

Apache Brooklyn has a web console which can be used to control the application. The Brooklyn log will contain the 
address of the management interface:

<pre>
INFO  Started Brooklyn console at http://127.0.0.1:8081/, running classpath://brooklyn.war
</pre>

By default it can be accessed by opening [127.0.0.1:8081](http://127.0.0.1:8081) in your web browser.

The rest of this getting started guide uses the Apache Brooklyn command line interface (CLI) tool, `br`. 
This tool is both distributed with Apache Brooklyn or can be downloaded {% if 'SNAPSHOT' in book.brooklyn_version %}
from [here](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=brooklyn-client-cli&v={{book.brooklyn_version}}&c=bin&e=zip).
{% else %}
using the most appropriate link for your OS:

* [Windows](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn_version}}/apache-brooklyn-{{book.brooklyn_version}}-client-cli-windows.zip)
* [Linux](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn_version}}/apache-brooklyn-{{book.brooklyn_version}}-client-cli-linux.tar.gz)
* [OSX](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn_version}}/apache-brooklyn-{{book.brooklyn_version}}-client-cli-macosx.tar.gz)
{% endif %}

For details on the CLI, see the [Client CLI Reference]({{ book.path.guide }}/ops/cli/) page. 

{% if output.name == 'website' %}
## Next
The first thing we want to do with Brooklyn is **[deploy a blueprint](blueprints.md)**.
{% endif %}
