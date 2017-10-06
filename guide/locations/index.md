---
title: Locations
layout: website-normal
children:
- { path: provisioned-machine-requirements.md, section_position: 8 }
check_directory_for_children: true
---

Locations are the environments to which Brooklyn deploys applications. Most commonly these 
are cloud services such as AWS, GCE, and IBM Softlayer. Brooklyn also supports deploying 
to a pre-provisioned network or to localhost (primarily useful for testing blueprints).

See also:

* The [Locations yaml guide]({{ book.path.guide }}/blueprints/setting-locations.html)
* Use within an entity of the configuration option 
  [provisioning.properties]({{ book.path.guide }}/blueprints/entity-configuration.html#entity-provisioningproperties-overriding-and-merging)
* How to add location definitions to the [Catalog]({{ book.path.guide }}/blueprints/catalog/); and 
* How to use [Externalized Configuration]({{ book.path.guide }}/ops/externalized-configuration.html).

The requirements for how a provisioned machine should behave will depend on the
entites subsequently deployed there.

Below are a set of common assumptions, made by many entity implementations, which
could cause subsequent errors if they do not hold. These relate to the machine's 
configuration, rather than additional networking or security that a given Cloud 
might offer.

Also see the [Troubleshooting]({{ book.path.guide }}/ops/troubleshooting/) docs.


## Remote Access

### SSH or WinRM Access

Many entities require ssh'ing (or using WinRM for Windows), to install and configure 
the software.

An example of disabling all ssh'ing is shown below:

    location:
      aws-ec2:us-east-1:
        identity: XXXXXXXX
        credential: XXXXXXXX
        waitForSshable: false
        pollForFirstReachableAddress: false
    services:
    - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
      brooklyn.config:
        onbox.base.dir.skipResolution: true
        sshMonitoring.enabled: false


### Parsing SSH stdout: No Extra Lines

For entities that execute ssh commands, these sometimes parse the resulting stdout.

It is strongly recommended that VMs are configured so that no additional stdout is written when executing 
remote ssh (or WinRM) commands. Such stdout risks interfering with the response parsing in some blueprints.

For example, if configuring the VM to write out "Last login" information, this should be done for only 
"interactive" shells (see [Stackoverflow](http://stackoverflow.com/a/415444/1393883) for more details).


### Passwordless Sudo

Does passwordless sudo work?

Try executing:

    sudo whoami

See [Passwordless Sudo]({{ book.path.guide }}/locations/index.html#passwordless-sudo).


## Advertised Addresses

### Hostname Resolves Locally

Does the hostname known at the box resolve at the box?

Try executing:

    ping $(hostname)

if not, consider setting `generate.hostname: true` in the location config, for jclouds-based locations.


### IP Resolves Locally

For the IP address advertised in Brooklyn using the sensor `host.addresses.private` (or `host.subnet.address`), 
can the machine reach that IP?

Get the sensor value, and then try executing:

    ping ${PRIVATE_IP}

Is there a public IP (advertised using the sensor `host.addresses.public`, or `host.address`), and can the 
machine reach it?

Get the sensor value, and then try executing:

    ping ${PUBLIC_IP}


## Networking

### Public Internet Access

Can the machine reach the public internet, and does DNS resolve?

Try executing:

    ping www.example.org


### Machine's Hostname in DNS

Is the machine hostname well-known? If ones does a DNS lookup, e.g. from the Brooklyn server, does it resolve and 
does it return the expected IP (e.g. the same IP as the `host.addresses.public` sensor)? Try using the hostname
that the machine reports when you execute `hostname`.

Many blueprints do not require this, instead using IP addresses directly. Some blueprints may include registration
with an appropriate DNS server. Some clouds do this automatically.


### Reachability

When provisioning two machines, can these two machines reach each other on the expected IP(s) and hostname(s)?

Try using `ping` from one machine to another using the public or subnet ip or hostname.
However, note that `ping` requires access over ICMP, which may be disabled. Alternatively,
try connecting to a specific TCP port using `telnet <address> <port>`.


### Firewalls

What firewall(s) are running on the machine, and are the required ports open?
On linux, check things like `iptables`, `firewalld`, `ufw` or other commercial
firewalls. On Windows, check the settings of the 
[Windows Firewall](https://en.wikipedia.org/wiki/Windows_Firewall).

Consider using `openIptables: true`, or even `stopIptables: true`.


## Sufficient Entropy for /dev/random

Is there sufficient entropy on the machine, for `/dev/random` to respond quickly?

Try executing:

    { cat /dev/random > /tmp/x & } ; sleep 10 ; kill %1 ; { cat /dev/random > /tmp/x & } ; sleep 1 ; kill %1 ; wc /tmp/x | awk '{print $3}'

The result should be more than 1M.

If not, consider setting `installDevUrandom: true` for jclouds-based locations.

See instructions to [Increase Entropy]({{ book.path.guide }}/ops/troubleshooting/increase-entropy.html).


## File System

### Permissions of /tmp

Is `/tmp` writable?

Try executing:

    touch /tmp/amp-test-file ; rm /tmp/amp-test-file

Are files in `/tmp` executable (e.g. some places it has been mounted NO_EXECUTE)?

Try executing:

    echo date > /tmp/brooklyn-test.sh && chmod +x /tmp/brooklyn-test.sh && /tmp/brooklyn-test.sh && rm /tmp/brooklyn-test.sh

{% include '_clouds.md' %}
{% include '_AWS.md' %}
{% include '_azure-ARM.md' %}
{% include '_azure-classic.md' %}
{% include '_cloudstack.md' %}
{% include '_GCE.md' %}
{% include '_ibm-softlayer.md' %}
{% include '_openstack.md' %}
{% include '_inheritance-and-named-locations.md' %}
{% include '_byon.md' %}
{% include '_ssh-keys.md' %}
{% include '_localhost.md' %}
{% include '_location-customizers.md' %}
{% include '_location-customizer-security-groups.md' %}
{% include '_special-locations.md' %}
