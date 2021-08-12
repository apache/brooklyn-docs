```yaml
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
```
