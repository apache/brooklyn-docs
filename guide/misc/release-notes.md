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

Changes since 0.9.0:

1. [minor] `ClassCoercionException` has moved package. The old one was deleted to prevent errors inadvertently trying to catch it.

For changes in prior versions, please refer to the release notes for 
[0.9.0]({{ site.path.v }}/0.9.0/misc/release-notes.html).
