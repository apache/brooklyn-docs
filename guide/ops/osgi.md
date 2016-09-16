---
title: OSGi Distribution
layout: website-normal
children:
- osgi-configuration.md
---

# Running Apache Brooklyn inside Karaf container

The Apache Brooklyn Karaf based distribution lives in brooklyn-server/karaf/apache-brooklyn folder.
It's still in a testing stage so some features might not work as expected. Do reach out if you
find any problems.

## Building

{% highlight bash %}
cd brooklyn-server
mvn clean install
cd karaf/apache-brooklyn/target
tar -zxvf apache-brooklyn-{{ site.brooklyn-version }}.tar.gz
cd apache-brooklyn-{{ site.brooklyn-version }}
{% endhighlight %}

## Running

Start the instance using the following command

{% highlight bash %}
bin/karaf
{% endhighlight %}

This will launch the [Karaf console](https://karaf.apache.org/manual/latest/users-guide/console.html)
where you can interact with the running instance. Note that Brooklyn has already started at this point
and is reachable at the usual web console url.

To start in debug mode use

{% highlight bash %}
bin/karaf debug
{% endhighlight %}

and connect to port 5005 using your debugger.

To pause startup until the debugger is connected you can use

{% highlight bash %}
JAVA_DEBUG_OPTS='-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005' bin/karaf debug
{% endhighlight %}

The Karaf container will keep state like installed bundles and configuration between restarts.
To reset any changes add **clean** to the cli arguments.

## Configuring

Configuration of Brooklyn when running under Karaf is largely done through standard Karaf mechanisms. 
See the page on [OSGI Configuration](osgi-configuration.html) for details.