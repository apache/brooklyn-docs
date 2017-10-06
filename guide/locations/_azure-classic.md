---
section: Azure Compute Classic
section_type: inline
section_position: 3
---

### Azure Compute Classic
 
Azure is a cloud computing platform and infrastructure created by Microsoft. Apache Brooklyn includes support for both Azure Classic and Azure ARM, as
one of the [Apache jclouds](http://jclouds.org) supported clouds `Microsoft Azure Compute`.

The two modes of using Azure are the "classic deployment" model and the newer "Azure Resource Manager" (ARM)
model. See [https://azure.microsoft.com/en-gb/documentation/articles/resource-manager-deployment-model/](https://azure.microsoft.com/en-gb/documentation/articles/resource-manager-deployment-model/)
for details.


#### Setup the Azure credentials

Microsoft Azure requests are signed by SSL certificate. You need to upload one into your account in order to use an Azure
location.

```bash
# create the certificate request
mkdir -m 700 $HOME/.brooklyn
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $HOME/.brooklyn/azure.pem -out $HOME/.brooklyn/azure.pem
# create the p12 file, and note your export password. This will be your test credentials.
openssl pkcs12 -export -out $HOME/.brooklyn/azure.p12 -in $HOME/.brooklyn/azure.pem -name "brooklyn :: $USER"
# create a cer file
openssl x509 -inform pem -in $HOME/.brooklyn/azure.pem -outform der -out $HOME/.brooklyn/azure.cer
```

Finally, upload .cer file to the management console at https://manage.windowsazure.com/@myId#Workspaces/AdminTasks/ListManagementCertificates to authorize this certificate.

Please note, you can find the "myId" value for this link by looking at the URL when logged into the Azure management portal.

**Note**, you will need to use `.p12` format in the `brooklyn.properties`.


#### How to configure Apache Brooklyn to use Azure Compute

First, in your `brooklyn.properties` define a location as follows:

```properties
brooklyn.location.jclouds.azurecompute.identity=$HOME/.brooklyn/azure.p12
brooklyn.location.jclouds.azurecompute.credential=<P12_EXPORT_PASSWORD>
brooklyn.location.jclouds.azurecompute.endpoint=https://management.core.windows.net/<YOUR_SUBSCRIPTION_ID>
brooklyn.location.jclouds.azurecompute.vmNameMaxLength=45
brooklyn.location.jclouds.azurecompute.jclouds.azurecompute.operation.timeout=120000
brooklyn.location.jclouds.azurecompute.user=<USER_NAME>
brooklyn.location.jclouds.azurecompute.password=<PASSWORD>
```

During the VM provisioning, Azure will set up the account with `<USER_NAME>` and `<PASSWORD>` automatically.
Notice, `<PASSWORD>` must be a minimum of 8 characters and must contain 3 of the following: a lowercase character, an uppercase
character, a number, a special character.

To force Apache Brooklyn to use a particular image in Azure, say Ubuntu 14.04.1 64bit, one can add:

    brooklyn.location.jclouds.azurecompute.imageId=b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_1-LTS-amd64-server-20150123-en-us-30GB

From $BROOKLYN_HOME, you can list the image IDs available using the following command:

    ./bin/client "list-images --location azure-west-europe"

To force Brooklyn to use a particular hardwareSpec in Azure, one can add something like:

    brooklyn.location.jclouds.azurecompute.hardwareId=BASIC_A2

From $BROOKLYN_HOME, you can list the hardware profile IDs available using the following command:

    ./bin/client "list-hardware-profiles --location azure-west-europe"

At the time of writing, the classic deployment model has the possible values shown below.
See https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-size-specs/
for further details, though that description focuses on the new "resource manager deployment"
rather than "classic".

 * `Basic_A0` to `Basic_A4`
 * `Standard_D1` to `Standard_D4`
 * `Standard_G1` to `Standard_G5`
 * `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge`


##### Named location

For convenience, you can define a named location, like:

```properties
brooklyn.location.named.azure-west-europe=jclouds:azurecompute:West Europe
brooklyn.location.named.azure-west-europe.displayName=Azure West Europe
brooklyn.location.named.azure-west-europe.imageId=b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_1-LTS-amd64-server-20150123-en-us-30GB
brooklyn.location.named.azure-west-europe.hardwareId=BASIC_A2
brooklyn.location.named.azure-west-europe.user=test
brooklyn.location.named.azure-west-europe.password=MyPassword1!
```

This will create a location named `azure-west-europe`. It will inherit all the configuration
defined on `brooklyn.location.jclouds.azurecompute`. It will also augment and override this
configuration (e.g. setting the display name, image id and hardware id).

On Linux VMs, The `user` and `password` will create a user with that name and set its password,
disabling the normal login user and password defined on the `azurecompute` location.


#### Windows VMs on Azure

The following configuration options are important for provisioning Windows VMs in Azure:

* `osFamily: windows` tells Apache Brooklyn to consider it as a Windows machine

* `useJcloudsSshInit: false` tells jclouds to not try to connect to the VM

* `vmNameMaxLength: 15` tells the cloud client to strip the VM name to maximum 15 characters. 
  This is the maximum size supported by Azure Windows VMs.

* `winrm.useHttps` tells Apache Brooklyn to configure the WinRM client to use HTTPS.
  
  This is currently not supported in the default configuration for other clouds, where
  Apache Brooklyn is deploying Windows VMs.

  If the parameter value is `false` the default WinRM port is 5985; if `true` the default port 
  for WinRM will be 5986. Use of default ports is stongly recommended.

* `winrm.useNtlm` tells Apache Brooklyn to configure the WinRM client to use NTLM protocol.

  For Azure, this is mandatory.
  
  For other clouds, this value is used in the cloud init script to configure WinRM on the VM.   
  If the value is `true` then Basic Authentication will be disabled and the WinRM client will only use Negotiate plus NTLM.  
  If the value is `false` then Basic Authentication will be enabled and the WinRM client will use Basic Authentication.

  NTLM is the default Authentication Protocol.

  The format of this configuration option is subject to change: WinRM supports several 
  authentication mechanisms, so this may be changed to a prioritised list so as to
  provide fallback options.

* `user` tells Apache Brooklyn which user to login as. The value should match that supplied 
  in the `overrideLoginUser` of the `templateOptions`.

* `password`: tells Apache Brooklyn the password to use when connecting. The value should
  match that supplied in the `overrideLoginPassword` of the `templateOptions`.

* `templateOptions: { overrideLoginUser: adminuser, overrideLoginPassword: Pa55w0rd! }`  
  tells the Azure Cloud to provision a VM with the given admin username and password. Note that
  no "Administrator" user will be created.
  
  If this config is not set then the VM will have a default user named "jclouds" with password 
  "Azur3Compute!". It is **Strongly Recommended** that these template options are set.

  **Notice**: one cannot use `Administrator` as the user in Azure.

  This configuration is subject to change in future releases.


###### Sample Windows Blueprint

Below is an example for provisioning a Windows-based entity on Azure. Note the placeholder values 
for the identity, credential and password.

```yaml
name: Windows Test @ Azure
location:
  jclouds:azurecompute:West Europe:
    identity: /home/users/brooklyn/.brooklyn/azure.p12
    credential: xxxxxxxp12
    endpoint: https://management.core.windows.net/12345678-1234-1234-1234-123456789abc
    imageId: 3a50f22b388a4ff7ab41029918570fa6__Windows-Server-2012-Essentials-20141204-enus
    hardwareId: BASIC_A2
    osFamily: windows
    useJcloudsSshInit: false
    vmNameMaxLength: 15
    winrm.useHttps: true
    user: brooklyn
    password: secretPass1!
    templateOptions:
      overrideLoginUser: brooklyn
      overrideLoginPassword: secretPass1!
services:
- type: org.apache.brooklyn.entity.software.base.VanillaWindowsProcess
  brooklyn.config:
    install.command: echo install phase
    launch.command: echo launch phase
    checkRunning.command: echo launch phase
```

Below is an example named location for Azure, configured in `brooklyn.properties`. Note the 
placeholder values for the identity, credential and password.

```properties
brooklyn.location.named.myazure=jclouds:azurecompute:West Europe
brooklyn.location.named.myazure.displayName=Azure West Europe (windows)
brooklyn.location.named.myazure.identity=$HOME/.brooklyn/azure.p12
brooklyn.location.named.myazure.credential=<P12_EXPORT_PASSWORD>
brooklyn.location.named.myazure.endpoint=https://management.core.windows.net/<YOUR_SUBSCRIPTION_ID>
brooklyn.location.named.myazure.vmNameMaxLength=15
brooklyn.location.named.myazure.jclouds.azurecompute.operation.timeout=120000
brooklyn.location.named.myazure.imageId=3a50f22b388a4ff7ab41029918570fa6__Windows-Server-2012-Essentials-20141204-enus
brooklyn.location.named.myazure.hardwareId=BASIC_A2
brooklyn.location.named.myazure.osFamily=windows
brooklyn.location.named.myazure.useJcloudsSshInit=false
brooklyn.location.named.myazure.winrm.useHttps=true
brooklyn.location.named.myazure.user=brooklyn
brooklyn.location.named.myazure.password=secretPass1!
brooklyn.location.named.myazure.templateOptions={ overrideLoginUser: amp, overrideLoginPassword: secretPass1! }
```

###### User and Password Configuration

As described under the configuration options, the username and password must be explicitly supplied
in the configuration.

This is passed to the Azure Cloud during provisioning, to create the required user. These values 
correspond to the options `AdminUsername` and `AdminPassword` in the Azure API.

If a hard-coded password is not desired, then within Java code a random password could be 
auto-generated and passed into the call to `location.obtain(Map<?,?>)` to override these values.

This approach differs from the behaviour of clouds like AWS, where the password is auto-generated 
by the cloud provider and is then retrieved via the cloud provider's API after provisioning the VM.


###### WinRM Configuration

The WinRM initialization in Azure is achieved through configuration options in the VM provisioning request.
The required configuration is to enabled HTTPS (if Azure is told to use http, the VM comes pre-configured 
with WinRM encrypted over HTTP). The default is then to support NTLM protocol.

The setup of Windows VMs on Azure differs from that on other clouds, such as AWS. In contrast, on AWS an 
init script is passed to the cloud API to configure WinRM appropriately.

_Windows initialization scripts in Azure are unfortunately not supported in "classic deployment"  
model, but are available in the newer "resource manager deployment" model as an "Azure VM Extension"._
