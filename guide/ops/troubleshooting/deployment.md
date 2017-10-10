---
layout: website-normal
title: Troubleshooting Deployment
toc: /guide/toc.json
---
# {{ page.title }}

This guide describes common problems encountered when deploying applications.


## YAML deployment errors

The error `Invalid YAML: Plan not in acceptable format: Cannot convert ...` means that the text is not 
valid YAML. Common reasons include that the indentation is incorrect, or that there are non-matching
brackets.

The error `Unrecognized application blueprint format: no services defined` means that the `services:`
section is missing.

An error like the one shown below means that the given entity type (in this case com.acme.Foo) is not in the catalog or on the classpath:

```bash
Deployment plan item Service[name=<null>,description=<null>,serviceType=com.acme.Foo,characteristics=[],customAttributes={}] cannot be matched
```


An error like the one shown below means that the given location (in this case aws-ec3) was unknown:

```bash
Illegal parameter for 'location' (aws-ec3); not resolvable: java.util.NoSuchElementException: Unknown location 'aws-ec3': either this location is not recognised or there is a problem with location resolver configuration
```

This means it does not match any of the named locations in brooklyn.properties, nor any of the clouds enabled in the jclouds support, nor any of the locations added dynamically through the catalog API.


## VM Provisioning Failures

There are many stages at which VM provisioning can fail! An error `Failure running task provisioning` 
means there was some problem obtaining or connecting to the machine.

An error like `... Not authorized to access cloud ...` usually means the wrong identity/credential was used.

