---
title_in_menu: Configuring Brooklyn
title: Brooklyn Configuration and Options
layout: website-normal
children:
- { section: Memory Usage }
- { section: Authentication }
- brooklyn_cfg.md
- https.md
- cors.md
---

Apache Brooklyn contains a number of configuration options managed across several files. 
Historically Brooklyn has been configured through a brooklyn.properties file, this changed 
to a [brooklyn.cfg](brooklyn_cfg) file when the Karaf release became the default in Brooklyn 0.12.0.

The configurations for [persistence](/guide/ops/persistence) and [high availability](/guide/ops/high-availability) are described
elsewhere in this manual.

Configuration of Apache Brooklyn when running under Karaf is largely done through standard Karaf mechanisms. 
The Karaf "Configuration Admin" subsystem is used to manage configuration values loaded at first boot from the
`.cfg` files in the `etc` directory of the distribution. In the Karaf command line these can then be viewed
and manipulated by the `config:` commands, see the [Karaf documentation](https://karaf.apache.org/manual/latest/) for full details.

## Configuring Brooklyn Properties

To configure the Brooklyn runtime create an `etc/brooklyn.cfg` file. If you have previously used `brooklyn.properties` it follows the same
file format. Values can be viewed and managed dynamically via the OSGI configuration admin commands in Karaf,
e.g. `config:property-set`. The global `~/.brooklyn/brooklyn.properties` is still supported and has higher
priority for duplicate keys, but its values can't be manipulated with the Karaf commands, so its use is
discouraged.

You can use the standard `~/.brooklyn/brooklyn.properties` file to configure Brooklyn. Alternatively
create `etc/brooklyn.cfg` inside the distribution folder (same file format). The keys in the former override
those in the latter.

Web console related configuration is done through the corresponding Karaf mechanisms:

  * The port is set in `etc/org.ops4j.pax.web.cfg`, key `org.osgi.service.http.port`.
  * For authentication the JAAS realm "webconsole" is used; by default it will use any
    SecurityProvider implementations configured in Brooklyn falling back to auto generating
    the password. To configure a custom JAAS realm see the `jetty.xml` file in 
    `brooklyn-server/karaf/jetty-config/src/main/resources`
    and override it by creating a custom one in `etc` folder. Point the "webconsole" login service
    to the JAAS realm you would like to use.
   * For other Jetty related configuration consult the Karaf and pax-web docs.

### Memory Usage

The amount of memory required by Apache Brooklyn process depends on the usage - for example the number of entities/VMs under management.

For a standard Brooklyn deployment, the defaults are to start with 256m, and to grow to 2g of memory. These numbers can be overridden 
by setting the `JAVA_MAX_MEM` and `JAVA_MAX_PERM_MEM` in the `bin/setenv` script:

    export JAVA_MAX_MEM="2G"

Apache Brooklyn stores a task history in-memory using [soft references](http://docs.oracle.com/javase/7/docs/api/java/lang/ref/SoftReference.html). 
This means that, once the task history is large, Brooklyn will continually use the maximum allocated memory. It will 
only expunge tasks from memory when this space is required for other objects within the Brooklyn process.

### Authentication and Security

There are two areas of authentication used in Apache Brooklyn, these are as follows:

* Karaf authentication

Apache Brooklyn uses [Apache Karaf](https://karaf.apache.org) as a core platform, this has user level security and
groups which can be configured as detailed [here](https://karaf.apache.org/manual/latest/security#_users_groups_roles_and_passwords).

* Apache Brooklyn authentication

Users and passwords for Brooklyn can be configured in the brooklyn.cfg as detailed [here](brooklyn_cfg#authentication).

### HTTPS Configuration

See [HTTPS Configuration](https) for general information on configuring HTTPS.


<!--
----------
-- NOTE: comment out this section on catalog as the behaviour described is not enabled by default since
-- https://github.com/apache/brooklyn-server/pull/233; re-enable this when that changes
----------
## Catalog in OSGi  
With the traditional launcher, Brooklyn loads the initial contents of the catalog from a `default.catalog.bom` file
as described in the section on [installation](/guide/ops/production-installation). Brooklyn finds Java 
implementations to provide for certain things in blueprints (entities, enrichers etc.) by scanning the classpath. 

In the OSGI world this approach is not used, as each bundle only has visibility of its own and its imported Java packages. 
Instead, in the Karaf OSGi container, each bundle can declare its own `catalog.bom` file, in the root of the bundle,
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

### Configuring applications in the Catalog

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


### Configuring custom bundle resolvers, type-plan transformers, and other bundles

As described throughout this user guide, 
Apache Brooklyn by default uses the CAMP YAML format to define types, including entities, 
and supports the `catalog.bom` format defined elsewhere and ZIP bundles containing `catalog.bom`
or OSGi metadata information.

It is possible to extend this, and supply additional item type definition formats
and bundle resolution strategies.
This is done by defining OSGi services in an OSGi bundle blueprint,
implementing `BrooklynTypePlanTransformer` and/or `BrooklynCatalogBundleResolver`.
This can be used to add support for any type of plan or bundle format,
such as Kubernetes Helm charts, TOSCA YAML topology definitions, or TOSCA CSAR bundles.

These services, or any additional bundles to install, can be specified in any of several ways:

* As part of Karaf startup, by specifying it in `etc/startup.properties` or as a boot feature/bundle

* Adding it to the `/etc/default.catalog.bom`

* Putting it in the OSGi `/deploy` folder (before or after startup)

* Manually after startup through the API or CLI (e.g. via `br catalog add`) 
  and subsequently restored through rebind

*Note*: If the initial catalog `/etc/default.catalog.bom` requires those bundles to be installed,
you must use the first option, otherwise, because OSGi startup can be non-deterministic, the bundles
might not be installed when the initial catalog is loaded. In addition, you must specify that the
services from those bundles are required prior to starting the initial catalog (and before rebind).
This can be done with the following setting in `brooklyn.cfg`: 

    brooklyn.osgi.dependencies.services.filters=<osgi-filter-or-list>
    
Where `<osgi-filter-or-list>` is of any of the following forms, using properties of the OSGi
service, the most common of which is `osgi.service.blueprint.compname`, the registered name 
of the OSGi service component in the blueprint:

    (osgi.service.blueprint.compname=myCustomBundleResolver)
    (&(osgi.service.blueprint.compname=myCustomBundleResolver)(customProp=customValue))
    ["(osgi.service.blueprint.compname=myCustomBundleResolver)","(osgi.service.blueprint.compname=myCustomPlanTransformer)"]

The first of these will block for the presence of a service registered with component name `myCustomBundleResolver`;
the second will block for a service with that component name _and_ the custom property set;
the third will block for two services, `myCustomBundleResolver` and one with component name `myCustomPlanTransformer`.

In addition, two other settings in that file may be relevant:

    brooklyn.osgi.dependencies.services.timeout = 2m
    brooklyn.osgi.startlevel.postinit           = 200

The first of these will cause catalog init / rebind to proceed after a timeout if the dependencies are not fulfilled,
after logging an error.  (By default it will block indefinitely, logging a debug message periodically.)

The second of these will change the OSGi start level after catalog init / rebind has completed.
This can be useful e.g. if using the hot-deploy `/deploy` folder but bundles there should not be activated
until _after_ the Brooklyn catalog has been initialized (or rebinding on a subsequent start).
It can be used along with these standard `org.apache.felix.fileinstall-deploy.cfg` settings
which should be changed to a level above `100` but less than or equal to the `brooklyn.osgi.startlevel.postinit` level:

    felix.fileinstall.start.level  = 180
    felix.fileinstall.active.level = 180

*Note #2*: It is recommended that bundles that provide OSGi services _not_ contain a `catalog.bom`,
as that can in some situations cause a race between loading the services and installing the `catalog.bom`.
A clear separation between service bundles and catalog bundles prevents that situation.
(On rebind, bundles that have OSGi metadata and not a `catalog.bom` are loaded first,
to ensure any OSGi services they provide are available to other bundles,
for any of the bundle installation techniques listed above.)


### Caveats

In the OSGi world specifying class names by string in Brooklyn's configuration will work only
for classes living in Brooklyn's core modules. Raise an issue or ping us on IRC if you find
a case where this doesn't work for you. For custom SecurityProvider implementations refer to the
documentation of BrooklynLoginModule.
    
 END Catalog in Karaf comment -->


