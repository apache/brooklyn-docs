---
title: OSGi Distribution
layout: website-normal
children:
- osgi-configuration.md
---

# Running Apache Brooklyn inside Karaf container

The Apache Brooklyn Karaf based distribution lives in brooklyn-dist/karaf/apache-brooklyn folder.
It's still in a testing stage so some features might not work as expected. Please contact us on the 
[mailing list](mailto:dev@brooklyn.apache.org) if you find any problems.

## Building

{% highlight bash %}
cd brooklyn-dist
mvn clean install
cd karaf/apache-brooklyn/target
tar -zxvf apache-brooklyn-{{ site.brooklyn-version }}.tar.gz
cd apache-brooklyn-{{ site.brooklyn-version }}
{% endhighlight %}

## Running

Start the instance with a console in the foreground using the following command

{% highlight bash %}
bin/karaf
{% endhighlight %}

This will launch the [Karaf console](http://karaf.apache.org/manual/latest/)
where you can interact with the running instance. Note that Brooklyn has already started at this point
and is reachable at the usual web console url.

To start in debug mode use

{% highlight bash %}
bin/karaf debug
{% endhighlight %}

and connect to port 5005 using your normal Java debugger.

To pause startup until the debugger is connected you can use

{% highlight bash %}
JAVA_DEBUG_OPTS='-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005' bin/karaf debug
{% endhighlight %}


Start the instance as a server in the background using the following command

{% highlight bash %}
bin/start
{% endhighlight %}

The Karaf container will keep state such as installed bundles and configuration between restarts.
To reset any changes add **clean** to the cli arguments.

## Configuring

Configuration of Brooklyn when running under Karaf is largely done through standard Karaf mechanisms. 
See the page on [OSGI Configuration](osgi-configuration.html) for details.