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
