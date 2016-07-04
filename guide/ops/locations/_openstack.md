---
section: Openstack
title: Openstack
section_type: inline
section_position: 6
---

## Openstack

### Apache jclouds

Support for OpenStack is provided by Apache jclouds. For more information, see their guide
[here](https://jclouds.apache.org/guides/openstack/).


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


### Basic Location Structure

This is a basic inline YAML template for an OpenStack location:

    location:
        jclouds:clouds:openstack-nova:
            endpoint: http://x.x.x.x:5000/v2.0/
            identity: "your-tenant:your-username"
            credential: your-password

            # imageId, hardwareId, and loginUser* are optional
            imageId: your-region-name/your-image-id
            hardwareId: your-region-name/your-flavor-id
            loginUser: 'ubuntu'
            loginUser.privateKeyFile: /path/to/your/privatekey

            jclouds.openstack-nova.auto-generate-keypairs: false
            jclouds.openstack-nova.auto-create-floating-ips: true

            templateOptions:
                networks: [ "your-network-id" ]
                floatingIpPoolNames: [ "your-floatingIp-pool" ]
                securityGroups: ['your-security-group']

                # Optional if 'jclouds.openstack-nova.auto-generate-keypairs' is assigned to 'true'
                keyPairName: "your-keypair"

This is the same OpenStack location in a format that can be added to your
`brooklyn.properties` file:

    brooklyn.location.named.My\ Openstack=jclouds:openstack-nova:http://x.x.x.x:5000/v2.0/
    brooklyn.location.named.My\ OpenStack.identity=your-tenant:your-username
    brooklyn.location.named.My\ OpenStack.credential=your-password
    brooklyn.location.named.My\ OpenStack.endpoint=http://x.x.x.x:5000/v2.0/

    brooklyn.location.named.My\ OpenStack.imageId=your-region-name/your-image-id
    brooklyn.location.named.My\ OpenStack.hardwareId=your-region-name/your-flavor-id
    brooklyn.location.named.My\ OpenStack.loginUser=ubuntu
    brooklyn.location.named.My\ OpenStack.loginUser.privateKeyFile=/path/to/your/privatekey
    brooklyn.location.named.My\ OpenStack.openstack-nova.auto-generate-keypairs=false
    brooklyn.location.named.My\ OpenStack.openstack-nova.auto-create-floating-ips=true

    brooklyn.location.named.My\ OpenStack.networks=your-network-id
    brooklyn.location.named.My\ OpenStack.floatingIpPoolNames=your-floatingIp-pool
    brooklyn.location.named.My\ OpenStack.securityGroups=your-security-group
    brooklyn.location.named.My\ OpenStack.keyPair=your-keypair

Chose a value of `your-flavor-id` from one of the defaults, or create your own flavor if
you have administrator privileges.
For for more information, see the
[OpenStack flavors guide](http://docs.openstack.org/admin-guide/cli_manage_flavors.html).

The default flavors are:

    +-----+-----------+-----------+------+
    | ID  | Name      | Memory_MB | Disk |
    +-----+-----------+-----------+------+
    | 1   | m1.tiny   | 512       | 1    |
    | 2   | m1.small  | 2048      | 20   |
    | 3   | m1.medium | 4096      | 40   |
    | 4   | m1.large  | 8192      | 80   |
    | 5   | m1.xlarge | 16384     | 160  |
    +-----+-----------+-----------+------+

For an even more detailed example location configuration, consult the
[template properties file](https://brooklyn.apache.org/v/latest/start/brooklyn.properties).


### Other features

Consult jclouds' [Nova template options](https://jclouds.apache.org/reference/javadoc/1.9.x/org/jclouds/openstack/nova/v2_0/compute/options/NovaTemplateOptions.html)
for futher options when configuring Openstack locations.

### Troubleshooting

#### jclouds Namespace Issue

A change to Nova's API resulted in all extensions having the same "fake" namespace which
the current version of jclouds does not yet support.

If you are having problems deploying to OpenStack, consult your Brooklyn debug log and
look for the following:


    "namespace": "http://docs.openstack.org/compute/ext/fake_xml"


If this appears, perform the following steps as a workaround:

* Generate a patch JAR `openstack-devtest-compute-1.9.2.jar`
by building: https://github.com/cloudsoft/jclouds-openstack-devtest
* Copy the patch JAR into $BROOKLYN_HOME/lib/patch
* Change `jclouds:openstack-nova` to `jclouds:openstack-devtest-compute` in your location
configuration

Here is a simple example template to be used with this workaround:


    location:
        jclouds:openstack-devtest-compute:
            endpoint: http://x.x.x.x:5000/v2.0/
            identity: "your-tenant:your-username"
            credential: your-password
            templateOptions:
                networks: [ "your-network-id" ]
                floatingIpPoolNames: [ "your-floatingIp-pool" ]


Note that the following values will be set by default when omitted above:


    jclouds.keystone.credential-type=passwordCredentials
    jclouds.openstack-nova.auto-generate-keypairs: true
    jclouds.openstack-nova.auto-create-floating-ips: true



