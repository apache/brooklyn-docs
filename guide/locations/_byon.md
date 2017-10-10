---
section: BYON
section_position: 8
section_type: inline
---

### BYON

"Bring-your-own-nodes" mode is useful in production, where machines have been provisioned by someone else,
and during testing, to cut down provisioning time.

Your nodes must meet the following prerequisites:

- A suitable OS must have been installed on all nodes
- The node must be running sshd (or similar)
- the brooklyn user must be able to ssh to each node as root or as a user with passwordless sudo permission. (For more information on SSH keys, see [here](#ssh-keys).) 

To deploy to machines with known IP's in a blueprint, use the following syntax:

```yaml
location:
  byon:
    user: brooklyn
    privateKeyFile: ~/.ssh/brooklyn.pem
    hosts:
    - 192.168.0.18
    - 192.168.0.19
```

Some of the login properties as described above for jclouds are supported,
but not `loginUser` (as no users are created), and not any of the
VM creation parameters such as `minRam` and `imageId`.
(These clearly do not apply in the same way, and they are *not* 
by default treated as constraints, although an entity can confirm these
where needed.)
As before, if the brooklyn user and its default key are authorized for the hosts,
those fields can be omitted.

Named locations can also be configured in your `brooklyn.properties`,
using the format `byon:(key=value,key2=value2)`.
For convenience, for hosts wildcard globs are supported.

```bash
brooklyn.location.named.On-Prem\ Iron\ Example=byon:(hosts="10.9.1.1,10.9.1.2,produser2@10.9.2.{10,11,20-29}")
brooklyn.location.named.On-Prem\ Iron\ Example.user=produser1
brooklyn.location.named.On-Prem\ Iron\ Example.privateKeyFile=~/.ssh/produser_id_rsa
brooklyn.location.named.On-Prem\ Iron\ Example.privateKeyPassphrase=s3cr3tpassphrase
```

Alternatively, you can create a specific BYON location through the location wizard tool available within the web console.
This location will be saved as a [catalog entry](../blueprints/catalog/index.md#locations-in-catalog) for easy reusability.

For more complex host configuration, one can define custom config values per machine. In the example 
below, there will be two machines. The first will be a machine reachable on
`ssh -i ~/.ssh/brooklyn.pem -p 8022 myuser@50.51.52.53`. The second is a windows machine, reachable 
over WinRM. Each machine has also has a private address (e.g. for within a private network).

```yaml
location:
  byon:
    hosts:
    - ssh: 50.51.52.53:8022
      privateAddresses: [10.0.0.1]
      privateKeyFile: ~/.ssh/brooklyn.pem
      user: myuser
    - winrm: 50.51.52.54:8985
      privateAddresses: [10.0.0.2]
      password: mypassword
      user: myuser
      osFamily: windows
```

The BYON location also supports a machine chooser, using the config key `byon.machineChooser`. 
This allows one to plugin logic to choose from the set of available machines in the pool. For
example, additional config could be supplied for each machine. This could be used (during the call
to `location.obtain()`) to find the config that matches the requirements of the entity being
provisioned. See `FixedListMachineProvisioningLocation.MACHINE_CHOOSER`.