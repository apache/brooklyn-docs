---
section: Specialized Locations
section_position: 13
section_type: inline
---

### Specialized Locations

Some additional location types are supported for specialized situations:

#### Single Host

The spec `host`, taking a string argument (the address) or a map (`host`, `user`, `password`, etc.),
provides a convenient syntax when specifying a single host.
For example:

{% read snippets/_location-special-single.camp.md %}

Or, in `brooklyn.properties`, set `brooklyn.location.named.host1=host:(192.168.0.1)`.


#### The Multi Location

The spec `multi` allows multiple locations, specified as `targets`,
to be combined and treated as one location.

##### Sequential Consumption

In its simplest form, this will use the first target location where possible,
and will then switch to the second and subsequent locations when there are no
machines available.

In the example below, it provisions the first node to `192.168.0.1`, then it provisions into AWS
us-east-1 region (because the bring-your-own-nodes region will have run out of nodes).

{% read snippets/_location-special-sequential.camp.md %}

##### Round-Robin Consumption and Availability Zones for Clustered Applications

A `DynamicCluster` can be configured to cycle through its deployment targets round-robin when
provided with a location that supports the `AvailabilityZoneExtension` -- the `multi` location
supports this extension.

The configuration option `dynamiccluster.zone.enable` on `DynamicCluster` tells it to query the
given location for `AvailabilityZoneExtension` support. If the location supports it, then the
cluster will query for the list of availability zones (which in this case is simply the list of
targets) and deploy to them round-robin.

In the example below, the cluster will request VMs round-robin across three different
locations (in this case, the locations were already added to the catalog, or defined in
`brooklyn.properties`).

{% read snippets/_location-special-round.camp.md %}

Of course, clusters can also be deployed round-robin to real availability zones offered by
cloud providers, as long as their locations support `AvailabilityZoneExtension`. Currently, only
AWS EC2 locations support this feature.

In the example below, the cluster will request VMs round-robin across the availability zones
provided by AWS EC2 in the "us-east-1" region.

{% read snippets/_location-special-availability.camp.md %}

For more information about AWS EC2 availability zones, see
[this guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html).

Custom alternatives to round-robin are also possible using the configuration option
`dynamiccluster.zone.placementStrategy` on `DynamicCluster`.


#### The Server Pool

The {% include java_link.html class_name="ServerPool" package_path="org/apache/brooklyn/entity/machine/pool" project_subpath="software/base" %}
entity type allows defining an entity which becomes available as a location.