AWS requires a X-Amz-Date header which contains the date of the Apache Brooklyn AWS client.
If the date on the server is wrong, for example several minutes behind you will get an 
Authorization Exception. This is to prevent replay attacks. Please be sure to set the clock 
correctly on the machine running Apache Brooklyn. To set the time on Linux you can use the ntp 
client (e.g. `sudo ntpdate pool.ntp.org`). We advise running the 
[ntp daemon](http://www.tldp.org/LDP/sag/html/basic-ntp-config.html) so that the clock is kept 
continually in sync.

An error like `Unable to match required VM template constraints` means that a matching image (e.g. AMI in AWS terminology) could not be found. This 
could be because an incorrect explicit image id was supplied, or because the match-criteria could not
be satisfied using the given images available in the given cloud. The first time this error is 
encountered, a listing of all images in that cloud/region will be written to the debug log.

Failure to form an ssh connection to the newly provisioned VM can be reported in several different ways, 
depending on the nature of the error. This breaks down into failures at different points:

* Failure to reach the ssh port (e.g. `... could not connect to any ip address port 22 on node ...`).
* Failure to do the very initial ssh login (e.g. `... Exhausted available authentication methods ...`).
* Failure to ssh using the newly created user.

There are many possible reasons for this ssh failure, which include:

* The VM was "dead on arrival" (DOA) - sometimes a cloud will return an unusable VM. One can work around
  this using the `machineCreateAttempts` configuration option, to automatically retry with a new VM.
* Local network restrictions. On some guest wifis, external access to port 22 is forbidden.
  Check by manually trying to reach port 22 on a different machine that you have access it.
* NAT rules not set up correctly. On some clouds that have only private IPs, Brooklyn can automatically
  create NAT rules to provide access to port 22. If this NAT rule creation fails for some reason,
  then Brooklyn will not be able to reach the VM. If NAT rules are being created for your cloud, then
  check the logs for warnings or errors about the NAT rule creation.
* ssh credentials incorrectly configured. The Brooklyn configuration is very flexible in how ssh
  credentials can be configured. However, if a more advanced configuration is used incorrectly (e.g. 
  the wrong login user, or invalid ssh keys) then this will fail.
* Wrong login user. The initial login user to use when first logging into the new VM is inferred from 
  the metadata provided by the cloud provider about that image. This can sometimes be incomplete, so
  the wrong user may be used. This can be explicitly set using the `loginUser` configuration option.
  An example of this is with some Ubuntu VMs, where the "ubuntu" user should be used. However, on some clouds
  it defaults to trying to ssh as "root".
* Bad choice of user. By default, Brooklyn will create a user with the same name as the user running the
  Brooklyn process; the choice of user name is configurable. If this user already exists on the machine, 
  then the user setup will not behave as expected. Subsequent attempts to ssh using this user could then fail.
* Custom credentials on the VM. Most clouds will automatically set the ssh login details (e.g. in AWS using  
  the key-pair, or in CloudStack by auto-generating a password). However, with some custom images the VM
  will have hard-coded credentials that must be used. If Brooklyn's configuration does not match that,
  then it will fail.
* Guest customisation by the cloud. On some clouds (e.g. vCloud Air), the VM can be configured to do
  guest customisation immediately after the VM starts. This can include changing the root password.
  If Brooklyn is not configured with the expected changed password, then the VM provisioning may fail
  (depending if Brooklyn connects before or after the password is changed!).
 
A very useful debug configuration is to set `destroyOnFailure` to false. This will allow ssh failures to
be more easily investigated.

#### java.security.KeyException when Provisioning VM

The exception `java.security.KeyException` can be thrown when jclouds is attempting the SSL handshake,
to make cloud API calls. This can happen if the version of nss is older than 3.16 - the nss package
includes the ssl library.

To fix this on CentOS, run:

```bash
sudo yum upgrade nss
```

For a discussion of investigating this kind of issue, see this [Backslasher blog](http://blog.backslasher.net/java-ssl-crash.html).

The full stacktrace is shown below:

```java
Caused by: javax.net.ssl.SSLException: java.security.ProviderException: java.security.KeyException
	at sun.security.ssl.Alerts.getSSLException(Alerts.java:208)
	at sun.security.ssl.SSLSocketImpl.fatal(SSLSocketImpl.java:1949)
	at sun.security.ssl.SSLSocketImpl.fatal(SSLSocketImpl.java:1906)
	at sun.security.ssl.SSLSocketImpl.handleException(SSLSocketImpl.java:1889)
	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1410)
	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1387)
	at sun.net.www.protocol.https.HttpsClient.afterConnect(HttpsClient.java:559)
	at sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:185)
	at sun.net.www.protocol.http.HttpURLConnection.getOutputStream0(HttpURLConnection.java:1283)
	at sun.net.www.protocol.http.HttpURLConnection.getOutputStream(HttpURLConnection.java:1258)
	at sun.net.www.protocol.https.HttpsURLConnectionImpl.getOutputStream(HttpsURLConnectionImpl.java:250)
	at org.jclouds.http.internal.JavaUrlHttpCommandExecutorService.writePayloadToConnection(JavaUrlHttpCommandExecutorService.java:294)
	at org.jclouds.http.internal.JavaUrlHttpCommandExecutorService.convert(JavaUrlHttpCommandExecutorService.java:170)
	at org.jclouds.http.internal.JavaUrlHttpCommandExecutorService.convert(JavaUrlHttpCommandExecutorService.java:64)
	at org.jclouds.http.internal.BaseHttpCommandExecutorService.invoke(BaseHttpCommandExecutorService.java:95)
	... 64 more
Caused by: java.security.ProviderException: java.security.KeyException
	at sun.security.ec.ECKeyPairGenerator.generateKeyPair(ECKeyPairGenerator.java:147)
	at java.security.KeyPairGenerator$Delegate.generateKeyPair(KeyPairGenerator.java:703)
	at sun.security.ssl.ECDHCrypt.<init>(ECDHCrypt.java:77)
	at sun.security.ssl.ClientHandshaker.serverKeyExchange(ClientHandshaker.java:721)
	at sun.security.ssl.ClientHandshaker.processMessage(ClientHandshaker.java:281)
	at sun.security.ssl.Handshaker.processLoop(Handshaker.java:979)
	at sun.security.ssl.Handshaker.process_record(Handshaker.java:914)
	at sun.security.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:1062)
	at sun.security.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1375)
	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1403)
	... 74 more
Caused by: java.security.KeyException
	at sun.security.ec.ECKeyPairGenerator.generateECKeyPair(Native Method)
	at sun.security.ec.ECKeyPairGenerator.generateKeyPair(ECKeyPairGenerator.java:128)
	... 83 more
```


## Timeout Waiting For Service-Up

A common generic error message is that there was a timeout waiting for service-up.

This just means that the entity did not get to service-up in the pre-defined time period (the default is 
two minutes, and can be configured using the `start.timeout` config key; the timer begins after the 
start tasks are completed).

See the [overview](overview.md) for where to find additional information, especially the section on
"Entity's Error Status".

## Invalid packet error

If you receive an error message similar to the one below when provisioning a VM, it means that the wrong username is being used for ssh'ing to the machine. The "invalid packet" is because a response such as "Please login as the ubuntu user rather than root user." is being sent back.

You can workaround the issue by explicitly setting the user that Brooklyn should use to login to the VM  (typically the OS default user).

```bash
error acquiring SFTPClient() (out of retries - max 50)
Invalid packet: indicated length too large
java.lang.IllegalStateException
Invalid packet: indicated length too large
```

An example of how to explicitly set the user is shown below (when defining a Location) by using 'loginUser': 

```yaml
brooklyn.locations:
- type: jclouds:aws-ec2
  brooklyn.config:
    displayName: aws-us-east-1
    region: us-east-1
    identity: <add>
    credential: <add>
    loginUser: centos
```

## SSLException close_notify Exception

The following error, when deploying a blueprint, has been shown to be caused by issues with DNS provided by your ISP or
traffic filtering such as child-safe type filtering:

    Caused by: javax.net.ssl.SSLException: Received fatal alert: close_notify

To resolve this try disabling traffic filtering and setting your DNS to a public server such as 8.8.8.8 to use google
[DNS](https://www.wikiwand.com/en/Google_Public_DNS).  [See here](https://developers.google.com/speed/public-dns/docs/using) for details on how to configure this.
