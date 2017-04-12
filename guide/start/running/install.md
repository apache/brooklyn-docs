---
section: Install Apache Brooklyn
section_type: inline
section_position: 1
---

## Install Apache Brooklyn

{::options parse_block_html="true" /}

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">Vagrant</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Centos / RHEL 7</a></li>
    <li class="impl-3-tab"><a data-target="#impl-3, .impl-3-tab" data-toggle="tab" href="#">OSX / Linux</a></li>
    <li class="impl-4-tab"><a data-target="#impl-4, .impl-4-tab" data-toggle="tab" href="#">Windows</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

<strong class="hidden started-pdf-include">a) Vagrant</strong>

[Vagrant](https://www.vagrantup.com/){:target="_blank"} is a software package which automates the process of setting up virtual machines (VM) such as [Oracle VirtualBox](https://www.virtualbox.org){:target="_blank"}. We recommend it as the easiest way of getting started with Apache Brooklyn.

Firstly, download and install:

 * [Vagrant](https://www.vagrantup.com/downloads.html){:target="_blank"}
 * [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads){:target="_blank"}
 
Then download the provided Apache Brooklyn vagrant configuration from [here](https://www.apache.org/dyn/closer.lua?action=download&filename=brooklyn/apache-brooklyn-{{site.brooklyn-version}}/apache-brooklyn-{{site.brooklyn-version}}-vagrant.tar.gz){:target="_blank"}. This archive contains everything you need to create an environment for use with this guide, providing an Apache Brooklyn instance and some blank VMs.

Extract the `tar.gz` archive and navigate into the expanded `apache-brooklyn-{{site.brooklyn-version}}-vagrant` folder

{% highlight bash %}
$ tar xvf apache-brooklyn-{{site.brooklyn-version}}-vagrant.tar.gz
$ cd apache-brooklyn-{{site.brooklyn-version}}-vagrant
{% endhighlight %}


</div>
<div id="impl-2" class="tab-pane fade">

<strong class="hidden started-pdf-include">b) Centos / RHEL 7</strong>

For Centos 7 and RHEL 7 users, the recommended way to install Apache Brooklyn on RPM-based Linux distributions is by using the RPM package. 

RPM is the de facto standard for packaging software on these Linux distributions and provides a mechanism for installing, upgrading and removing packages such as Apache Brooklyn. The RPM package contains all the necessary files associated with the Apache Brooklyn application. 

Download the Apache Brooklyn [RPM distribution](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}-1.noarch.rpm){:target="_blank"}.

Once downloaded, run the following shell command as root:

{% highlight bash %}
$ yum install apache-brooklyn-{{site.brooklyn-version}}-1.rpm
{% endhighlight %}

</div>
<div id="impl-3" class="tab-pane fade">

<strong class="hidden started-pdf-include">c) OSX / Linux</strong>

For Linux or OSX please download the Apache Brooklyn `tar.gz` archive from the [download]({{site.path.website}}/download/){:target="_blank"} section.

{% if brooklyn_version contains 'SNAPSHOT' %}
Extract the `tar.gz` archive (note: as this is a -SNAPSHOT version, your filename will be slightly different):
{% else %}
Extract the `tar.gz` archive and navigate into the expanded `apache-brooklyn-{{ site.brooklyn-version }}` folder.
{% endif %}

{% if brooklyn_version contains 'SNAPSHOT' %}
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
<div id="impl-4" class="tab-pane fade">

<strong class="hidden started-pdf-include">d) Windows</strong>

For all versions of Microsoft Windows, please download the Apache Brooklyn zip file from [here]({{site.path.website}}/download/){:target="_blank"}. 

Extract this zip file to a directory on your computer such as `c:\Program Files\brooklyn` where `c` is the letter of your operating system drive.

</div>
</div>

---

It is not necessary at this time, but depending on what you are going to do, 
you may wish to set up other configuration options first:
 
* [Security](../ops/brooklyn_properties.html)
* [Persistence](../ops/persistence/)
* [Cloud credentials](../locations/)