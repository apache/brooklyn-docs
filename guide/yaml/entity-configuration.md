---
title: Entity Configuration
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

Within a blueprint or catalog item, entities can be configured. The rules for setting this 
configuration, including when composing and extending existing entities, is described in this 
section. 


### Basic Configuration

Within a YAML file, entity configuration should be supplied within a `brooklyn.config` map. It is 
also possible to supply configuration at the top-level of the entity. However, that approach is
discouraged as it can sometimes be ambiguous (e.g. if the config key is called "name" or "type"), 
and also it does not work in all contexts such as for an enricher's configuration.

A simple example is shown below:

{% highlight yaml %}
services:
- type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
  brooklyn.config:
    webapp.enabledProtocols: http
    http.port: 9080
    wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-webapp/0.9.0/brooklyn-example-hello-world-webapp-0.9.0.war
{% endhighlight %}

If no config value is supplied, the default for that config key will be used. For example, 
`http.port` would default to 8080 if not explicitly supplied.

Some config keys also have a short-form (e.g. `httpPort` instead of `http.port` would also work 
in the YAML example above). However, that approach is discouraged as it does not work in all contexts
such as for inheriting configuration from a parent entity.


### Configuration in a Catalog Item

When defining an entity in the catalog, it can include configuration values like any other 
blueprint. It can also explicitly declare config keys. For details of how to write and add
catalog items, see [Catalog]({{ site.path.guide }}/ops/catalog/). For more details of 
declaring config keys, see the section ["Declaring New Config Keys" in Custom Entities](custom-entities.html).

The example below illustrates the principles:

{% highlight yaml %}
brooklyn.catalog:
  items:
  - id: entity-config-example
    displayName: Entity Config Example
    item:
      type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
      brooklyn.parameters:
      - name: custom.message
        type: string
        default: Hello
      brooklyn.config:
        shell.env:
          MESSAGE: $brooklyn:config("custom.message")
        launch.command: |
          echo "My example launch command: $MESSAGE"
        checkRunning.command: |
          echo "My example checkRunning command: $MESSAGE"
{% endhighlight %}

Once added to the catalog, it can be used with the simple blueprint below (substituting the location
of your choice). Because no configuration has been overridden, this will use the default value
for `custom.message`, and will use the given values for `launch.command` and `checkRunning.command`:

{% highlight yaml %}
location: aws-ec2:us-east-1
services:
- type: entity-config-example
{% endhighlight %}


### Inheriting Configuration from a Parent Entity

Configuration passed to an entity is inherited by all child entities, unless explicitly overridden.
This can simplify some blueprints, but also care should be taken to ensure default values are not 
accidentally overridden.

In the example below, the `wars.root` config key is inherited by all TomcatServer entities created
under the cluster, so they will use that war:

{% highlight yaml %}
services:
- type: org.apache.brooklyn.entity.group.DynamicCluster
  brooklyn.config:
    wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-webapp/0.9.0/brooklyn-example-hello-world-webapp-0.9.0.war
    memberSpec:
      $brooklyn:entitySpec:
        type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
{% endhighlight %}


### Inheriting Configuration from Super-type

When using an entity from the catalog, its configuration values can be overridden. For example,
consider the `entity-config-example` added to the catalog in the section "Configuration in a 
Catalog Item". We can override these values:

{% highlight yaml %}
location: aws-ec2:us-east-1
services:
- type: entity-config-example
  brooklyn.config:
    custom.message: Goodbye
    launch.command: |
      echo "Different example launch command: $MESSAGE"
{% endhighlight %}

If not overridden, then the existing values from the super-type will be used.


### Configuration Precedence

There are several places that a configuration value can come from. If different values are 
specified in multiple places, then the order of precedence is as listed below:

1. Configuration on the entity itself
2. Inherited configuration from the super-type
3. Inherited configuration from the parent entity (or grandparent, etc)
4. The config key's default value


### Merging Configuration Values

For some configuration values, the most logical behaviour is to merge the configuration value
with that in the super-type. This depends on the type and meaning of the config key, and is thus 
an option when defining the config key.

Currently it is only supported for merging config keys of type Map.

Some common config keys will default to merging the values from the super-type. These config keys  
include those below. The value is merged with that of its super-type (but will not be merged with 
the value on a parent entity):

* `shell.env`: a map of environment variables to pass to the runtime shell
* `files.preinstall`: a mapping of files, to be copied before install, to destination name relative to installDir
* `templates.preinstall`: a mapping of templates, to be filled in and copied before pre-install, to destination name relative to installDir 
* `files.install`: a mapping of files, to be copied before install, to destination name relative to installDir 
* `templates.install`: a mapping of templates, to be filled in and copied before install, to destination name relative to installDir 
* `files.runtime`: a mapping of files, to be copied before customisation, to destination name relative to runDir 
* `templates.runtime`: a mapping of templates, to be filled in and copied before customisation, to destination name relative to runDir 
* `provisioning.properties`: custom properties to be passed in when provisioning a new machine

