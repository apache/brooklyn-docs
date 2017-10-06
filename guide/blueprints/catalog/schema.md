---
title: Catalog Items YAML Syntax
layout: website-normal
---

### Catalog Items YAML Syntax

An item or items to be added to the catalog is defined by a YAML file,
specifying the catalog metadata for the items and the actual blueprint or resource definition.


#### General YAML Schema

Catalog items can be defined using the general structure below:

~~~ yaml
brooklyn.catalog:
 <catalog-metadata>
 items:
 - <additional-catalog-metadata>
   item:
     <blueprint-or-resource-definition>
 - <additional-catalog-metadata>
   item:
     <blueprint-or-resource-definition>
~~~ 

Alternatively, a single catalog item can be defined using the following general structure:

~~~ yaml
brooklyn.catalog:
 <catalog-metadata>
 item:
   <blueprint-or-resource-definition>
~~~ 

For example, the YAML below adds to the catalog a Tomcat entity with some additional default 
configuration:

~~~ yaml
brooklyn.catalog:
 items:
 - id: tomcat-server
   version: "1.0.0"
   itemType: entity
   item:
     type: org.apache.brooklyn.entity.webapp.tomcat.Tomcat8Server
     brooklyn.config:
       webapp.enabledProtocols: https
       httpsSsl:
         url: classpath://org/apache/brooklyn/entity/webapp/sample-java-keystore.jks
         alias: myname
         password: mypass
~~~ 


#### Catalog Metadata

Catalog metadata fields supply the additional information required in order to register an item in the catalog. 
These fields can be supplied as `key: value` entries 
where either the `<catalog-metadata>` or `<additional-catalog-metadata>` placeholders are,
with the latter overriding the former unless otherwise specified below.

The following metadata is *required* for all items:

- `id`: a human-friendly unique identifier for how this catalog item will be referenced from blueprints
- `version`: multiple versions of a blueprint can be installed and used simultaneously;
 this field disambiguates between blueprints of the same `id`.
 Note that this is typically *not* the version of the software being installed,
 but rather the version of the blueprint. For more information on versioning, see below.
 (Also note YAML treats numbers differently to Strings. Explicit quotes are recommended, to avoid 
 `1.10` being interpretted as the number `1.1`.)
- `itemType`: the type of the item being defined. The supported item types are:
 - `entity`
 - `template`
 - `policy`
 - `location`

To reference a catalog item in another blueprint, simply reference its ID and optionally its version number.
For instance, if we've added an item with metadata `{ id: datastore, version: "1.0" }` (such as the example below),
we could refer to it in another blueprint with: 

~~~ yaml
services:
- type: datastore:1.0
~~~ 

In addition to the above fields, exactly **one** of the following is also required:

- `item`: the YAML for an entity, or policy, or location specification 
 (a map containing `type` and optional `brooklyn.config`). For a "template" item, it
 should be a map containing `services` (i.e. the usual YAML format for a full application
 blueprint). **Or**
- `items`: a list of catalog items, where each entry in the map follows the same schema as
 the `brooklyn.catalog` value, and the keys in these map override any metadata specified as
 a sibling of this `items` key (or, in the case of `brooklyn.libraries` they add to the list);
 if there are references between items, then order is important:
 `items` are processed in order, depth-first, and forward references are not supported. Entries
 can be URL to another catalog file to include, inheriting the metadata from the current hierarchy.
 Libraries defined so far in the metadata will be used to load classpath entries. For example:

~~~ yaml
brooklyn.catalog:
 brooklyn.libraries:
 - http://some.server.or.other/path/my.jar
 items:
 - classpath://my-catalog-entries-inside-jar.bom
 - some-property: value
   include: classpath://more-catalog-entries-inside-jar.bom
 - id: use-from-my-catalog
   version: "1.0.0"
   itemType: entity
   item:
     type: some-type-defined-in-my-catalog-entries
     brooklyn.config:
       some.config: "some value"
~~~

The following optional catalog metadata is supported:
 
- `name`: a nicely formatted display name for the item, used when presenting it in a GUI.
- `description`: supplies an extended textual description for the item.
- `iconUrl`: points to an icon for the item, used when presenting it in a GUI.
 The URL prefix `classpath` is supported but these URLs may *not* refer to resources in any OSGi 
 bundle in the `brooklyn.libraries` section (to prevent requiring all OSGi bundles to be loaded 
 at launch). Icons are instead typically installed either at the web server from which the OSGi 
 bundles or catalog items are supplied or in the `conf` folder of the Brooklyn distro.
- `scanJavaAnnotations` [experimental; deprecated]: if provided (as `true`), this will scan any 
 locally provided library URLs for types annotated `@Catalog` and extract metadata to include 
 them as catalog items. If no libraries are specified this will scan the default classpath.
 This feature will likely be removed.
 Also note that external OSGi dependencies are not supported 
 and other metadata (such as versions, etc) may not be applied.
