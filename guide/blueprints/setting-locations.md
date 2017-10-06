---
title: Setting Locations
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

Brooklyn supports a very wide range of target locations. 
With deep integration to [Apache jclouds](https://jclouds.apache.org), most well-known clouds 
and cloud platforms are supported. See the [Locations guide]({{ book.path.guide }}/locations/) 
for details and more examples.

### Cloud Example

The following example is for Amazon EC2:

!CODEFILE "example_yaml/simple-appserver-with-location.yaml"

(You'll need to replace the `identity` and `credential` with the 
"Access Key ID" and "Secret Access Key" for your account,
as configured in the [AWS Console](https://console.aws.amazon.com/iam/home?#security_credential).)

Other popular public clouds include `softlayer`, `google-compute-engine`, and `rackspace-cloudservers-us`.
Private cloud systems including `openstack-nova` and `cloudstack` are also supported,
although for these you'll supply an `endpoint: https://9.9.9.9:9999/v2.0/` 
(or `client/api/` in the case of CloudStack) instead of the `region`.


### "Bring Your Own Nodes" (BYON) Example

You can also specify pre-existing servers to use -- "bring-your-own-nodes".
The example below shows a pool of machines that will be used by the entities within the 
application.

!CODEFILE "example_yaml/simple-appserver-with-location-byon.yaml"

### Single Line and Multi Line Locations

A simple location can be specified on a single line. Alternatively, it can be split to have one
configuration option per line (recommended for all but the simplest locations).

For example, the two examples below are equivalent:

```yaml
location: byon(name="my loc",hosts="1.2.3.4",user="bob",privateKeyFile="~/.ssh/bob_id_rsa")
```

```yaml
location:
  byon:
    name: "my loc"
    hosts:
    - "1.2.3.4"
    user: "bob"
    privateKeyFile: "~/.ssh/bob_id_rsa"
```


### Specific Locations for Specific Entities

One can define specific locations on specific entities within the blueprint (instead of, or as 
well as, defining the location at the top-level of the blueprint).

The example below will deploy Tomcat and JBoss App Server to different Bring Your Own Nodes
locations:

!CODEFILE "example_yaml/simple-appserver-with-location-per-entity.yaml"

The rules for precedence when defining a location for an entity are:

* The location defined on that specific entity.
* If no location is defined, then the first ancestor that defines an explicit location.
* If still no location is defined, then the location defined at the top-level of the blueprint.

This means, for example, that if you define an explicit location on a cluster then it will be used 
for all members of that cluster.


### Multiple Locations

Some entities are written to expect a set of locations. For example, a `DynamicFabric` will
create a member entity in each location that it is given. To supply multiple locations, simply
use `locations` with a yaml list.

In the example below, it will create a cluster of app-servers in each location. One location is
used for each `DynamicCluster`; all app-servers inside that cluster will obtain a machine from
that given location.

!CODEFILE "example_yaml/fabric-with-multiple-locations.yaml"

The entity hierarchy at runtime will have a `DynamicFabric` with two children, each of type 
`DynamicCluster` (each running in different locations), each of which initially has three 
app-servers.
 
For brevity, this example excludes the credentials for aws-ec2. These could either be specificed
in-line or defined as named locations in the catalog (see below).


### Adding Locations to the Catalog

The examples above have given all the location details within the application blueprint.
It is also possible (and indeed preferred) to add the location definitions to the catalog
so that they can be referenced by name in any blueprint.

For more information see the [Operations: Catalog]({{ book.path.guide }}/blueprints/catalog/) section of 
the User Guide.


### Externalized Configuration

For simplicity, the examples above have included the cloud credentials. For a production system, 
it is strongly recommended to use [Externalized Configuration]({{ book.path.guide }}/ops/externalized-configuration.html)
to retrieve the credentials from a secure credentials store, such as [Vault](https://www.vaultproject.io).


### Use of provisioning.properties

An entity that represents a "software process" can use the configuration option 
`provisioning.properties` to augment the location's configuration. For more information, see
[Entity Configuration]({{ book.path.guide }}/blueprints/entity-configuration.html#entity-provisioningproperties-overriding-and-merging)
details.
