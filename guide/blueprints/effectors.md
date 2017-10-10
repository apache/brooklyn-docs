---
title: Effectors
layout: website-normal
---
# {{ page.title }}

Effectors perform an operation of some kind, carried out by a Brooklyn Entity.
They can be manually invoked or triggered by a [Policy]({{ book.path.guide }}/blueprints/policies.html).

Common uses of an effector include the following:

*   Perform a command on a remote machine.
*   Collect data and publish them to sensors.

Entities have default effectors, the lifecycle management effectors like `start`, `stop`, `restart`, and clearly more `Effectors` can be attached to them.

Off-the-Shelf Effectors
----------------------

Effectors are highly reusable as their inputs, thresholds and targets are customizable.

### SSHCommandEffector

An `Effector` to invoke a command on a node accessible via SSH.

It enables execution of a `command` in a specific `execution director` (executionDir) by using a custom `shell environment` (shellEnv).
By default, the specified command will be executed on the entity where the effector is attached or on all *children* or all *members* (if it is a group) by configuring `executionTarget`.

There are a number of additional configuration keys available for the `SSHCommandEffector`:

| Configuration Key                 | Default | Description                                                                          |
|-----------------------------------|---------|--------------------------------------------------------------------------------------|
| command                           |         | command to be executed on the execution target                                       |
| executionDir                      |         | possible values: 'GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'TRACE' |
| shellEnv                          |         | custom shell environment where the command is executed                               |
| executionTarget                   | ENTITY  | possible values: 'MEMBERS', 'CHILDREN'                                               |

Here is a simple example of an `SshCommandEffector` definition:

```yaml
  brooklyn.initializers:
  - type: org.apache.brooklyn.core.effector.ssh.SshCommandEffector
    brooklyn.config:
      name: sayHiNetcat
      description: Echo a small hello string to the netcat entity
      command: |
        echo $message | nc $TARGET_HOSTNAME 4321
      parameters:
        message:
          description: The string to pass to netcat
          defaultValue: hi netcat
```

See [`here`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/ssh/SshCommandEffector.html) for more details.

### HTTPCommandEffector

An `Effector` to invoke HTTP endpoints.

It allows the user to specify the URI, the HTTP verb, credentials for authentication and HTTP headers.

There are a number of additional configuration keys available for the `HTTPCommandEffector`:

| Configuration Key                 | Default          | Description                                                                                                   |
|-----------------------------------|------------------|---------------------------------------------------------------------------------------------------------------|
| uri                               |                  | URI of the endpoint                                                                                           |
| httpVerb                          |                  | possible values: 'GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'TRACE'                          |
| httpUsername                      |                  | user name for the authentication                                                                              |
| httpPassword                      |                  | password for the authentication                                                                               |
| headers                           | application/json | It explicitly supports `application/x-www-form-urlencoded`                                                    |
| httpPayload                       |                  | The body of the http request                                                                                  |
| jsonPath                          |                  | A jsonPath expression to extract values from a json object                                                    |
| jsonPathAndSensors                |                  | A map where keys are jsonPath expressions and values the name of the sensor where to publish extracted values |


When a the header `HttpHeaders.CONTENT_TYPE` is equals to *application/x-www-form-urlencoded* and the `httpPayload` is a `map`, the payload is transformed into a single string using `URLEncoded`.

```yaml
brooklyn.initializers:
- type: org.apache.brooklyn.core.effector.http.HttpCommandEffector
  brooklyn.config:
    name: request-access-token
    description: Request an access token for the Azure API
    uri:
      $brooklyn:formatString:
      - "https://login.windows.net/%s/oauth2/token"
      - $brooklyn:config("tenant.id")
    httpVerb: POST
    httpPayload:
      resource: https://management.core.windows.net/
      client_id: $brooklyn:config("application.id")
      grant_type: client_credentials
      client_secret: $brooklyn:config("application.secret")
    jsonPathAndSensors:
      $.access_token: access.token
    headers:
      Content-Type: "application/x-www-form-urlencoded"
```

See [`here`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/http/HttpCommandEffector.html) for more details.

### AddChildrenEffector

An `Effector` to add a child blueprint to an entity.

```yaml
brooklyn.initializers:
- type: org.apache.brooklyn.core.effector.AddChildrenEffector
  brooklyn.config:
    name: add_tomcat
    blueprint_yaml: |
        name: sample
        description: Tomcat sample JSP and servlet application.
        origin: http://www.oracle.com/nCAMP/Hand
        services:
        -
            type: io.camp.mock:AppServer
            name: Hello WAR
            wars:
                /: hello.war
            controller.spec:
                port: 80

        brooklyn.catalog:
        name: catalog-name
        type: io.camp.mock.MyApplication
        version: 0.9
        libraries:
        - name: org.apache.brooklyn.test.resources.osgi.brooklyn-test-osgi-entities
            version: 0.1.0
            url: classpath:/brooklyn/osgi/brooklyn-test-osgi-entities.jar
    auto_start: true
```

One of the config keys `BLUEPRINT_YAML` (containing a YAML blueprint (map or string)) or `BLUEPRINT_TYPE` (containing a string referring to a catalog type) should be supplied, but not both.

See [`here`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/AddChildrenEffector.html) for more details.

Writing an Effector
-------------------

### Your First Effector

Effectors generally perform actions on entities.
Each effector instance is associated with an entity,
and at runtime it will typically exectute an operation, collect the result and, potentially, publish it as sensor on that entity, performing some computation.

Writing an effector is straightforward.
Simply extend [`AddEffector`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/AddEffector.html),
providing an implementation for `newEffectorBuilder` and adding a constructor that consumes the builder or override an existing effector.

```java

 public MyEffector(ConfigBag params) {
    super(newEffectorBuilder(params).build());
}

public static EffectorBuilder<String> newEffectorBuilder(ConfigBag params) {
    EffectorBuilder<String> eff = AddEffector.newEffectorBuilder(String.class, params);
    eff.impl(new Body(eff.buildAbstract(), params));
    return eff;
}
```

and supply an `EffectorBody` similar to:

```java

protected static class Body extends EffectorBody<String> {
    ...

    @Override
    public String call(final ConfigBag params) {
     ...
    }
}
```

### Best Practice

The following recommendations should be considered when designing effectors:

#### Effectors should be small and composable

One effector which executes a command and emits a sensor, and a second effector which uses the previous sensor, if defined, to execute another operation.

