---
title: FAQ
layout: website-normal
---

# Running Apache Brooklin inside Karaf container

The Apache Brooklyn Karaf based distribution lives in brooklyn-server/karaf/apache-brooklyn folder.

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

To start in debug mode use

{% highlight bash %}
bin/karaf debug
{% endhighlight %}

and connect to port 5005 using your debugger.

To pause startup until the debugger is connected you can use

{% highlight bash %}
JAVA_DEBUG_OPTS='-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005' bin/karaf debug
{% endhighlight %}

## Configuring

You can use the standard ~/.brooklyn/brooklyn.properties file to configure Brooklyn. Alternatively
create etc/brooklyn.cfg inside the distribution folder (same file format). The keys in the former override
those in the latter.

Web console related configuration is done through the corresponding Karaf mechanisms:
  * The port is set in etc/org.ops4j.pax.web.cfg, key org.osgi.service.http.port.
  * For authentication the JAAS realm "webconsole" is used; by default it will use any
    SecurityProvider implementations configured in Brooklyn falling back to auto generating
    the password. To configure a custom JAAS realm see the jetty.xml file in "brooklyn-server/karaf/jetty-config/src/main/resources"
    and override it by creating a custom one in "etc" folder. Point the "webconsole" login service
    to the JAAS realm you would like to use.
   * For other Jetty related configuration consult the Karaf and pax-web docs.


## Caveats

In the OSGi world specifying class names by string in Brooklyn's configuraiton will work only
for classes living in Brooklyn's core modules. Raise an issue or ping us on IRC if you find
a case where this doesn't work for you. For custom SecurityProvider implementations refer to the
documentation of BrooklynLoginModule.
