---
title: WinRM4j Limitations
layout: website-normal
---


### Apache Brooklyn limitations on using WinRM over HTTP and HTTPS

HTTPS is supported and recommended for use with WinRM via Apache Brooklyn in any wide-area scenario.
Note however that there is no straightforward way to configure specific certificates to trust,
and thus Apache Brooklyn will accept any certificate used in a HTTPS WinRM connection;
traffic will be encrypted but other means will be necessary to protect against MITM attacks.

WinRM 2.0 supports encryption mechanisms on top of HTTP. However those are not supported in Apache Brooklyn.

For production usage also see the [Microsoft Guidelines](https://msdn.microsoft.com/en-us/library/ee309366(v=vs.85).aspx).


### Incorrect Exit Codes

Some limitations with WinRM (or at least the chosen WinRM Client!) are listed below:

##### Single-line PowerShell files

When a PowerShell file contains just a single command, the execution of that file over WinRM returns exit code 0
even if the command fails! This is the case for even simple examples like `exit 1` or `thisFileDoesNotExist.exe`.

A workaround is to add an initial command, for example:

    Write-Host dummy line for workaround 
    exit 1

##### Direct Configuration of PowerShell commands

If a command is directly configured with PowerShell that includes `exit`, the return code over WinRM
is not respected. For example, the command below will receive an exit code of 0.

    launch.powershell.command: |
      echo first
      exit 1

##### Direct Configuration of Batch commands

If a command is directly configured with a batch exit, the return code over WinRM
is not respected. For example, the command below will receive an exit code of 0.

    launch.command: exit /B 1

##### Non-zero Exit Code Returned as One

In some configurations, scripts can report any non-zero exit code as `1`.
It may be possible to workaround this where the exit code is needeed by using
e.g. `install.command: powershell -command "C:\\installmssql.ps1"`
instead of `install.powershell.command: "C:\\installmssql.ps1"`
If this is problematic, please consider submitting a patch to `VanillaWindowsProcess`!

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
environment variables are set). The installation pattern for Linux-based blueprints,
of using brooklyn-managed-processes/installs, is not used or recommended on Windows.
Files will be uploaded to C:\ if no explicit directory is supplied, which is untidy, 
unnecessarily exposes the scripts to the user, and could cause conflicts if multiple 
entities are installed.

Blueprint authors are strongly encourages to explicitly specific directories for file
uploads and in their PowerShell scripts.

### Windows template settings for an Unattended Installation

Windows template needs certain configuration to be applied to prevent Windows setup UI from being displayed.
The default behavior is to display it if there are incorrect or empty settings. Showing Setup UI will prevent the proper
deployment, because it will expect interaction by the user such as agreeing on the license agreement or some of the setup dialogs.

Detailed instruction how to prepare an Unattended installation are provided at [https://technet.microsoft.com/en-us/library/cc722411%28v=ws.10%29.aspx](https://technet.microsoft.com/en-us/library/cc722411%28v=ws.10%29.aspx).

