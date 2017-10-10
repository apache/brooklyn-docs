---
layout: website-normal
title: Writing an Entity
---
# {{ page.title }}

## Ways to write an entity

There are several ways to write a new entity:

* For Unix/Linux, write YAML blueprints, for example using a **`VanillaSoftwareProcess`** and 
  configuring it with your scripts.
* For Windows, write YAML blueprints using **`VanillaWindowsProcess`** and configure the PowerShell
  scripts.
* For composite entities, use YAML to compose exiting types of entities (potentially overwriting
  parts of their configuration), and wire them together.
* Use **[Chef recipes](../chef/index.md)**.
* Use **[Salt formulas](../salt/index.md)**.
* Use **[Ansible playbooks](../ansible/index.md)**.
* Write pure-java, extending existing base-classes. For example, the `GistGenerator` 
  [example](defining-and-deploying.md). These can use utilities such as `HttpTool` and 
  `BashCommands`.
* Write pure-Java blueprints that extend `SoftwareProcess`. However, the YAML approach is strongly
  recommended over this approach.
* Write pure-Java blueprints that compose together existing entities, for example to manage
  a cluster. Often this is possible in YAML and that approach is strongly recommended. However,
  sometimes the management logic may be so complex that it is easier to use Java.

The rest of this section covers writing an entity in pure-java (or other JVM languages).


## Things To Know

All entities have an interface and an implementation. The methods on the interface 
are its effectors; the interface also defines its sensors.

Entities are created through the management context (rather than calling the  
constructor directly). This returns a proxy for the entity rather than the real 
instance, which is important in a distributed management plane.

All entity implementations inherit from `AbstractEntity`, often through one of the following:

* **`SoftwareProcessImpl`**:  if it's a software process
* **`VanillaJavaAppImpl`**:  if it's a plain-old-java app
* **`JavaWebAppSoftwareProcessImpl`**:  if it's a JVM-based web-app
* **`DynamicClusterImpl`**, **`DynamicGroupImpl`** or **`AbstractGroupImpl`**:  if it's a collection of other entities

Software-based processes tend to use *drivers* to install and
launch the remote processes onto *locations* which support that driver type.
For example, `AbstractSoftwareProcessSshDriver` is a common driver superclass,
targetting `SshMachineLocation` (a machine to which Brooklyn can ssh).
The various `SoftwareProcess` entities above (and some of the exemplars 
listed at the end of this page) have their own dedicated drivers.

Finally, there are a collection of *traits*, such as `Resizable`, 
in the package ``brooklyn.entity.trait``. These provide common
sensors and effectors on entities, supplied as interfaces.
Choose one (or more) as appropriate.



## Key Steps

*NOTE: Consider instead writing a YAML blueprint for your entity.*

So to get started:

1. Create your entity interface, extending the appropriate selection from above,
   to define the effectors and sensors.
2. Include an annotation like `@ImplementedBy(YourEntityImpl.class)` on your interface,
   where `YourEntityImpl` will be the class name for your entity implementation.
3. Create your entity class, implementing your entity interface and extending the 
   classes for your chosen entity super-types. Naming convention is a suffix "Impl"
   for the entity class, but this is not essential.
4. Create a driver interface, again extending as appropriate (e.g. `SoftwareProcessDriver`).
   The naming convention is to have a suffix "Driver". 
5. Create the driver class, implementing your driver interface, and again extending as appropriate.
   Naming convention is to have a suffix "SshDriver" for an ssh-based implementation.
   The correct driver implementation is found using this naming convention, or via custom
   namings provided by the `BasicEntityDriverFactory`.
6. Wire the `public Class getDriverInterface()` method in the entity implementation, to specify
   your driver interface.
7. Provide the implementation of missing lifecycle methods in your driver class (details below)
8. Connect the sensors from your entity (e.g. overriding `connectSensors()` of `SoftwareProcessImpl`)..
   See the sensor feeds, such as `HttpFeed` and `JmxFeed`.

Any JVM language can be used to write an entity. However use of pure Java is encouraged for
entities in core brooklyn. 


## Helpful References

A few handy pointers will help make it easy to build your own entities.
Check out some of the exemplar existing entities
(note, some of the other entities use deprecated utilities and a deprecated class 
hierarchy; it is suggested to avoid these, looking at the ones below instead):

* `JBoss7Server`
* `MySqlNode`

You might also find the following helpful:

* **[Entity Design Tips](../../dev/tips/index.md#EntityDesign)**
* The **[User Guide](../../)**
* The **[Mailing List](https://mail-archives.apache.org/mod_mbox/brooklyn-dev/)**
