---
title: Effectors
layout: website-normal
---

Effectors perform an operation of some kind, carried out by a Brooklyn Entity.
They can be manually invoked or triggered by a [Policy](/guide/blueprints/policies/).

Common uses of an effector include the following:

*   Perform a command on a remote machine.
*   Collect data and publish them to sensors.

Entities have default effectors, the lifecycle management effectors like `start`, `stop`, `restart`, and clearly more `Effectors` can be attached to them.

Off-the-Shelf Effectors
----------------------

Effectors are highly reusable as their inputs, thresholds and targets are customizable.

### SshCommandEffector

An `Effector` to invoke a command on a node accessible via SSH.

It enables execution of a `command` in a specific `execution director` (executionDir) by using a custom `shell environment` (shellEnv).
By default, the specified command will be executed on the entity where the effector is attached or on all *children* or all *members* (if it is a group) by configuring `executionTarget`.

There are a number of additional configuration keys available for the `SshCommandEffector`:

| Configuration Key                 | Default | Description                                                                          |
|-----------------------------------|---------|--------------------------------------------------------------------------------------|
| command                           |         | command to be executed on the execution target                                       |
| executionDir                      |         | possible values: 'GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'TRACE' |
| shellEnv                          |         | custom shell environment where the command is executed                               |
| executionTarget                   | ENTITY  | possible values: 'MEMBERS', 'CHILDREN'                                               |

Here is a simple example of an `SshCommandEffector` definition:

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

See [`here`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/ssh/SshCommandEffector.html) for more details.

### ContainerEffector

This defines an effector to invoke a command or (a list of commands) on a container node accessible via `kubectl`.
This that the `kubectl` CLI is available on the host where Apache Brooklyn is running
and configured to access the desired Kubernetes cluster and the associated images.
Supported Kubernetes environments to run containers include EKS, GKE, AKS, and (locally) Minikube and Docker Desktop.

This effector is defined in the blueprint to be added to the entity using Apache Brooklyn initializers.

It enables execution of a `command` in a specific container managed by a Kubernetes cluster. _Under the covers_ the commands and other configurations are used to generate a Kubernetes job that will execute in its own namespace. Regardless of the job execution result (success or failure) the namespace is deleted at the end, unless configured otherwise. 

There are a number of configuration keys available for the `ContainerEffector`:

