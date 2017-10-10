---
section: CloudStack
title: Apache CloudStack
section_type: inline
section_position: 4
---

## Apache CloudStack

### Connection Details

The endpoint URI will normally have the suffix `/client/api/`.

The identity is the "api key" and the credential is the "secret key". These can be generated in 
the CloudStack gui: under accounts, select "view users", then "generate key".

    location:
      jclouds:cloudstack:
        endpoint: https://cloud.acme.com/client/api
        identity: abcdefghijklmnopqrstuvwxyz01234567890-abcdefghijklmnopqrstuvwxyz01234567890-abcdefghij
        credential: mycred-abcdefghijklmnopqrstuvwxyz01234567890-abcdefghijklmnopqrstuvwxyz01234567890-abc

Users are strongly recommended to use 
[externalized configuration](../ops/externalized-configuration.md) for better
credential management, for example using [Vault](https://www.vaultproject.io/).


### Common Configuration Options

Below are examples of configuration options that use values specific to CloudStack environments:

* The `imageId` is the template id. For example,
  `imageId: db0bcce3-9e9e-4a87-a953-2f46b603498f`.

* The `region` is CloudStack zone id.
  For example `region: 84539b9c-078e-458a-ae26-c3ffc5bb1ec9`..

* `networkName` is the network id (within the given zone) to be used. For example, 
  `networkName: 961c03d4-9828-4037-9f4d-3dd597f60c4f`.

For further configuration options, consult 
[jclouds CloudStack template options](https://jclouds.apache.org/reference/javadoc/1.9.x/org/jclouds/cloudstack/compute/options/CloudStackTemplateOptions.html).
These can be used with the **[templateOptions](#custom-template-options)** configuration option.


### Using a Pre-existing Key Pair

The configuration below uses a pre-existing key pair:

    location:
      jclouds:cloudstack:
        ...
        loginUser: root
        loginUser.privateKeyFile: /path/to/keypair.pem
        keyPair: my-keypair


### Using Pre-existing Security Groups

To specify existing security groups, their IDs must be used rather than their names (note this
differs from the configuration on other clouds!).
 
The configuration below uses a pre-existing security group:

    location:
      jclouds:cloudstack:
        ...
        templateOptions:
          generateSecurityGroup: false
          securityGroupIds:
          - 12345678-90ab-def0-1234-567890abcdef


### Using Static NAT

Assigning a public IP to a VM at provision-time is referred to as "static NAT" in CloudStack
parlance. To give some consistency across different clouds, the configuration option is named
`autoAssignFloatingIp`. For example, `autoAssignFloatingIp: false`.


### CloudMonkey CLI

The [CloudStack CloudMonkey CLI](https://cwiki.apache.org/confluence/display/CLOUDSTACK/CloudStack+cloudmonkey+CLI)
is a very useful tool. It gives is an easy way to validate that credentials are correct, and to query  
the API to find the correct zone IDs etc.

Useful commands include:

    # for finding the ids of the zones:
    cloudmonkey api listZones

    # for finding the ids of the networks.
    cloudmonkey api listNetworks | grep -E "id =|name =|========="


### CloudStack Troubleshooting

These troubleshooting tips are more geared towards problems encountered in old test/dev 
CloudStack environment.


#### Resource Garbage Collection Issues

The environment may run out of resources, due to GC issues, preventing the user from creating new 
VMs or allocating IP addresses (May respond with this error message: 
`errorCode=INTERNAL_ERROR, errorText=Job failed due to exception Unable to create a deployment for VM`). 
There are two options worth checking it to enforce clearing up the zombie resources:

* Go to the Accounts tab in the webconsole and tap on the Update Resource Count button.
* Restart the VPC in question from the Network tab.


#### Releasing Allocated Public IP Addresses

Releasing an allocated Public IP from the web console did not free up the resources. Instead 
CloudMonkey can be used to dissociate IPs and expunge VMs.

Here is a CloudMonkey script to dissociate any zombie IPs:

    cloudmonkey set display json;
    cloudmonkey api listPublicIpAddresses | grep '"id":' > ips.txt; 
    sed -i -e s/'      "id": "'/''/g ips.txt;
    sed -i -e s/'",'/''/g ips.txt
    for line in $(cat ips.txt); do cloudmonkey api disassociateIpAddress id="$line"; done
    rm ips.txt;
    cloudmonkey set display default;


#### Restarting VPCs

Errors have been encountered when a zone failed to provision new VMs, with messages like:

    Job failed due to exception Resource [Host:15] is unreachable: Host 15: Unable to start instance due to null

The workaround was to restart the VPC networks:

* Log into the CloudStack web-console.
* Go to Network -> VPC (from the "select view")
* For each of the VPCs, click on the "+" in the "quickview" column, and invoke "restart VPC".

Other symptoms of this issue were that: 1) an administrator could still provision VMs using 
the admin account, which used a different network; and 2) the host number was very low, so it 
was likely to be a system host/VM that was faulty.
