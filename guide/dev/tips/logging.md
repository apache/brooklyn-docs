---
title: Logging
layout: website-normal
---

## Logging for Developers: A Quick Overview

For logging, we use **log4j** which implements the slf4j API.
This means you can use any slf4j compliant logging framework,
with a default configuration which just works out of the box
and bindings to the other common libraries (``java.util.logging``, ``logback``, ...)
if you prefer one of those.


### OSGi based Apache Brooklyn

While developing it may be useful to change logging level of some of the Apache Brooklyn modules.
The easiest way to do that is via the karaf console which can be started by `bin/client`.
(Details regarding using [Apache Brooklyn Karaf console](../../blueprints/java/bundle-dependencies.html#karaf-console))
For example if you would like to inspect jclouds API calls, enable jclouds.wire logging just enable it from karaf client.

    log:set DEBUG jclouds.wire

To check other log levels.

    log:list

If for some reason log level needs modified before the first start of Karaf
then you can modify the config file `etc/org.ops4j.pax.logging.cfg` before hand.
For more information check
[https://ops4j1.jira.com/wiki/display/paxlogging/Configuration](https://ops4j1.jira.com/wiki/display/paxlogging/Configuration).

#### Karaf Log commands

Logging commands are available through the karaf console.  These let you interact with the logs and dynamically change
logging configuration in a running application.

Some useful log: commands are:

log:display mylogger -p "%d - %c - %m%n"    - Show the log entries for a specific logger with a different pattern.

log:get/set                                 - Show / set the currently configured log levels

log:tail                                    - As display but will show continuously

log:exception-display                       - Display the last exception
 
#### Bundles

You can capture logs from a specific bundle or set of bundles and e.g. write that to a different file.

    log4j.appender.sift=org.apache.log4j.sift.MDCSiftingAppender
    log4j.appender.sift.key=myBundle
    log4j.appender.sift.default=karaf
    log4j.appender.sift.appender=org.apache.log4j.FileAppender
    log4j.appender.sift.appender.layout=org.apache.log4j.PatternLayout
    log4j.appender.sift.appender.layout.ConversionPattern=%d{ISO8601} | %-5.5p | %-16.16t | %-32.32c{1} | %m%n
    log4j.appender.sift.appender.file=${karaf.data}/log/mybundle.debug.log
    log4j.appender.sift.appender.append=true

For a detailed reference to the sift appender see [Karaf Advanced configuration](https://karaf.apache.org/manual/latest/#_advanced_configuration)

### Classic - non-OSGI based Apache Brooklyn

To use:

* **Users**:
If using a brooklyn binary installation, simply edit the ``logback.xml``
or ``logback-custom.xml`` supplied in the archive, sometimes in a ``conf/``
directory.

* **Developers**:
When setting up a new project, if you want logging it is recommended to include 
the ``brooklyn-logback-xml`` project as an *optional* and *provided* maven dependency, 
and then to put custom logging configuration in either ``logback-custom.xml`` or ``logback-main.xml``, 
as described below.


#### Customizing Your Logging

The project ``brooklyn-logback-xml`` supplies a ``logback.xml`` configuration,
with a mechanism which allows it to be easily customized, consumed, and overridden.
You may wish to include this as an *optional* dependency so that it is not forced
upon downstream projects.  This ``logback.xml`` file supplied contains just one instruction,
to include ``logback-main.xml``, and that file in turn includes:

* ``logback-custom.xml``
* ``brooklyn/logback-appender-file.xml``
* ``brooklyn/logback-appender-stdout.xml``
* ``brooklyn/logback-logger-excludes.xml``
* ``brooklyn/logback-debug.xml``
   
For the most common customizations, simply create a ``logback-custom.xml`` on your classpath
(ensuring it is loaded *before* brooklyn classes in classpath ordering in the pom)
and supply your customizations there:  

{% highlight xml %}
<included>
    <!-- filename to log to -->           
    <property name="logging.basename" scope="context" value="acme-app" />
    
    <!-- additional loggers -->
    <logger name="com.acme.app" level="DEBUG"/>
</included>
{% endhighlight %}

For other configuration, you can override individual files listed above.
For example:

* To remove debug logging, create a trivial ``brooklyn/logback-debug.xml``, 
  containing simply ``<included/>``.
* To customise stdout logging, perhaps to give it a threshhold WARN instead of INFO,
  create a ``brooklyn/logback-appender-stdout.xml`` which defines an appender STDOUT.
* To discard all brooklyn's default logging, create a ``logback-main.xml`` which 
  contains your configuration. This should look like a standard logback
  configuration file, except it should be wrapped in ``<included>`` XML tags rather
  than ``<configuration>`` XML tags (because it is included from the ``logback.xml``
  which comes with ``brooklyn-logback-xml``.)
* To redirect all jclouds logging to a separate file include ``brooklyn/logback-logger-debug-jclouds.xml``.
  This redirects all logging from ``org.jclouds`` and ``jclouds`` to one of two files: anything
  logged from Brooklyn's persistence thread will end up in a `persistence.log`, everything else
  will end up in ``jclouds.log``.

You should **not** supply your own ``logback.xml`` if you are using ``brooklyn-logback-xml``.
If you do, logback will detect multiple files with that name and will scream at you.
If you wish to supply your own ``logback.xml``, do **not** include ``brooklyn-logback-xml``.
(Alternatively you can include a ``logback.groovy`` which causes logback to ignore ``logback.xml``.)

You can set a specific logback config file to use with:

{% highlight bash %}
-Dlogback.configurationFile=/path/to/config.xml
{% endhighlight %}


#### Assemblies

When building an assembly, it is recommended to create a ``conf/logback.xml`` which 
simply includes ``logback-main.xml`` (which comes from the classpath).  Users of the assembly
can then edit the ``logback.xml`` file in the usual way, or they can plug in to the configuration 
mechanisms described above, by creating files such as ``logback-custom.xml`` under ``conf/``.

Including ``brooklyn-logback-xml`` as an *optional* and *provided* dependency means everything
should work correctly in IDE's but it will not include the extra ``logback.xml`` file in the assembly.
(Alternatively if you include the ``conf/`` dir in your IDE build, you should exclude this dependency.)

With this mechanism, you can include ``logback-custom.xml`` and/or other files underneath 
``src/main/resources/`` of a project, as described above (for instance to include custom
logging categories and define the log file name) and it should get picked up, 
both in the IDE and in the assembly.   

#### Tests

For unit testing, where no karaf context exits, Brooklyn uses logback.  Brooklyn project's ``test`` scope includes the ``brooklyn-utils-test-support`` project
which supplies a ``logback-test.xml``. logback uses this file in preference to ``logback.xml``
when available (ie when running tests). 

#### Caveats

* If you're not getting the logging you expect in the IDE, make sure 
  ``src/main/resources`` is included in the classpath.
  (In eclipse, right-click the project, the Build Path -> Configure,
  then make sure all dirs are included (All) and excluded (None) -- 
  ``mvn clean install`` should do this for you.)

* You may find that your IDE logs to a file ``brooklyn-tests.log`` 
  if it doesn't distinguish between test build classpaths and normal classpaths.

* Logging configuration using file overrides such as this is very sensitive to
  classpath order. To get a separate `brooklyn-tests.log` file during testing,
  for example, the `brooklyn-test-support` project with scope `test` must be
  declared as a dependency *before* `brooklyn-logback-includes`, due to the way
  both files declare `logback-appender-file.xml`.
  
* Similarly note that the `logback-custom.xml` file is included *after* 
  logging categories and levels are declared, but before appenders are declared,
  so that logging levels declared in that file dominate, and that 
  properties from that file apply to appenders.

* Finally remember this is open to improvement. It's the best system we've found
  so far but we welcome advice. In particular if it could be possible to include
  files from the classpath with wildcards in alphabetical order, we'd be able
  to remove some of the quirks listed above (though at a cost of some complexity!).
