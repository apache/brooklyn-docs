---
title: Windows Blueprints
layout: website-normal
children:
- client.md
- tips.md
- limitations.md
- troubleshoot.md
---

Brooklyn can deploy to Windows servers using WinRM to run commands. These deployments can be 
expressed in pure YAML, and utilise PowerShell to install and manage the software process. 
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

Or for an existing Windows machine:

    location:
      byon:
        hosts:
        - winrm: 10.0.0.1
          user: Administrator
          password: pa55w0rd
          osFamily: windows



A Sample Blueprint
------------------

Creating a Windows VM is done using the `org.apache.brooklyn.entity.software.base.VanillaWindowsProcess` entity type. This is very similar
to `VanillaSoftwareProcess`, but adapted to work for Windows and WinRM instead of Linux. We suggest you read the
[documentation for VanillaSoftwareProcess]({{ site.path.guide }}/blueprints/custom-entities.html#vanilla-software-using-bash) to find out what you
can do with this entity.

Entity authors are strongly encouraged to write Windows PowerShell or Batch scripts as separate 
files, to configure these to be uploaded, and then to configure the appropriate command as a 
single line that executes given script.

For example here is a simplified blueprint:

    name: Server with 7-Zip

    location: windows-machine       # register this, or inject the above instead

    services:
    - type: org.apache.brooklyn.entity.software.base.VanillaWindowsProcess
      brooklyn.config:
        templates.preinstall:
          /path/to/install7zip.ps1: "C:\\install7zip.ps1"
        install.command: powershell -command "C:\\install7zip.ps1"
        customize.command: echo true
        launch.command: echo true
        stop.command: echo true
        checkRunning.command: echo true
        installer.download.url: http://www.7-zip.org/a/7z938-x64.msi

The installation script - referred to as `/path/to/install7zip.ps1` in the example above (but put this on your Brooklyn server or in the bundle classpath) - is:

    $Path = "C:\InstallTemp"
    New-Item -ItemType Directory -Force -Path $Path

    $Url = "${config['installer.download.url']}"
    $Dl = [System.IO.Path]::Combine($Path, "installer.msi")
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile( $Url, $Dl )

    Start-Process "msiexec" -ArgumentList '/qn','/i',$Dl -RedirectStandardOutput ( [System.IO.Path]::Combine($Path, "stdout.txt") ) -RedirectStandardError ( [System.IO.Path]::Combine($Path, "stderr.txt") ) -Wait


Learn More
----------

A few other WinRM resources are available:

* [Tips and Tricks](tips.md)
* [About the Winrm4j Client](client.md)
* [Troubleshooting](troubleshoot.md)
* [Limitations](limitations.md)

