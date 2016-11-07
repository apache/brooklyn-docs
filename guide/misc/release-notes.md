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

2. [minor] Default config key values are now coerced to the right type when accessed.
Previously coercion only applied to values set, so if a default value was accessed, the caller would get the 
value and type of the default value, not coerced to the type of the config key.
This was inconsistent with cases where a value is set for the config key, as callers in that case will get the
value coerced to the type of the config key. This was a bug as callers should always be able to expect
the config value to be of the declared type, consistently across default values and explicitly set values.

    As an example, if a config key is typed (e.g. `port`) and a caller uses code such as `$brooklyn:config` to access
that value, previously they would see the numeric value if the value comes from a default;
if that is what is being expected it is an error as a JSON map for `PortRange` would be returned if a config value is set,
but the erroneous usage might not have been noticed if the port only ever came from a default value. 
The fix in this case is to use `$brooklyn:attributeWhenReady` if the caller wants the actual value selected from the range
(through port inferencing done e.g. in `SoftwareProcess` entities),
or to declare the sensor of type `int` if they do not want port ranges and inferencing to be supported.



For changes in prior versions, please refer to the release notes for 
[0.9.0]({{ site.path.v }}/0.9.0/misc/release-notes.html).
