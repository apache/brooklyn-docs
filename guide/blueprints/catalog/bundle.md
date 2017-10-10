---
title: Bundling
layout: website-normal
---
# {{ page.title }}

### Bundling Catalog Resources

It is possible to upload catalog items and associated resources as a single bundle to AMP.
This is useful when you have a blueprint that needs to reference external scripts, icons,
config files or other resources, or 
when you have multiple blueprints that you want to keep in sync. Brooklyn will persist any 
uploaded bundles so that they are available after a restart or on HA failover.

The bundle must be a ZIP file including a `catalog.bom` in the root.
(The `br` CLI will create a ZIP from a local folder, for convenience.)
The `catalog.bom` must declare a `bundle` identifier and a `version`, 
following Brooklyn's [versioning](versioning.md) rules.
Brooklyn will keep track of that bundle, allowing items to be added and removed as a group,
and associated resources to be versioned and included alongside them. 
With SNAPSHOT-version bundles, it allows replacement of multiple related items at the same time,
and in advanced cases it allows setting up dependent bundles 
(specified as `brooklyn.libraries` or, for people familiar with OSGi, the `Required-bundle` manifest header) 
which will be searched if a blueprint in one bundle references resources from another bundle.

Resources in the bundle can be referenced from the `catalog.bom` by using
the `classpath:` URL protocol, as in `classpath://path/to/script.sh`.
This can also be used to load resources in explicitly declared dependent bundles. 


### Example

In this example, we will create a simple `my-server` catalog item, bundled with a simple script. The script will be run when launching the server.

First, create a folder called bundleFolder, then add a file called myfile.sh to it. 
The contents of myfile.sh should be as follows:

~~~ bash
echo Hello, World!
~~~

Now create a file in bundleFolder called `catalog.bom` with the following contents:

~~~ yaml
brooklyn.catalog:
  bundle: MyServerBundle
  version: 1.0.0
  items:  
    - id: my-server
      item: 
        type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
        brooklyn.config:
          files.runtime:
            classpath://myfile.sh: files/myfile.sh
          launch.command: |
            chmod +x ./files/myfile.sh
            ./files/myfile.sh        
        checkRunning.command: echo "Running"  
        
~~~

The `bundle: MyServerBundle` line specifies the OSGI bundle name for this bundle. Any resources included
in this bundle will be accessible on the classpath, but will be scoped to this bundle. This prevents an
issue where multiple bundles include the same resource.

To create the bundle, simply use the br command as follows. This will create a zip and send it to Brooklyn. Please note you can also specify a zip file (either on the file system or hosted remotely):

~~~ bash
br catalog add bundleFolder
~~~

This will have added our bundle to the catalog. We can now deploy an instance of our server as follows. Please note that in this example we deploy to localhost. If you have not setup your machine to use localhost please see the instructions [here](../../locations#localhost-setup) or use a non localhost location. 

~~~ yaml
location: localhost
services:
- type: my-server
~~~

We can now see the result of running that script. In the UI find the activities for this application. The start activity has a sub task called launch (you will have to click through multiple activities called start/launch. Looking at the stdout of the launch task you should see:

~~~ bash  
Hello, World!
~~~

Alternatively you can view the script directly if you run the following against localhost. Please note that brooklyn-username and the id of your app will be different.

~~~ bash
cat /tmp/brooklyn-username/apps/nl9djqbq2i/entities/VanillaSoftwareProcess_g52gahfxnt/files/myfile.sh
~~~

It should look like this:

~~~ bash
echo Hello, World!
~~~

Now modify `myfile.sh` to contain a different message, change the version number in `catalog.bom` to
`1.1.0`, and use the br command to send the bundle to the server.

If you now deploy a new instance of the server using the same YAML as above, you should be
able to confirm that the new script has been run (either by looking at the stdout of the launch task, or looking at the script itself)

At this point, it is also possible to deploy the original `Hello, World!` version by explicitly stating
the version number in the YAML:

~~~ yaml
location: localhost
services:
- type: my-server:1.0.0
~~~

To demonstrate the scoping, you can create another bundle with the following `catalog.bom`. Note the
bundle name and entity id have been changed, but it still references a script with the same name.

~~~ yaml
brooklyn.catalog:
  bundle: DifferentServerBundle
  version: 1.0.0
  item:  
    id: different-server
    type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
    brooklyn.config:
      files.runtime:
        classpath://myfile.sh: files/myfile.sh
      launch.command: |
        chmod +x ./files/myfile.sh
        ./files/myfile.sh
        
      checkRunning.command:
        echo "Running"  
~~~

Now create a new `myfile.sh` script with a different message, and use the br command to send the bundle to Brooklyn.

Now deploy a blueprint which deploys all three servers. Each of the three deployments will utilise the script that was included with their bundle.

~~~ yaml
location: localhost
services:
- type: my-server:1.0.0
- type: my-server:1.1.0
- type: different-server
~~~

**Note**: All three entities copy a file from `classpath://myfile.sh`, but as they are in different bundles, the scripts copied to the server will be different.
