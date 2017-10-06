---
title: Common Classes and Entities
layout: website-normal
---

<!-- TODO old, needs work (refactoring!) and use of java_link -->

### Entity Class Hierarchy

By convention in Brooklyn the following words have a particular meaning:

* *Group* - a homogeneous grouping of entities (which need not all be managed by the same parent 
  entity)
* *Cluster* - a homogeneous collection of entities (all managed by the "cluster" entity)
* *Fabric* - a multi-location collection of entities, with one per location; often used with a cluster per location
* *Application* - a top-level entity, which can have one or more child entities.

The following constructs are often used for Java entities:

* *entity spec* defines an entity to be created; used to define a child entity, or often to 
  define the type of entity in a cluster.
* *traits* (mixins) providing certain capabilities, such as *Resizable* and *Startable*.
* *Resizable* entities can re-sized dynamically, to increase/decrease the number of child entities.
  For example, scaling up or down a cluster. It could similarly be used to vertically scale a VM,
  or to resize a disk.
* *Startable* indicates the effector to be executed on initial deployment (`start()`) and on 
  tear down (`stop()`).


### Configuration

Configuration keys are typically defined as static named fields on the Entity interface. These
define the configuration values that can be passed to the entity during construction. For
example:

```java
public static final ConfigKey<String> ROOT_WAR = new ConfigKeys.newStringConfigKey(
        "wars.root",
        "WAR file to deploy as the ROOT, as URL (supporting file: and classpath: prefixes)");
```

If supplying a default value, it is important that this be immutable. Otherwise, it risks users
of the blueprint modifying the default value, which would affect blueprints that are subsequently 
deployed.

One can optionally define a `@SetFromFlag("war")`. This defines a short-hand for configuring the
entity. However, it should be used with caution - when using configuration set on a parent entity
(and thus inherited), the `@SetFromFlag` short-form names are not checked. The long form defined 
in the constructor should be meaningful and sufficient. The usage of `@SetFromFlag` is therefore
discouraged.

The type `AttributeSensorAndConfigKey<?>` can be used to indicate that a config key should be resolved,
and its value set as a sensor on the entity (when `ConfigToAttributes.apply(entity)` is called).

A special case of this is `PortAttributeSensorAndConfigKey`. This is resolved to find an available 
port (by querying the target location). For example, the value `8081+` means that then next available
port starting from 8081 will be used.


### Declaring Sensors

Sensors are typically defined as static named fields on the Entity interface. These define 
the events published by the entity, which interested parties can subscribe to. For example:

```java
AttributeSensor<String> MANAGEMENT_URL = Sensors.newStringSensor(
        "crate.managementUri",
        "The address at which the Crate server listens");
```


### Declaring Effectors

Effectors are the operations that an entity supports. There are multiple ways that an entity can 
be defined. Examples of each are given below.

#### Effector Annotation

A method on the entity interface can be annotated to indicate it is an effector, and to provide
metadata about the effector and its parameters.

```java
@org.apache.brooklyn.core.annotation.Effector(description="Retrieve a Gist")
public String getGist(@EffectorParam(name="id", description="Gist id") String id);
```


#### Static Field Effector Declaration

A static field can be defined on the entity to define an effector, giving metadata about that effector.

```java
public static final Effector<String> EXECUTE_SCRIPT = Effectors.effector(String.class, "executeScript")
        .description("invokes a script")
        .parameter(ExecuteScriptEffectorBody.SCRIPT)
        .impl(new ExecuteScriptEffectorBody())
        .build();
```

In this example, the implementation of the effector is an instance of `ExecuteScriptEffectorBody`. 
This implements `EffectorBody`. It will be invoked whenever the effector is called.


#### Dynamically Added Effectors

An effector can be added to an entity dynamically - either as part of the entity's `init()`
or as separate initialization code. This allows the implementation of the effector to be shared
amongst multiple entities, without sub-classing. For example:

