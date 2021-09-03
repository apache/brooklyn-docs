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
where either the `<catalog-metadata>` or `<additional-catalog-metadata>` placeholders are in the examples above,
with the latter overriding the former unless otherwise specified below.


###### Definitional Metadata

**`id`**
A human-friendly unique identifier for how this catalog item will be referenced from blueprints.
This is required.

**`version`**
Multiple versions of a blueprint can be installed and used simultaneously;
this field disambiguates between blueprints of the same `id`.
This can be omitted where the `version` is defined at an ancestor node, and in
practice it usually is, so that all items in a bundle take the same version. 
Note that this is typically *not* the version of the software being installed,
but rather the version of the blueprint. For more information on versioning, see [Versioning](/guide/blueprints/catalog/versioning.md).
(Also note YAML treats numbers differently to Strings. Explicit quotes are recommended, to avoid
`1.10` being interpretted as the number `1.1`.)

To reference a catalog item in another blueprint, simply reference its ID and optionally its version number.
For instance, if the catalog contains an item with metadata `{ id: datastore, version: "1.0" }`
we could refer to it in another blueprint with:

~~~ yaml
services:
- type: datastore:1.0
~~~

**`itemType`**
The type of the item being defined. The supported common spec item types are: `application`, `entity`, `policy`, and `location`.
Two additional item types are `template`, which is a not-necessarily-deployable application for use as a starting
point in composer (the YAML can even be invalid); and `bean` which defines types for use in config, initializers,
and elsewhere. If the type can be inferred from the definition this can be omitted.

**`format`**
The schema format used for the item definitions.
This determines the transformer to use; if omitted at a level it is inherited from ancestors,
and if `auto` (or omitted on ancestors) then the format is autodetected.
Transformer formats that ship with Apache Brooklyn include:
`brooklyn-camp` (the primary format used throughout, where a key `type: <parent-spec-type>` identifies the parent spec
for entities, policies, etc, and config under `brooklyn.config`) 
and `bean-with-type` (where a key `type: <parent-type>` is used to define a bean and fields as siblings).
Extensions may provide additional formats.

Exactly **one** of `item` and `items` is also required:

**`item`**
The YAML for an entity, or policy, or location specification
(a map containing `type` and optional `brooklyn.config`). For a "template" item, it
should be a map containing `services` (i.e. the usual YAML format for a full application
blueprint).

**`items`**
A list of catalog items, where each entry in the map follows the same schema as
the `brooklyn.catalog` value, and the keys in the map override any metadata specified as
a sibling of this `items` key (or, in the case of `brooklyn.libraries` they add to the list);
if there are references between items, then order is important:
`items` are processed in order, depth-first, and forward references are not supported. Entries
can be URLs to another catalog file to include, inheriting the metadata from the current hierarchy.
Libraries defined so far in the metadata will be used to load classpath entries. For example:

~~~ yaml
brooklyn.catalog:
 brooklyn.libraries:
 - http://example.com/path/my.jar
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


##### Optional Metadata

The following optional catalog metadata is supported:

**`name`**
A nicely formatted display name for the item, used when presenting it in a GUI.

**`description`**
Supplies an extended textual description for the item.

**`iconUrl`**
Points to an icon for the item, used when presenting it in a GUI.
The URL prefix `classpath` is supported but these URLs may *not* refer to resources in any OSGi
bundle in the `brooklyn.libraries` section (to prevent requiring all OSGi bundles to be loaded
at launch). Icons are instead typically installed either at the web server from which the OSGi
bundles and catalog items are supplied or in the `conf` directory of the Brooklyn distro.

**`brooklyn.libraries`**
A list of pointers to OSGi bundles required for the catalog item.
This can be omitted if blueprints are pure YAML and everything required is included in the classpath and catalog.
Where custom Java code or bundled resources is needed, however, OSGi JARs supply
a convenient packaging format and a very powerful versioning format.

Libraries can be supplied in short form:
~~~yaml
brooklyn.libraries:
- "http://example.com/bundle-1.0.2.jar"
- "http://example.com/another-bundle-3.3.0.jar"
~~~

Or in long form:
~~~yaml
brooklyn.libraries:
- name: "symbolic-name"
  version: "1.0"
  url: "http://example.com/bundle-1.0.jar"
  auth:
    username: $brooklyn:external("myprovider", "username")
    password: $brooklyn:external("myprovider", "password")
~~~
The only mandatory property in the long form is `url`. Brooklyn will skip the download when a bundle with matching `name` and `version` is already installed.

URLs should point at immutable OSGi bundles;
if the contents at any of these URLs changes, the behaviour of the blueprint may change
whenever a bundle is reloaded in a Brooklyn server,
and if entities have been deployed against that version, their behavior may change in subtle or potentially incompatible ways.
To avoid this situation, it is highly recommended to use OSGi version stamps as part of the URL.

Specify `auth` if the resource at `url` requires authentication to access.
Do not write the username and password directly into the file; instead
use [external configuration](/guide/ops/externalized-configuration.md)
to reference the values.

**`include`**
A URL to another catalog file to include, inheriting the meta from the current hierarchy.
Libraries defined so far in the meta will be used to load classpath entries. `include` must be used
when you have sibling properties. If it's the only property it may be skipped by having the URL as the
value - see `items` example above.


##### Deprecated Metadata

The following metadata is no longer supported and will be ignored in a future release:

**`scanJavaAnnotations`**
If provided (as `true`), this will scan any
locally provided library URLs for types annotated `@Catalog` and extract metadata to include
them as catalog items. If no libraries are specified this will scan the default classpath.
This feature will likely be removed.
Also note that external OSGi dependencies are not supported
and other metadata (such as versions, etc) may not be applied.


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

In addition to blueprints, locations can be added to the Apache Brooklyn catalog. The example below shows a location for the vagrant configuration used in the [getting started guide](/guide/start/blueprints.html), formatted as a catalog entry.

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