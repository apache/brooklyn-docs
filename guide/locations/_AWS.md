---
section: Amazon Web Services (AWS)
title: Amazon Web Services
section_type: inline
section_position: 2
---

## Amazon Web Services (AWS)

### Credentials

AWS has an "access key" and a "secret key", which correspond to Brooklyn's identity and credential
respectively.

These keys are the way for any programmatic mechanism to access the AWS API.

To generate an access key and a secret key, see [jclouds instructions](http://jclouds.apache.org/guides/aws)
and [AWS IAM instructions](http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html).

An example of the expected format is shown below:

    location:
      jclouds:aws-ec2:
        region: us-east-1
        identity: ABCDEFGHIJKLMNOPQRST
        credential: abcdefghijklmnopqrstu+vwxyzabcdefghijklm

Users are strongly recommended to use 
[externalized configuration](/guide/ops/externalized-configuration.md) for better
credential management, for example using [Vault](https://www.vaultproject.io/).


### Common Configuration Options

Below are examples of configuration options that use values specific to AWS EC2:

* The `region` is the [AWS region code](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html).
  For example, `region: us-east-1`. You can in-line the region name using the following format: `jclouds:aws-ec2:us-east-1`.
  A specific availability zone within the region can be specified by including its letter identifier as a suffix. 
  For example, `region: us-east-1a`.

* The `hardwareId` is the [instance type](https://aws.amazon.com/ec2/instance-types/). For example,
  `hardwareId: m4.large`.

* The `imageId` is the region-specific [AMI id](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html).
  For example, `imageId: us-east-1/ami-05ebd06c`.

* The `securityGroups` option takes one or more names of pre-existing 
  [security groups](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html).
  For example, `securityGroups: mygroup1` or `securityGroups: [ mygroup1, mygroup2 ]`.

### EBS boot volume size

The size of the EBS boot volume for a VM can be specified using `mapNewVolumeToDeviceName` in `templateOptions` as shown below:

    location:
      jclouds:aws-ec2:
        region: ...
        templateOptions:
          mapNewVolumeToDeviceName:
           - /dev/sda1
           - 123
           - true

Where `/dev/sda1` is the device name of the boot volume on the selected AMI, `123` is the size of the volume in gigabytes 
and `true` is a boolean indicating the volume should be deleted on VM termination.
        

### Using a Registered Key Pair

You can specify a `keyPair` to use for initial provisioning as a configuration option.
If this is omitted, Brooklyn will use jclouds to create a new ad hoc key pair at AWS
for that machine, and it will delete it afterwards.  This is usually seamless and
occurs behind the scenes, with the post-provision user set up and configured as normal
for all locations.  However using AWS heavily or optimizing creation, using a known
key pairs can  
[make some images](https://issues.apache.org/jira/browse/JCLOUDS-1356) more reliable
and speed things up.

First, in the AWS Console, open the EC2 service in the region you are interested in,
then click "Key Pairs" at the left.  For `us-east-1`, the link is 
[here](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1).
Click "Create Key Pair" (or "Import Key Pair" if you want to provide a public key) and
follow the instructions.

Then define your location as follows for `aws-us-east-1`.  Make sure to replace the
`XXXX` sections with the key-pair name defined above and the corresponding private key data. 

```yaml
brooklyn.catalog:
  version: "1.0"
  itemType: location
  items:
  - id: aws-base
    item:
      type: jclouds:aws-ec2
      brooklyn.config:
        identity: XXXXXXXXXXXXXXXX
        credential: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx
  - id: aws-us-east-1
    item:
      type: aws-base
      brooklyn.config:
        region: us-east-1
        keyPair: XXXXXXXXX
        loginUser.privateKeyData: |
          -----BEGIN RSA PRIVATE KEY-----
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          -----END RSA PRIVATE KEY-----
```


### Using Subnets and Security Groups

Apache Brooklyn can run with AWS VPC and both public and private subnets.
Simply provide the `subnet-a1b2c3d4` as the `networkName` when deploying:

    location:
      jclouds:aws-ec2:
        region: us-west-1
        networkName: subnet-a1b2c3d4   # use your subnet ID

Subnets are typically used in conjunction with security groups.
Brooklyn does *not* attempt to open additional ports
when private subnets or security groups are supplied,
so the subnet and ports must be configured appropriately for the blueprints being deployed.
You can configure a default security group with appropriate (or all) ports opened for
access from the appropriate (or all) CIDRs and security groups,
or you can define specific `securityGroups` on the location
or as `provisioning.properties` on the entities.

Make sure that Brooklyn has access to the machines under management.
This includes SSH, which might be done with a public IP created with inbound access
on port 22 permitted for a CIDR range including the IP from which Brooklyn contacts it.
Alternatively you can run Brooklyn on a machine in that same subnet, or
set up a VPN or jumphost which Brooklyn will use.

### Tidying up after jclouds

Security groups are not always deleted by jclouds. This is due to a limitation in AWS (see
https://issues.apache.org/jira/browse/JCLOUDS-207). In brief, AWS prevents the security group
from being deleted until there are no VMs using it. However, there is eventual consistency for
recording which VMs still reference those security groups: after deleting the VM, it can sometimes
take several minutes before the security group can be deleted. jclouds retries for 3 seconds, but
does not block for longer.

Whilst there is eventual consistency for recording which VMs still reference security groups, after deleting a VM, it can sometimes take several minutes before a security group can be deleted

There is utility written by [Cloudsoft](http://www.cloudsoft.io/) for deleting these unused resources:
[http://blog.abstractvisitorpattern.co.uk/2013/03/tidying-up-after-jclouds.html](http://blog.abstractvisitorpattern.co.uk/2013/03/tidying-up-after-jclouds.html).
