---
title: Custom Entities
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---
# {{ page.title }}

So far we've covered how to configure and compose entities.
There's a large library of blueprints available, but
there are also times when you'll want to write your own.

For complex use cases, you can write JVM, but for many common situations,
some of the highly-configurable blueprints make it easy to write in YAML,
including `bash` and Chef.
 

### Vanilla Software using `bash`

The following blueprint shows how a simple script can be embedded in the YAML
(the `|` character is special YAML which makes it easier to insert multi-line text):

!CODEFILE "example_yaml/vanilla-bash-netcat.yaml"

This starts a simple `nc` listener on port 4321 which will respond `hello` to the first
session which connects to it. Test it by running `telnet localhost 4321`
or opening `http://localhost:4321` in a browser.

Note that it only allows you connect once, and after that it fails.
This is deliberate! We'll repair this later in this example.
Until then however, in the *Applications* view you can click the server,
go to the `Effectors` tab, and click `restart` to bring if back to life.  

This is just a simple script, but it shows how any script can be easily embedded here,
including a script to download and run other artifacts.
Many artifacts are already packaged such that they can be downloaded and launched 
with a simple script, and `VanillaSoftwareProcess` can also be used for them. 


#### Downloading Files

We can specify a `download.url` which downloads an artifact 
(and automatically unpacking TAR, TGZ, and ZIP archives)
before running `launch.command` relative to where that file is installed (or unpacked),
with the default `launch.command` being `./start.sh`.

So if we create a file `/tmp/netcat-server.tgz` containing just `start.sh` in the root
which contains the line `echo hello | nc -l 4321`, 
we can instead write our example as: 

!CODEFILE "example_yaml/vanilla-bash-netcat-file.yaml"


#### Determining Successful Launch

The default method used to determine a successful launch of `VanillaSoftwareProcess` is to run a 
command over ssh to do a health check. The health check is done post-launch (repeating until it 
succeeds, before then reporting that the entity has started).

The default command used to carry out this health check will determine if the pid, written to 
`$PID_FILE` is running. This is why we included in the entity's launch script the line 
`echo $! > $PID_FILE`.

You'll observe this if you connect to one of the netcat services (e.g. via `telnet localhost 4321`):
the `nc` process exits afterwards, causing Brooklyn to set the entity to an `ON_FIRE` state.
(You can also test this with a `killall nc`).

There are other options for determining health: you can set `checkRunning.command` and `stop.command` instead,
as documented on the javadoc and config keys of the
[org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/entity/software/base/VanillaSoftwareProcess.html)
class, and those scripts will be used instead of checking and stopping the process whose PID is in `$PID_FILE`. For example:

!CODEFILE "example_yaml/vanilla-bash-netcat-more-commands.yaml"

#### Periodic Health Check

After start-up is complete, the health check described above is also run periodically, defaulting 
to every 5 seconds (configured with the config key `softwareProcess.serviceProcessIsRunningPollPeriod`).

This ssh-based polling can be turned off by configuring `sshMonitoring.enabled: false`. However, if 
no alternative health-check is defined then failure of the process would never be detected by Brooklyn.

