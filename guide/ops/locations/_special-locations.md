---
section: Specialized Locations
section_position: 11
section_type: inline
---

### Specialized Locations

Some additional location types are supported for specialized situations:

#### Single Host

The spec `host`, taking a string argument (the address) or a map (`host`, `user`, `password`, etc.),
provides a convenient syntax when specifying a single host.
For example:

{% highlight yaml %}
location: host:(192.168.0.1)
services:
- type: org.apache.brooklyn.entity.webapp.jboss.JBoss7Server 
{% endhighlight %}

Or, in `brooklyn.properties`, set `brooklyn.location.named.host1=host:(192.168.0.1)`.


#### The Multi Location

The spec `multi` allows multiple locations, specified as `targets`,
to be combined and treated as one location.

In its simplest form, this will use the first target location where possible,
and will then switch to the second and subsequent locations when there are no
machine available.

In the example below, it provisions the first node to `192.168.0.1`, then it provisions into AWS 
us-east-1 region (because the bring-your-own-nodes region will have run out of nodes).

{% highlight yaml %}
location:
  multi:
    targets:
    - byon:(hosts=192.168.0.1)
    - jclouds:aws-ec2:us-east-1
services:
- type: org.apache.brooklyn.entity.group.DynamicCluster
  brooklyn.config:
    initialSize: 3
    memberSpec:
      $brooklyn:entitySpec:
        type: org.apache.brooklyn.entity.machine.MachineEntity
{% endhighlight %}

The `multi` location also supports the "availability zone" location extension: it presents each  
target location as an "availability zone". This means that a cluster can be configured to
round-robin across the targets.

For example, in the blueprint below the cluster will request VMs round-robin across the three zones
(where `zone1` etc are locations already added to the catalog, or defined in brooklyn.properties).
The configuration option `dynamiccluster.zone.enable` on `DynamicCluster` tells it to query the 
given location for the `AvailabilityZoneExtension`. If available, it will query for the list of  
zones (in this case the list of targets), and then use them round-robin. Custom alternatives to 
round-robin are also possible using the configuration option `dynamiccluster.zone.placementStrategy`
on `DynamicCluster`.

{% highlight yaml %}
location:
  multi:
    targets:
    - zone1
    - zone2
    - zone3
services:
- type: org.apache.brooklyn.entity.group.DynamicCluster
  brooklyn.config:
    dynamiccluster.zone.enable: true
    initialSize: 4
    memberSpec:
      $brooklyn:entitySpec:
        type: org.apache.brooklyn.entity.machine.MachineEntity
{% endhighlight %}


#### The Server Pool

The {% include java_link.html class_name="ServerPool" package_path="org/apache/brooklyn/entity/machine/pool" project_subpath="software/base" %}
entity type allows defining an entity which becomes available as a location.

