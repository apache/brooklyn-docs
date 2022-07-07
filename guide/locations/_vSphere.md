---
section: VMware vSphere
section_position: 6
section_type: inline
---

### VMware vSphere

[VMware vSphere](https://docs.vmware.com/en/VMware-vSphere) is VMware's virtualization platform, which transforms data centers into aggregated computing infrastructures that include CPU, storage, and networking resources.
vSphere manages these infrastructures as a unified operating environment, and provides you with the tools to administer the data centers that participate in that environment.
Apache Brooklyn includes support for vSphere servers regardless of the underlying provider ([AWS](https://aws.amazon.com/vmware), [Hetzner](https://docs.hetzner.com/robot/dedicated-server/virtualization/vmware-esxi/), etc).

To deploy applications on a vSphere server Apache Brooklyn needs to know its vRealize Automation endpoint that is used to communicate with vCenter to discover compute resources, collect data, and provision machines. 
It is recommended to create customized VM templates to be cloned to speed up provisioning operations.
The vSphere Server endpoint is secured and credentials must be provided in the vSphere location catalog definition.

Below are examples of configuration options that use values specific to a vSphere server:

{% read _vSphere_configuration.md %}

The next two sections show a Linux and Windows locations examples.

#### Sample Linux Blueprint

Placeholders surrounded with `<>` have to be replaced with their respective values.

```yaml
brooklyn.catalog:
  id: my-vsphere-linux-location
  name: my-vsphere-linux-location
  itemType: location
    item:
      type: vsphere
      brooklyn.config:
        displayName: vSphere VMware Linux

        # vcenter access
        endpoint: https://<VSPHERE-SERVER>/sdk
        identity: <VSPHERE-USER>
        credential: <VSPHERE-PASS>

        resourcePool: Resources
        cluster: <COMPUTE-CLUSTER>
        datastore: <DATASTORE>
        customDomain: <DOMAIN>
        folder: <FOLDER>

        # VM template details
        imageId: <TEMPLATE-VM>
        user: <VM-USER>
        password: <VM-PASSWORD>
        networks:
        - name: <NETWORK-NAME>

        # Prefix machine name with initials
        cloudMachineNamer: org.apache.brooklyn.core.location.cloud.names.CustomMachineNamer
        custom.machine.namer.machine: <PREFIX>-${entity.application.id}-LINUX-${entity.displayName[0..*10]}-${entity.id}
        vmNameMaxLength: 80
```


#### Sample Windows Blueprint

Placeholders surrounded with `<>` have to be replaced with their respective values.

```yaml
brooklyn.catalog:
  id: my-vsphere-windows-location
  name: my-vsphere-windows-location
  itemType: location
    item:
      type: vsphere
      brooklyn.config:
        displayName: vSphere VMware Windows

        # vcenter access
        endpoint: https://<VSPHERE-SERVER>/sdk
        identity: <VSPHERE-USER>
        credential: <VSPHERE-PASS>

        resourcePool: Resources
        cluster: <COMPUTE-CLUSTER>
        datastore: <DATASTORE>
        customDomain: <DOMAIN>
        folder: <FOLDER>

        # VM template details
        imageId: <TEMPLATE-VM>
        osFamily: Windows
        user: Administrator
        password: <VM-PASSWORD>
        networks:
        - name: <NETWORK-NAME>

        # Prefix machine name with initials
        cloudMachineNamer: org.apache.brooklyn.core.location.cloud.names.CustomMachineNamer
        custom.machine.namer.machine: <PREFIX>-${entity.application.id}-WINDOWS-${entity.displayName[0..*10]}-${entity.id}
        vmNameMaxLength: 80
```