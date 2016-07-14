---
title: Running Apache Brooklyn
title_in_menu: Running Apache Brooklyn
layout: website-normal
menu_parent: index.md
---

This guide will walk you through deploying an example 3-tier web application to a public cloud, and demonstrate the autoscaling capabilities of the Brooklyn platform.

Two methods of deployment are detailed in this tutorial, using virtualisation with Vagrant and an install in your own environment (such as your local machine or in your private/public cloud). 

The latter assumes that you have a [Java Runtime Environment (JRE)](https://www.java.com){:target="_blank"} installed (version 7 or later), as Brooklyn is Java under the covers. 

To get you up-and-running quickly, the Vagrant option will provision four compute nodes for you to deploy applications to. 

## Install Apache Brooklyn

{::options parse_block_html="true" /}

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">Vagrant</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Centos / RHEL 7</a></li>
    <li class="impl-3-tab"><a data-target="#impl-3, .impl-3-tab" data-toggle="tab" href="#">Ubuntu / Debian</a></li>
    <li class="impl-4-tab"><a data-target="#impl-4, .impl-4-tab" data-toggle="tab" href="#">OSX / Linux</a></li>
    <li class="impl-5-tab"><a data-target="#impl-5, .impl-5-tab" data-toggle="tab" href="#">Windows</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

<strong class="hidden started-pdf-include">a) Vagrant</strong>

[Vagrant](https://www.vagrantup.com/){:target="_blank"} is a software package which automates the process of setting up virtual machines (VM) such as [Oracle VirtualBox](https://www.virtualbox.org){:target="_blank"}. We recommend it as the easiest way of getting started with Apache Brooklyn.

Firstly, download and install:

 * [Vagrant](https://www.vagrantup.com/downloads.html){:target="_blank"}
 * [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads){:target="_blank"}
 
Then download the provided Apache Brooklyn vagrant configuration from {% if site.brooklyn-version contains 'SNAPSHOT' %}
from [here](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=brooklyn-vagrant&v={{site.brooklyn-version}}&c=dist&e=zip){:target="_blank"}.
{% else %}
[here](https://www.apache.org/dyn/closer.lua?action=download&filename=brooklyn/apache-brooklyn-{{site.brooklyn-version}}/apache-brooklyn-{{site.brooklyn-version}}-vagrant.tar.gz){:target="_blank"}.
{% endif %} This archive contains everything you need to create an environment for use with this guide, providing an Apache Brooklyn instance and some blank VMs.

Extract the `tar.gz` archive and navigate into the expanded `apache-brooklyn-{{site.brooklyn-version}}-vagrant` folder {% if site.brooklyn-version contains 'SNAPSHOT' %}(note: as this is a -SNAPSHOT version, your filename will be slightly different){% endif %}

{% highlight bash %}
$ tar xvf apache-brooklyn-{{site.brooklyn-version}}-vagrant.tar.gz
$ cd apache-brooklyn-{{site.brooklyn-version}}-vagrant
{% endhighlight %}


</div>
<div id="impl-2" class="tab-pane fade">

<strong class="hidden started-pdf-include">b) Centos / RHEL 7</strong>

{% if site.brooklyn-version contains 'SNAPSHOT' %}<strong>Please note, an RPM is not available for snapshot builds</strong>{% endif %}

For Centos 7 and RHEL 7 users, the recommended way to install Apache Brooklyn on RPM-based Linux distributions is by using the RPM package. 

RPM is the de facto standard for packaging software on these Linux distributions and provides a mechanism for installing, upgrading and removing packages such as Apache Brooklyn. The RPM package contains all the necessary files associated with the Apache Brooklyn application. 

{% if site.brooklyn-version contains 'SNAPSHOT' %}
This is a snapshot build and no RPM is available, please download [a different version]({{site.path.website}}/download/).
{% else %}
Download the Apache Brooklyn [RPM distribution](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}/apache-brooklyn-{{site.brooklyn-version}}-1.noarch.rpm){:target="_blank"}.
{% endif %}

Once downloaded, run the following shell command as root:

{% highlight bash %}
$ yum install apache-brooklyn-{{site.brooklyn-version}}-1.rpm
{% endhighlight %}

</div>
<div id="impl-3" class="tab-pane fade">

<strong class="hidden started-pdf-include">c) Debian / Ubuntu</strong>

For Ubuntu and Debian users, the recommended way to install Apache Brooklyn is to use the deb file. 

The deb file is the de facto standard for packaging software on these Linux distributions and provides a mechanism for installing, upgrading and removing packages such as Apache Brooklyn. The deb package contains all the necessary files associated with the Apache Brooklyn application. 

{% if site.brooklyn-version contains 'SNAPSHOT' %}
Download the Apache Brooklyn [deb distribution](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=deb-packaging&v={{site.brooklyn-version}}&e=deb){:target="_blank"}.
{% else %}
Download the Apache Brooklyn [deb distribution](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn_{{site.brooklyn-version}}_noarch.deb){:target="_blank"}.
{% endif %}

Once downloaded, run the following shell command:

{% highlight bash %}
$ sudo dpkg -i apache-brooklyn_{{site.brooklyn-version}}_noarch.deb
{% endhighlight %}

</div>
<div id="impl-4" class="tab-pane fade">

<strong class="hidden started-pdf-include">d) OSX / Linux</strong>

For Linux or OSX please download the Apache Brooklyn `tar.gz` archive from the [download]({{site.path.website}}/download/){:target="_blank"} section.

