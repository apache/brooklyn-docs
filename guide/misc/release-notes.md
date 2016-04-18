---
layout: website-normal
title: Release Notes
---

## Version {{ site.brooklyn-version }}

{% if SNAPSHOT %}
**You are viewing a SNAPSHOT release (master branch), so this list is in progress!**
{% endif %}

Thanks go to our community for their improvements, feedback and guidance, and
to Brooklyn's commercial users for funding much of this development.

### New Features

1. Brooklyn has now graduated to an Apache top-level project - this is our first release without the "incubating"
   designation.
1. A new YAML editor that supports syntax highlighting and other conveniences for editing blueprints.
1. The `br` command line tool allows Brooklyn to be controlled from a shell and to be scripted. You no longer need to
   use the web UI or REST API to control Brooklyn.
1. Parameters (config keys) can now be defined in YAML, using `brooklyn.parameters`. This allows YAML entities to
   advertise how they should be parameterized, for use in the UI and in documentation tools, and do coercion on these
   values. For a good demonstration, see the "Custom Entities" section of the YAML chapter of the user guide.
1. New locations can be added to the catalog with an easy-to-use wizard. 
1. `$brooklyn:external(...)` extension for taking values from other sources is supported in more places.
1. OSGi-native mode using Karaf, to simplify packaging of blueprints.
1. A new pure-java WinRM client (winrm4j). This eliminates a number of large dependencies, reducing the size of Brooklyn.
1. jclouds and several other dependencies updated to newer versions.
1. Performance and reliability improvements.
1. Our source code repository is now split into modules covering broad areas of functionality. Combined with some
   cleanup, this significantly reduces the size of data that needs to be downloaded when cloning the repository.

### Backwards Compatibility

Changes since 0.8.0-incubating:

1. **Major:** The classes HttpTool and HttpToolResponse in brooklyn-core (package org.apache.brooklyn.util.core.http)
have been moved to brooklyn-utils-common, in package org.apache.brooklyn.util.
Classes such as HttpFeed that previously returned org.apache.brooklyn.util.core.http.HttpToolResponse in some methods now 
return org.apache.brooklyn.util.HttpToolResponse.

2. **Major:** Locations set in YAML or on a spec are no longer passed to `child.start(...)` by `AbstractApplication`;
this has no effect in most cases as `SoftwareProcess.start` looks at local and inherited locations, but in ambiguous cases
it means that locally defined locations are now preferred. Other classes of entities may need to do similar behaviour,
and it means that calls to `Entity.getLocations()` in some cases will not show parent locations,
unless discovered and set locally e.g. `start()`. The new method `Entities.getAllInheritedLocations(Entity)`
can be used to traverse the hierarchy.  It also means that when a type in the registry (catalog) includes a location,
and a caller references it, that location will now take priority over a location defined in a parent.
Additionally, any locations specified in YAML extending the registered type will now *replace* locations on the referenced type;
this means in many cases an explicit `locations: []` when extending a type will cause locations to be taken from the
parent or application root in YAML. Related to this, tags from referencing specs now preceed tags in the referenced types,
and the referencing catalog item ID also takes priority; this has no effect in most cases, but if you have a chain of
referenced types blueprint plan source code and the catalog item ID are now set correctly. 

3. Task cancellation is now propagated to dependent submitted tasks, including backgrounded tasks if they are transient.
Previously when a task was cancelled the API did not guarantee semantics but the behaviour was to cancel sub-tasks only 
in very limited cases. Now the semantics are more precise and controllable, and more sub-tasks are cancelled.
This can prevent some leaked waits on `attributeWhenReady`.

4. The name of the sensor `VanillaWindowsProcess.WINRM_PORT` has been changed from `winrmPort` to `winrm.port`.
<br>
During the development some wrong named sensors appeared for WINRM_PORT. They are still there for backwards compatibility but they are deprecated.
<br>
If you are referencing this sensor in blueprint DSL or somewhere else please use the key `winrm.port`.

5. The name of the sensor `VanillaWindowsProcess.RDP_PORT` has been changed from `rdpPort` to `rdp.port`.
<br>
If you are referencing this sensor in blueprint DSL or somewhere else please use the key `rdp.port`.

6. Location resolvers now generate `LocationSpec` instances instead of `Location` instances.
This makes it clearer when locations become managed and prevents a memory leak which can
happen when some locations are never unmanaged. All implementations of `LocationResolver`
need to be updated to conform to the new interface.   
   
7. The named location `localhost` is no longer automatically added by default on a fresh Brooklyn install.
Instead UI users are directed to a location wizard where they can configure their targets, including localhost. 
If you require `localhost` to be available on boot, define it as a named location in `brooklyn.properties`
or the default catalog. (The property `brooklyn.location.name.localhost=localhost` is usually sufficient.)

For changes in prior versions, please refer to the release notes for 
[0.8.0](/v/0.8.0-incubating/misc/release-notes.html).
