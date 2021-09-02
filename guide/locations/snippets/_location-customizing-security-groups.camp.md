```yaml
name: ports @ AWS
location: jclouds:aws-ec2:us-west-2
services:
  - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
    brooklyn.config:
      provisioning.properties:
        customizers:
          - $brooklyn:object:
              type: org.apache.brooklyn.location.jclouds.networking.SharedLocationSecurityGroupCustomizer
              object.fields: {tcpPortRanges: ["900-910", "915", "22"], udpPortRanges: ["100","200-300"], cidr: "82.40.153.101/24"}
```
