---
title: Windows Blueprints
layout: website-normal
children:
- client.md
---
# {{ page.title }}

Brooklyn can deploy to Windows servers using WinRM to run commands. These deployments can be 
expressed in pure YAML, and utilise Powershell to install and manage the software process. 
This approach is similar to the use of SSH for UNIX-like servers.


About WinRM
-----------

WinRM - or *Windows Remote Management* to give its full title - is a system administration service provided in all
recent Windows Server operating systems. It allows remote access to system information (provided via WMI) and the
ability to execute commands. For more information refer to [Microsoft's MSDN article on Windows Remote
Management](https://msdn.microsoft.com/en-us/library/aa384426(v=vs.85).aspx).

WinRM is available by default in Windows Server, but is not enabled by default. Brooklyn will, in most cases, be able
to switch on WinRM support, but this is dependent on your cloud provider supporting a user metadata service with script
execution (see [below](#user-metadata-service-requirement)).


Locations for Windows
---------------------

You must define a new location in Brooklyn for Windows deployments. Windows deployments require a different VM image
ID to Linux, as well as some other special configuration, so you must have separate Brooklyn locations for Windows and
Linux deployments.

In particular, you will most likely want to set these properties on your location:

* `imageId` or `imageNameRegex` - select your preferred Windows Server image from your cloud provider.
* `hardwareId` or `minRam`/`minCores` - since Windows machines generally require more powerful servers, ensure you get
  a machine with the required specification.
* `useJcloudsSshInit` - this must be set to `false`. Without this setting, jclouds will attempt to connect to the new
  VMs using SSH, which will fail on Windows Server.
* `templateOptions` - you may also wish to request a larger disk size. This setting is cloud specific; on AWS, you can
  request a 100GB disk by setting this property to `{mapNewVolumeToDeviceName: ["/dev/sda1", 100, true]}`.

In your YAML blueprint:

    ...
    location:
      jclouds:aws-ec2:
        region: us-west-2
        identity: AKA_YOUR_ACCESS_KEY_ID
        credential: <access-key-hex-digits>
        imageNameRegex: Windows_Server-2012-R2_RTM-English-64Bit-Base-.*
        imageOwner: 801119661308
        hardwareId: m3.medium
        useJcloudsSshInit: false
        templateOptions: {mapNewVolumeToDeviceName: ["/dev/sda1", 100, true]}
    ...

Alternatively, you can define a new named location in `brooklyn.properties`:

    brooklyn.location.named.AWS\ Oregon\ Win = jclouds:aws-ec2:us-west-2
    brooklyn.location.named.AWS\ Oregon\ Win.displayName = AWS Oregon (Windows)
    brooklyn.location.named.AWS\ Oregon\ Win.imageNameRegex = Windows_Server-2012-R2_RTM-English-64Bit-Base-.*
    brooklyn.location.named.AWS\ Oregon\ Win.imageOwner = 801119661308
    brooklyn.location.named.AWS\ Oregon\ Win.hardwareId = m3.medium
    brooklyn.location.named.AWS\ Oregon\ Win.useJcloudsSshInit = false
    brooklyn.location.named.AWS\ Oregon\ Win.templateOptions = {mapNewVolumeToDeviceName: ["/dev/sda1", 100, true]}



A Sample Blueprint
------------------

Creating a Windows VM is done using the `org.apache.brooklyn.entity.software.base.VanillaWindowsProcess` entity type. This is very similar
to `VanillaSoftwareProcess`, but adapted to work for Windows and WinRM instead of Linux. We suggest you read the
[documentation for VanillaSoftwareProcess]({{ book.path.guide }}/blueprints/custom-entities.html#vanilla-software-using-bash) to find out what you
can do with this entity.

Entity authors are strongly encouraged to write Windows Powershell or Batch scripts as separate 
files, to configure these to be uploaded, and then to configure the appropriate command as a 
single line that executes given script.

For example - here is a simplified blueprint (but see [Tips and Tricks](#tips-and-tricks) below!):

    name: Server with 7-Zip

    location:
      jclouds:aws-ec2:
        region: us-west-2
        identity: AKA_YOUR_ACCESS_KEY_ID
        credential: <access-key-hex-digits>
        imageNameRegex: Windows_Server-2012-R2_RTM-English-64Bit-Base-.*
        imageOwner: 801119661308
        hardwareId: m3.medium
        useJcloudsSshInit: false
        templateOptions: {mapNewVolumeToDeviceName: ["/dev/sda1", 100, true]}

    services:
    - type: org.apache.brooklyn.entity.software.base.VanillaWindowsProcess
      brooklyn.config:
        templates.preinstall:
          file:///Users/richard/install7zip.ps1: "C:\\install7zip.ps1"
        install.command: powershell -command "C:\\install7zip.ps1"
        customize.command: echo true
        launch.command: echo true
        stop.command: echo true
        checkRunning.command: echo true
        installer.download.url: http://www.7-zip.org/a/7z938-x64.msi

The installation script - referred to as `/Users/richard/install7zip.ps1` in the example above - is:

    $Path = "C:\InstallTemp"
    New-Item -ItemType Directory -Force -Path $Path

    $Url = "${config['installer.download.url']}"
    $Dl = [System.IO.Path]::Combine($Path, "installer.msi")
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile( $Url, $Dl )

    Start-Process "msiexec" -ArgumentList '/qn','/i',$Dl -RedirectStandardOutput ( [System.IO.Path]::Combine($Path, "stdout.txt") ) -RedirectStandardError ( [System.IO.Path]::Combine($Path, "stderr.txt") ) -Wait

Where security-related operation are to be executed, it may require the use of `CredSSP` to obtain
the correct Administrator privileges: you may otherwise get an access denied error. See the sub-section 
[How and Why to re-authenticate within a powershell script](#how-and-why-to-re-authenticate-within-a-powershell-script) for more details.

This is only a very simple example. A more complex example can be found in the [Microsoft SQL Server blueprint in the
Brooklyn source code]({{ book.brooklyn.url.git }}/software/database/src/main/resources/org/apache/brooklyn/entity/database/mssql).


Tips and Tricks
---------------

The best practices for other entities (e.g. using [VanillaSoftwareProcess]({{ book.path.guide }}/blueprints/custom-entities.html#vanilla-software-using-bash))
apply for WinRM as well.

### Execution Phases

Blueprint authors are strongly encouraged to provide an implementation for install, launch, stop 
and checkRunning. These are vital for the generic effectors such as stopping and restarting the 
process.

### Powershell

Powershell commands can be supplied using config options such as `launch.powershell.command`.

This is an alternative to supplying a standard batch command using config such as `launch.command`.
For a given phase, only one of the commands (Powershell or Batch) should be supplied.

### Getting the Right Exit Codes

WinRM (or at least the chosen WinRM client!) can return a zero exit code even on error in certain 
circumstances. It is therefore advisable to follow the guidelines below.

*For a given command, write the Powershell or Batch script as a separate multi-command file. 
Upload this (e.g. by including it in the `files.preinstall` configuration). For the configuration
of the given command, execute the file.*

When you have a command inside the powershell script which want to report its non zero exiting, 
please consider adding a check for its exit code after it.
Example:

    & "C:\install.exe"
    If ($lastexitcode -ne 0) {
        exit $lastexitcode
    }

For Powershell files, consider including 

    $ErrorActionPreference = "Stop"

at the start of the file. 
`$ErrorActionPreference` Determines how Windows PowerShell responds to a non-terminating
error (an error that does not stop the cmdlet processing) at the
command line or in a script, cmdlet, or provider, such as the
errors generated by the Write-Error cmdlet.
https://technet.microsoft.com/en-us/library/hh847796.aspx

See [Incorrect Exit Codes](#incorrect-exit-codes) under Known Limitations below.

### Executing Scripts From Batch Commands

In a batch command, you can execute a batch file or Powershell file. For example:

    install.command: powershell -NonInteractive -NoProfile -Command "C:\\install7zip.ps1"

Or alternatively:

    install.command: C:\\install7zip.bat

### Executing Scripts From Powershell

In a Powershell command, you can execute a batch file or Powershell file. There are many ways
to do this (see official Powershell docs). For example:
 
    install.powershell.command: "& C:\\install7zip.ps1"

Or alternatively:

    install.powershell.command: "& C:\\install7zip.bat"

Note the quotes around the command. This is because the "&" has special meaning in a YAML value. 

### Parameterised Scripts

Calling parameterised Batch and Powershell scripts is done in the normal Windows way - see
offical Microsoft docs. For example:

    install.command: "c:\\myscript.bat myarg1 myarg2"

Or as a Powershell example:

    install.powershell.command: "& c:\\myscript.ps1 -key1 myarg1 -key2 myarg2"

It is also possible to construct the script parameters by referencing attributes of this or
other entities using the standard `attributeWhenReady` mechanism. For example:

    install.command: $brooklyn:formatString("c:\\myscript.bat %s", component("db").attributeWhenReady("datastore.url"))

### Powershell - Using Start-Process

When you are invoking a command from a powershell script with `Start-Process` cmdlet,
please use the `-Wait` and the `-PassThru` arguments.
Example `Start-Process C:\mycommand -Wait -PassThru`

Using `-Wait` guarantees that the script process and its children and thus the winrm session won't be terminated until it is finished.
`-PassThru` Returns a process object for each process that the cmdlet started. By default, this cmdlet does not generate any output.
See https://technet.microsoft.com/en-us/library/hh849848.aspx

### Rebooting

Where a reboot is required as part of the entity setup, this can be configured using
config like `pre.install.reboot.required` and `install.reboot.required`. If required, the 
installation commands can be split between the pre-install, install and post-install phases
in order to do a reboot at the appropriate point of the VM setup.

We Strongly recommend to **write blueprints in a way that they do NOT restart automatically windows** and
use one of the `pre.install.reboot.required` or `install.reboot.required` parameters to perform restart.

### Install Location

Blueprint authors are encouraged to explicitly specify the full path for file uploads, and 
for paths in their Powershell scripts (e.g. for installation, configuration files, log files, etc).

### How and Why to re-authenticate within a powershell script

Some installation scripts require the use of security-related operations. In some environments,  
these fail by default when executed over WinRM, even though the script may succeed when run locally   
(e.g. by using RDP to connect to the machine and running the script manually). There may be no  
clear indication from Windows why it failed (e.g. for MSSQL install, the only clue is a   
security exception in the installation log).

When a script is run over WinRM, the credentials under which the script are run are marked as
'remote' credentials, which are prohibited from running certain security-related operations. The 
solution is to obtain a new set of credentials within the script and use those credentials to 
required commands.

The WinRM client uses Negotiate+NTLM to authenticate against the machine.
This mechanism applies certain restrictions to executing commands on the windows host.

For this reason you should enable CredSSP on the windows host which grants all privileges available to the user.
 https://technet.microsoft.com/en-us/library/hh849719.aspx#sectionSection4

To use `Invoke-Command -Authentication CredSSP` the Windows Machine has to have:
- Up and running WinRM over http. The custom-enable-credssp.ps1 script enables winrm over http because `Invoke-Command` use winrm over http by default.
  Invoke-Command can be used with -UseSSL option but this will lead to modifying powershell scripts.
  With always enabling winrm over http on the host, blueprint's powershell scripts remain consistent and not depend on the winrm https/http environments.
  We hope future versions of winrm4j will support CredSSP out of the box and wrapping commands in Invoke-Command will not be needed.
- Added trusted host entries which will use Invoke-Command
- Allowed CredSSP

All the above requirements are enabled in Apache Brooklyn through [brooklyn-server/software/base/src/main/resources/org/apache/brooklyn/software/base/custom-enable-credssp.ps1](https://github.com/apache/brooklyn-server/blob/master/software/base/src/main/resources/org/apache/brooklyn/software/base/custom-enable-credssp.ps1)
script which enables executing commands with CredSSP in the general case.
The script works for most of the Windows images out there version 2008 and later.

Please ensure that Brooklyn's changes are compatible with your organisation's security policy.

Check Microsoft Documentation for more information about [Negotiate authenticate mechanism on technet.microsoft.com](https://msdn.microsoft.com/en-us/library/windows/desktop/aa378748(v=vs.85).aspx)

Re-authentication also requires that the password credentials are passed in plain text within the
script. Please be aware that it is normal for script files - and therefore the plaintext password - 
to be saved to the VM's disk. The scripts are also accessible via the Brooklyn web-console's 
activity view. Access to the latter can be controlled via 
[Entitlements]({{book.path.guide}}/blueprints/java/entitlements.html).

As an example (taken from MSSQL install), the command below works when run locally, but fails over 
WinRM:

    ( $driveLetter + "setup.exe") /ConfigurationFile=C:\ConfigurationFile.ini

The code below can be used instead (note this example uses Freemarker templating):

    & winrm set winrm/config/service/auth '@{CredSSP="true"}'
    & winrm set winrm/config/client/auth '@{CredSSP="true"}'
    #
    $pass = '${attribute['windows.password']}'
    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($($env:COMPUTERNAME + "\${location.user}"), $secpasswd)
    #
    $exitCode = Invoke-Command -ComputerName $env:COMPUTERNAME -Credential $mycreds -ScriptBlock {
        param($driveLetter)
        $process = Start-Process ( $driveLetter + "setup.exe") -ArgumentList "/ConfigurationFile=C:\ConfigurationFile.ini" -RedirectStandardOutput "C:\sqlout.txt" -RedirectStandardError "C:\sqlerr.txt" -Wait -PassThru -NoNewWindow
        $process.ExitCode
    } -Authentication CredSSP -ArgumentList $driveLetter
    #
    exit $exitCode

In this example, the `${...}` format is FreeMarker templating. Those sections will be substituted
before the script is uploaded for execution. To explain this example in more detail:

* `${attribute['windows.password']}` is substituted for the entity's attribute "windows.password".
  This (clear-text) password is sent as part of the script. Assuming that HTTPS and NTLM is used,
  the script will be encrypted while in-flight.

* The `${location.user}` gets (from the entity's machine location) the username, substituting this 
  text for the actual username. In many cases, this will be "Administrator". However, on some  
  clouds a different username (with admin privileges) will be used.

* The username and password are used to create a new credential object (having first converted the
  password to a secure string).

* Credential Security Service Provider (CredSSP) is used for authentication, to pass the explicit  
  credentials when using `Invoke-Command`.


### Windows AMIs on AWS

Windows AMIs in AWS change regularly (to include the latest Windows updates). If using the community
AMI, it is recommended to use an AMI name regex, rather than an image id, so that the latest AMI is 
always picked up. If an image id is used, it may fail as Amazon will delete their old Windows AMIs.

If using an image regex, it is recommended to include the image owner in case someone else uploads
a similarly named AMI. For example:

    brooklyn.location.named.AWS\ Oregon\ Win = jclouds:aws-ec2:us-west-2
    brooklyn.location.named.AWS\ Oregon\ Win.imageNameRegex = Windows_Server-2012-R2_RTM-English-64Bit-Base-.*
    brooklyn.location.named.AWS\ Oregon\ Win.imageOwner = 801119661308
    ...

## stdout and stderr in a Powershell script

When calling an executable in a Powershell script, the stdout and stderr will usually be output to the console.
This is captured by Brooklyn, and shown in the activities view under the specific tasks.

An alternative is to redirect stdout and stderr to a file on the VM, which can be helpful if one expects sys admins
to log into the VM. However, be warned that this would hide the stdout/stderr from Brooklyn's activities view.

For example, instead of running the following:

    D:\setup.exe /ConfigurationFile=C:\ConfigurationFile.ini

 The redirect can be achieved by using the `Start-Process` scriptlet:

    Start-Process D:\setup.exe -ArgumentList "/ConfigurationFile=C:\ConfigurationFile.ini" -RedirectStandardOutput "C:\sqlout.txt" -RedirectStandardError "C:\sqlerr.txt" -PassThru -Wait

The `-ArgumentList` is simply the arguments that are to be passed to the executable, `-RedirectStandardOutput` and
`RedirectStandardError` take file locations for the output (if the file already exists, it will be overwritten). The
`-PassThru` argument indicates that Powershell should write to the file *in addition* to the console, rather than
*instead* of the console. The `-Wait` argument will cause the scriptlet to block until the process is complete.

Further details can be found on the [Start-Process documentation page](https://technet.microsoft.com/en-us/library/hh849848.aspx)
on the Microsoft TechNet site.


Troubleshooting
---------------

Much of the [operations troubleshooting guide]({{ book.path.guide }}/ops/troubleshooting/) is applicable for Windows blueprints.  

### User metadata service requirement

WinRM requires activation and configuration before it will work in a standard Windows Server deployment. To automate
this, Brooklyn will place a setup script in the user metadata blob. Services such as Amazon EC2's `Ec2ConfigService`
will automatically load and execute this script. If your chosen cloud provider does not support `Ec2ConfigService` or
a similar package, or if your cloud provider does not support user metadata, then you must pre-configure a Windows image
with the required WinRM setup and make Brooklyn use this image.

If the configuration options `userMetadata` or `userMetadataString` are used on the location, then this will override
the default setup script. This allows one to supply a custom setup script. However, if userMetadata contains something
else then the setup will not be done and the VM may not not be accessible remotely over WinRM.

### Credentials issue requiring special configuration

When a script is run over WinRM over HTTP, the credentials under which the script are run are marked as
'remote' credentials, which are prohibited from running certain security-related operations. This may prevent certain
operations. The installer from Microsoft SQL Server is known to fail in this case, for example. For a workaround, please
refer to [How and Why to re-authenticate withing a powershell script](#how-and-why-to-re-authenticate-within-a-powershell-script) 
above.

### WebServiceException: Could not send Message

We detected a `WebServiceException` and different `SocketException`
during deployment of long lasting Application Blueprint against VcloudDirector.

Launching the blueprint bellow was giving constantly this type of error on launch step.

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
a restart was happening ~2 minutes after the VM is provisioned.
Logging in the host and search for System event of type 1074 in Windows Event Viewer, we found two 1074 events where the second one was

    The process C:\Windows\system32\winlogon.exe (W2K12-STD) has initiated the restart of computer WIN-XXXX on behalf of user
    NT AUTHORITY\SYSTEM for the following reason: Operating System: Upgrade (Planned) Reason Code: 0x80020003 Shutdown Type: restart Comment:

Normally on other clouds only one restart event is registered and the first time winrm connection is made the Windows VM is ready for use. 

For this particular case when you want this second restart to finish we made `waitWindowsToStart` location parameter
which basically adds additional check assuring the Windows VM provisioning is done.


For example when using `waitWindowsToStart: 5m` location parameter, Apache Brooklyn will wait 5 minutes to see if a disconnect occurs.
If it does, then it will again wait 5m for the machine to come back up.
The default behaviour in Apache Brooklyn is to consider provisioning done on the first successful winrm connection, without waiting for restart. 


To determine whether you should use this parameter you should carefully inspect how the image you choose to provision is behaving.
If the description above matches your case and you are getting **connection failure message in the middle of the installation process** for your blueprints,
a restart probably occurred and you should try this parameter.

Before using this parameter we advice to check whether this is really your case.
To verify the behavior check as described above.

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

Incorrectly prepared Windows template can cause the deployment to time-out expecting an interaction by the user.
You can verify if this is the case by RDP to the deployment which is taking to much time to complete. 
It is recommended to manually deploy a single VM for every newly created Windows template to verify that it can be
used for unattended installations and it doesn't wait and/or require an input by the user.
See [Windows template settings for an Unattended Installation](#windows-template-settings-for-an-unattended-installation) under Known Limitations below. 

### Windows log files

Details of the commands executed, and their results, can be found in the Brooklyn log and in the Brooklyn 
web-console's activity view. 

There will also be log files on the Windows Server. System errors in Windows are usually reported in the Windows Event Log -  
see [https://technet.microsoft.com/en-us/library/cc766042.aspx](https://technet.microsoft.com/en-us/library/cc766042.aspx) 
for more information.

Additional logs may be created by some Windows programs. For example, MSSQL creates a log in 
`%programfiles%\Microsoft SQL Server\130\Setup Bootstrap\Log\` - for more information see 
[https://msdn.microsoft.com/en-us/library/ms143702.aspx](https://msdn.microsoft.com/en-us/library/ms143702.aspx).


Known Limitations
-----------------

WinRM 2.0 supports encryption mechanisms on top of HTTP. However those are not supported in Apache Brooklyn.
For production adoptions please make sure you follow Microsoft Guidelines https://msdn.microsoft.com/en-us/library/ee309366(v=vs.85).aspx

### Apache Brooklyn limitations on using WinRM over HTTP and HTTPS

By default Apache Brooklyn is currently using unencrypted HTTP for WinRM communication. It does not support encrypted HTTP for WinRM.

HTTPS is supported but there is no mechanism of specifying which certificates to trust.
Currently Apache Brooklyn will accept any certificate used in a HTTPS WinRM connection.

### Incorrect Exit Codes

Some limitations with WinRM (or at least the chosen WinRM Client!) are listed below:

##### Single-line Powershell files

When a Powershell file contains just a single command, the execution of that file over WinRM returns exit code 0
even if the command fails! This is the case for even simple examples like `exit 1` or `thisFileDoesNotExist.exe`.

A workaround is to add an initial command, for example:

    Write-Host dummy line for workaround 
    exit 1

##### Direct Configuration of Powershell commands

If a command is directly configured with Powershell that includes `exit`, the return code over WinRM
is not respected. For example, the command below will receive an exit code of 0.

    launch.powershell.command: |
      echo first
      exit 1

##### Direct Configuration of Batch commands

If a command is directly configured with a batch exit, the return code over WinRM
is not respected. For example, the command below will receive an exit code of 0.

    launch.command: exit /B 1

##### Non-zero Exit Code Returned as One

If a batch or Powershell file exits with an exit code greater than one (or negative), this will 
be reported as 1 over WinRM.

We advise you to use native commands (non-powershell ones) since executing it as a native command
will return the exact exit code rather than 1.
For instance if you have installmssql.ps1 script use `install.command: powershell -command "C:\\installmssql.ps1"`
rather than using `install.powershell.command: "C:\\installmssql.ps1"`
The first will give you an exact exit code rather than 1

### PowerShell "Preparing modules for first use"

The first command executed over WinRM has been observed to include stderr saying "Preparing 
modules for first use", such as that below:

    < CLIXML
    <Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj><Obj S="progress" RefId="1"><TNRef RefId="0" /><MS><I64 N="SourceId">2</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>

The command still succeeded. This has only been observed on private clouds (e.g. not on
AWS). It could be related to the specific Windows images in use. It is recommended that 
VM images are prepared carefully, e.g. so that security patches are up-to-date and the
VM is suitably initialised.

### WinRM executeScript failed: httplib.BadStatusLine: ''

As described in https://issues.apache.org/jira/browse/BROOKLYN-173, a failure has been
observed where the 10 attempts to execute the command over WinRM failed with:

    httplib.BadStatusLine: ''

Subsequently retrying the command worked. It is unclear what caused the failure, but could 
have been that the Windows VM was not yet in the right state.

One possible workaround is to ensure the Windows VM is in a good state for immediate use (e.g. 
security updates are up-to-date). Another option is to increase the number of retries, 
which defaults to 10. This is a configuration option on the machine location, so can be set on
the location's brooklyn.properties or in the YAML: 

    execTries: 20

### Direct Configuration of Multi-line Batch Commands Not Executed

If a command is directly configured with multi-line batch commands, then only the first line 
will be executed. For example the command below will only output "first":

    launch.command: |
      echo first
      echo second

The workaround is to write a file with the batch commands, have that file uploaded, and execute it.

Note this is not done automatically because that could affect the capture and returning
of the exit code for the commands executed.

### Install location

Work is required to better configure a default install location on the VM (e.g. so that 
environment variables are set). The installation pattern for linux-based blueprints,
of using brooklyn-managed-processes/installs, is not used or recommended on Windows.
Files will be uploaded to C:\ if no explicit directory is supplied, which is untidy, 
unnecessarily exposes the scripts to the user, and could cause conflicts if multiple 
entities are installed.

Blueprint authors are strongly encourages to explicitly specific directories for file
uploads and in their Powershell scripts.

### Windows template settings for an Unattended Installation

Windows template needs certain configuration to be applied to prevent windows setup UI from being displayed.
The default behavior is to display it if there are incorrect or empty settings. Showing Setup UI will prevent the proper
deployment, because it will expect interaction by the user such as agreeing on the license agreement or some of the setup dialogs.

Detailed instruction how to prepare an Unattended installation are provided at [https://technet.microsoft.com/en-us/library/cc722411%28v=ws.10%29.aspx](https://technet.microsoft.com/en-us/library/cc722411%28v=ws.10%29.aspx).

