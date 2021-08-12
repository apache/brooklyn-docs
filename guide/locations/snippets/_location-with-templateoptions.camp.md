```yaml
    location: AWS_eu-west-1
    services:
    - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
      provisioning.properties:
        templateOptions:
          subnetId: subnet-041c8373
          mapNewVolumeToDeviceName: ["/dev/sda1", 100, true]
          securityGroupIds: ['sg-4db68928']
```
