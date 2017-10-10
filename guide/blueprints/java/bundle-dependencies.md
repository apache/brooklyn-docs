---
title: Handling Bundle Dependencies
layout: website-normal
---
# {{ page.title }}

Some Java blueprints will require third party libraries. These need to be made available to the
Apache Brooklyn runtime. There are a number of ways this can be achieved.

### Classic Mode: Dropins Folder

In Brooklyn classic mode (i.e. when not using Karaf), jars can be added to `./lib/dropins/`.
After restarting Brooklyn, these will be available on the classpath.

In Brooklyn classic mode, there is an embedded OSGi container. This is used for installing 
libraries referenced in catalog items.

### OSGi Bundles

#### Introduction to OSGi Bundles

An [OSGi bundle](https://en.wikipedia.org/wiki/OSGi#Bundles) is a jar file with additional 
metadata in its manifest file. The `MANIFEST.MF` file contains the symbolic name and version 
of the bundle, along with details of its dependencies and of the packages it exports 
(which are thus visible to other bundles).

The [maven-bundle-plugin](http://felix.apache.org/documentation/subprojects/apache-felix-maven-bundle-plugin-bnd.html) 
is a convenient way of building OSGi bundles.

#### OSGi Bundles Declared in Catalog Items  

Within a [catalog item]({{ book.path.guide}}/blueprints/catalog/), a list of URLs can be supplied under
`brooklyn.libraries`. Each URL should point to an OSGi bundle. This list should include the OSGi 
bundle that has the Java code for your blueprint, and also the OSGi bundles that it depends
on (including all transitive dependencies).

It is vital that these jars are built correctly as OSGi bundles, and that all transitive 
dependencies are included. The bundles will be added to Karaf in the order given, so a bundle's
dependencies should be listed before the bundle(s) that depend on them.

In the [GistGenerator example]({{ book.path.guide}}/blueprints/java/defining-and-deploying.html), the 
[catalog.bom file]({{ book.path.guide}}/blueprints/java/gist_generator/gist_generator.bom) included
the URL of the dependency `org.eclipse.egit.github.core`. It also (before that line) included
its transitive dependency, which is a specific version of `gson`.

For Java blueprint developers, this is often the most convenient way to share a blueprint.

Similarly for those wishing to use a new blueprint, this is often the simplest mechanism: the
dependencies are fully described in the catalog item, which makes it convenient for deploying 
to Apache Brooklyn instances where there is not direct access to Karaf or the file system.


#### Adding Bundles and Features Directly to Karaf

Bundles and features can be added manually, directly to Karaf.

However, note this only affects the single Karaf instance. If running in HA mode or if provisioning
a new instance of Apache Brooklyn, the bundles will also need to be added to these Karaf instances.


##### Karaf Console

Login to the [Karaf console](https://karaf.apache.org/manual/latest/#_shell_console_basics)
using `./bin/client`, and add the bundles and features as desired.

Examples of some useful commands are shown below:

```bash
karaf@amp> bundle:install -s http://repo1.maven.org/maven2/org/apache/servicemix/bundles/org.apache.servicemix.bundles.egit.github.core/2.1.5_1/org.apache.servicemix.bundles.egit.github.core-2.1.5_1.jar
Bundle ID: 316

karaf@amp> bundle:list -t 0 -s | grep github
318 | Active   |  80 | 2.1.5.1                       | org.apache.servicemix.bundles.egit.github.core

karaf@amp> bundle:headers org.apache.servicemix.bundles.egit.github.core
...

karaf@amp> bundle:uninstall org.apache.servicemix.bundles.egit.github.core
```


##### Karaf Deploy Folder

Karaf support [hot deployment](https://karaf.apache.org/manual/latest/#_deployers). There are a 
set of deployers, such as feature and KAR deployers, that handle deployment of artifacts added
to the `deploy` folder.

Note that the Karaf console can give finer control (including for uninstall).


### Karaf KAR files

[Karaf KAR](https://karaf.apache.org/manual/latest/kar) is an archive format (Karaf ARchive).
A KAR is a jar file (so a zip file), which contains a set of feature descriptors and bundle jar files.

This can be a useful way to bundle a more complex Java blueprint (along with its dependencies), to
make it easier for others to install.

A KAR file can be built using the 
[maven plugin org.apache.karaf.tooling:features-maven-plugin](https://karaf.apache.org/manual/latest/#_maven).


### Karaf Features

A [karaf feature.xml](https://karaf.apache.org/manual/latest/#_create_a_features_xml_karaf_feature_archetype)
defines a set of bundles that make up a feature. Once a feature is defined, one can add it to a Karaf instance:
either directly (e.g. using the [Karaf console](https://karaf.apache.org/manual/latest/#_shell_console_basics)), or
by referencing it in another feature.xml file. 


### Embedded Dependencies

An OSGi bundle can 
[embed jar dependencies](http://felix.apache.org/documentation/subprojects/apache-felix-maven-bundle-plugin-bnd.html#embedding-dependencies)
within it. This allows dependencies to be kept private within a bundle, and easily shipped with that bundle.

To keep these private, it is vital that the OSGi bundle does not import or export the packages
contained within those embedded jars, and does not rely on any of those packages in the public 
signatures of any packages that are exported or imported.


### Converting Non-OSGi Dependencies to Bundles

If a dependencies is not available as an OSGi bundle (and you don't want to just [embed the jar](#embedded-dependencies)),
there are a few options for getting an equivalent OSGi bundle:

* Use a ServiceMix re-packaged jar, if available. ServiceMix have re-packed many common dependencies as
  OSGi bundles, and published them on [Maven Central](https://search.maven.org).

* Use the `wrap:` prefix. The [PAX URL Wrap protocol](https://ops4j1.jira.com/wiki/display/paxurl/Wrap+Protocol) 
  is an OSGi URL handler that can process your legacy jar at runtime and transform it into an OSGi bundle.  
  This can be used when declaring a dependency in your feature.xml, and when using the Karaf console's 
  `bundle:install`. Note that it is not yet supported in Brooklyn's `brooklyn.libraries` catalog items.

* Re-package the bundle yourself, offline, to produce a valid OSGi bundle.

