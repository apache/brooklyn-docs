---
title: Winrm4j Client
layout: website-normal
---

## Winrm4j parameters

Check [org.apache.brooklyn.location.winrm.WinRmMachineLocation](https://github.com/apache/brooklyn-server/blob/master/software/winrm/src/main/java/org/apache/brooklyn/location/winrm/WinRmMachineLocation.java#L82-L112)
parameters available for WinRM.

* host <String>: Host to connect to (required).Default value `null`
* port <Integer>: WinRM port to use when connecting to the remote machine.<br>
  If no port is specified then it defaults to a port depending on the `winrm.useHttps` flag.
* winrm.useHttps <Boolean>: The parameter tells the machine sensors whether the winrm port is over https. If the parameter is true then 5986 will be used as a winrm port.<br>
  Default value: `false`
* retriesOfNetworkFailures <Integer>: The parameter sets the number of retries for connection failures. If you use high value, consider taking care for the machine's network.<br>
  Default value: `4`
* winrm.useNtlm <Boolean>: The parameter configures tells the machine sensors whether the winrm port is over https. If the parameter is true then 5986 will be used as a winrm port.<br>
  Default value: `true`
* winrm.computerName <String>: Windows Computer Name to use for authentication.<br>
  Default value: `null`
* user <String>: User to connect as<br>
  Default value: `null`
* password <String>: Password to use to connect.<br>
  Default value: `null`
* waitWindowsToStart <Duration>: By default Brooklyn will return the machine immediately after Brooklyn is able to WinRM. Sometimes restart could happen after a Windows VM is provisioned.
  This could be because of System Upgrade or other.
  By setting this config key to 60s, 5m or other X Duration of time Brooklyn will wait X amount of time for disconnect to occur.
  If connection failure occurs it will wait X amount of time for the machine to come up.<br>
  Default value: `null`

If there are location config keys prefixed with `brooklyn.winrm.config.` prefix will be removed
and it will be used to instantiate a `org.apache.brooklyn.util.core.internal.winrm.WiRmTool` implementation.

## WinRM Connectivity Diagnostics

If you are experiencing problems with a windows blueprint against a jclouds location 
where Apache Brooklyn complains about failing to connect to the IP you should check those things.

1. Apache Brooklyn is using correct username and password
1. Apache Brooklyn can reach the IP of the provisioned machine. WinRM port 5985 or 5986 is also reachable from Apache Brooklyn.
1. Check whether `WinRmMachineLocation#getDefaultUserMetadataString(ConfigurationSupportInternal)` is applied on the VM.
   This script should be passed to the cloud and executed in order to configure WinRM according to Apache Brooklyn requirements for authentication.
   So far windows startup script are known to be supported on AWS EC2 and VCloud Director.
   If your cloud doesn't use this script then tune WinRM parameters accordingly.
1. Check whether you use winrm over http or over https.
  1. If you are using WinRM over http then make sure WinRM service on target VM has `AllowUnencrypted = true`

If the quick list above doesn't help then follow the steps bellow.

To speed up diagnosing the problem we advice to trigger a deployment with the JcloudsLocation flag `destroyOnFailure: false` so you can check status of the provisioned machine
or try later different WinRM parameters with a Apache Brooklyn [BYON Location](../../locations/index.html#byon).

After you determined what is the username and the password you can proceed with next steps.
*(Notice that for cloud providers which use Auto Generated password will not be logged.
For these cases use Java Debug to retrieve ot or provision a VM manually with the same parameters when using Apache Brooklyn to provision a jclouds location.)*

The first step is to find what is the winrm service configuration on the target host.

1. If you have RDP access or KVM like access to the VM then check the winrm service status with the command bellow.
   `winrm get winrm/config/service`
   If you are using http you should have AllowUnencrypted to false.
   Encryption is supported only over https.
   Sample output:

        MaxConcurrentOperations = 4294967295
        MaxConcurrentOperationsPerUser = 1500
        EnumerationTimeoutms = 240000
        MaxConnections = 300
        MaxPacketRetrievalTimeSeconds = 120
        AllowUnencrypted = true
        Auth
            Basic = false
            Kerberos = true
            Negotiate = true
            Certificate = false
            CredSSP = true
            CbtHardeningLevel = Relaxed
        DefaultPorts
            HTTP = 5985
            HTTPS = 5986
        IPv4Filter = *
        IPv6Filter = *
        EnableCompatibilityHttpListener = false
        EnableCompatibilityHttpsListener = false
        CertificateThumbprint
        AllowRemoteAccess = true

Use an Apache Brooklyn BYON blueprint to try easily other connection options.

    location:
      byon:
        hosts:
        - winrm: 10.0.0.1
          user: Administrator
          password: pa55w0rd
          osFamily: windows
    services:
    - type: org.apache.brooklyn.entity.software.base.VanillaWindowsProcess
      brooklyn.config:
         checkRunning.command: echo checkRunning
         install.command: echo installCommand

1. Check IP is reachable from Apache Brooklyn instance
   Check whether `telnet 10.0.0.1 5985` makes successfully a socket.
1. If AllowUnencrypted is false and you are using winrm over http then apply `winrm set winrm/config/service @{AllowUnencrypted="true"}`
   *If jclouds or the cloud provider doesn't support passing `sysprep-specialize-script-cmd` then consider modifying Windows VM Image.* 
1. Check your username and password. Notice in Windows passwords are case sensitive.
   Here is how it looks log from a wrong password:

        INFO: Authorization loop detected on Conduit "{http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd}WinRmPort.http-conduit" on URL "http://192.168.122.1:5985/wsman" with realm "null"
        Oct 21, 2016 10:43:11 AM org.apache.cxf.phase.PhaseInterceptorChain doDefaultLogging
        WARNING: Interceptor for {http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd}WinRmService#{http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd}Create has thrown exception, unwinding now
        org.apache.cxf.interceptor.Fault: Could not send Message.
        at org.apache.cxf.interceptor.MessageSenderInterceptor$MessageSenderEndingInterceptor.handleMessage(MessageSenderInterceptor.java:64)

1. When having wrong password you may want to try logging on a different domain
   This is possible from `brooklyn.winrm.config.winrm.computerName` location config.
1. If you want to configure Windows target host with https then check the article [Configuring WINRM for HTTPS](https://support.microsoft.com/en-us/kb/2019527)
1. If you are still seeing authorization errors then try connecting via winrm with the embedded winrs client.
   First make sure you have the server in trusted hosts.

Then execute a simple command like

    winrs -r:10.0.2.15 -unencrypted -u:Administrator -p:pa55w0rd ipconfig
