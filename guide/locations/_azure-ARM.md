---
section: Azure Compute ARM
section_type: inline
section_position: 2
---

### Azure Compute ARM

Azure Resource Manager (ARM) is a framework for deploying and managing applications across resources and managing groups of resources as single logical units on the Microsoft Azure cloud computing platform.

#### Setup the Azure credentials

Firstly, install and configure Azure CLI following [these steps](https://docs.microsoft.com/en-us/azure/cli-install-nodejs).

Using the Azure CLI, run the following commands to create a service principal

    # Set mode to ARM
    azure config mode arm
    
    # Enter your Microsoft account credentials when prompted
    azure login
    
    # Set current subscription to create a service principal
    azure account set <Subscription-id>
    
    # Create an AAD application with your information.
    azure ad app create --name <name> --password <Password> --home-page <home-page> --identifier-uris <identifier-uris>
    
    # For example: azure ad app create --name "myappname"  --password abcd --home-page "https://myappwebsite" --identifier-uris "https://myappwebsite"
    
    # Output will include a value for `Application Id`, which will be used for the live tests
    
    # Create a Service Principal
    azure ad sp create --applicationId <Application-id>
    
    # Output will include a value for `Object Id`, to be used in the next step 


Run the following commands to assign roles to the service principal

    # Assign roles for this service principal
    azure role assignment create --objectId <Object-id> -o Contributor -c /subscriptions/<Subscription-id>/

Look up the the tenant Id

    azure account show -s <Subscription-id> --json

    # output will be a JSON which will include the `Tenant id`

Verify service principal

    azure login -u <Application-id> -p <Password> --service-principal --tenant <Tenant-id>

#### Using the Azure ARM Location

Below is an example Azure ARM location in YAML which will launch a Ubuntu instance in south east asia:

    brooklyn.catalog:
      id: my-azure-arm-location
      name: "My Azure ARM location"
      itemType: location
      item:
        type: jclouds:azurecompute-arm
        brooklyn.config:
          identity: <Application-id>
          credential: <Password>
          endpoint: https://management.azure.com/subscriptions/<Subscription-id>
          oauth.endpoint: https://login.microsoftonline.com/<Tenant-id>/oauth2/token
      
          jclouds.azurecompute.arm.publishers: OpenLogic
          region: southeastasia
          loginUser: brooklyn
          templateOptions:
            overrideAuthenticateSudo: true 

Fill the values `<Application-id>`, `<Password>`, `<Subscription-id>` and `<Tenant-id>` in from the values generated when 
setting up your credentials. In addition; several keys, not required in other locations need to be specified in order to 
use the Azure Compute ARM location. These are:

    jclouds.azurecompute.arm.publishers: OpenLogic

The publishers is any item from the list available here: [https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-cli-ps-findimage](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-cli-ps-findimage)
    
    region: southeastasia    

The region is any region from the list available here: [https://azure.microsoft.com/en-us/regions/](https://azure.microsoft.com/en-us/regions/)

    loginUser: brooklyn
        
The loginUser can be anything, as long as it's specified. 

    templateOptions:
        overrideAuthenticateSudo: true

The `overrideAuthenticateSudo: true` key tells Apache Brooklyn that default on Azure images do not have passwordless sudo 
configured by default.

#### Using Windows on Azure ARM

This section contains material how to create a Windows location on Azure ARM. Some of the used parameters are explained in the section above.

Windows on Azure ARM requires manually created [Azure KeyVault](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-get-started)
Azure KeyVaults can be created [via Azure cli](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-manage-with-cli2#create-a-key-vault)
or [Azure portal UI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-keyvault-parameter). KeyVault's secret is a key
stored in protected .PFX file. It needs to be prepared upfront or created with the [Add-AzureKeyVaultKey](https://docs.microsoft.com/en-us/powershell/module/azurerm.keyvault/add-azurekeyvaultkey?view=azurermps-4.0.0) cmdlet.

* `osFamily: windows` tells Apache Brooklyn to consider it as a Windows machine

* `useJcloudsSshInit: false` tells jclouds to not try to connect to the VM

* `vmNameMaxLength: 15` tells the cloud client to strip the VM name to maximum 15 characters.
  This is the maximum size supported by Azure Windows VMs.

* `winrm.useHttps` tells Apache Brooklyn to configure the WinRM client to use HTTPS.

* `secrets` Specifies the KeyVault configuration

  `sourceVault` Resource `id` of the KeyVault

   `vaultCertificates` `certificateStore` has to use `My` as a value.
    KeyVault's `certificateUrl`. An URI to the [Secret Identifier](https://docs.microsoft.com/en-us/rest/api/keyvault/about-keys--secrets-and-certificates#BKMK_DataTypes)

* `windowsConfiguration`

   `provisionVMAgent` whether Azure to install an agent on the VM. It must be set to `true`

   `winRM` It defines the `listeners` section. If `listeners` is `https` then `certificateUrl` needs to be set. Its value must match the one of `secrets`'s `certificateUrl`.

* `additionalUnattendContent` Additional content. Normally it can be defined as `null`

* `enableAutomaticUpdates` whether to enable the automatic windows updates. It can be set to `false`, if automatic updates are not desired

###### Sample Windows Blueprint

Placeholders surrounded with `<>` have to be replcaced with their respective values.

{% highlight yaml %}
brooklyn.catalog:
  id: my-azure-arm-location
  name: "My Azure ARM location"
  itemType: location
  item:
    type: jclouds:azurecompute-arm
    brooklyn.config:
      identity: <Application-id>
      credential: <Password>
      endpoint: https://management.azure.com/subscriptions/<Subscription-id>
      oauth.endpoint: https://login.microsoftonline.com/<Tenant-id>/oauth2/token
      jclouds.azurecompute.arm.publishers: MicrosoftWindowsServer
      jclouds.azurecompute.operation.timeout: 120000

      winrm.useHttps: true
      osFamily: windows
      imageId: <Azure_location>/MicrosoftWindowsServer/WindowsServer/2012-R2-Datacenter
      region: <Azure_location>
      vmNameMaxLength: 15
      useJcloudsSshInit: false
      destroyOnFailure: false

      templateOptions:
        overrideLoginUser: brooklyn
        overrideLoginPassword: "secretPass1!"
        secrets:
        - sourceVault:
            id: "/subscriptions/<Subscription-id>/resourceGroups/<ResourceGroup>/providers/Microsoft.KeyVault/vaults/<KeyVault-name>"
          vaultCertificates:
          - certificateUrl: "<KeyVault-uri>"
            certificateStore: My
        windowsConfiguration:
          provisionVMAgent: true
          winRM:
            listeners:
            - protocol: https
              certificateUrl: "<KeyVault-uri>"
          additionalUnattendContent: null
          enableAutomaticUpdates: true
{% endhighlight %}

#### Known issues
There are currently two known issues with Azure ARM:

* It can take a long time for VMs to be provisioned
* The Azure ARM APIs appear to have some fairly strict rate limiting that can result in AzureComputeRateLimitExceededException