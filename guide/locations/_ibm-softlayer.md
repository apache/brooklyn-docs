---
section: IBM Softlayer
title: IBM Softlayer
section_type: inline
section_position: 6
---

## IBM SoftLayer

### Credentials

Credentials can be obtained from the Softlayer API, under "administrative -> user administration -> api-access".

For example:

    location:
      jclouds:softlayer:
        region: ams01
        identity: my-user-name
        credential: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

Users are strongly recommended to use 
[externalized configuration](../ops/externalized-configuration.md) for better
credential management, for example using [Vault](https://www.vaultproject.io/).


### Common Configuration Options

Below are examples of configuration options that use values specific to Softlayer:

* The `region` is the [Softlayer datacenter](http://www.softlayer.com/data-centers).
  For example, `region: dal05`.

* The `hardwareId` is an auto-generated combination of the hardware configuration options.
  This is because there is no concept of hardwareId or hardware profile names in Softlayer. 
  An example value is `hardwareId: "cpu=1,memory=1024,disk=25,type=LOCAL"`.

* The `imageId` is the [Image template](https://knowledgelayer.softlayer.com/learning/introduction-image-templates).
  For example, `imageId: CENTOS_6_64`.


### VLAN Selection

SoftLayer may provision VMs in different VLANs, even within the same region.
Some applications require VMs to be on the *same* internal subnet; blueprints
for these can specify this behaviour in SoftLayer in one of two ways.

The VLAN ID can be set explicitly using the fields
`primaryNetworkComponentNetworkVlanId` and
`primaryBackendNetworkComponentNetworkVlanId` of `SoftLayerTemplateOptions`
when specifying the location being used in the blueprint, as follows:

    location:
      jclouds:softlayer:
        region: ams01
        templateOptions:
          # Enter your preferred network IDs
          primaryNetworkComponentNetworkVlanId: 1153481
          primaryBackendNetworkComponentNetworkVlanId: 1153483

This method requires that a VM already exist and you look up the IDs of its
VLANs, for example in the SoftLayer console UI, and that subsequently at least
one VM in that VLAN is kept around.  If all VMs on a VLAN are destroyed
SoftLayer may destroy the VLAN.  Creating VLANs directly and then specifying
them as IDs here may not work.  Add a line note

The second method tells Brooklyn to discover VLAN information automatically: it
will provision one VM first, and use the VLAN information from it when
provisioning subsequent machines. This ensures that all VMs are on the same
subnet without requiring any manual VLAN referencing, making it very easy for
end-users.

To use this method, we tell brooklyn to use `SoftLayerSameVlanLocationCustomizer`
as a location customizer.  This can be done on a location as follows:

    location:
      jclouds:softlayer:
        region: lon02
        customizers:
        - $brooklyn:object:
            type: org.apache.brooklyn.location.jclouds.softlayer.SoftLayerSameVlanLocationCustomizer
        softlayer.vlan.scopeUid: "my-custom-scope"
        softlayer.vlan.timeout: 10m

Usually you will want the scope to be unique to a single application, but if you
need multiple applications to share the same VLAN, simply configure them with
the same scope identifier.

It is also possible with many blueprints to specify this as one of the
`provisioning.properties` on an *application*:

    services:
    - type: org.apache.brooklyn.entity.stock.BasicApplication
      id: same-vlan-application
      brooklyn.config:
        provisioning.properties:
          customizers:
          - $brooklyn:object:
              type: org.apache.brooklyn.location.jclouds.softlayer.SoftLayerSameVlanLocationCustomizer
        softlayer.vlan.scopeUid: "my-custom-scope"
        softlayer.vlan.timeout: 10m

If you are writing an entity in Java, you can also use the helper
method `forScope(String)` to create the customizer. Configure the
provisioning flags as follows:

    JcloudsLocationCustomizer vlans = SoftLayerSameVlanLocationCustomizer.forScope("my-custom-scope");
    flags.put(JcloudsLocationConfig.JCLOUDS_LOCATION_CUSTOMIZERS.getName(), ImmutableList.of(vlans));


### Configuration Options

The allowed configuration keys for the `SoftLayerSameVlanLocationCustomizer`
are:

-   **softlayer.vlan.scopeUid** The scope identifier for locations whose
    VMs will have the same VLAN.

-   **softlayer.vlan.timeout** The amount of time to wait for a VM to
    be configured before timing out without setting the VLAN ids.

-   **softlayer.vlan.publicId** A specific public VLAN ID to use for
    the specified scope.

-   **softlayer.vlan.privateId** A specific private VLAN ID to use for
    the specified scope.

An entity being deployed to a customized location will have the VLAN ids set as
sensors, with the same names as the last two configuration keys.

***NOTE*** If the SoftLayer location is already configured with specific VLANs
then this customizer will have no effect.



