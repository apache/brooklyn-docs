---
title: Upgrades
layout: website-normal
---

This section provides all necessary information to upgrade Apache Brooklyn for both the RPM/DEB and Tarball packages.

## Backwards Compatibility

Apache Brooklyn version 0.12.0 onward runs primarily inside a Karaf container. When upgrading from 0.11.0 or below,
this update changes the mechanisms for launching Brooklyn.
This will impact any custom scripting around the launching of Brooklyn, and the supplying of command line arguments.

Use of the `lib/dropins` and `lib/patch` folders will no longer work (because Karaf does not support that kind of classloading).
Instead, code must be built and installed as [OSGi bundles](https://en.wikipedia.org/wiki/OSGi#Bundles).


{% include_relative _server.md %}

{% include_relative _blueprints.md %}

{% include_relative _systems-under-mgmt.md %}

