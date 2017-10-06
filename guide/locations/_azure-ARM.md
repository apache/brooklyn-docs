---
section: Azure Compute ARM
section_type: inline
section_position: 2
---

### Azure Compute ARM

Azure Resource Manager (ARM) is a framework for deploying and managing applications across resources and managing groups of resources as single logical units on the Microsoft Azure cloud computing platform.

#### Setup the Azure credentials

##### Azure CLI 2.0

Firstly, install and configure Azure CLI following [these steps](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

You will need to obtain your *subscription ID* and *tenant ID* from Azure. To do this using the CLI, first, log in:

    az login

Or, if you are already logged in, request an account listing:

    az account list

In either case, this will return a subscription listing, similar to that shown below.

    [
      {
        "cloudName": "AzureCloud",
        "id": "012e832d-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "isDefault": true,
        "name": "QA Team",
        "state": "Enabled",
        "tenantId": "ba85e8cd-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "user": {
          "name": "qa@example.com",
          "type": "user"
        }
      },
      {
        "cloudName": "AzureCloud",
        "id": "341751b0-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "isDefault": false,
        "name": "Developer Team",
        "state": "Enabled",
        "tenantId": "ba85e8cd-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "user": {
          "name": "dev@example.com",
          "type": "user"
        }
      }
    ]

Choose one of the subscriptions and make a note of its *id* - henceforth the subscription ID - and the *tenantId*.

Next we need to create an *application* and a *service principle*, and grant permissions to the service principle. Use these commands:

    # Create an AAD application with your information.
    az ad app create --display-name <name> --password <Password> --homepage <home-page> --identifier-uris <identifier-uris>
    
    # For example: az ad app create --display-name "myappname"  --password abcd --homepage "https://myappwebsite" --identifier-uris "https://myappwebsite"

Take a note of the *appId* shown.

    # Create a Service Principal
    az ad sp create --id <Application-id>

Take a note of the *objectId* shown - this will be the service principal object ID. (Note that any of the *servicePrincipalNames* can also be used in place of the object ID.)

    # Assign roles for this service principal. The "principal" can be the "objectId" or any one of the "servicePrincipalNames" from the previous step
    az role assignment create --assignee <Service-Principal> --role Contributor --scope /subscriptions/<Subscription-ID>/

By this stage you should have the following information:

* A subscription ID
* A tenant ID
* An application ID
* A service principle (either by its object ID, or by any one of its names)

We can now verify this information that this information can be used to log in to Azure:

    az login --service-principal -u <Application-ID> --password abcd --tenant <Tenant-ID>

##### Azure CLI 1.0

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

#### Useful configuration options for Azure ARM

You can add these options directly under the `brooklyn.config` element in the example above:

* `jclouds.compute.resourcename-prefix` and `jclouds.compute.resourcename-delimiter` - defaults to `jclouds` and `-` respectively. If jclouds is choosing the name for a resource (for example, a virtual machine), these properties will alter the way the resource is named.

You can add these options into the `templateOptions` element inside the `brooklyn.config` element in the example above:

* `resourceGroup` - select a Resource Group to deploy resources into. If not given, jclouds will generate a new resource group with a partly-random name.

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

```yaml
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
```

#### Known issues
There are currently two known issues with Azure ARM:

* It can take a long time for VMs to be provisioned
* The Azure ARM APIs appear to have some fairly strict rate limiting that can result in AzureComputeRateLimitExceededException
