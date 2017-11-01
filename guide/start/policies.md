---
title: Getting Started - Policies
---

## A Clustered Example

We'll now look at a more complex example that better shows the capabilities of Brooklyn, including
management of a running clustered application.

Below is the annotated blueprint. [Download the blueprint](example_yaml/mycluster.yaml) into a 
text file, `mycluster.yaml`, in your workspace. *Before* you create an application with it, 
review and/or change the the location where the application will be deployed.

You will need four machines for this example: one for the load-balancer (nginx), and three for the 
Tomcat cluster (but you can reduce this by changing the `maxPoolSize` below).

{% if output.name == 'website' %}

{% tour %}

{% block title="Describe your application", description="Start by giving it a name, optionally adding a version and other metadata." %}
<span class="ann_highlight">name: Tomcat Cluster</span>

{% block title="Define the target location", description="Blueprints are designed for portability. Pick from dozens of clouds in hundreds of datacenters. Or machines with fixed IP addresses, localhost, Docker on [Clocker](http://clocker.io), etc." %}
<span class="ann_highlight">location:</span>
  byon:
    user: vagrant
    password: vagrant
    hosts:
      - 10.10.10.101
      - 10.10.10.102
      - 10.10.10.103
      - 10.10.10.104

{% block title="Define a cluster", description="Customize with config keys, such as the initial size. Define the members of the cluster." %}
services:
<span class="ann_highlight">- type: org.apache.brooklyn.entity.group.DynamicCluster</span>
  name: Cluster
  id: cluster
  brooklyn.config:
    cluster.initial.size: 1
    dynamiccluster.memberspec:
      $brooklyn:entitySpec:
        type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
        name: Tomcat Server
        brooklyn.config:
          wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-webapp/0.8.0-incubating/brooklyn-example-hello-world-webapp-0.8.0-incubating.war

{% block title="Tomcat auto-repair policy", description="For each member of the cluster, include an auto-repair policy that restarts the service. If it repeatedly fails, the service will be propagate a failure notification." %}
        brooklyn.policies:
<span class="ann_highlight">        - type: org.apache.brooklyn.policy.ha.ServiceRestarter</span>
          brooklyn.config:
            failOnRecurringFailuresInThisDuration: 5m
        brooklyn.enrichers:
<span class="ann_highlight">        - type: org.apache.brooklyn.policy.ha.ServiceFailureDetector</span>
          brooklyn.config:
            entityFailed.stabilizationDelay: 30s

{% block title="Cluster auto-replace policy", description="On the cluster, handle a member's failure by replacing it with a brand new member." %}
  brooklyn.policies:
<span class="ann_highlight">  - type: org.apache.brooklyn.policy.ha.ServiceReplacer</span>

{% block title="Auto-scaling policy", description="Auto-scale the cluster, based on runtime metrics of the cluster. For a simplistic demonstration, this uses requests per second." %}
<span class="ann_highlight">  - type: org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy</span>
    brooklyn.config:
      metric: webapp.reqs.perSec.perNode
      metricUpperBound: 3
      metricLowerBound: 1
      resizeUpStabilizationDelay: 2s
      resizeDownStabilizationDelay: 1m
      maxPoolSize: 3

{% block title="Aggregate the member's metrics", description="Add an enricher to aggregate the member's requests per second. For a simplistic demonstration, this uses requests per second." %}
<span class="ann_highlight">  - type: org.apache.brooklyn.enricher.stock.Aggregator</span>
    brooklyn.config:
      enricher.sourceSensor: $brooklyn:sensor("webapp.reqs.perSec.windowed")
      enricher.targetSensor: $brooklyn:sensor("webapp.reqs.perSec.perNode")
      enricher.aggregating.fromMembers: true
      transformation: average

{% block title="Define a load-balancer", description="Add a load balancer entity. Configure it to monitor and balance across the cluster of Tomcat servers, which was given: id: cluster" %}
<span class="ann_highlight">- type: org.apache.brooklyn.entity.proxy.nginx.NginxController</span>
  name: Load Balancer (nginx)
  brooklyn.config:
    loadbalancer.serverpool: $brooklyn:entity("cluster")
    nginx.sticky: false

{% endtour %}

{% else %}

