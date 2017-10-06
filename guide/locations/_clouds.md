---
section: Clouds
section_type: inline
section_position: 1
---

### Clouds

For most cloud provisioning tasks, Brooklyn uses
<a href="http://jclouds.org">Apache jclouds</a>.
The identifiers for some of the most commonly used jclouds-supported clouds are
(or [see the full list](http://jclouds.apache.org/reference/providers/)):

* `jclouds:aws-ec2:<region>`: Amazon EC2, where `:<region>` might be `us-east-1` or `eu-west-1` (or omitted)
* `jclouds:softlayer:<region>`: IBM Softlayer, where `:<region>` might be `dal05` or `ams01` (or omitted)
* `jclouds:google-compute-engine`: Google Compute Engine
* `jclouds:openstack-nova:<endpoint>`: OpenStack, where `:<endpoint>` is the access URL (required)
* `jclouds:cloudstack:<endpoint>`: Apache CloudStack, where `:<endpoint>` is the access URL (required)

For any of these, of course, Brooklyn needs to be configured with an `identity` and a `credential`:

```yaml
location:
  jclouds:aws-ec2:
    identity: ABCDEFGHIJKLMNOPQRST
    credential: s3cr3tsq1rr3ls3cr3tsq1rr3ls3cr3tsq1rr3l
``` 

The above YAML can be embedded directly in blueprints, either at the root or on individual services.
If you prefer to keep the credentials separate, you can instead store them as a [catalog entry]({{ book.path.guide }}/blueprints/catalog/index.html#locations-in-catalog) or set them in `brooklyn.properties` 
in the `jclouds.<provider>` namespace:

```bash
brooklyn.location.jclouds.aws-ec2.identity=ABCDEFGHIJKLMNOPQRST  
brooklyn.location.jclouds.aws-ec2.credential=s3cr3tsq1rr3ls3cr3tsq1rr3ls3cr3tsq1rr3l
```

And in this case you can reference the location in YAML with `location: jclouds:aws-ec2`.

Alternatively, you can use the location wizard tool available within the web console
to create any cloud location supported by <a href="http://jclouds.org">Apache jclouds</a>.
This location will be saved as a [catalog entry]({{ book.path.guide }}/blueprints/catalog/index.html#locations-in-catalog) for easy reusability.

Brooklyn irons out many of the differences between clouds so that blueprints run similarly
in a wide range of locations, including setting up access and configuring images and machine specs.
The configuration options are described in more detail below.

In some cases, cloud providers have special features or unusual requirements. 
These are outlined in **[More Details for Specific Clouds](#more-details-on-specific-clouds)**.

#### OS Initial Login and Setup

Once a machine is provisioned, Brooklyn will normally attempt to log in via SSH and configure the machine sensibly.

The credentials for the initial OS log on are typically discovered from the cloud, 
but in some environments this is not possible.
The keys `loginUser` and either `loginUser.password` or `loginUser.privateKeyFile` can be used to force
Brooklyn to use specific credentials for the initial login to a cloud-provisioned machine.

(This custom login is particularly useful when using a custom image templates where the cloud-side account 
management logic is not enabled. For example, a vCloud (vCD) template can have guest customization that will change
the root password. This setting tells Apache Brooklyn to only use the given password, rather than the initial 
randomly generated password that vCD returns. Without this property, there is a race for such templates:
does Brooklyn manage to create the admin user before the guest customization changes the login and reboots,
or is the password reset first (the latter means Brooklyn can never ssh to the VM). With this property, 
Brooklyn will always wait for guest customization to complete before it is able to ssh at all. In such
cases, it is also recommended to use `useJcloudsSshInit=false`.)

Following a successful logon, Brooklyn performs the following steps to configure the machine:

1. creates a new user with the same name as the user `brooklyn` is running as locally
  (this can be overridden with `user`, below).

1. install the local user's `~/.ssh/id_rsa.pub` as an `authorized_keys` on the new machine,
   to make it easy for the operator to `ssh` in
   (override with `privateKeyFile`; or if there is no `id_{r,d}sa{,.pub}` an ad hoc keypair will be generated
   for the regular Brooklyn user;
   if there is a passphrase on the key, this must be supplied)  

1. give `sudo` access to the newly created user (override with `grantUserSudo: false`)

1. disable direct `root` login to the machine

These steps can be skipped or customized as described below.

#### jclouds Config Keys

The following is a subset of the most commonly used configuration keys used to customize 
cloud provisioning.
For more keys and more detail on the keys below, see 
[JcloudsLocationConfig](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/location/jclouds/JcloudsLocationConfig.html).

###### VM Creation
    
- Most providers require exactly one of either `region` (e.g. `us-east-1`) or `endpoint` (the URL, usually for private cloud deployments)

- Hardware requirements can be specified, including 
  `minRam`, `minCores`, `minDisk` and `os64Bit`; or as a specific `hardwareId`

- VM image constraints can be set using `osFamily` (e.g. `Ubuntu`, `CentOS`, `Debian`, `RHEL`)
  and `osVersionRegex`, or specific VM images can be specified using `imageId` or `imageNameRegex`

- Specific VM images can be specified using `imageId` or `imageNameRegex`

- Specific Security Groups can be specified using `securityGroups`, as a list of strings (the existing security group names),
  or `inboundPorts` can be set, as a list of numeric ports (selected clouds only)

- Where a key pair is registered with a target cloud for logging in to machines,
  Brooklyn can be configured to request this when provisioning VMs by setting `keyPair` (selected clouds only). 
  Note that if this `keyPair` does not correspond your default `~/.ssh/id_rsa`, you must typically 
  also specify the corresponding `loginUser.privateKeyFile` as a file or URL accessible from Brooklyn.

- A specific VM name (often the hostname) base to be used can be specified by setting `groupId`.
  By default, this name is constructed based on the entity which is creating it,
  including the ID of the app and of the entity.
  (As many cloud portals let you filter views, this can help find a specific entity or all machines for a given application.)
  For more sophisticated control over host naming, you can supply a custom 
  [CloudMachineNamer](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/location/cloud/names/CloudMachineNamer.html),
  for example
  `cloudMachineNamer: CustomMachineNamer`.
  [CustomMachineNamer](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/core/location/cloud/names/CustomMachineNamer.html)
  will use the entity's name or following a template you supply.
  On many clouds, a random suffix will be appended to help guarantee uniqueness;
  this can be removed by setting `vmNameSaltLength: 0` (selected clouds only).
  <!-- TODO jclouds softlayer includes a 3-char hex suffix -->
  
- A DNS domain name where this host should be placed can be specified with `domainName`
  (in selected clouds only)

- User metadata can be attached using the syntax `userMetadata: { key: value, key2: "value 2" }` 
  (or `userMetadata=key=value,key2="value 2"` in a properties file)

- By default, several pieces of user metadata are set to correlate VMs with Brooklyn entities,
  prefixed with `brooklyn-`.
  This user metadata can be omitted by setting `includeBrooklynUserMetadata: false`.

- You can specify the number of attempts Brooklyn should make to create
  machines with `machineCreateAttempts` (jclouds only). This is useful as an efficient low-level fix
  for those occasions when cloud providers give machines that are dead on arrival.
  You can of course also resolve it at a higher level with a policy such as 
  [ServiceRestarter](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/ha/ServiceRestarter.html).

- If you want to investigate failures, set `destroyOnFailure: false`
  to keep failed VM's around. (You'll have to manually clean them up.)
  The default is false: if a VM fails to start, or is never ssh'able, then the VM will be terminated.
  
- You can set `useMachinePublicAddressAsPrivateAddress` to true to overwrite the VMs private IP with its public IP. This is useful as it can be difficult to get VMs communicating via the private IPs they are assigned in some clouds.  Using this config, blueprints which use private IPs can still be deployed to these clouds.
  
  ###### OS Setup

- `user` and `password` can be used to configure the operating user created on cloud-provisioned machines

- The `loginUser` config key (and subkeys) control the initial user to log in as,
  in cases where this cannot be discovered from the cloud provider
 
- Private keys can be specified using `privateKeyFile`; 
  these are not copied to provisioned machines, but are required if using a local public key
  or a pre-defined `authorized_keys` on the server.
  (For more information on SSH keys, see [here](#ssh-keys).) 

- If there is a passphrase on the key file being used, you must supply it to Brooklyn for it to work, of course!
  `privateKeyPassphrase` does the trick (as in `brooklyn.location.jclouds.privateKeyPassphrase`, or other places
  where `privateKeyFile` is valid).  If you don't like keys, you can just use a plain old `password`.

- Public keys can be specified using `publicKeyFile`, 
  although these can usually be omitted if they follow the common pattern of being
  the private key file with the suffix `.pub` appended.
  (It is useful in the case of `loginUser.publicKeyFile`, where you shouldn't need,
  or might not even have, the private key of the `root` user when you log in.)

- Provide a list of URLs to public keys in `extraSshPublicKeyUrls`,
  or the data of one key in `extraSshPublicKeyData`,
  to have additional public keys added to the `authorized_keys` file for logging in.
  (This is supported in most but not all locations.)
  
- Use `dontCreateUser` to have Brooklyn run as the initial `loginUser` (usually `root`),
  without creating any other user.

- A post-provisioning `setup.script` can be specified to run an additional script, before making the `Location` 
  available to entities. This may take the form of a URL of a script or a [data URI](https://en.wikipedia.org/wiki/Data_URI_scheme).
  Note that if using a data URI it is usually a good idea to [base64](https://en.wikipedia.org/wiki/Base64) this string to escape problem characters
  in more complex scripts. The base64 encoded script should then be prefixed with `data:text/plain;base64,` to denote this. 
  For example if you wanted to disable a yum repository called `reponame` prior to using the machine, you could use the following command:
  
  `sudo yum-config-manager --disable reponame`
    
  Base64 encoding can be done with a with a tool such as [this](https://www.base64encode.org/) or a linux command such as:
  
  `echo "sudo yum-config-manager --disable reponame" | base64`
  
  With the base64 prefix this would then look like this:

  `setup.script: data:text/plain;base64,c3VkbyB5dW0tY29uZmlnLW1hbmFnZXIgLS1kaXNhYmxlIHJlcG9uYW1l`

  The `setup.script` can also take [FreeMarker](http://freemarker.org/) variables in a `setup.script.vars`
  property. Variables are set in the format `key1:value1,key2:value2` and used in the form `${key1}`. So for the above example:
  
  `setup.script.vars: repository:reponame`
  
  then
  
  `setup.script: data:sudo yum-config-manager --disable ${repository}`
  
  or encoded in base64:
  
  `setup.script: data:text/plain;base64,c3VkbyB5dW0tY29uZmlnLW1hbmFnZXIgLS1kaXNhYmxlICR7cmVwb3NpdG9yeX0=`
  
  This enables the name of the repository to be passed in to the script.

- Use `openIptables: true` to automatically configure `iptables`, to open the TCP ports required by
  the software process. One can alternatively use `stopIptables: true` to entirely stop the
  iptables service.

- Use Entity configuration flag `effector.add.openInboundPorts: true` to add an effector for opening ports in a cloud Security Group.
  The config is supported for all SoftwareProcessImpl implementations.

- Use `installDevUrandom: true` to fall back to using `/dev/urandom` rather than `/dev/random`. This setting
  is useful for cloud VMs where there is not enough random entropy, which can cause `/dev/random` to be
  extremely slow (causing `ssh` to be extremely slow to respond).

- Use `useJcloudsSshInit: false` to disable the use of the native jclouds support for initial commands executed 
  on the VM (e.g. for creating new users, setting root passwords, etc.). Instead, Brooklyn's ssh support will
  be used. Timeouts and retries are more configurable within Brooklyn itself. Therefore this option is particularly 
  recommended when the VM startup is unusual (for example, if guest customizations will cause reboots and/or will 
  change login credentials).

- Use `brooklyn.ssh.config.noDeleteAfterExec: true` to keep scripts on the server after execution.
  The contents of the scripts and the stdout/stderr of their execution are available in the Brooklyn web console,
  but sometimes it can also be useful to have them on the box.
  This setting prevents scripts executed on the VMs from being deleted on completion.
  Note that some scripts run periodically so this can eventually fill a disk; it should only be used for dev/test. 

###### Custom Template Options

jclouds supports many additional options for configuring how a virtual machine is created and deployed, many of which
are for cloud-specific features and enhancements. Brooklyn supports some of these, but if what you are looking for is
not supported directly by Brooklyn, we instead offer a mechanism to set any parameter that is supported by the jclouds
template options for your cloud.

Part of the process for creating a virtual machine is the creation of a jclouds `TemplateOptions` object. jclouds
providers extends this with extra options for each cloud - so when using the AWS provider, the object will be of
type `AWSEC2TemplateOptions`. By [examining the source code](https://jclouds.apache.org/reference/javadoc/2.0.x/org/jclouds/aws/ec2/compute/AWSEC2TemplateOptions.html),
you can see all of the options available to you.

The `templateOptions` config key takes a map. The keys to the map are method names, and Brooklyn will find the method on
the `TemplateOptions` instance; it then invokes the method with arguments taken from the map value. If a method takes a
single parameter, then simply give the argument as the value of the key; if the method takes multiple parameters, the
value of the key should be an array, containing the argument for each parameter.

For example, here is a complete blueprint that sets some AWS EC2 specific options:

    location: AWS_eu-west-1
    services:
    - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
      provisioning.properties:
        templateOptions:
          subnetId: subnet-041c8373
          mapNewVolumeToDeviceName: ["/dev/sda1", 100, true]
          securityGroupIds: ['sg-4db68928']

Here you can see that we set three template options:

- `subnetId` is an example of a single parameter method. Brooklyn will effectively try to run the statement
  `templateOptions.subnetId("subnet-041c88373");`
- `mapNewVolumeToDeviceName` is an example of a multiple parameter method, so the value of the key is an array.
  Brooklyn will effectively true to run the statement `templateOptions.mapNewVolumeToDeviceName("/dev/sda1", 100, true);`
- `securityGroupIds` demonstrates an ambiguity between the two types; Brooklyn will first try to parse the value as
  a multiple parameter method, but there is no method that matches this parameter. In this case, Brooklyn will next try
  to parse the value as a single parameter method which takes a parameter of type `List`; such a method does exist so
  the operation will succeed.

If the method call cannot be matched to the template options available - for example if you are trying to set an AWS EC2
specific option but your location is an OpenStack cloud - then a warning is logged and the option is ignored.

###### Cloud Machine Naming

The name that Apache Brooklyn generates for your virtual machine will, by default, be based on your Apache Brooklyn server name and the IDs of the entities involved. This is the name you see in places such as the AWS console and will look something like:

    brooklyn-o8jql4-machinename-rkix-tomcat-wi-nca6-14b

If you have created a lot of virtual machines, this kind of naming may not be helpful. This can be changed using the following YAML in your location's `brooklyn.config`:

    cloudMachineNamer: org.apache.brooklyn.core.location.cloud.names.CustomMachineNamer
    custom.machine.namer.machine: My-Custom-Name-${entity.displayName}

A [FreeMarker](http://freemarker.org/) format is used in `custom.machine.namer.machine` which can take values from places such as the launching entity or location.

The above example will create a name such as:

    My-Custom-Name-Tomcat
    
Allowing you to more easily identify your virtual machines.

### More Details on Specific Clouds

Clouds vary in the format of the identity, credential, endpoint, and region.
Some also have their own idiosyncracies.  More details for configuring some common clouds
is included below. You may also find these sources helpful:

* The **[template brooklyn.properties]({{ book.path.guide }}/start/brooklyn.properties)** file
  in the Getting Started guide
  contains numerous examples of configuring specific clouds,
  including the format of credentials and options for sometimes-fiddly private clouds.
* The **[jclouds guides](https://jclouds.apache.org/guides)** describes low-level configuration
  sometimes required for various clouds.
