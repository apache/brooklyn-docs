* `endpoint` specifies the URL of an vRealize Automation endpoint.
* `identity` specifies the identity of the user accessing the vRealize Automation endpoint.
* `credential` specifies the password for the user accessing the vRealize Automation endpoint.
* `resourcePool` specifies the name of an existing resource pool by vCenter.
* `cluster` specifies the name of an existing cluster managed by vCenter.
* `datastore` specifies the name of an existing datastore managed by vCenter.
* `customDomain` specified an Active Directory domain.
* `folder` specifies the name of the folder that groups the VMs generated based on the location blueprint.
* `imageId` specifies the identifier of the VM to clone.
* `osFamily: windows` tells Apache Brooklyn to consider it as a Windows machine.
* `user` , `password` specify the credentials of the cloned VM. Apache Brooklyn uses them to log into the VM to customize it.
* `networks` specifies a list of networks the cloned VM will be added in.
* `cloudMachineNamer: org.apache.brooklyn.core.location.cloud.names.CustomMachineNamer` a special Apache Brooklyn type that provides unique VM names.
* `custom.machine.namer.machine` specifies a template for the `cloudMachineNamer` to use when generating unique VM names.
* `vmNameMaxLength:80` tells vCenter to strip the VM name to maximum 15 characters.