- `brooklyn.libraries`: a list of pointers to OSGi bundles required for the catalog item.
 This can be omitted if blueprints are pure YAML and everything required is included in the classpath and catalog.
 Where custom Java code or bundled resources is needed, however, OSGi JARs supply
 a convenient packaging format and a very powerful versioning format.
 Libraries should be supplied in the form 
 `brooklyn.libraries: [ "http://...", "http://..." ]`, 
 or as
 `brooklyn.libraries: [ { name: symbolic-name, version: "1.0", url: http://... }, ... ]` if `symbolic-name:1.0` 
 might already be installed from a different URL and you want to skip the download.
 Note that these URLs should point at immutable OSGi bundles;
 if the contents at any of these URLs changes, the behaviour of the blueprint may change 
 whenever a bundle is reloaded in a Brooklyn server,
 and if entities have been deployed against that version, their behavior may change in subtle or potentially incompatible ways.
 To avoid this situation, it is highly recommended to use OSGi version stamps as part of the URL.
- `include`: A URL to another catalog file to include, inheriting the meta from the current hierarchy.
 Libraries defined so far in the meta will be used to load classpath entries. `include` must be used
 when you have sibling properties. If it's the only property it may be skipped by having the URL as the
 value - see `items` example above.


#### Catalog YAML Examples

##### A Simple Example

The following example installs the `RiakNode` entity, making it also available as an application template,
with a nice display name, description, and icon.
It can be referred in other blueprints to as `datastore:1.0`,
and its implementation will be the Java class `org.apache.brooklyn.entity.nosql.riak.RiakNode` included with Brooklyn.

~~~ yaml
brooklyn.catalog:
 id: datastore
 version: "1.0"
 itemType: template
 iconUrl: classpath://org/apache/brooklyn/entity/nosql/riak/riak.png
 name: Datastore (Riak)
 description: Riak is an open-source NoSQL key-value data store.
 item:
   services:
   - type: org.apache.brooklyn.entity.nosql.riak.RiakNode
     name: Riak Node
~~~ 


##### Multiple Items

This YAML will install three items:

~~~ yaml
brooklyn.catalog:
 version: "1.1"
 iconUrl: classpath://org/apache/brooklyn/entity/nosql/riak/riak.png
 description: Riak is an open-source NoSQL key-value data store.
 items:
   - id: riak-node
     itemType: entity
     item:
       type: org.apache.brooklyn.entity.nosql.riak.RiakNode
       name: Riak Node
   - id: riak-cluster
     itemType: entity
     item:
       type: org.apache.brooklyn.entity.nosql.riak.RiakCluster
       name: Riak Cluster
   - id: datastore
     name: Datastore (Riak Cluster)
     itemType: template
     item:
       services:
       - type: riak-cluster
         brooklyn.config:
           # the default size is 3 but this can be changed to suit your requirements
           initial.size: 3
           provisioning.properties:
             # you can also define machine specs
             minRam: 8gb
~~~ 

The items this will add to the catalog are:

- `riak-node`, as before, but with a different name
- `riak-cluster` as a convenience short name for the `org.apache.brooklyn.entity.nosql.riak.RiakCluster` class
- `datastore`, now pointing at the `riak-cluster` blueprint, in SoftLayer and with the given size and machine spec, 
 as the default implementation for anyone
 requesting a `datastore` (and if installed atop the previous example, new references to `datastore` 
 will access this version because it is a higher number);
 because it is a template, users will have the opportunity to edit the YAML (see below).
 (This must be supplied after `riak-cluster`, because it refers to `riak-cluster`.)


#### Locations in the Catalog

In addition to blueprints, locations can be added to the Apache Brooklyn catalog. The example below shows a location for the vagrant configuration used in the [getting started guide]({{ book.path.guide }}/start/blueprints.html), formatted as a catalog entry.

~~~ yaml
brooklyn.catalog:
 id: vagrant
 version: "1.0"
 itemType: location
 name: Vagrant getting started location
 item:
   type: byon
   brooklyn.config:
     user: vagrant
     password: vagrant
     hosts:
       - 10.10.10.101
       - 10.10.10.102
       - 10.10.10.103
       - 10.10.10.104
~~~

Once this has been added to the catalog it can be used as a named location in yaml blueprints using:

~~~ yaml
location: vagrant
~~~


#### Legacy Syntax

The following legacy and experimental syntax is also supported, but deprecated:

~~~ yaml
<blueprint-definition>
brooklyn.catalog:
 <catalog-metadata>
~~~ 

In this format, the `brooklyn.catalog` block is optional;
and an `id` in the `<blueprint-definition>` will be used to determine the catalog ID. 
This is primarily supplied for OASIS CAMP 1.1 compatibility,
where the same YAML blueprint can be POSTed to the catalog endpoint to add to a catalog
or POSTed to the applications endpoint to deploy an instance.
(This syntax is discouraged as the latter usage, 
POSTing to the applications endpoint,
will ignored the `brooklyn.catalog` information;
this means references to any `item` blocks in the `<catalog-metadata>` will not be resolved,
and any OSGi `brooklyn.libraries` defined there will not be loaded.)