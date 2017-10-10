---
title: Feeds
layout: website-normal
---
# {{ page.title }}

<!-- TODO old, needs work (refactoring!) and use of java_link -->

### Feeds

`Feed`s within Apache Brooklyn are used to populate an entity's sensors. There are a variety of 
feed types, which commonly poll to retrieve the raw metrics of the entity (for example polling an 
HTTP management API, or over JMX).  


#### Persistence

There are two ways to associate a feed with an entity.

The first way is (within the entity) to call `feeds().addFeed(...)`.
This persists the feed: the feed will be automatically
added to the entity when the Brooklyn server restarts. It is important that all configuration
of the feed is persistable (e.g. not using any in-line anonymous inner classes to define
functions).

The feed builders can be passed a `uniqueTag(...)`, which will be used to ensure that on
rebind there will not be multiple copied of the feed (e.g. if `rebind()` had already re-created
the feed).

The second way is to just pass to the feed's builder the entity. When using this mechanism, 
the feed will be wired up to the entity but it will not be persisted. In this case, it is
important that the entity's `rebind()` method recreates the feed.


#### Types of Feed

##### HTTP Feed

An `HttpFeed` polls over http(s). An example is shown below:

```java
private HttpFeed feed;

@Override
protected void connectSensors() {
  super.connectSensors();
  
  feed = feeds().addFeed(HttpFeed.builder()
      .period(200)
      .baseUri(String.format("http://%s:%s/management/subsystem/web/connector/http/read-resource", host, port))
      .baseUriVars(ImmutableMap.of("include-runtime","true"))
      .poll(new HttpPollConfig(SERVICE_UP)
          .onSuccess(HttpValueFunctions.responseCodeEquals(200))
          .onError(Functions.constant(false)))
      .poll(new HttpPollConfig(REQUEST_COUNT)
          .onSuccess(HttpValueFunctions.jsonContents("requestCount", Integer.class)))
      .build());
}

@Override
protected void disconnectSensors() {
  super.disconnectSensors();
  if (feed != null) feed.stop();
}
```


##### SSH Feed

An SSH feed executes a command over ssh periodically. An example is shown below:

```java
private AbstractCommandFeed feed;

@Override
protected void connectSensors() {
  super.connectSensors();

  feed = feeds.addFeed(SshFeed.builder()
      .machine(mySshMachineLachine)
      .poll(new CommandPollConfig(SERVICE_UP)
          .command("rabbitmqctl -q status")
          .onSuccess(new Function() {
              public Boolean apply(SshPollValue input) {
                return (input.getExitStatus() == 0);
              }}))
      .build());
}

@Override
protected void disconnectSensors() {
  super.disconnectSensors();
  if (feed != null) feed.stop();
}
```

##### WinRm CMD Feed

A WinRM feed executes a windows command over winrm periodically. An example is shown below:

```java
private AbstractCommandFeed feed;

//@Override
protected void connectSensors() {
  super.connectSensors();

  feed = feeds.addFeed(CmdFeed.builder()
                .entity(entity)
                .machine(machine)
                .poll(new CommandPollConfig<String>(SENSOR_STRING)
                        .command("ipconfig")
                        .onSuccess(SshValueFunctions.stdout()))
                .build());
}

@Override
protected void disconnectSensors() {
  super.disconnectSensors();
  if (feed != null) feed.stop();
}
```

##### Windows Performance Counter Feed

This type of feed retrieves performance counters from a Windows host, and posts the values to sensors.

One must supply a collection of mappings between Windows performance counter names and Brooklyn 
attribute sensors.

This feed uses WinRM to invoke the windows utility <tt>typeperf</tt> to query for a specific set 
of performance counters, by name. The values are extracted from the response, and published to the
entity's sensors. An example is shown below:

```java
private WindowsPerformanceCounterFeed feed;

@Override
protected void connectSensors() {
  feed = feeds.addFeed(WindowsPerformanceCounterFeed.builder()
      .addSensor("\\Processor(_total)\\% Idle Time", CPU_IDLE_TIME)
      .addSensor("\\Memory\\Available MBytes", AVAILABLE_MEMORY)
      .build());
}

@Override
protected void disconnectSensors() {
  super.disconnectSensors();
  if (feed != null) feed.stop();
}
```


##### JMX Feed

This type of feed queries over JMX to retrieve sensor values. This can query attribute
values or call operations.

The JMX connection details can be automatically inferred from the entity's standard attributes,
or it can be explicitly supplied.

An example is shown below:

```java
private JmxFeed feed;

@Override
protected void connectSensors() {
  super.connectSensors();

  feed = feeds().addFeed(JmxFeed.builder()
      .period(5, TimeUnit.SECONDS)
      .pollAttribute(new JmxAttributePollConfig<Integer>(ERROR_COUNT)
          .objectName(requestProcessorMbeanName)
          .attributeName("errorCount"))
      .pollAttribute(new JmxAttributePollConfig<Boolean>(SERVICE_UP)
          .objectName(serverMbeanName)
          .attributeName("Started")
          .onError(Functions.constant(false)))
      .build());
}

Override
protected void disconnectSensors() {
  super.disconnectSensors();
  if (feed != null) feed.stop();
}
```



##### Function Feed

This type of feed periodically executes something to compute the attribute values. This 
can be a `Callable`, `Supplier` or Groovy `Closure`. It must be persistable (e.g. not use 
an in-line anonymous inner classes).

An example is shown below:

```java
public static class ErrorCountRetriever implements Callable<Integer> {
  private final Entity entity;
  
  public ErrorCountRetriever(Entity entity) {
    this.entity = entity;
  }
  
  @Override
  public Integer call() throws Exception {
    // TODO your implementation...
    return 0;
  }
}

private FunctionFeed feed;

@Override
protected void connectSensors() {
  super.connectSensors();

  feed = feeds().addFeed(FunctionFeed.builder()
    .poll(new FunctionPollConfig<Object, Integer>(ERROR_COUNT)
        .period(500, TimeUnit.MILLISECONDS)
        .callable(new ErrorCountRetriever(this))
        .onExceptionOrFailure(Functions.<Integer>constant(null))
    .build());
}
 
@Override
protected void disconnectSensors() {
  super.disconnectSensors();
  if (feed != null) feed.stop();
}
```
