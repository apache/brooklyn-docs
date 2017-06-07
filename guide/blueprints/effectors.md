---
title: Effectors
layout: website-normal
---

Effectors perform an operation of some kind, carried out by a Brooklyn Entity.
They can be manually invoked or triggered by a Policy.

Common uses of a effector include the following:

*	perform a command on a remote machine,
*	collect data and publish them to sensors.

Entities have default effectors, the lifecycle management effectors like ``start``, ``stop``, ``restart``, and clearly more ``Effectors`` can be attached to them.

Off-the-Shelf Effectors
----------------------

Effectors are highly reusable as their inputs, thresholds and targets are customizable.

### SSHCommandEffector

An ```Effector``` to invoke a command on a node accessible via SSH.

It allows to execute a ```command``` in a specific ```execution director``` (executionDir) by using a custom ```shell environment` (shellEnv).
By default, the specified command will be executed on the entity where the effector is attached or on all *children* or all *members* (if it is a group) by configuring ```executionTarget```.

Here a simple example of an ```SshCommandEffector``` definition:

{% highlight yaml %}
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
{% endhighlight %}

See [```here```](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/ssh/SshCommandEffector.html) for more details.

### HTTPCommandEffector

An ```Effector``` to invoke REST endpoints.

It allows to specify the URI, the HTTP verb, credentials for authentication and HTTP headers.

It deals with some ```HttpHeaders.CONTENT_TYPE``` namely *application/json* (as default) and *application/x-www-form-urlencoded*.
In the latter case, a map payload will be ```URLEncoded``` in a single string.

With optional ```JSON_PATH``` configuration key, the effector will extract a section of the json response.

Using ```JSON_PATHS_AND_SENSORS``` configuration key, it is possible to extract one or more values from a json response, and publish them in sensors.

{% highlight yaml %}
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
{% endhighlight %}

See [```here```](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/http/HttpCommandEffector.html) for more details.

### AddChildrenEffector

An ```Effector``` to add a child blueprint to an entity.

{% highlight yaml %}
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
{% endhighlight %}

One of the config keys ```BLUEPRINT_YAML``` (containing a YAML blueprint (map or string)) or ```BLUEPRINT_TYPE``` (containing a string referring to a catalog type) should be supplied, but not both.

See [```here```](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/AddChildrenEffector.html) for more details.

Writing an Effector
-------------------

### Your First Effector

Effectors generally perform actions on entities.
Each effector instance is associated with an entity,
and at runtime it will typically exectute an operation, collect the result and, potentially, publish it as sensor on that entity, performing some computation.

Writing a effector is straightforward.
Simply extend [``AddEffector``](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/AddEffector.html),
providing an implementation for ``newEffectorBuilder`` and adding a constructor that consumes the builder or override an existing effector.

{% highlight java %}

 public MyEffector(ConfigBag params) {
    super(newEffectorBuilder(params).build());
}

public static EffectorBuilder<String> newEffectorBuilder(ConfigBag params) {
    EffectorBuilder<String> eff = AddEffector.newEffectorBuilder(String.class, params);
    eff.impl(new Body(eff.buildAbstract(), params));
    return eff;
}
{% endhighlight %}

and supply an ```EffectorBody``` similar to:

{% highlight java %}

protected static class Body extends EffectorBody<String> {
    ...

    @Override
    public String call(final ConfigBag params) {
     ...
    }
}
{% endhighlight %}

### Best Practice

The following recommendations should be considered when designing policies:

#### Policies should be small and composable

One effector which executes a command and emits a sensor, and a second effector which uses the previous sensor, if defined, to execute another operation.

