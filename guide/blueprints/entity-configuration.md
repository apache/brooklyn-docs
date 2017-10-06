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

```yaml
services:
- type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
  brooklyn.config:
    webapp.enabledProtocols: http
    http.port: 9080
    wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-webapp/0.9.0/brooklyn-example-hello-world-webapp-0.9.0.war
```

If no config value is supplied, the default for that config key will be used. For example, 
`http.port` would default to 8080 if not explicitly supplied.

Some config keys also have a short-form (e.g. `httpPort` instead of `http.port` would also work 
in the YAML example above). However, that approach is discouraged as it does not work in all contexts
such as for inheriting configuration from a parent entity.


### Configuration in a Catalog Item

When defining an entity in the catalog, it can include configuration values like any other 
blueprint (i.e. inside the `brooklyn.config` block).

It can also explicitly declare config keys, using the `brooklyn.parameters` block. The example 
below illustrates the principle:

```yaml
brooklyn.catalog:
  items:
  - id: entity-config-example
    itemType: entity
    name: Entity Config Example
    item:
      type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
      brooklyn.parameters:
      - name: custom.message
        type: string
        description: Message to be displayed
        default: Hello
      brooklyn.config:
        shell.env:
          MESSAGE: $brooklyn:config("custom.message")
        launch.command: |
          echo "My example launch command: $MESSAGE"
        checkRunning.command: |
          echo "My example checkRunning command: $MESSAGE"
```

Once added to the catalog, it can be used with the simple blueprint below (substituting the location
of your choice). Because no configuration has been overridden, this will use the default value
for `custom.message`, and will use the given values for `launch.command` and `checkRunning.command`:

```yaml
location: aws-ec2:us-east-1
services:
- type: entity-config-example
```

For details of how to write and add catalog items, see [Catalog]({{ book.path.guide }}/blueprints/catalog/). 


#### Config Key Constraints

The config keys in the `brooklyn.parameters` can also have constraints defined, for what values
are valid. If more than one constraint is defined, then they must all be satisfied. The constraints 
can be any of:

* `required`: deployment will fail if no value is supplied for this config key.
* `regex: ...`: the value will be compared against the given regular expression.
* A predicate, declared using the DSL `$brooklyn:object`.  

This is illustrated in the example below:

```yaml
brooklyn.catalog:
  items:
  - id: entity-constraint-example
    itemType: entity
    name: Entity Config Example
    item:
      type: org.apache.brooklyn.entity.stock.BasicEntity
      brooklyn.parameters:
      - name: compulsoryExample
        type: string
        constraints:
        - required
      - name: addressExample
        type: string
        constraints:
        - regex: ^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$
      - name: numberExample
        type: double
        constraints:
        - $brooklyn:object:
            type: org.apache.brooklyn.util.math.MathPredicates
            factoryMethod.name: greaterThan
            factoryMethod.args:
            - 0.0
        - $brooklyn:object:
            type: org.apache.brooklyn.util.math.MathPredicates
            factoryMethod.name: lessThan
            factoryMethod.args:
            - 256.0
```

An example usage of this toy example, once added to the catalog, is shown below:

```yaml
services:
- type: entity-constraint-example
  brooklyn.config:
    compulsoryExample: foo
    addressExample: 1.1.1.1
    numberExample: 2.0
```


### Inheriting Configuration

Configuration can be inherited from a super-type, and from a parent entity in the runtime 
management hierarchy. This applies to entities and locations. In a future release, this will be
extended to also apply to policies and enrichers.

When a blueprint author defines a config key, they can explicitly specify the rules for inheritance 
(both for super/sub-types, and for the runtime management hiearchy). This gives great flexibilty,
but should be used with care so as not to surprise users of the blueprint.

The default behaviour is outlined below, along with examples and details of how to explilcitly 
define the desired behaviour.


#### Normal Configuration Precedence

There are several places that a configuration value can come from. If different values are 
specified in multiple places, then the order of precedence is as listed below:

1. Configuration on the entity itself
2. Inherited configuration from the super-type
3. Inherited configuration from the runtime type hierarchy
4. The config key's default value


#### Inheriting Configuration from Super-type

