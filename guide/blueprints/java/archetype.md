---
title: Creating from a Maven Archetype
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---
# {{ page.title }}

### Maven Archetype

Brooklyn includes a maven archetype, which can be used to create the project structure for 
developing a new Java entity, and generating the OSGi bundle for it.


#### Generating the Project

The archetype can be used interactively, by running:
```bash
$ mvn archetype:generate
```

The user will be prompted for the archetype to use (i.e. group "org.apache.brooklyn" 
and artifact "brooklyn-archetype-quickstart"), as well as options for the project 
to be created.

Alternatively, all options can be supplied at the command line. For example, 
if creating a project named "autobrick" for "com.acme":

<pre><code class="lang-sh">$ BROOKLYN_VERSION={{ book.brooklyn_version }}
$ mvn archetype:generate \
	-DarchetypeGroupId=org.apache.brooklyn \
	-DarchetypeArtifactId=brooklyn-archetype-quickstart \
	-DarchetypeVersion=${BROOKLYN_VERSION} \
	-DgroupId=com.acme \
	-DartifactId=autobrick \
	-Dversion=0.1.0-SNAPSHOT \
	-DpackageName=com.acme.autobrick \
	-DinteractiveMode=false</code></pre>

This will create a directory with the artifact name (e.g. "autobrick" in the example above).
Note that if run from a directory containing a pom, it will also modify that pom to add this as 
a module!

The project will contain an example Java entity. You can test this using the supplied unit tests,
and also replace it with your own code.

The `README.md` file within the project gives further guidance.


#### Building

To build, run the commands:

```bash
$ cd autobrick
$ mvn clean install
```


#### Adding to the Catalog

The build will produce an OSGi bundle in `target/autobrick-0.1.0-SNAPSHOT.jar`, suitable for 
use in the [Brooklyn catalog]({{ book.path.guide }}/blueprints/catalog/) (using `brooklyn.libraries`).

To use this in your Brooklyn catalog you will first have to copy the target jar to a suitable location. 
For developing/testing purposes storing on the local filesystem is fine. 
For production use, we recommend uploading to a remote maven repository or similar.

Once your jar is in a suitable location the next step is to add a new catalog item to Brooklyn. 
The project comes with a `catalog.bom` file, located in `src/main/resources`. 
Modify this file by adding a 'brooklyn.libraries' statement to the bom pointing to the jar. 
For example:

```yaml
brooklyn.catalog:
    brooklyn.libraries:
    - file:///path/to/jar/autobrick-0.1.0-SNAPSHOT.jar
    version: "0.1.0-SNAPSHOT"
    itemType: entity
    items:
    - id: com.acme.autobrick.MySample
      item:
        type: com.acme.autobrick.MySample
```

The command below will use the CLI to add this to the catalog of a running Brooklyn instance:

```bash
    br catalog add catalog.bom
```

After running that command, the OSGi bundle will have been added to the OSGi container, and the
entity will have been added to your catalog. It can then be used in the same way as regular Brooklyn 
entities.

For example, you can use the blueprint:

```yaml
services:
- type: com.acme.autobrick.MySample
```


### Testing Entities

The project comes with unit tests that demonstrate how to test entities, both within Java and
also using YAML-based blueprints.

A strongly recommended way is to write a YAML test blueprint using the test framework, and making  
this available to anyone who will use your entity. This will allow users to easily run the test
blueprint in their own environment (simply by deploying it to their own Brooklyn server) to confirm 
that the entity is working as expected. An example is contained within the project at 
`src/test/resources/sample-test.yaml`.
