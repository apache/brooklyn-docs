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

Changes since 0.10.0:

1. The usage of `ManagementContext.getConfig()` is deprecated for storing non-config data like
singletons and cached objects. Use `ManagementContext.getScratchpad()` instead. Affected objects:

  * BrooklynCampConstants.CAMP_PLATFORM
  * CampYamlParser.YAML_PARSER_KEY
  * BrooklynServiceAttributes.BROOKLYN_REST_OBJECT_MAPPER
  * BrooklynWebConfig.SECURITY_PROVIDER_INSTANCE


For changes in prior versions, please refer to the release notes for 
[0.10.0]({{ site.path.v }}/0.10.0/misc/release-notes.html).
