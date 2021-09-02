```yaml
location:
  multi:
    targets:
      - my-location-1
      - my-location-2
      - my-location-3
services:
  - type: org.apache.brooklyn.entity.group.DynamicCluster
    brooklyn.config:
      dynamiccluster.zone.enable: true
      cluster.initial.size: 3
      dynamiccluster.memberspec:
        $brooklyn:entitySpec:
          type: org.apache.brooklyn.entity.machine.MachineEntity
```
