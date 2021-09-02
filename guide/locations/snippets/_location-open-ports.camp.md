```yaml
location: jclouds:aws-ec2:us-west-2
services:
  - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
    brooklyn.config:
      effector.add.openInboundPorts: true
```