| Configuration Key     | Default | Description                                                                                                                                                                                                                           |
|-----------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| image                 |         | Docker image name, the container will be created from. (mandatory)                                                                                                                                                                    |
| imagePullPolicy       | `Always` | Possible values: `IfNotPresent`, `Always`, `Never`. Same values from the Kubernetes official documentation, the only advantage is that Apache Brooklyn is case insensitive. So, for example 'NEVER` and `never` are accepted as well. |
| jobIdentifier         |         | An identifier to use to identify the jobs and containers in Kubernetes, with salt added (defaults to Brooklyn entity ID)                                                                                                              |
| keepContainerForDebug | `false` | When set to true, the namespace" and associated resources and services are not destroyed after execution, thus allowing access to the container for in-dept debugging.                                                                |
| bashScript            |         | A bash script to run (convenience for command `bash` `-c` and args as supplied here; a list, multiline string, or single line string are all accepted                                                                                 |
| command               |         | The command (and args) to execute on the container.                                                                                                                                                                                   |
| args                  |         | If the container is declared with an `ENTRYPOINT`, you might want to provide only arguments for the default command configured by the container.                                                                                      |
| timeout               | `5m`    | How much should Kubernetes wait before considering a job to be failed and mark the container as failed as well. Defaults to 5m.                                                                                                       |
| workingDir            |         | The directory where the commands should be executed, can be a directory in the container or on a volume attached to it.                                                                                                               |
| volumeMounts          |         | Configuration to mount a volume into a container.(Same syntax as Kubernetes.)                                                                                                                                                         |
| volumes               |         | List of directories with data that is accessible across multiple containers. These directories must exists and be configured in the Kubernetes cluster.                                                                               |

Environment variables using the `shell.env`  Apache Brooklyn property are passed on to the container. 

The following example shows a sample blueprint of configuring the `ContainerEffector` for a simple `BasicStartable` entity with a list of simple commands being run on a container based on the [Perl](https://hub.docker.com/_/perl) image. Notice the last `echo $hello` command in the list; this prints the value of the `hello` environment variable configured using `shell.env` Apache Brooklyn configuration key.

{% highlight yaml %}

name: container-effector
services:
- type: 'org.apache.brooklyn.entity.stock.BasicStartable:1.1.0-SNAPSHOT'
  brooklyn.initializers:
    - type: org.apache.brooklyn.tasks.kubectl.ContainerEffector
      brooklyn.config:
        name: container-effector
        description: Very simple container effector
        shell.env:
          hello: world-amp
        image: perl
        imagePullPolicy: IfNotPresent
        bashScript: >
          HELLO=$(ls -la)
          echo $HELLO
          date
          echo $hello

  brooklyn.initializers:
    - type: org.apache.brooklyn.tasks.kubectl.ContainerEffector
      brooklyn.config:
        name: run-spark-job
        image: my-spark-container

{% endhighlight %}

The following example shows a sample blueprint of configuring the `ContainerEffector` for a simple `BasicStartable` entity with a simple command passes as arguments to the [Perl](https://hub.docker.com/_/perl) image.

{% highlight yaml %}

name: container-effector
services:
- type: 'org.apache.brooklyn.entity.stock.BasicStartable:1.1.0-SNAPSHOT'
  brooklyn.initializers:
    - type: org.apache.brooklyn.tasks.kubectl.ContainerEffector
      brooklyn.config:
        name: container-effector
        description: Very simple container effector
        shell.env:
           hello: world-amp
        image: perl
        imagePullPolicy: IfNotPresent
        args:
          - echo
          - hello

{% endhighlight %}

**Note:**  Not all Kubernetes configuration properties are supported at the moment. 

**Note:** Job template properties `completions`, `parallelism` and `backoffLimit` have been enforced to 1 in an attempt to prevent Kubernetes to attempt more than one job run. In case of failure, by default, Kubernetes tries to run the same job 6 times, thus creating six pods.

**Note:** For trying this effector locally, we recommend using downloading [Minikube](https://minikube.sigs.k8s.io)  or install it on your local using package manager.

**Note:** If you want to use your own image you can try customizing an existing one. We recommend you keep the image small to keep things quick. For example, the image described by the following Docker file is only 73MB in size(based on the minimal [Alpine](https://hub.docker.com/_/alpine)) and can be used to execute terraform commands.

{% highlight yaml %}

FROM alpine:latest

RUN apk update && apk add --no-cache wget terraform unzip

CMD ["/bin/sh"]

{% endhighlight %}

The same Apache Brooklyn configuration can be used to declare a `ContainerSensor` for an entity, as shown in the following blueprint. The smaller image is very suitable for a container sensor, since sensors are evaluated periodically.

{% highlight yaml %}

name: entity-with-container-sensor
services:
- type: 'org.apache.brooklyn.entity.stock.BasicStartable:1.1.0-SNAPSHOT'
  brooklyn.initializers:
    - type: org.apache.brooklyn.tasks.kubectl.ContainerSensor
      brooklyn.config:
        image: perl
        imagePullPolicy: never
        args:
          - echo
          - hello
        name: test-sensor
        period: 20s

{% endhighlight %}

### HttpCommandEffector

An `Effector` to invoke HTTP endpoints.

It allows the user to specify the URI, the HTTP verb, credentials for authentication and HTTP headers.

There are a number of additional configuration keys available for the `HttpCommandEffector`:

| Configuration Key                 | Default          | Description                                                                                                   |
|-----------------------------------|------------------|---------------------------------------------------------------------------------------------------------------|
| uri                               |                  | URI of the endpoint                                                                                           |
| httpVerb                          |                  | possible values: 'GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'TRACE'                          |
| httpUsername                      |                  | user name for the authentication                                                                              |
| httpPassword                      |                  | password for the authentication                                                                               |
| headers                           | application/json | It explicitly supports `application/x-www-form-urlencoded`                                                    |
| httpPayload                       |                  | The body of the HTTP request                                                                                  |
| jsonPath                          |                  | A jsonPath expression to extract values from a JSON object                                                    |
| jsonPathAndSensors                |                  | A map where keys are jsonPath expressions and values the name of the sensor where to publish extracted values |

When the header `HttpHeaders.CONTENT_TYPE` is equals to *application/x-www-form-urlencoded* and the `httpPayload` is a `map`, the payload is transformed into a single string using `URLEncoded`.

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

See [`here`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/effector/http/HttpCommandEffector.html) for more details.

### AddChildrenEffector

An `Effector` to add a child blueprint to an entity.

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

and supply an `EffectorBody` similar to:

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

The following recommendations should be considered when designing effectors:

#### Effectors should be small and composable

One effector which executes a command and emits a sensor, and a second effector which uses the previous sensor, if defined, to execute another operation.

