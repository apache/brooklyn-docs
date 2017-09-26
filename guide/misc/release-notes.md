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

1. Auto-bundling of BOMs and the ability to manage and persist bundles:  related entities are now grouped in bundles
and all management activity (deletion, upgrades, persistence) done at the level of the bundle.
You can now start a new Brooklyn instance pointed at a persistence store,
and it will automatically load all bundles installed into the previous Brooklyn
through the REST API.

1. Application deployment now supports "create-or-reuse" where an application ID can be supplied,
and deployment is undertaken only if the ID is not yet present.
This supports workflows that require idempotency or something deployed in a singleton pattern,
such as in a continuous integration pipeline.  

1. jclouds latest version: improved Azure support and more.

1. Optimization: much better memory usage and better CPU usage.


### Backwards Compatibility

Changes since 0.11.0:

1. The `cluster.first` sensor set by a group on its children has been removed due to ambiguity and deadlock. 
Equivalent information can be retrieved by looking at the `cluster.first.entity` and this now updates correctly.

1. Version names now have a recommended syntax, and warnings will occur if it is not followed.
In obscure cases where version strings differ only in symbols, 
different version names can map to the same OSGi version string and may now
block install or cause replacement where previously they could exist simultaneously.
For example if you have a bundle `1.0.0$SNAPSHOT` and you install `1.0.0&SNAPSHOT`, this will now be treated as a replacement.

1. Types (catalog items) are validated sooner and so errors may occur earlier if there are invalid blueprints.
In addition if a bundle cannot be installed, it now reverts to the state before the bundle installation.
(Previously it would leave the bundle in the half-installed error state for the user to remedy.) 

1. Deletion and deprecation of individual catalog items is no longer persisted or kept after a restart.
These changes should be done by updating or deleting the BOM/bundle containing the item. 


For changes in prior versions, please refer to the release notes for 
[0.11.0]({{ site.path.v }}/0.11.0/misc/release-notes.html).
