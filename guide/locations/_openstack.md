---
section: OpenStack
title: OpenStack
section_type: inline
section_position: 7
---

## OpenStack

### Apache jclouds

Support for OpenStack is provided by Apache jclouds. For more information, see their guide
[here](https://jclouds.apache.org/guides/openstack/).


### Connection Details

The endpoint URI is that of keystone (normally on port 5000).

The identity normally consists of a colon-separated tenant and username. The credential is 
the password. For example:

    location:
      jclouds:openstack-nova:
        endpoint: http://x.x.x.x:5000/v2.0/
        identity: "your-tenant:your-username"
        credential: your-password

OpenStack Nova access information can be downloaded from the openstack web interface, for example 
as an openrc.sh file. It is usually available from API Access tab in "Access & Security" section.
This file will normally contain the identity and credential.

Users are strongly recommended to use 
[externalized configuration]({{ book.path.guide }}/ops/externalized-configuration.html) for better
credential management, for example using [Vault](https://www.vaultproject.io/).


### Common Configuration Options

Below are examples of configuration options that use values specific to OpenStack environments:

* The `imageId` is the id of an image. For example,
  `imageId: RegionOne/08086159-8b0b-4970-b332-a7a929ee601f`.
  These ids can be found from the the CLI or the web-console, for example in IBM Blue Box London, 
  the URL is https://tenant-region.openstack.blueboxgrid.com/project/images/.

* The `hardwareId` is the [flavor id](http://docs.openstack.org/admin-guide/compute-flavors.html).
  For example `hardwareId: RegionOne/1`. These ids can be found from the the CLI or the web-console,
  for example in IBM Blue Box, the URL is https://tenant-region.openstack.blueboxgrid.com/admin/flavors/.

The default flavors are shown below (though the set of flavors can be 
[managed by the admin](http://docs.openstack.org/admin-guide/cli_manage_flavors.html)):

    +-----+-----------+-----------+------+
    | ID  | Name      | Memory_MB | Disk |
    +-----+-----------+-----------+------+
    | 1   | m1.tiny   | 512       | 1    |
    | 2   | m1.small  | 2048      | 20   |
    | 3   | m1.medium | 4096      | 40   |
    | 4   | m1.large  | 8192      | 80   |
    | 5   | m1.xlarge | 16384     | 160  |
    +-----+-----------+-----------+------+

For further configuration options, consult 
[jclouds Nova template options](https://jclouds.apache.org/reference/javadoc/2.0.x/org/jclouds/openstack/nova/v2_0/compute/options/NovaTemplateOptions.html).
These can be used with the **[templateOptions](#custom-template-options)** configuration option.


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

The `autoAssignFloatingIp` option means that a [floating ip](https://www.mirantis.com/blog/configuring-floating-ip-addresses-networking-openstack-public-private-clouds/)
will be assigned to the VM at provision-time.

A floating IP pool name can also be specified. If not set, a floating IP from any available pool will be chosen.
This is set using the [template option](#custom-template-options). For example:

    location:
      jclouds:openstack-nova:
        ...
        autoAssignFloatingIp: true
        templateOptions:
          # Pool names to use when allocating a floating IP
          floatingIpPoolNames:
          - "pool name"


### Basic Location Structure

This is a basic inline YAML template for an OpenStack location:

    location:
        jclouds:openstack-nova:
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

    brooklyn.location.named.My\ OpenStack=jclouds:openstack-nova:http://x.x.x.x:5000/v2.0/
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


### Troubleshooting

#### Cloud Credentials Failing

If the cloud API calls return `401 Unauthorized` (e.g. in a `org.jclouds.rest.AuthorizationException`),
then this could be because the credentials are incorrect.

A good way to check this is to try the same credentials with the 
[OpenStack nova command line client](http://docs.openstack.org/user-guide/common/cli_install_openstack_command_line_clients.html).


#### Unable to SSH: Wrong User

If SSH authentication fails, it could be that the login user is incorrect. For most clouds, this 
is inferred from the image metadata, but if no (or the wrong) login user is specified then it will  
default to root. The correct login user can be specified using the configuration option `loginUser`.
For example, `loginUser: ubuntu`.

The use of the wrong login user can also result in the obscure message, caused by 
an unexpected response saying to use a different user. For more technical information, see 
this [sshj github issue](https://github.com/hierynomus/sshj/issues/75). The message is:

    Received message too long 1349281121


#### I Want to Use My Own KeyPair

By default, jclouds will auto-generate a new [key pair](http://docs.openstack.org/user-guide/cli_nova_configure_access_security_for_instances.html)
for the VM. This key pair will be deleted automatically when the VM is deleted.

Alternatively, you can use a pre-existing key pair. If so, you must also specify the corresponding
private key (pem file, or data) to be used for the initial login. The name used in the `keyPair` 
configuration must match the name of a key pair that has already been added in OpenStack.
For example:
   
    location:
      jclouds:clouds:openstack-nova:
        ...
        jclouds.openstack-nova.auto-generate-keypairs: false
        keyPair: "my-keypair"
        loginUser: ubuntu
        loginUser.privateKeyFile: /path/to/my/privatekey.pem


#### Error "doesn't contain ... -----BEGIN"

If using `loginUser.privateKeyFile` (or `loginUser.privateKeyData`), this is expected to be a .pem
file. If a different format is used (e.g. a .ppk file), it will give an error like that below:

    Error invoking start at EmptySoftwareProcessImpl{id=TrmhitVc}: chars
    PuTTY-User-Key-File-2: ssh-rsa
    ...
    doesn't contain % line [-----BEGIN ]


#### Warning Message: "Ignoring request to set..."

If you see a warning log message like that below:

    2016-06-23 06:05:12,297 WARN  o.a.b.l.j.JcloudsLocation [brooklyn-execmanager-XlwkWB3k-312]: 
    Ignoring request to set template option loginUser because this is not supported by 
    org.jclouds.openstack.nova.v2_0.compute.options.NovaTemplateOptions

It can mean that the location configuration option is in the wrong place. The configuration under 
`templateOptions` must correspond to those options on the
[jclouds Nova template options](https://jclouds.apache.org/reference/javadoc/1.9.x/org/jclouds/openstack/nova/v2_0/compute/options/NovaTemplateOptions.html).
However, template options such as `loginUser` are top-level configuration options that should not
be inside the `templateOptions` section.


#### HttpResponseException Accessing Compute Endpoint

The Keystone endpoint is first queried to get the API access endpoints for the appropriate services.

Some private OpenStack installs are (mis)configured such that the returned addresses are not always 
directly accessible. It could be that the service is behind a VPN, or that they rely on hostnames
that are only in a private DNS.

You can find the service endpoints in OpenStack, either using the CLI or the web-console. For 
example, in Blue Box the URL is https://tenant-region.openstack.blueboxgrid.com/project/access_and_security/.
You can then check if the Compute service endpoint is directly reachable.


#### VM Failing to Provision

It can be useful to drop down to the OpenStack nova CLI, or to jclouds, to confirm that VM
provisioning is working and to check which options are required.

For example, try following [these jclouds instructions](https://github.com/jclouds/jclouds-examples/tree/master/compute-basics#your-own-openstack-nova).


#### jclouds Namespace Issue

A change to Nova's API (in the Mitaka release) resulted in all extensions having the same "fake" 
namespace which the current version of jclouds does not yet support.

If you are having problems deploying to OpenStack, consult your Brooklyn debug log and
look for the following:

    "namespace": "http://docs.openstack.org/compute/ext/fake_xml"

If you already have `jclouds:openstack-mitaka-nova`, then try using this instead of the vanilla
`jclouds:openstack-nova`. For example:

    location:
        jclouds:openstack-mitaka-nova:
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