When using an entity from the catalog, its configuration values can be overridden. For example,
consider the `entity-config-example` added to the catalog in the section 
[Configuration in a Catalog Item](#configuration-in-a-catalog-item).
We can override these values. If not overridden, then the existing values from the super-type will be used:

```yaml
location: aws-ec2:us-east-1
services:
- type: entity-config-example
  brooklyn.config:
    custom.message: Goodbye
    launch.command: |
      echo "Sub-type launch command: $MESSAGE"
```



In this example, the `custom.message` overrides the default defined on the config key.
The `launch.command` overrides the original command. The other config (e.g. `checkRunning.command`)
is inherited unchanged.

It will write out: `Sub-type launch command: Goodbye`.


#### Inheriting Configuration from a Parent in the Runtime Management Hieararchy

Configuration passed to an entity is inherited by all child entities, unless explicitly overridden.

In the example below, the `wars.root` config key is inherited by all TomcatServer entities created
under the cluster, so they will use that war:

```yaml
services:
- type: org.apache.brooklyn.entity.group.DynamicCluster
  brooklyn.config:
    wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-webapp/0.9.0/brooklyn-example-hello-world-webapp-0.9.0.war
    dynamiccluster.memberspec:
      $brooklyn:entitySpec:
        type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
```

In the above example, it would be better to have specified the `wars.root` configuration in the 
`TomcatServer` entity spec, rather than at the top level. This would make it clearer for the reader
what is actually being configured.

The technique of inherited config can simplify some blueprints, but care should be taken. 
For more complex (composite) blueprints, this can be difficult to use safely; it relies on 
knowledge of the internals of the child components. For example, the inherited config 
may impact multiple sub-components, rather than just the specific entity to be changed.
This is particularly true when using complex items from the catalog, and when using common config 
values (e.g. `install.version`).

An alternative approach is to declare the expected configuration options at the top level of the
catalog item, and then (within the catalog item) explicitly inject those values into the correct
sub-components. Users of this catalog item would set only those exposed config options, rather 
than trying to inject config directly into the nested entities.


#### DSL Evaluation of Inherited Config

When writing blueprints that rely on inheritance from the runtime management hierarchy, it is 
important to  understand how config keys that use DSL will be evaluated. In particular, when 
evaluating a DSL expression, it will be done in the context of the entity declaring the config 
value (rather than on the entity using the config value).

For example, consider the config value `$brooklyn:attributeWhenReady("host.name")`
declared on entity X, and inherited by child entity Y. If entity Y uses this config value, 
it will get the "host.name" attribute of entity X.

Below is another (contrived!) example of this DSL evaluation. When evaluating `refExampleConfig`,
it retrievies the value of `exampleConfig` which is the DSL expression, and evaluates this in the 
context of the parent entity that declares it. Therefore `$brooklyn:config("ownConfig")` returns 
the parent's `ownConfig` value, and the final result for `refExampleConfig` is set to "parentValue":

```yaml
services:
- type: org.apache.brooklyn.entity.stock.BasicApplication
  brooklyn.config:
    ownConfig: parentValue
    exampleConfig: $brooklyn:config("ownConfig")
  
  brooklyn.children:
  - type: org.apache.brooklyn.entity.stock.BasicEntity
    brooklyn.config:
      ownConfig: childValue
      refExampleConfig: $brooklyn:config("exampleConfig")
```

_However, the web-console also shows other misleading (incorrect!) config values for the child 
entity. It shows the inherited config value of `exampleConfig` as "childValue" (because the
REST api did not evaluate the DSL in the correct context, when retrieving the value! 
See https://issues.apache.org/jira/browse/BROOKLYN-455._


#### Merging Configuration Values

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
the section [Configuration in a Catalog Item](#configuration-in-a-catalog-item)).
The environment variables will include the `MESSAGE` 
set in the super-type and the `MESSAGE2` set here:

```yaml
location: aws-ec2:us-east-1
services:
- type: entity-config-example
  brooklyn.config:
    shell.env:
      MESSAGE2: Goodbye
    launch.command: |
      echo "Different example launch command: $MESSAGE and $MESSAGE2"
```

To explicitly remove a value from the super-type's map (rather than adding to it), a blank entry
can be defined. 


#### Entity provisioning.properties: Overriding and Merging

An entity (which extends `SoftwareProcess`) can define a map of `provisioning.properties`. If 
the entity then provisions a location, it passes this map of properties to the location for
obtaining the machine. These properties will override and augment the configuration on the location
itself.

When deploying to a jclouds location, one can specify `templateOptions` (of type map). Rather than
overriding, these will be merged with any templateOptions defined on the location.

In the example below, the VM will be provisioned with minimum 2G ram and minimum 2 cores. It will 
also use the merged template options value of 
`{placementGroup: myPlacementGroup, securityGroupIds: sg-000c3a6a}`:

```yaml
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
```

The merging of `templateOptions` is shallow (i.e. maps within the `templateOptions` are not merged). 
In the example below, the `userMetadata` value within `templateOptions` will be overridden by the 
entity's value, rather than the maps being merged; the value used when provisioning will be 
`{key2: val2}`:

```yaml
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
```


#### Re-inherited Versus not Re-inherited

For some configuration values, the most logical behaviour is for an entity to "consume" the config
key's value, and thus not pass it down to children in the runtime type hierarchy. This is called
"not re-inherited".

Some common config keys that will not re-inherited include:

* `install.command` (and the `pre.install.command` and `post.install.command`) 
* `customize.command` (and the `pre.customize.command` and `post.customize.command`)
* `launch.command` (and the ``pre.launch.command` and `post.launch.command`)
* `checkRunning.command`
* `stop.command`
* The similar commands for `VanillaWindowsProcess` powershell.
* The file and template install config keys (e.g. `files.preinstall`, `templates.preinstall`, etc)

An example is shown below. Here, the "logstash-child" is a sub-type of `VanillaSoftwareProcess`,
and is co-located on the same VM as Tomcat. We don't want the Tomcat's configuration, such as 
`install.command`, to be inherited by the logstash child. If it was inherited, the logstash-child
entity might re-execute the Tomcat's install command! Instead, the `install.command` config is
"consumed" by the Tomcat instance and is not re-inherited:

```yaml
services:
- type: org.apache.brooklyn.entity.webapp.tomcat.Tomcat8Server
  brooklyn.config:
    children.startable.mode: background_late
  brooklyn.children:
  - type: logstash-child
    brooklyn.config:
      logstash.elasticsearch.host: $brooklyn:entity("es").attributeWhenReady("urls.http.withBrackets")
...
```

"Not re-inherited" differs from "never inherited". The example below illustrates the difference, 
though this use is discouraged (it is mostly for backwards compatibility). The `post.install.command`
is not consumed by the `BasicApplication`, so will be inherited by the `Tomcat8Server` which will
consume it. The config value will therefore not be inherited by the `logstash-child`.

```yaml
services:
- type: org.apache.brooklyn.entity.stock.BasicApplication
  brooklyn.config:
    post.install.command: echo "My post.install command"
  brooklyn.children:
  - type: org.apache.brooklyn.entity.webapp.tomcat.Tomcat8Server
    brooklyn.config:
      children.startable.mode: background_late
    brooklyn.children:
    - type: logstash-child
      brooklyn.config:
        logstash.elasticsearch.host: $brooklyn:entity("es").attributeWhenReady("urls.http.withBrackets")
...
```


#### Never Inherited

For some configuration values, the most logical behaviour is for the value to never be inherited
in the runtime management hiearchy.

Some common config keys that will never inherited include:

* `defaultDisplayName`: this is the name to use for the entity, if an explicit name is not supplied.
  This is particularly useful when adding an entity in a catalog item (so if the user does not give
  a name, it will get a sensible default). It would not be intuitive for all the children of that
  entity to also get that default name.

* `id`: the id of an entity (as supplied in the YAML, to allow references to that entity) is not 
  inherited. It is the id of that specific entity, so must not be shared by all its children.


#### Inheritance Modes: Deep Dive

The javadoc in the code is useful for anyone who wants to go deep! See
`org.apache.brooklyn.config.BasicConfigInheritance` and `org.apache.brooklyn.config.ConfigInheritances`
in the repo https://github.com/apache/brooklyn-server.

When defining a new config key, the exact semantics for inheritance can be defined. There are 
separate options to control config inheritance from the super-type, and config inheritance from the
parent in the runtime management hierarchy.

The possible modes are:

* `NEVER_INHERITED`: indicates that a key's value should never be inherited (even if defined on 
  an entity that does not know the key). Most usages will prefer `NOT_REINHERITED`.

* `NOT_REINHERITED`: indicates that a config key value (if used) should not be passed down to
  children / sub-types. Unlike `NEVER_INHERITED`, these values can be passed down if they are not
  used by the entity (i.e. if the entity does not expect it). However, when used by a child,
  it will not be passed down any further. If the inheritor also defines a value the parent's 
  value is ignored irrespective  (as in `OVERWRITE`; see `NOT_REINHERITED_ELSE_DEEP_MERGE` if merging 
  is desired).

* `NOT_REINHERITED_ELSE_DEEP_MERGE`: as `NOT_REINHERITED` but in cases where a value is inherited 
  because a parent did not recognize it, if the inheritor also defines a value the two values should 
  be merged.

* `OVERWRITE`: indicates that if a key has a value at both an ancestor and a descendant, the 
  descendant and his descendants will prefer the value at the descendant.

* `DEEP_MERGE`: indicates that if a key has a value at both an ancestor and a descendant, the 
  descendant and his descendants should attempt to merge the values. If the values are not mergable,
  behaviour is undefined (and often the descendant's value will simply overwrite).


#### Explicit Inheritance Modes

_The YAML support for explicitly defining the inheritance mode is still work-in-progress. The options
documented below will be enhanced in a future version of Brooklyn, to better support the modes described
above._

In a YAML blueprint, within the `brooklyn.parameters` section for declaring new config keys, one can
set the mode for `inheritance.type` and `inheritance.parent` (i.e. for inheritance from the super-type, and
inheritance in the runtime management hierarchy). The possible values are:

* `deep_merge`: the inherited and the given value should be merged; maps within the map will also be merged
* `always`: the inherited value should be used, unless explicitly overridden by the entity
* `none`: the value should not be inherited; if there is no explicit value on the entity then the default value will be used

Below is a (contrived!) example of inheriting the `example.map` config key. When using this entity
in a blueprint, the entity's config will be merged with that defined in the super-type, and the 
parent entity's value will never be inherited:

```yaml
brooklyn.catalog:
  items:
  - id: entity-config-inheritance-example
    version: "1.1.0-SNAPSHOT"
    itemType: entity
    name: Entity Config Inheritance Example
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
```

The blueprints below demonstrate the various permutations for setting configuration for the
config `example.map`. This can be inspected by looking at the entity's config. The config
we see for app1 is the inherited `{MESSAGE: "Hello"}`; in app2 we define additional configuration,
which will be merged to give `{MESSAGE: "Hello", MESSAGE_IN_CHILD: "InChild"}`; in app3, the 
config from the parent is not inherited because there is an explicit inheritance.parent of "none",
so it just has the value `{MESSAGE: "Hello"}`; in app4 again the parent's config is ignored,
with the super-type and entity's config being merged to give  `{MESSAGE: "Hello", MESSAGE_IN_CHILD: "InChild"}`.

```yaml
location: aws-ec2:us-east-1
services:
- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app1
  brooklyn.children:
  - type: entity-config-inheritance-example

- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app2
  brooklyn.children:
  - type: entity-config-inheritance-example
    brooklyn.config:
      example.map:
        MESSAGE_IN_CHILD: InChild

- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app3
  brooklyn.config:
    example.map:
      MESSAGE_IN_PARENT: InParent
  brooklyn.children:
  - type: entity-config-inheritance-example

- type: org.apache.brooklyn.entity.stock.BasicApplication
  name: app4
  brooklyn.config:
    example.map:
      MESSAGE_IN_PARENT: InParent
  brooklyn.children:
  - type: entity-config-inheritance-example
    brooklyn.config:
      example.map:
        MESSAGE_IN_CHILD: InChild
```

A limitations of `inheritance.parent` is when inheriting values from parent and grandparent 
entities: a value specified on the parent will override (rather than be merged with) the
value on the grandparent.


#### Merging Policy and Enricher Configuration Values

A current limitation is that sub-type inheritance is not supported for configuration of
policies and enrichers. The current behaviour is that config is not inherited. The concept of
inheritance from the runtime management hierarchy does not apply for policies and enrichers
(they do not have "parents"; they are attached to an entity).