A simple example of merging `shell.env` is shown below (building on the `entity-config-example` in 
the previous section). The environment variables will include the `MESSAGE` set in the super-type 
and the `MESSAGE2` set here:

{% highlight yaml %}
location: aws-ec2:us-east-1
services:
- type: entity-config-example
  brooklyn.config:
    shell.env:
      MESSAGE2: Goodbye
    launch.command: |
      echo "Different example launch command: $MESSAGE and $MESSAGE2"
{% endhighlight %}

To explicitly remove a value from the super-type's map (rather than adding to it), a blank entry
can be defined. 

When defining a new config key, the exact semantics for inheritance can be defined. There are 
separate options for `inheritance.type` and `inheritance.parent` (the former determines how
config inheritance from the super-type is handles; the latter determines how inheritance 
from the parent entity is handled. The possible values are:

* `deep_merge`: the inherited and the given value should be merged; maps within the map will also be merged
* `always`: the inherited value should be used, unless explicitly overridden by the entity
* `none`: the value should not be inherited; if there is no explicit value on the entity then the default value will be used

Below is a (contrived!) example of inheriting the `example.map` config key. When using this entity
in a blueprint, the entity's config will be merged with that defined in the super-type, and the 
parent entity's value will never be inherited:

{% highlight yaml %}
brooklyn.catalog:
  items:
  - id: entity-config-example
    version: 1.1.0-SNAPSHOT
    displayName: Entity Config Example
    item:
      type: org.apache.brooklyn.entity.machine.MachineEntity
      brooklyn.parameters:
      - name: example.map
        type: java.util.Map
        inheritance.type: deep_merge
        inheritance.parent: none
        default:
          MESSAGE_IN_DEFAULT: InDefault
      brooklyn.config:
        example.map:
          MESSAGE: Hello
{% endhighlight %}

The blueprints below demonstrate the various permutations for setting configuration for the
config `example.map`. This can be inspected by looking at the entity's config. The config
we see for app1 is the inherited `{MESSAGE: "Hello"}`; in app2 we define additional configuration,
which will be merged to give `{MESSAGE: "Hello", MESSAGE_IN_CHILD: "InChild"}`; in app3, the 
config from the parent is not inherited because there is an explicit inheritance.parent of "none",
so it just has the value `{MESSAGE: "Hello"}`; in app4 again the parent's config is ignored,
with the super-type and entity's config being merged to give  `{MESSAGE: "Hello", MESSAGE_IN_CHILD: "InChild"}`.

{% highlight yaml %}
location: aws-ec2:us-east-1
services:
- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app1
  brooklyn.children:
  - type: entity-config-example

- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app2
  brooklyn.children:
  - type: entity-config-example
    brooklyn.config:
      example.map:
        MESSAGE_IN_CHILD: InChild

- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app3
  brooklyn.config:
    example.map:
      MESSAGE_IN_PARENT: InParent
  brooklyn.children:
  - type: entity-config-example

- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app4
  brooklyn.config:
    example.map:
      MESSAGE_IN_PARENT: InParent
  brooklyn.children:
  - type: entity-config-example
    brooklyn.config:
      example.map:
        MESSAGE_IN_CHILD: InChild
{% endhighlight %}

A limitations of `inheritance.parent` is when inheriting values from parent and grandparent 
entities: a value specified on the parent will override (rather than be merged with) the
value on the grandparent.


### Entity provisioning.properties: Overriding and Merging

An entity (which extends `SoftwareProcess`) can define a map of `provisioning.properties`. If 
the entity then provisions a location, it passes this map of properties to the location for
obtaining the machine. These properties will override and augment the configuration on the location
itself.

When deploying to a jclouds location, one can specify `templateOptions` (of type map). Rather than
overriding, these will be merged with any templateOptions defined on the location.

In the example below, the VM will be provisioned with minimum 2G ram and minimum 2 cores. It will 
also use the merged template options value of 
`{placementGroup: myPlacementGroup, securityGroupIds: sg-000c3a6a}`:

{% highlight yaml %}
location:
  aws-ec2:us-east-1:
    minRam: 2G
    templateOptions:
      placementGroup: myPlacementGroup
services:
- type: org.apache.brooklyn.entity.machine.MachineEntity
  brooklyn.config:
    provisioning.properties:
      minCores: 2
      templateOptions:
        securityGroupIds: sg-000c3a6a
{% endhighlight %}

The merging of `templateOptions` is shallow (i.e. maps within the `templateOptions` are not merged). 
In the example below, the `userMetadata` value within `templateOptions` will be overridden by the 
entity's value, rather than the maps being merged; the value used when provisioning will be 
`{key2: val2}`:

{% highlight yaml %}
location:
  aws-ec2:us-east-1:
    templateOptions:
      userMetadata:
        key1: val1
services:
- type: org.apache.brooklyn.entity.machine.MachineEntity
  brooklyn.config:
    provisioning.properties:
      userMetadata:
        key2: val2
{% endhighlight %}



### Merging Location, Policy and Enricher Configuration Values

A current limitation is that `inheritance.type` is not supported for configuration of locations,
policies and enrichers. The current behaviour is that config is not inherited.