See [Health Check Sensors](#health-check-sensors) for alternative ways of detecting failures.


#### Port Inferencing

If you're deploying to a cloud machine, a firewall might block the port 4321.
We can tell Brooklyn to open this port explicitly by specifying `inboundPorts: [ 4321 ]`;
however a more idiomatic way is to specify a config ending with `.port`,
such as:

!CODEFILE "example_yaml/vanilla-bash-netcat-port.yaml"

The regex for ports to be opened can be configured using
the config `inboundPorts.configRegex` (which has `.*\.port` as the default value).

Config keys of type `org.apache.brooklyn.api.location.PortRange` (aka `port`)
have special behaviour: when configuring, you can use range notation `8000-8100` or `8000+` to tell Brooklyn
to find **one** port matching; this is useful when ports might be in use.
In addition, any such config key will be opened, 
irrespective of whether it matches the `inboundPorts.configRegex`. 
To prevent any inferencing of ports to open, you can set the config `inboundPorts.autoInfer` to `false`.

Furthermore, the port inferencing capability takes in account static `ConfigKey` fields that
are defined on any Entity sub-class. So, `ConfigKey` fields that are based on `PortRanges` type will
be also included as required open ports.

Note that in the example above, `netcat.port` must be specified in a `brooklyn.config` block.
This block can be used to hold any config (including for example the `launch.command`),
but for convenience Brooklyn allows config keys declared on the underlying type
to be specified up one level, alongside the type.
However config keys which are *not* declared on the type *must* be declared in the `brooklyn.config` block. 


### Passing custom variables

Blueprint scripts can be parametrised through environment variables, making them reusable in different use-cases.
Define the variables in the `env` block and then reference them using the standard bash notation:

!CODEFILE "example_yaml/vanilla-bash-netcat-env.yaml"

Non-string objects in the `env` map will be serialized to JSON before passing them to the script.


#### Declaring New Config Keys

We can define config keys to be presented to the user 
using the `brooklyn.parameters` block:

!CODEFILE "example_yaml/vanilla-bash-netcat-port-parameter.yaml"

The example above will allow a user to specify a message to send back
and the port where netcat will listen.
The metadata on these parameters is available at runtime in the UI
and through the API, and is used when populating a catalog.

The example also shows how these values can be passed as environment variables to the launch command.
The `$brooklyn:config(...)` function returns the config value supplied or default.
For the type `port`, an attribute sensor is also created to report the *actual* port used after port inference,
and so the `$brooklyn:attributeWhenReady(...)` function is used.
(If `$brooklyn:config("netcat.port")` had been used, `4321+` would be passed as `NETCAT_PORT`.)

This gives us quite a bit more power in writing our blueprint:

* Multiple instances of the server can be launched simultaneously on the same host, 
  as the `4321+` syntax enables Brooklyn to assign them different ports
* If this type is added to the catalog, a user can configure the message and the port;
  we'll show this in the next section


### Using the Catalog and Clustering

The *Catalog* tab allows you to add blueprints which you can refer to in other blueprints.
In that tab, click *+* then *YAML*, and enter the following:

!CODEFILE "example_yaml/vanilla-bash-netcat-catalog.bom"

This is the same example as in the previous section, wrapped according to the catalog YAML requirements,
with one new block added defining an enricher. An enricher creates a new sensor from other values;
in this case it will create a `main.uri` sensor by populating a `printf`-style string `"http://%s:%s"`
with the sensor values.

With this added to the catalog, we can reference the type `netcat-example` when we deploy an application.
Return to the *Home* or *Applications* tab, click *+*, and submit this YAML blueprint:

!CODEFILE "example_yaml/vanilla-bash-netcat-reference.yaml"

This extends the previous blueprint which we registered in the catalog,
meaning that we don't need to include it each time.
Here, we've elected to supply our own message, but we'll use the default port.
More importantly, we can package it for others to consume -- or take items others have built.

We can go further and use this to deploy a cluster,
this time giving a custom port as well as a custom message: 

!CODEFILE "example_yaml/vanilla-bash-netcat-cluster.yaml"

In either of the above examples, if you explore the tree in the *Applications* view
and look at the *Summary* tab of any of the server instances, you'll now see the URL where netcat is running.
But remember, netcat will stop after one run, so you'll only be able to use each link once
before you have to restart it.  You can also run `restart` on the cluster,
and if you haven't yet experimented with `resize` on the cluster you might want to do that.


### Attaching Policies

Besides detecting this failure, Brooklyn policies can be added to the YAML to take appropriate 
action. A simple recovery here might just to automatically restart the process:

!CODEFILE "example_yaml/vanilla-bash-netcat-restarter.yaml"

Autonomic management in Brooklyn often follows the principle that complex behaviours emerge
from composing simple policies.
The blueprint above uses one policy to triggering a failure sensor when the service is down,
and another responds to such failures by restarting the service.
This makes it easy to configure various aspects, such as to delay to see if the service itself recovers
(which here we've set to 15 seconds) or to bail out on multiple failures within a time window (which again we are not doing).
Running with this blueprint, you'll see that the service shows as on fire for 15s after a `telnet localhost 4321`,
before the policy restarts it. 


### Sensors and Effectors

#### Effectors

For an even more interesting way to test it, look at the blueprint defining
[a netcat server and client](example_yaml/vanilla-bash-netcat-w-client.yaml).
This uses `brooklyn.initializers` to define an effector to `sayHiNetcat` on the `Simple Pinger` client,
using `env` variables to inject the `netcat-server` location and 
`parameters` to pass in per-effector data:

      env:
        TARGET_HOSTNAME: $brooklyn:entity("netcat-server").attributeWhenReady("host.name")
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


#### Sensors

This blueprint also uses initializers to define sensors on the `netcat-server` entity
so that the `$message` we passed above gets logged and reported back:

      launch.command: |
        echo hello | nc -l 4321 >> server-input &
        echo $! > $PID_FILE
      brooklyn.initializers:
      - type: org.apache.brooklyn.core.sensor.ssh.SshCommandSensor
        brooklyn.config:
          name: output.last
          period: 1s
          command: tail -1 server-input


#### Windows Command Sensor

Like the blueprint above, the following example also uses `brooklyn.initializers` to define sensors on the entity,
this time however it is a windows VM and uses `WinRmCommandSensor`.

    - type: org.apache.brooklyn.entity.software.base.VanillaWindowsProcess
      brooklyn.config:
        launch.command: echo launching
        checkRunning.command: echo running
      brooklyn.initializers:
      - type: org.apache.brooklyn.core.sensor.windows.WinRmCommandSensor
        brooklyn.config:
          name: ip.config
          period: 60s
          command: hostname


#### Health Check Sensors

As mentioned [previously](#periodic-health-check), the default health check is to execute the check-running
command over ssh every 5 seconds. This can be very CPU intensive when there are many entities. An alternative
is to disable the ssh-polling (by setting `sshMonitoring.enabled: false`) and to configure a different 
health-check.

See documentation on the [Entity's error status]({{ book.path.guide }}/ops/troubleshooting/overview.html#entitys-error-status)
for how Brooklyn models an entity's health.

In the snippet below, we'll define a new health-check sensor (via http polling), and will automatically add this
to the `service.notUp.indicators`. If that map is non-empty, then the entity's `service.isUp` will be set
automatically to `false`:

    services:
    - type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
      brooklyn.config:
        launch.command: |
          ...
        checkRunning.command: true
        sshMonitoring.enabled: false

      brooklyn.initializers:
        - type: org.apache.brooklyn.core.sensor.http.HttpRequestSensor
          brooklyn.config:
            name: http.healthy
            period: 5s
            suppressDuplicates: true
            jsonPath: "$"
            uri:
              $brooklyn:formatString:
              - "http://%s:8080/healthy"
              - $brooklyn:attributeWhenReady("host.name")

      brooklyn.enrichers:
        - type: org.apache.brooklyn.enricher.stock.UpdatingMap
          brooklyn.config:
            enricher.sourceSensor: $brooklyn:sensor("http.healthy")
            enricher.targetSensor: $brooklyn:sensor("service.notUp.indicators")
            enricher.updatingMap.computing:
              $brooklyn:object:
                type: "com.google.guava:com.google.common.base.Functions"
                factoryMethod.name: "forMap"
                factoryMethod.args:
                  - true: null
                    false: "false"
                  - "no value"

The `HttpRequestSensor` configures the entity to poll every 5 seconds on the given URI,
taking the json result as the sensor value.

The `UpdatingMap` enricher uses that sensor to populate an entry in the `service.notUp.indicators`.
It transforms the `http.healthy` sensor value using the given function: if the http poll returned
`true`, then it is mapped to `null` (so is removed from the `service.noUp.indicators`); if the
poll returned `false`, then `"false"` is added to the indicators map; otherwise `"no value"` is
added to the indicators map.
 

#### Summary

These examples do relatively simple things, but they
illustrate many of the building blocks used in real-world blueprints,
and how they can often be easily described and combined in Brooklyn YAML blueprints.
