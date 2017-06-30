---
section: Customizing Cloud Security Groups
section_position: 12
section_type: inline
---

## Customizing Cloud Security Groups

Before using SharedLocationSecurityGroupCustomizer, please first refer to [Port Inferencing](../../blueprints/custom-entities.html#port-inferencing).

A security group is a named collection of network access rules that are use to limit the types of traffic that have access to instances.<br>
Security group is the standard way to set firewall restrictions on the AWS-EC2 environment.
[docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html)

When deploying to AWS EC2 target, by default Apache Brooklyn creates security group attached to the VM.
It is easy to add additional rules to the initial security group using `org.apache.brooklyn SharedLocationSecurityGroupCustomizer`.

YAML Example:

    name: ports @ AWS
    location: jclouds:aws-ec2:us-west-2:
    services:
    - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
      brooklyn.config:
        provisioning.properties:
          customizers:
          - $brooklyn:object:
              type: org.apache.brooklyn.location.jclouds.networking.SharedLocationSecurityGroupCustomizer
              object.fields: {tcpPortRanges: ["900-910", "915", "22"], udpPortRanges: ["100","200-300"], cidr: "82.40.153.101/24"}


Make sure that you have rule which makes port 22 accessible from Apache Brooklyn.

### Opening ports during runtime.

Apache Brooklyn exposes the SharedLocationSecurityGroupCustomizer functionality after entity is deployed <br>
just by supplying `effector.add.openInboundPorts: true` "brooklyn.config".
Example configuration in effector

    location: jclouds:aws-ec2:us-west-2
    services:
    - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
      brooklyn.config:
        effector.add.openInboundPorts: true

### Known limitations

Not all cloud providers support Security Group abstraction.
`SharedLocationSecurityGroupCustomizer` is known to work well with Amazon EC2.<br>
Other clouds which support Security Groups:

- Openstack
- Azure - jclouds-labs azurecompute implementation uses endpoints rules when creating a VM instance.
  jclouds:azurecompute based location do not have security groups so SharedLocationSecurityGroupCustomizer is used it will fail to find a security group.

