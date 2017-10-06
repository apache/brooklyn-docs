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
[externalized configuration]({{ book.path.guide }}/ops/externalized-configuration.html) for better
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


### EC2 "Classic" Problems with VPC-only Hardware Instance Types

If you have a pre-2014 Amazon account, it is likely configured in some regions to run in "EC2 Classic" mode
by default, instead of the more modern "VPC" default mode.  This can cause failures when requesting certain hardware
configurations because many of the more recent hardware "instance types" only run in "VPC" mode.
For instance when requesting an instance with `minRam: 8gb`, Brooklyn may opt for an `m4.large`,
which is a VPC-only instance type. If you are in a region configured to use "EC2 Classic" mode,
you may see a message such as this:

    400 VPCResourceNotSpecified: The specified instance type can only be used in a VPC.
    A subnet ID or network interface ID is required to carry out the request.

This is a limitation of "legacy" accounts.  The easiest fixes are either:

* specify an instance type which is supported in classic, such as `m3.xlarge` (see below)
* move to a different region where VPC is the default
  (`eu-central-1` should work as it *only* offers VPC mode,
  irrespective of the age of your AWS account)
* get a new AWS account -- "VPC" will be the default mode
  (Amazon recommend this and if you want to migrate existing deployments
  they provide [detailed instructions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/vpc-migrate.html))

To understand the situation, the following resources may be useful:

* Background on VPC vs Classic:  [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-vpc.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-vpc.html)
* Good succinct answers to FAQs: [http://aws.amazon.com/vpc/faqs/#Default_VPCs]()
* Check if a region in your account is "VPC" or "Classic": [http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/default-vpc.html#default-vpc-availability]()
* Regarding instance types:
  * All instance types: [https://aws.amazon.com/ec2/instance-types]()
  * Those which require VPC: [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-vpc.html#vpc-only-instance-types]()

If you want to solve this problem with your existing account,
you can create a VPC and instruct Brooklyn to use it:

1. Use the "Start VPC Wizard" option in [the VPC dashboard](https://console.aws.amazon.com/vpc),
  making sure it is for the right region, and selecting a "Single Public Subnet".
  (More information is in [these AWS instructions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html#create-a-vpc).)
2. Once the VPC is created, open the "Subnets" view and modify the "Public subnet"
   so that it will "Auto-assign Public IP".
3. Next click on the "Security Groups" and find the `default` security group for that VPC.
   Modify its "Inbound Rules" to allow "All traffic" from "Anywhere".
   (Or for more secure options, see the instructions in the previous section,
   "Using Subnets".)
4. Finally make a note of the subnet ID (e.g. `subnet-a1b2c3d4`) for use in Brooklyn.

You can then deploy blueprints to the subnet, allowing VPC hardware instance types,
by specifying the subnet ID as the `networkName` in your YAML blueprint.
This is covered in the previous section, "Using Subnets".


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
