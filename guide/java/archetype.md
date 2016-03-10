---
title: Creating from a Maven Archetype
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

### Maven Archetype

Brooklyn includes a maven archetype, which can be used to create the project structure for 
developing a new Java entity, and generating the OSGi bundle for it.


#### Generating the Project

The archetype can be used interactively, by running:
{% highlight bash %}
$ mvn archetype:generate
{% endhighlight %}

The user will be prompted for the archetype to use (i.e. group "org.apache.brooklyn" 
and artifact "brooklyn-archetype-quickstart"), as well as options for the project 
to be created.

Alternatively, all options can be supplied at the command line. For example, 
if creating a project named "autobrick" for "com.acme":

{% highlight bash %}
$ mvn archetype:generate \
	-DarchetypeGroupId=org.apache.brooklyn \
	-DarchetypeArtifactId=brooklyn-archetype-quickstart \
	-DarchetypeVersion={{ site.brooklyn-version }} \
	-DgroupId=com.acme -DartifactId=autobrick \
	-Dversion=0.1.0-SNAPSHOT \
	-DpackageName=com.acme.autobrick \
	-DinteractiveMode=false
{% endhighlight %}

This will create a directory with the artifact name (e.g. "autobrick" in the example above).
Note that if run from a directory containing a pom, it will also modify that pom to add this as 
a module!

The project will contain an example Java entity. You can test this using the supplied unit tests,
and also replace it with your own code.

The `README.md` file within the project gives further guidance.


#### Building

To build, run the commands:

{% highlight bash %}
$ cd autobrick
$ mvn clean install
{% endhighlight %}


#### Adding to the Catalog

The build will produce an OSGi bundle in `target/autobrick-0.1.0-SNAPSHOT.jar`, suitable for 
use in the [Brooklyn catalog]({{ site.path.guide }}/ops/catalog/) (using `brooklyn.libraries`).

The project comes with a `sample.bom` file, located in `src/test/resources`. You will first have 
to copy the target jar to a suitable location, and update the URL in `sample.bom` to point at that 
jar.

The command below will use the REST api to add this to the catalog of a running Brooklyn instance:

    curl -u admin:pa55w0rd http://127.0.0.1:8081/v1/catalog --data-binary @src/test/resources/sample.bom

The YAML blueprint below shows an example usage of this blueprint:

    name: my sample
    services:
    - type: com.acme.MySampleInCatalog:1.0


### Testing Entities

The project comes with unit tests that demonstrate how to test entities, both within Java and
also using YAML-based blueprints.

A strongly recommended way is to write a YAML test blueprint using the test framework, and making  
this available to anyone who will use your entity. This will allow users to easily run the test
blueprint in their own environment (simply by deploying it to their own Brooklyn server) to confirm 
that the entity is working as expected. An example is contained within the project at 
`src/test/resources/sample-test.yaml`.