```yaml
name: Tomcat Cluster

location:
  byon:
    user: vagrant
    password: vagrant
    hosts:
      - 10.10.10.101
      - 10.10.10.102
      - 10.10.10.103
      - 10.10.10.104
 
services:
- type: org.apache.brooklyn.entity.group.DynamicCluster
  name: Cluster
  id: cluster
  brooklyn.config:
    cluster.initial.size: 1
    dynamiccluster.memberspec:
      $brooklyn:entitySpec:
        type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
        name: Tomcat Server
        brooklyn.config:
          wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-webapp/0.8.0-incubating/brooklyn-example-hello-world-webapp-0.8.0-incubating.war
 
        brooklyn.policies:
        - type: org.apache.brooklyn.policy.ha.ServiceRestarter
          brooklyn.config:
            failOnRecurringFailuresInThisDuration: 5m
        brooklyn.enrichers:
        - type: org.apache.brooklyn.policy.ha.ServiceFailureDetector
          brooklyn.config:
            entityFailed.stabilizationDelay: 30s
 
  brooklyn.policies:
  - type: org.apache.brooklyn.policy.ha.ServiceReplacer
 
  - type: org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy
    brooklyn.config:
      metric: webapp.reqs.perSec.perNode
      metricUpperBound: 3
      metricLowerBound: 1
      resizeUpStabilizationDelay: 2s
      resizeDownStabilizationDelay: 1m
      maxPoolSize: 3

  brooklyn.enrichers:
  - type: org.apache.brooklyn.enricher.stock.Aggregator
    brooklyn.config:
      enricher.sourceSensor: $brooklyn:sensor("webapp.reqs.perSec.windowed")
      enricher.targetSensor: $brooklyn:sensor("webapp.reqs.perSec.perNode")
      enricher.aggregating.fromMembers: true
      transformation: average

- type: org.apache.brooklyn.entity.proxy.nginx.NginxController
  name: Load Balancer (nginx)
  brooklyn.config:
    loadbalancer.serverpool: $brooklyn:entity("cluster")
    nginx.sticky: false
```

{% endif %}

## The Tomcat Cluster

The `DynamicCluster` can dynamically increase or decrease the number of members. Resizing the 
cluster can either be carried out manually via effectors or automatically by attaching an 
`AutoScalerPolicy`.

It is configured with a `dynamiccluster.memberspec`, which defines the type and configurtion of members
in the cluster. In our example, each is a Tomcat server with a WAR deployed at the root URL.

Deploy the app:

```
$ br deploy mycluster.yaml
 Id:       nGY58ZZN   
 Name:     Tomcat Cluster   
 Status:   In progress   
```

And wait for the app to be running, viewing its state with:

```
$ br application
 Id         Name             Status    Location   
 nGY58ZZN   Tomcat Cluster   RUNNING   Mf0CJac6   
```

You can view the list of entities within the cluster with the command below (which drills into the 
application named "Tomcat Cluster", then into its child entity named "Cluster", and then lists its
entities):

```
$ br application "Tomcat Cluster" entity "Cluster" entity
 Id         Name            Type   
 dYfUvLIw   quarantine      org.apache.brooklyn.entity.group.QuarantineGroup   
 tOpMeYYr   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
```

The "quarantine" entity is used when Tomcat servers fail to start correctly - this entity is by 
default added to the quarantine group, where it can later be investigated. This can be disabled using
the configuration `dynamiccluster.quarantineFailedEntities: false`.


## Tomcat auto-repair

Each Tomcat entity has a `ServiceFailureDetector` enricher and a `ServiceRestarter` policy. 

An *enricher* generates new events or sensor values (metrics) for the entity by modifying or 
aggregating data from one or more other sensors. A *policy* coordinates the runtime management of 
entities by carrying out actions, initiated by specific triggers. Policies are often used to keep 
the system in a healthy state, such as handling failures and auto-scaling.

The built-in functionality of the Tomcat entity is to use the "service.state" sensor to report 
its status. It will be "on-fire" when a failure is detected, or "running" when healthy, or one of
the other lifecycle states such as "starting", "stopping" or "stopped". 

The `ServiceFailureDetector` enricher emits an "Entity Failed" event whenever a failure is detected, 
and similarly an "Entity Recovered" event when recovered. The configuration option 
`serviceOnFireStabilizationDelay` will suppress reporting of failure until the entity is detected 
as failed for the given duration. This is very useful so as not to over-react to temporary failures.

The `ServiceRestarter` policy attaches to an entity in order to restart the service on failure. If  
there are subsequent failures within a configurable time interval, or if the restart fails, the  
service entity is marked as failed and no futher restarts are attempted.

Try killing the Tomcat process for one of the members in the cluster. The command below will kill
Tomcat on the vagrant VMs named "byon1" to "byon4":

```bash
for i in byon{1..4}; do
  vagrant ssh ${i} --command 'ps aux | grep -i tomcat |  grep -v grep | awk '\''{print $2}'\'' | xargs kill -9'
done
```

You can view the state of the Tomcat server with the command below (which drills into the  
application named "Tomcat Cluster", then into its child entity named "Cluster", and then into the  
first member of the cluster named "Tomcat Server"):

