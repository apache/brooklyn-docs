```yaml
location:
  multi:
    targets:
      - byon:(hosts=192.168.0.1)
      - jclouds:aws-ec2:us-east-1
services:
  - type: org.apache.brooklyn.entity.group.DynamicCluster
    brooklyn.config:
      cluster.initial.size: 3
      dynamiccluster.memberspec:
        $brooklyn:entitySpec:
          type: org.apache.brooklyn.entity.machine.MachineEntity
```
