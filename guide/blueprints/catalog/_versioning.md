---
section: Versioning
title: Versioning
section_type: inline
section_position: 4
---

### Versioning

Version numbers follow the OSGi convention. This can have a major, minor, micro and qualifier part.
For example, `1.0`. `1.0.1` or `1.0.1-20150101`.

The combination of `id:version` strings must be unique across the catalog.
It is an error to deploy the same version of an existing item:
to update a blueprint, it is recommended to increase its version number;
alternatively in some cases it is permitted to delete an `id:version` instance
and then re-deploy.
If no version is specified, re-deploying will automatically
increment an internal version number for the catalog item.

When referencing a blueprint, if a version number is not specified 
the latest non-snapshot version will be loaded when an entity is instantiated.