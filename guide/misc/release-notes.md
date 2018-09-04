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
[0.12.0]({{ site.path.v }}/0.12.0/misc/release-notes.html).