{% if site.brooklyn-version contains 'SNAPSHOT' %}
Extract the `tar.gz` archive (note: as this is a -SNAPSHOT version, your filename will be slightly different):
{% else %}
Extract the `tar.gz` archive and navigate into the expanded `apache-brooklyn-{{ site.brooklyn-version }}` folder.
{% endif %}

{% if site.brooklyn-version contains 'SNAPSHOT' %}
{% highlight bash %}
$ tar -zxf apache-brooklyn-dist-{{ site.brooklyn-version }}-timestamp-dist.tar.gz
$ cd apache-brooklyn-{{ site.brooklyn.version }}
{% endhighlight %}
{% else %}
{% highlight bash %}
$ tar -zxf apache-brooklyn-{{ site.brooklyn-version }}-dist.tar.gz
$ cd apache-brooklyn-{{ site.brooklyn.version }}
{% endhighlight %}
{% endif %}

</div>
<div id="impl-5" class="tab-pane fade">

<strong class="hidden started-pdf-include">e) Windows</strong>

For all versions of Microsoft Windows, please download the Apache Brooklyn zip file from [here]({{site.path.website}}/download/){:target="_blank"}. 

Extract this zip file to a directory on your computer such as `c:\Program Files\brooklyn` where `c` is the letter of your operating system drive.

</div>
</div>

---

It is not necessary at this time, but depending on what you are going to do, 
you may wish to set up other configuration options first:
 
* [Security](../ops/brooklyn_properties.html)
* [Persistence](../ops/persistence/)
* [Cloud credentials](../ops/locations/)

## Launch Apache Brooklyn

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">Vagrant</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Centos / RHEL</a></li>
    <li class="impl-3-tab"><a data-target="#impl-3, .impl-3-tab" data-toggle="tab" href="#">Ubuntu / Debian</a></li>
    <li class="impl-4-tab"><a data-target="#impl-4, .impl-4-tab" data-toggle="tab" href="#">OSX / Linux</a></li>
    <li class="impl-5-tab"><a data-target="#impl-5, .impl-5-tab" data-toggle="tab" href="#">Windows</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

<strong class="hidden started-pdf-include">a) Vagrant</strong>

Now start Apache Brooklyn with the following command:

{% highlight bash %}
$ vagrant up brooklyn
{% endhighlight %}

You can see if Apache Brooklyn launched OK by viewing the log files with the command

{% highlight bash %}
$ vagrant ssh brooklyn --command 'sudo journalctl -n15 -f -u brooklyn'
{% endhighlight %}


</div>
<div id="impl-2" class="tab-pane fade">

<strong class="hidden started-pdf-include">b) Centos / RHEL 7</strong>

Apache Brooklyn should now have been installed and be running as a system service. It can stopped and started with the standard systemctl commands:

{% highlight bash %}
$ systemctl start|stop|restart|status brooklyn
{% endhighlight %}

The application should then output its logs to `/var/log/brooklyn/apache-brooklyn.debug.log` and `/var/log/brooklyn/apache-brooklyn.info.log`.

</div>
<div id="impl-3" class="tab-pane fade">

<strong class="hidden started-pdf-include">c) Ubuntu / Debian</strong>

Apache Brooklyn should now have been installed and be running as a system service. It can stopped and started with the standard service commands:

{% highlight bash %}
$ sudo service brooklyn start|stop|restart|status
{% endhighlight %}

The application should then output its logs to `/var/log/brooklyn/apache-brooklyn.debug.log` and `/var/log/brooklyn/apache-brooklyn.info.log`.

</div>
<div id="impl-4" class="tab-pane fade">

<strong class="hidden started-pdf-include">d) OSX / Linux</strong>

Now start Apache Brooklyn with the following command:

{% highlight bash %}
$ bin/brooklyn launch
{% endhighlight %}

The application should then output its log into the console and also `apache-brooklyn.debug.log` and `apache-brooklyn.info.log`

</div>
<div id="impl-5" class="tab-pane fade">

<strong class="hidden started-pdf-include">e) Windows</strong>

You can now start Apache Brooklyn by running `c:\Program Files\brooklyn\bin\brooklyn.bat`

The application should then output its log into the console and also `c:\Program Files\brooklyn\apache-brooklyn.debug.log` and `c:\Program Files\brooklyn\apache-brooklyn.info.log`

</div>
</div>

---

## Control Apache Brooklyn

Apache Brooklyn has a web console which can be used to control the application. The Brooklyn log will contain the 
address of the management interface:

<pre>
INFO  Started Brooklyn console at http://127.0.0.1:8081/, running classpath://brooklyn.war
</pre>

By default it can be accessed by opening [127.0.0.1:8081](http://127.0.0.1:8081){:target="_blank"} in your web browser.

The rest of this getting started guide uses the Apache Brooklyn command line interface (CLI) tool, `br`. 
This tool is both distributed with Apache Brooklyn or can be downloaded {% if site.brooklyn-version contains 'SNAPSHOT' %}
from [here](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=brooklyn-client-cli&v={{site.brooklyn-version}}&c=bin&e=zip).
{% else %}
using the most appropriate link for your OS:

* [Windows](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}/apache-brooklyn-{{site.brooklyn-version}}-client-cli-windows.zip)
* [Linux](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}/apache-brooklyn-{{site.brooklyn-version}}-client-cli-linux.tar.gz)
* [OSX](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}/apache-brooklyn-{{site.brooklyn-version}}-client-cli-macosx.tar.gz)
{% endif %}

For details on the CLI, see the [Client CLI Reference](../ops/cli/) page. 


## Next

<div class="started-pdf-exclude">

The first thing we want to do with Brooklyn is **[deploy a blueprint](blueprints.html)**.

</div>