```
$ br application "Tomcat Cluster" entity "Cluster" entity "Tomcat Server"
 Id:              tOpMeYYr   
 Name:            Tomcat Server   
 Status:          ON_FIRE   
 ServiceUp:       false   
 Type:            org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
 CatalogItemId:   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer:0.0.0.SNAPSHOT   
```

<!-- COMMENT:
You can view its activity, to see the call to restart, using:

```bash
br application "Tomcat Cluster" entity "Cluster" entity "Tomcat Server" activity
```

TODO Why doesn't the restart() show in the activity view?!
-->

After the given `stabilizationDelay`, the Tomcat server will be automatically restarted.


## Cluster auto-replace

The cluster has a `ServiceReplacer` policy. This attaches to a `DynamicCluster` and replaces a 
failed member; if this fails, it sets the Cluster state to on-fire.

To simulate a terminal failure of a member, repeatedly kill the process (using the command 
above).

The Tomcat server should be replaced by a new member of the cluster, and then the old failed member
removed.

You can view the list of Tomcat servers in the cluster with the command below (which drills into the  
application named "Tomcat Cluster", then into its child entity named "Cluster", and then lists the 
child entities):

```
$ br application "Tomcat Cluster" entity "Cluster" entity
 Id         Name            Type   
 dYfUvLIw   quarantine      org.apache.brooklyn.entity.group.QuarantineGroup   
 tOpMeYYr   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
 mgoRpkKH   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
```


## Auto-scaling

The `AutoScalerPolicy` attaches to a `Resizable` entity (in this case the `DynamicCluster`) and 
dynamically adjusts its size in response to keeping a metric within a given range. It adds/removes 
members (e.g. Tomcat instances) automatically.

In this example policy, the `metricUpperBound` for requests per second per server is configured 
very low at just 3. This makes it simple to trigger auto-scaling. The `resizeUpStabilizationDelay` 
of 2 seconds means the load must be sustained for at least that length of time. The  
`resizeDownStabilizationDelay` of 1 minute means there must be low load for a full one minute 
before it will scale back down.

Find the URL of the load-balancer - see the `NginxController` sensor named `main.uri`.

To generate load, you can use your web-browser by repeatedly refreshing that page. Alternatively,
you could use a load generator like jmeter, or use a script such as the one shown below 
(changing URL for the URL of your load-balancer):

```bash
URL=http://10.10.10.101:8000/
for i in {1..600}; do
  for j in {1..50}; do 
    curl --fail --silent ${URL} > /dev/null || echo "Curl failed with exit code $?"
  done
  echo "Finished batch $i"
  sleep 1
done
```

While those curl commands run in a separate terminal, you can look at the metrics for the first
Tomcat server using the command:

```
$ br application "Tomcat Cluster" entity "Cluster" entity "Tomcat Server" sensor
 Name                                            Description                                                                              Value   
 ...
 webapp.reqs.perSec.last                         Reqs/sec (last datapoint)                                                                0.9980039920159681
 webapp.reqs.perSec.windowed                     Reqs/sec (over time window)                                                              0.9326571333555038
 webapp.reqs.processingTime.fraction.last        Fraction of time spent processing, reported by webserver (percentage, last datapoint)    "0.067%"
 webapp.reqs.processingTime.fraction.windowed    Fraction of time spent processing, reported by webserver (percentage, over time window)  "0.073%"
 webapp.reqs.processingTime.max                  Max processing time for any single request, reported by webserver (millis)               ""
 webapp.reqs.processingTime.total                Total processing time, reported by webserver (millis)                                    "3.12s"
 webapp.reqs.total                               Request count                                                                            5575
 webapp.tomcat.connectorStatus                   Catalina connector state name                                                            "STARTED"
 webapp.url                                      URL                                                                                      "http://10.10.10.103:18082/"
 ...
```
 
You can look at the average requests per second on the cluster with the command:
 
```
$ br application "Tomcat Cluster" entity "Cluster" sensor "webapp.reqs.perSec.perNode"
 25.765557404326124
```

When this value exceeds 3 for two seconds, the cluster with scale up. You can see the new instance
using the command:

```
$ br application "Tomcat Cluster" entity "Cluster" entity
 Id         Name            Type   
 dYfUvLIw   quarantine      org.apache.brooklyn.entity.group.QuarantineGroup   
 mgoRpkKH   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
 xpLeJufy   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
 CpabLxZE   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
```

Cancel the curl commands (or wait for them to finish), and then wait for the one minute 
`resizeDownStabilizationDelay`. The cluster will scale back to the minimum one instance.

```
$ br application "Tomcat Cluster" entity "Cluster" entity
 Id         Name            Type   
 dYfUvLIw   quarantine      org.apache.brooklyn.entity.group.QuarantineGroup   
 mgoRpkKH   Tomcat Server   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
```
