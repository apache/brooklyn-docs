---
title: WinRM4j Troubleshooting
layout: website-normal
---

Note: in addition to the Windows-specific points here,
much of the [operations troubleshooting guide]({{book.path.docs}}/ops/troubleshooting/index.md) is applicable for Windows blueprints. 


### WinRM Basics

If you can't get WinRM to work at all, see the notes on [the Winrm4j client](client.md) which includes detailed troubleshooting
for basic connectivity.


### User metadata service requirement

WinRM requires activation and configuration before it will work in a standard Windows Server deployment. To automate
this, Brooklyn will place a setup script in the user metadata blob. Services such as Amazon EC2's `Ec2ConfigService`
will automatically load and execute this script. If your chosen cloud provider does not support `Ec2ConfigService` or
a similar package, or if your cloud provider does not support user metadata, then you must pre-configure a Windows image
with the required WinRM setup and make Brooklyn use this image.

If the configuration options `userMetadata` or `userMetadataString` are used on the location, then this will override
the default setup script. This allows one to supply a custom setup script. However, if userMetadata contains something
else then the setup will not be done and the VM may not not be accessible remotely over WinRM.


### Credentials and privileges requiring special configuration

When a script is run over WinRM over HTTP, the credentials under which the script are run are marked as
'remote' credentials, which are prohibited from running certain security-related operations. This may prevent certain
operations. The installer from Microsoft SQL Server is known to fail in this case, for example. For a workaround, please
refer to [How and Why to re-authenticate withing a PowerShell script](tips.md#how-and-why-to-re-authenticate-within-a-powershell-script) 
above.

In some cases where security-related operation are to be executed, it may require the use of `CredSSP` to obtain
the correct Administrator privileges: you may otherwise get an access denied error. See the sub-section
[How and Why to re-authenticate within a powershell script](#how-and-why-to-re-authenticate-within-a-powershell-script) for more details.


### WebServiceException: Could not send Message

We detected a `WebServiceException` and different `SocketException`
during deployment of long-lasting Application Blueprint against VcloudDirector.

Launching the blueprint below was giving constantly this type of error on launch step.

    services:
      type: org.apache.brooklyn.entity.software.base.VanillaWindowsProcess
      brooklyn.config:
        pre.install.command: echo preInstallCommand
        install.command: echo installCommand > C:\\install.txt
        post.install.command: echo postInstallCommand
        customize.command: echo customizeCommand
        pre.launch.command: echo preLaunchCommand
        launch.powershell.command: |
          Start-Sleep -s 400
          Write-Host Test Completed
        post.launch.command: echo postLaunchCommand
        checkRunning.command: echo checkRunningCommand
        stop.command: echo stopCommand
        
With series of tests we concluded that on the Vcloud Director environment we were using
a restart was happening about 2 minutes after the VM is provisioned.
Logging in the host and search for System event of type 1074 in Windows Event Viewer, we found two 1074 events where the second one was

    The process C:\Windows\system32\winlogon.exe (W2K12-STD) has initiated the restart of computer WIN-XXXX on behalf of user
    NT AUTHORITY\SYSTEM for the following reason: Operating System: Upgrade (Planned) Reason Code: 0x80020003 Shutdown Type: restart Comment:

Normally on other clouds only one restart event is registered and the first time WinRM connection is made the Windows VM is ready for use. 

For this particular case when you want this second restart to finish we made `waitWindowsToStart` location parameter
which basically adds additional check assuring the Windows VM provisioning is done.


For example when using `waitWindowsToStart: 5m` location parameter, Apache Brooklyn will wait 5 minutes to see if a disconnect occurs.
If it does, then it will again wait 5m for the machine to come back up.
The default behaviour in Apache Brooklyn is to consider provisioning done on the first successful WinRM connection, without waiting for restart. 


To determine whether you should use this parameter you should carefully inspect how the image you choose to provision is behaving.
If the description above matches your case and you are getting **connection failure message in the middle of the installation process** for your blueprints,
a restart probably occurred and you should try this parameter.

Before using this parameter we advice to check whether this is really your case.


### AMIs not found

If using the imageId of a Windows community AMI, you may find that the AMI is deleted after a few weeks.
See [Windows AMIs on AWS](#windows-amis-on-aws) above.


### VM Provisioning Times Out

In some environments, provisioning of Windows VMs can take a very long time to return a usable VM.
If the image is old, it may install many security updates (and reboot several times) before it is
usable.

On a VMware vCloud Director environment, the guest customizations can cause the VM to reboot (sometimes
several times) before the VM is usable.

This could cause the WinRM connection attempts to timeout. The location configuration option 
`waitForWinRmAvailable` defaults to `30m` (i.e. 30 minutes). This can be increased if required.

Incorrectly prepared Windows templates can cause the deployment to time-out expecting an interaction by the user.
You can verify if this is the case by RDPing to the in-progress deployment.
It is recommended that any new Windows template be tested with a manually deployment to verify that it can be
used for unattended installations and it doesn't wait and/or require an input by the user.
See [Windows template settings for an Unattended Installation](limitations.md#windows-template-settings-for-an-unattended-installation) under Known Limitations below. 


### Windows log files

Details of the commands executed, and their results, can be found in the Brooklyn log and in the Brooklyn 
web-console's activity view. 

There will also be log files on the Windows Server. System errors in Windows are usually reported in the Windows Event Log -  
see [https://technet.microsoft.com/en-us/library/cc766042.aspx](https://technet.microsoft.com/en-us/library/cc766042.aspx) 
for more information.

Additional logs may be created by some Windows programs. For example, MSSQL creates a log in 
`%programfiles%\Microsoft SQL Server\130\Setup Bootstrap\Log\` - for more information see 
[https://msdn.microsoft.com/en-us/library/ms143702.aspx](https://msdn.microsoft.com/en-us/library/ms143702.aspx).


### WinRM Commands Fail on Java Version 8u161

As described in bug [BROOKLYN-592](https://issues.apache.org/jira/browse/BROOKLYN-592),
WinRM commands in an entity fail for certain versions of Java 8 (from 8u161, fixed in 8u192).

This is caused by the Java bug [JDK-8196491](https://bugs.openjdk.java.net/browse/JDK-8196491).

The error within Brooklyn will look like:

```
org.apache.brooklyn.util.core.internal.winrm.WinRmException: (Administrator@52.87.226.190:5985) : failed to execute command: SOAPFaultException: Marshalling Error: Entity References are not allowed in SOAP documents
	at org.apache.brooklyn.util.core.internal.winrm.winrm4j.Winrm4jTool.propagate(Winrm4jTool.java:257)
	at org.apache.brooklyn.util.core.internal.winrm.winrm4j.Winrm4jTool.exec(Winrm4jTool.java:214)
	at org.apache.brooklyn.util.core.internal.winrm.winrm4j.Winrm4jTool.executeCommand(Winrm4jTool.java:117)
    ...
Caused by: java.lang.UnsupportedOperationException: Entity References are not allowed in SOAP documents
	at com.sun.xml.internal.messaging.saaj.soap.SOAPDocumentImpl.createEntityReference(SOAPDocumentImpl.java:148)
    ...
```

The workaround is to downgrade Java to 8u151 or similar, or upgrade to 8u192 or later.


