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
