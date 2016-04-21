---
layout: website-normal
title: OSGI Catalog
---

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