```java
Effector<Void> GET_GIST = Effectors.effector(Void.class, "createGist")
        .description("Create a Gist")
        .parameter(String.class, "id", "Gist id")
        .buildAbstract();

public static void CreateGistEffectorBody implements EffectorBody<Void>() {
    @Override
    public Void call(ConfigBag parameters) {
        // impl
        return null;
    }
}

@Override
public void init() {
    getMutableEntityType().addEffector(CREATE_GIST, new CreateGistEffectorBody());
}
```


### Effector Invocation

There are several ways to invoke an effector programmatically:

* Where there is an annotated method, simply call the method on the interface.

* Call the `invoke` method on the entity, using the static effector declaration. For example:  
  `entity.invoke(CREATE_GIST, ImmutableMap.of("id", id));`.

* Call the utility method `org.apache.brooklyn.core.entity.Entities.invokeEffector`. For example:  
  `Entities.invokeEffector(this, targetEntity, CREATE_GIST, ImmutableMap.of("id", id));`.

When an effector is invoked, the call is intercepted to wrap it in a task. In this way, the 
effector invocation is tracked - it is shown in the Activity view.

When `invoke` or `invokeEffector` is used, the call returns a `Task` object (which extends 
`Future`). This allows the caller to understand progress and errors on the task, as well as 
calling `task.get()` to retrieve the return value. Be aware that `task.get()` is a blocking 
function that will wait until a value is available before returning.


### Tasks

_Warning: the task API may be changed in a future release. However, backwards compatibility
will be maintained where possible._

When implementing entities and policies, all work done within Brooklyn is executed as Tasks.
This makes it trackable and visible to administrators. For the activity list to show a break-down 
of an effector's work (in real-time, and also after completion), tasks and sub-tasks must be 
created.

In common situations, tasks are implicitly created and executed. For example, when implementing
an effector using the `@Effector` annotation on a method, the method invocation is automatically
wrapped as a task. Similarly, when a subscription is passed an event (e.g. when using 
`SensorEventListener.onEvent(SensorEvent<T> event)`, that call is done inside a task.

Within a task, it is possible to create and execute sub-tasks. A common way to do this is to 
use `DynamicTasks.queue`. If called from within a a "task queuing context" (e.g. from inside an
effector implementation), it will add the task to be executed. By default, the outer task will not be
marked as done until its queued sub-tasks are complete.

When creating tasks, the `TaskBuilder` can be used to create simple tasks or to create compound tasks
whose sub-tasks are to be executed either sequentially or in parallel. For example:

```java
TaskBuilder.<Integer>builder()
        .displayName("stdout-example")
        .body(new Callable<Integer>() { public Integer call() { System.out.println("example"; } })
        .build();
```

There are also builder and factory utilities for common types of operation, such as executing SSH 
commands using `SshTasks`.

A lower level way to submit tasks within an entity is to call `getExecutionContext().submit(...)`.
This automatically tags the task to indicate that its context is the given entity.

An even lower level way to execute tasks (to be ignored except for power-users) is to go straight  
to the `getManagementContext().getExecutionManager().submit(...)`. This is similar to the standard
Java `Executor`, but also supports more metadata about tasks such as descriptions and tags.
It also supports querying for tasks. There is also support for submitting `ScheduledTask` 
instances which run periodically.

The `Tasks` and `BrooklynTaskTags` classes supply a number of conveniences including builders to 
make working with tasks easier.


### Subscriptions and the Subscription Manager

Entities, locations, policies and enrichers can subscribe to events. These events could be
attribute-change events from other entities, or other events explicitly published by the entities.

A subscription is created by calling `subscriptions().subscribe(entity, sensorType, sensorEventListener)`.
The `sensorEventListener` will be called with the event whenever the given entity emits a sensor of
the given type. If `null` is used for either the entity or sensor type, this is treated as a 
wildcard.

It is very common for a policy or enricher to subscribe to events, to kick off actions or to 
publish other aggregated attributes or events. 
