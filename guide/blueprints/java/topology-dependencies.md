---
layout: website-normal
title: Topology, Dependencies, and Management Policies
title_in_menu: Topology, Dependencies, and Management Policies
---
# {{ page.title }}

Applications written in YAML can similarly be written in Java. However, the YAML approach is 
recommended.

## Define your Application Blueprint

The example below creates a three tier web service, composed of an Nginx load-balancer, 
a cluster of Tomcat app-servers, and a MySQL database. It is similar to the [YAML policies
example](../../start/policies.md), but also includes the MySQL database
to demonstrate the use of dependent configuration.

!CODEFILE "java_app/ExampleWebApp.java"

To describe each part of this:

* The application extends `AbstractApplication`.
* It implements `init()`, to add its child entities. The `init` method is called only once, when
  instantiating the entity instance.
* The `addChild` method takes an `EntitySpec`. This describes the entity to be created, defining
  its type and its configuration.
* The `brooklyn.example.db.url` is a system property that will be passed to each `TomcatServer` 
  instance. Its value is the database's URL (discussed below).
* The policies and enrichers provide in-life management of the application, to restart failed
  instances and to replace those components that repeatedly fail.
* The `NginxController` is the load-balancer and reverse-proxy: by default, it round-robins to 
  the ip:port of each member of the cluster configured as the `SERVER_POOL`.


## Dependent Configuration

Often a component of an application will depend on another component, where the dependency
information is only available at runtime (e.g. it requires the IP of a dynamically provisioned
component). For example, the app-servers in the example above require the database URL to be 
injected.

The "DependentConfiguration" methods returns a future (or a "promise" in the language of 
some other programming languages): when the  value is needed, the caller will block to wait for  
the future to resolve. It will block only "at the last moment" when the value is needed (e.g. 
after the VMs have been provisioned and the software is installed, thus optimising the 
provisioning time). It will automatically monitor the given entity's sensor, and generate the 
value when the sensor is populated.

The `attributeWhenReady` is used to generate a configuration value that depends on the dynamic 
sensor value of another entity - in the example above, it will not be available until that 
`MySqlNode.DATASTORE_URL` sensor is populated. At that point, the JDBC URL will be constructed 
(as defined in the `formatString` method, which also returns a future).
