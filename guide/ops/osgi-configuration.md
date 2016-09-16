---
title: OSGi Configuration
layout: website-normal
---

Configuration of Brooklyn when running under Karaf is largely done through standard Karaf mechanisms. 
The Karaf "Configuration Admin" subsystem is used to manage configuration values loaded at first boot from the
`.cfg` files in the `etc` directory of the distribution. In the Karaf command line these can then be viewed
and manipulated by the `config:` commands, see the Karaf documentation for full details.

## Configuring Brooklyn Properties

To configure the Brooklyn runtime create an `etc/brooklyn.cfg` file, following the standard `brooklyn.properties`
file format. Values can be viewed and managed dynamically via the OSGI configuration admin commands in Karaf,
e.g. `config:property-set`. The global `~/.brooklyn/brooklyn.properties` is still supported and has higher
priority for duplicate keys, but it's values can't be manipulated with the Karaf commands, so its use is
discouraged.

You can use the standard `~/.brooklyn/brooklyn.properties` file to configure Brooklyn. Alternatively
create `etc/brooklyn.cfg` inside the distribution folder (same file format). The keys in the former override
those in the latter.

Web console related configuration is done through the corresponding Karaf mechanisms:

  * The port is set in `etc/org.ops4j.pax.web.cfg`, key `org.osgi.service.http.port`.
  * For authentication the JAAS realm "webconsole" is used; by default it will use any
    SecurityProvider implementations configured in Brooklyn falling back to auto generating
    the password. To configure a custom JAAS realm see the `jetty.xml` file in `brooklyn-server/karaf/jetty-config/src/main/resources`
    and override it by creating a custom one in `etc` folder. Point the "webconsole" login service
    to the JAAS realm you would like to use.
   * For other Jetty related configuration consult the Karaf and pax-web docs.

## HTTPS Configuration

See [HTTPS Configuration](https.html) for general information on configuring HTTPS.

In `etc/org.ops4j.pax.web.cfg` in the Brooklyn Karaf distribution root, un-comment the settings:

{% highlight properties %}
org.osgi.service.http.port.secure=8443
org.osgi.service.http.secure.enabled=true
org.ops4j.pax.web.ssl.keystore=${karaf.home}/etc/keystores/keystore.jks
org.ops4j.pax.web.ssl.password=password
org.ops4j.pax.web.ssl.keypassword=password
org.ops4j.pax.web.ssl.clientauthwanted=false
org.ops4j.pax.web.ssl.clientauthneeded=false
{% endhighlight %}

replacing the passwords with appropriate values, and restart the server. Note the keystore location is relative to 
the installation root, but a fully qualified path can also be given, if it is desired to use some separate pre-existing
store.


<!--
----------
-- NOTE: comment out this section on catalog as the behaviour described is not enabled by default since
-- https://github.com/apache/brooklyn-server/pull/233; re-enable this when that changes
----------
## Catalog in Karaf  
With the traditional launcher, Brooklyn loads the initial contents of the catalog from a `default.catalog.bom` file
as described in the section on [installation](/guide/ops/production-installation.html). Brooklyn finds Java 
implementations to provide for certain things in blueprints (entities, enrichers etc.) by scanning the classpath. 

In the OSGI world this approach is not used, as each bundle only has visibility of its own and its imported Java packages. 
Instead, in Karaf, each bundle can declare its own `catalog.bom` file, in the root of the bundle,
with the catalog declarations for any entities etc. that the bundle contains.

For example, the `catalog.bom` file for Brooklyn's Webapp bundle looks like (abbreviated):

    brooklyn.catalog:
        version: ...
        items:
        - id: org.apache.brooklyn.entity.webapp.nodejs.NodeJsWebAppService
          itemType: entity
          item:
            type: org.apache.brooklyn.entity.webapp.nodejs.NodeJsWebAppService
            name: Node.JS Application
        ...
        - id: resilient-bash-web-cluster-template
          itemType: template
          name: "Template: Resilient Load-Balanced Bash Web Cluster with Sensors"
          description: |
            Sample YAML to provision a cluster of the bash/python web server nodes,
            with sensors configured, and a load balancer pointing at them,
            and resilience policies for node replacement and scaling
          item:
            name: Resilient Load-Balanced Bash Web Cluster (Brooklyn Example)

In the above YAML the first item declares that the bundle provides an entity whose type is
`org.apache.brooklyn.entity.webapp.nodejs.NodeJsWebAppService`, and whose name is 'Node.JS Application'.  The second
item declares that the bundle provides a template application, with id  `resilient-bash-web-cluster-template`, and
includes a description for what this is.

## Configuring the applications in the Catalog

When running some particular deployment of Brooklyn it may not be desirable for the sample applications to appear in
the catalog (for clarity, "application" here in the sense of an item with `itemType: template`).
For example, if you have developed
some bundle with your own application and added it to Karaf then you might want only your own application to appear in
the catalog.

Brooklyn contains a mechanism to allow you to configure what bundles will add their applications to the catalog.
The Karaf configuration file `/etc/org.apache.brooklyn.core.catalog.bomscanner.cfg` contains two properties,
one `whitelist` and the other `blacklist`, that bundles must satisfy for their applications to be added to the catalog.
Each property value is a comma-separated list of regular expressions.  The symbolic id of the bundle must match one of
the regular expressions on the whitelist, and not match any expression on the blacklist, if its applications
are to be added to the bundle.  The default values of these properties are to admit all bundles, and forbid none.

## Caveats

In the OSGi world specifying class names by string in Brooklyn's configuration will work only
for classes living in Brooklyn's core modules. Raise an issue or ping us on IRC if you find
a case where this doesn't work for you. For custom SecurityProvider implementations refer to the
documentation of BrooklynLoginModule.
    
 END Catalog in Karaf comment -->


