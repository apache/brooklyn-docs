---
title: Adding Catalog Items to Quick Launch
---
To add a Tomcat entity not only in the catalog, but in the Quick Launch as well, the entity must be tagged with `catalog_quick_launch`.
This allows admins to curate what appears in the quick launch bar on the home page. 
More tags can be added for the same entity, for other purposes.

~~~ yaml
brooklyn.catalog:
 items:
 - id: tomcat-server
   version: "1.0.0"
   itemType: entity
   tags: [ catalog_quick_launch ]
   item:
     type: org.apache.brooklyn.entity.webapp.tomcat.Tomcat8Server
     brooklyn.config:
       webapp.enabledProtocols: https
       httpsSsl:
         url: classpath://org/apache/brooklyn/entity/webapp/sample-java-keystore.jks
         alias: myname
         password: mypass
~~~