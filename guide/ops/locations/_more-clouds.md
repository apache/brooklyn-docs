---
section: More Details on Specific Clouds
title: More on Clouds
section_type: inline
section_position: 2
---

### More Details on Specific Clouds

To connect to a Cloud, Brooklyn requires appropriate credentials. These comprise the `identity` and 
`credential` in Brooklyn terminology. 

For private clouds (and for some clouds being targeted using a standard API), the `endpoint`
must also be specified, which is the cloud's URL.  For public clouds, Brooklyn comes preconfigured 
with the endpoints, but many offer different choices of the `region` where you might want to deploy.  

Clouds vary in the format of the identity, credential, endpoint, and region.
Some also have their own idiosyncracies.  More details for configuring some common clouds
is included below. You may also find these sources helpful:

* The **[template brooklyn.properties]({{ site.path.guide }}/start/brooklyn.properties)** file 
  in the Getting Started guide 
  contains numerous examples of configuring specific clouds, 
  including the format of credentials and options for sometimes-fiddly private clouds.
* The **[jclouds guides](https://jclouds.apache.org/guides)** describes low-level configuration
  sometimes required for various clouds.
 

## Amazon Web Services (AWS)

### Credentials

AWS has an "access key" and a "secret key", which correspond to Brooklyn's identity and credential 
respectively.

These keys are the way for any programmatic mechanism to access the AWS API.

To generate an access key and a secret key, see [jclouds instructions](http://jclouds.apache.org/guides/aws) 
and [AWS IAM instructions](http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html).

An example of the expected format is shown below:

    brooklyn.location.jclouds.aws-ec2.identity=ABCDEFGHIJKLMNOPQRST
    brooklyn.location.jclouds.aws-ec2.credential=abcdefghijklmnopqrstu+vwxyzabcdefghijklm


### Tidying up after jclouds

Security groups are not always deleted by jclouds. This is due to a limitation in AWS (see
https://issues.apache.org/jira/browse/JCLOUDS-207). In brief, AWS prevents the security group
being deleted until there are no VMs using it. However, there is eventual consistency for
recording which VMs still reference those security groups: after deleting the VM, it can sometimes
take several minutes before the security group can be deleted. jclouds retries for 3 seconds, but 
does not block for longer.

There is utility written by Cloudsoft for deleting these unused resources:
http://www.cloudsoftcorp.com/blog/2013/03/tidying-up-after-jclouds.


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


## Google Compute Engine (GCE)

### Credentials

GCE uses a service account e-mail address for the identity and a private key as the credential.

To obtain these from GCE, see the [jclouds instructions](https://jclouds.apache.org/guides/google).

An example of the expected format is shown below.
Note that when supplying the credential in a properties file, it should be one long line 
with `\n` representing the new line characters:

    brooklyn.location.jclouds.google-compute-engine.identity=123456789012@developer.gserviceaccount.com
    brooklyn.location.jclouds.google-compute-engine.credential=-----BEGIN RSA PRIVATE KEY-----\nabcdefghijklmnopqrstuvwxyznabcdefghijk/lmnopqrstuvwxyzabcdefghij\nabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij+lm\nnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm\nnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxy\nzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk\nlmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvw\nxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghi\njklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstu\nvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefg\nhijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrs\ntuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcde\nfghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvw\n-----END RSA PRIVATE KEY-----


### Quotas

GCE accounts can have low default [quotas](https://cloud.google.com/compute/docs/resource-quotas).

It is easy to requesta quota increase by submitting a [quota increase form](https://support.google.com/cloud/answer/6075746?hl=en).
 

### Networks

GCE accounts often have a limit to the number of networks that can be created. One work around 
is to manually create a network with the required open ports, and to refer to that named network
in Brooklyn's location configuration.

To create a network, see [GCE network instructions](https://cloud.google.com/compute/docs/networking#networks_1).

For example, for dev/demo purposes an "everything" network could be created that opens all ports.

|| Name                        || everything                  |
|| Description                 || opens all tcp ports         |
|| Source IP Ranges            || 0.0.0.0/0                   |
|| Allowed protocols and ports || tcp:0-65535 and udp:0-65535 |


## IBM SoftLayer

### VLAN Selection

SoftLayer may provision VMs in different VLANs, even within the same region.
Some applications require VMs to be on the *same* internal subnet; blueprints
for these can specify this behaviour in SoftLayer in one of two ways.

The VLAN ID can be set explicitly using the fields
`primaryNetworkComponentNetworkVlanId` and
`primaryBackendNetworkComponentNetworkVlanId` of `SoftLayerTemplateOptions`
when specifying the location being used in the blueprint, as follows:

    location:
      jclouds:softlayer:
        region: ams01
        templateOptions:
          # Enter your preferred network IDs
          primaryNetworkComponentNetworkVlanId: 1153481
          primaryBackendNetworkComponentNetworkVlanId: 1153483

This method requires that a VM already exist and you look up the IDs of its
VLANs, for example in the SoftLayer console UI, and that subsequently at least
one VM in that VLAN is kept around.  If all VMs on a VLAN are destroyed
SoftLayer may destroy the VLAN.  Creating VLANs directly and then specifying
them as IDs here may not work.  Add a line note

The second method tells Brooklyn to discover VLAN information automatically: it
will provision one VM first, and use the VLAN information from it when
provisioning subsequent machines. This ensures that all VMs are on the same
subnet without requiring any manual VLAN referencing, making it very easy for
end-users.

To use this method, we tell brooklyn to use `SoftLayerSameVlanLocationCustomizer`
as a location customizer.  This can be done on a location as follows:

    location:
      jclouds:softlayer:
        region: lon02
        customizers:
        - $brooklyn:object:
            type: org.apache.brooklyn.location.jclouds.softlayer.SoftLayerSameVlanLocationCustomizer
        softlayer.vlan.scopeUid: "my-custom-scope"
        softlayer.vlan.timeout: 10m

Usually you will want the scope to be unique to a single application, but if you
need multiple applications to share the same VLAN, simply configure them with
the same scope identifier.

It is also possible with many blueprints to specify this as one of the
`provisioning.properties` on an *application*:

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

If you are writing an entity in Java, you can also use the helper
method `forScope(String)` to create the customizer. Configure the
provisioning flags as follows:

    JcloudsLocationCustomizer vlans = SoftLayerSameVlanLocationCustomizer.forScope("my-custom-scope");
    flags.put(JcloudsLocationConfig.JCLOUDS_LOCATION_CUSTOMIZERS.getName(), ImmutableList.of(vlans));


### Configuration Options

The allowed configuration keys for the `SoftLayerSameVlanLocationCustomizer`
are:

-   **softlayer.vlan.scopeUid** The scope identifier for locations whose
    VMs will have the same VLAN.

-   **softlayer.vlan.timeout** The amount of time to wait for a VM to
    be configured before timing out without setting the VLAN ids.

-   **softlayer.vlan.publicId** A specific public VLAN ID to use for
    the specified scope.

-   **softlayer.vlan.privateId** A specific private VLAN ID to use for
    the specified scope.

An entity being deployed to a customized location will have the VLAN ids set as
sensors, with the same names as the last two configuration keys.

***NOTE*** If the SoftLayer location is already configured with specific VLANs
then this customizer will have no effect.


## Openstack

### Networks

When multiple networks are available you should indicate which ones machines should join.
Do this by setting the desired values id as an option in the
**[templateOptions](#custom-template-options)** configuration:

    location:
      jclouds:openstack-nova:
        ...
        templateOptions:
          # Assign the node to all networks in the list.
          networks:
          - network-one-id
          - network-two-id
          - ...


### Floating IPs

Configuration of floating IPs is as networks; specify the pools to use as another
[template option](#custom-template-options):

    location:
      jclouds:openstack-nova:
        ...
        templateOptions:
          # Pool names to use when allocating a floating IP
          floatingIpPoolNames:
          - "pool name"


### Other features

Consult jclouds' [Nova template options](https://jclouds.apache.org/reference/javadoc/1.9.x/org/jclouds/openstack/nova/v2_0/compute/options/NovaTemplateOptions.html)
for futher options when configuring Openstack locations.
