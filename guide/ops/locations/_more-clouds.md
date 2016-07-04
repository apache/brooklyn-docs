---
section: More Details on Specific Clouds
title: More on Clouds
section_type: inline
section_position: 2
---

### More Details on Specific Clouds

To connect to a Cloud, Brooklyn requires appropriate credentials. These comprise the `identity` and
`credential` in Brooklyn terminology.

For private clouds (and for some clouds being targeted using a standard API), the `endpoint`
must also be specified, which is the cloud's URL.  For public clouds, Brooklyn comes preconfigured
with the endpoints, but many offer different choices of the `region` where you might want to deploy.

Clouds vary in the format of the identity, credential, endpoint, and region.
Some also have their own idiosyncracies.  More details for configuring some common clouds
is included below. You may also find these sources helpful:

* The **[template brooklyn.properties]({{ site.path.guide }}/start/brooklyn.properties)** file
  in the Getting Started guide
  contains numerous examples of configuring specific clouds,
  including the format of credentials and options for sometimes-fiddly private clouds.
* The **[jclouds guides](https://jclouds.apache.org/guides)** describes low-level configuration
  sometimes required for various clouds.


