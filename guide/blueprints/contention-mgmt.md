---
title: Contention Management
layout: website-normal
---

## Overview

Contention management has three components:

* A **Contention Management Service** (`contention-management-service` in `ContentionManagerEntity`):
  This tracks what resources are consumed, with what priority, and handles requests for additional resources
  by triggering entities with the Contention-Managed Entity Policy attached to freeze
  
* A **Contention-Managed Location** (`contention-managed-location` in `ContentionManagedMachineProvisioningLocation`):
  This location wraps a cloud and invokes the Contention Management Service to track usage
  and to request capacity be freed up when needed;
  entities which can be frozen must be deployed here, _and_ 
  entities which should be able to request capacity must be deployed here
  
* A **Contention-Managed Entity Policy** (`contention-management-policy` in `ContentionManagedEntityPolicy`):
  This policy should be attached to entities which can be frozen when required
  to make capacity for higher-priority deployments
  (note these entities should also be deployed to the corresponding Contention-Managed Location);
  this policy does _not_ need to be attached to entities which should be able to request capacity

## Example

Wrap your location into a `contention-managed-location` and deploy it using the Blueprint Importer or the `br` CLI:

```
brooklyn.catalog:
  id: 'contended-location'
  name: 'contended-location'
  itemType: location
  item:
    type: contention-managed-location
    brooklyn.config:
      target: [locationID[aws or byon]]
```

Or:

```
brooklyn.catalog:
  version: 0.3.0-snapshot
  items:
  - id: amazon-with-quota
    itemType: location
    item:
      type: contention-managed-location
      brooklyn.config:
        target: amazon-eu-west-1-fast-ubuntu
```

Then deploy the Contention Management Service:

```
name: Capacity Management
services:
  - type: contention-management-service
    brooklyn.config:
      vms.max: 1
```

Note we've specified an explicit maximum (more on this below).
This means only one VM can be made available.

Now deploy a low-priority app, with a Contention-Managed Entity Policy attached,
and deployed to the Contention-Managed Location.
The location of course can be inherited.
The policy can be attached to the root (application) or the entity,
but note if attached to the root the default "freeze" behavior will stop the app,
causing it to be removed (unless configured otherwise).
We attach it to the entity so the entity stops but not the application.
(There are no quorum policies set on the application here so it will remain healthy
even if the entity is stopped/frozen.) 


```
name: LOW
location:
  contention-managed-location:
    target: localhost  # or other location spec string
services:
  - type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
    brooklyn.config:
      launch.command: echo launching
      checkRunning.command: true
    brooklyn.policies:
      - type: contention-management-policy
        brooklyn.config:
          contention.manager.priority: 10
```

This is using the VM. A record of it can be observed in the sensors on the
`contention-management-service` entity's sensors.

If we deploy a higher-priority system, that will trigger the above VM to freeze
and allocate the VM to this item. 
Note the _same_ `contention-managed-location` spec is used.
Also note here there is no policy, but the priority is set on the application (inherited) --
this means this app won't be freezable (the policy does that),
but by using the location it will be able to trigger freezes.
It will also work if you use the format above with a higher priority.

```
name: HIGH
location:
  contention-managed-location:
    target: localhost  # or other location spec string
services:
  - type: org.apache.brooklyn.entity.software.base.VanillaSoftwareProcess
    brooklyn.config:
      launch.command: echo launching
      checkRunning.command: true
brooklyn.config:
  contention.manager.priority: 90
```

We can then stop the "HIGH" VanillaSoftwareProcess and see the "LOW" one unfreeze,
and restart it to freeze it again, etc.

## Details

### Multiple contexts

If you have a single contention-managed location and service,
they will be auto-detected and things will work fine.

If you want to do contention management in multiple environments,
the `contention-managed-location` _and_ the `contention-management-policy`
instances must be set with a reference to the appropriate `contention-management-service`
instance, e.g.:

```
  - type: contention-management-service
    id: contention-mgr1
    brooklyn.config:
      vms.max: 1
```

then on the locations _and_ policies:

```
    brooklyn.config:
      contention.manager.entity: $brooklyn:entity("contention-mgr") 
```


### Customized Behavior 
 
There are several config keys documented on the 3 types added by this bundle.
Consult the catalog for full information, but to draw attention to some of the main ones:

* On the `contention-management-policy`,
  the effectors to invoke can be set with `entity.freeze` and `entity.thaw`;
  these default to `stop` and `start`.
* On the `contention-managed-location`,
  `vms.max` can be used to specify a quota or artifical limit
  applied _in addition to_ any limit in the targeted location.
  If omitted, contention management will kick in when the targeted location
  reports it is out of capacity,
  so this is intended where stricter quotas are wanted (e.g. to prevent over-provisioning).

 
### Override

Note that if you manually start a frozen app, it goes into an "overridden" contention-management
status where the Contention Management Service will _not_ attempt to freeze it subsequently. 
 
 