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

1. In previous versions, the default behaviour was that the GO CLI would be built as part of the build. This behaviour could be disabled
   by adding `-Dno-go-client` to the build command, e.g. `mvn clean install -Dno-go-client`. This added significant time to the build, 
   and required that the GO distribution be installed. The default behaviour is now that the GO CLI will not be built, and can be enabled
   by adding `-Dclient` to the build command, e.g. `mvn clean install -Dclient`.

1. Similarly the deb, rpm, and Docker binaries were built by default. It was possible to disable the deb and rpm build by using
   `-Dnp-rpm -Dno-deb`, and it was not possible to disable the Docker build. Now all three are disabled default and can be included
   by adding `-Drpm -Ddeb -Ddocker`.


1. The documentation has been updated to include a description of how to include an entity in the Quick Launch section of the UI

1. Following a change to the latest version of openSSH, the process of generating an SSH key has changed, and the documentation
   has been updated to reflect that change. SSH keys generated in previous versions of openSSH are not affected and will continue
   to work.

1. The WinRM documentation has been expanded to include additional troubleshooting information, and known limitations.

1. Previously Brooklyn used logback for logging but this changed to be log4j when we moved to karaf. As Brooklyn now only supports
   karaf most logging is now done using the log4j framework by default. The documentation has been updated to reflect this, and
   now documents how to setup and configure log4j.

1. ConfigKey constraints have been expanded to include the option to add `glob`, `urlExists`, `forbiddenIf`, `forbiddenUnless`,
   `requiredIf`, `requiredUnless`, and additionally and Java Predicate can be used as a constraint.

1. Updates have been made to the type coercions primatives in YAML to allow optional, nullable (`Maybe`) values.

1. The REST API has been updated to include the icon url source on objects which contain one.

1. The UI has been updated to allow parameters to be defined in both a field-based and JSON manner.

1. The UI now allows greater zoom for large displays.

1. For static assets (e.g. logos), the webconsole previously allowed passwordless access. This has been updated so that
   login is now required to access static assets.

1. The DSL editor now allows references to `brooklyn.parameters`.

1. A new compact list view mode has been added to the UI.

1. Add callback has been added for customising yaml loading, allowing downstream projects to extend this behaviour

1. A separable pallet/config panel has been introduced in the UI, which allows more flexibility when using the graphical
   designer to design a blueprint. This supplements the existing functionality.

1. When defining a relationship, it is now possible to include a `memberspec` as part of the relationship.

1. A callback has been added for customising catalog save configuration.

1. Implements missing endpoint for palette API.

1. Improved config editor styling.

### Bug Fixes

1. Fixes BROOKLYN-586 (obsolete jsonpath package)

1. Fixes BROOKLYN-597 (removes md5/sha1 from build)

1. Fixes BROOKLYN-602 (config key order for yaml overrides)

1. Fixes BROOKLYN-605 (rebind issue)

1. Fixes BROOKLYN-607 (use CentOS image on Azure)

1. Fixes BROOKLYN-608 (karaf start issue)

1. Fixes OutOfMemoryError on Windows installations

1. Fixes spurious location errors in composer

1. Fixes the inline edit configuration for policies in app inspector

1. Fixes firefox multi-lines issue in configuration text-area

1. Fixes Firefox navigation issue in Composer

### Dependency Version Updates

1. Use Karaf 4.2.1

1. Use latest version of winrm4j (0.6.1)

1. Updates jetty version to 9.3.24.v20180605

1. Updates Jackson FasterXML to 2.9.8

1. Updates XStream Core to 1.4.11.1

1. Updates Apache Felix Framework to 5.6.12

1. Updates Java WinRM Library to 0.7.0

1. Updates Apache CXF to 3.2.8

1. Updates JavaX to 1.3

1. Updates Commons Compress to 1.18

1. Updates Apache Karaf JAAS Boot to 4.2.7

1. Updates JLine Bundle to 3.12.1

### Backwards Compatibility

Changes since 0.12.0:

1. BOM files that do not declare a version now give the version of the bundle to their entities,
   rather than the default `0.0.0-SNAPSHOT` version.
   When loading types, the version can now be specified as any Brooklyn-valid version string
   equivalent to the OSGi version (e.g. `1-SNAPSHOT` or `1.0.0.SNAPSHOT`).

1. Some catalog methods may return the same type multiple times, if contained in multiple bundles.
   Previously only one of the bundle's definition of the type was returned. 
   Except for anonymous bundles it is no longer allowed to have give items with the same name and version.
   (This is required to prevent Brooklyn from getting in to a state where it cannot rebind.)

1. Value resolution is now supported for config default values. Previously these would be coerced but
   not resolved beyond that -- i.e. TaskFactory values would not have tasks evaluated, and Map and
   Collection values would not be deeply resolved with their internals coerced or evaluated.
   This makes the semantics of default values consistent with explicit config values.    

1. Deep config resolution of nested items has changed to be consistent with when deep config applies.
   Deep config applies to maps and collections, but previously any Iterable contained therein
   would have a recursive deep config evaluation. Now this is limited to nested Collection types
   (Lists, Sets, etc) and Maps; nested Iterable instances that are not also Collections are 
   no longer traversed and resolved recursively. This makes their nested resolution consistent 
   with when such instances are non-nested config value, as deep resolution was not applied there.
   This mainly affects PortRange, where previously if set directly on a config key it would return
   the PortRange value but if accessed in a map such as `shell.env` any non-default value would 
   be expanded as a list `[1, 2]` (but default values would not be expanded, as per previous point,
   but now they are). 

For changes in prior versions, please refer to the release notes for 
[0.12.0]({{ site.path.v | relative_url }}/0.12.0/misc/release-notes.html).
