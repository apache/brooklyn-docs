```yaml
location: jclouds:aws-ec2:us-east-1
services:
  - type: org.apache.brooklyn.entity.group.DynamicCluster
    brooklyn.config:
      dynamiccluster.zone.enable: true
      cluster.initial.size: 3
      dynamiccluster.memberspec:
        $brooklyn:entitySpec:
          type: org.apache.brooklyn.entity.machine.MachineEntity
```
