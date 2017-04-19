---
title: Locations
layout: website-normal
children:
- { path: location-customizers.md, section_position: 8 }
check_directory_for_children: true
---

Locations are the environments to which Brooklyn deploys applications. Most commonly these 
are cloud services such as AWS, GCE, and IBM Softlayer. Brooklyn also supports deploying 
to a pre-provisioned network or to localhost (primarily useful for testing blueprints).

See also:

* The [Locations yaml guide]({{ site.path.guide }}/blueprints/setting-locations.html)
* Use within an entity of the configuration option 
  [provisioning.properties]({{ site.path.guide }}/blueprints/entity-configuration.html#entity-provisioningproperties-overriding-and-merging)
* How to add location definitions to the [Catalog]({{ site.path.guide }}/blueprints/catalog/); and 
* How to use [Externalized Configuration]({{ site.path.guide }}/ops/externalized-configuration.html).

{% child_content %}
