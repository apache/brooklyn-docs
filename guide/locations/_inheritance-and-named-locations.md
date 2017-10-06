---
section: Inheritance and Named Locations
title: Named Locations
section_type: inline
section_position: 7
---

### Inheritance and Named Locations

Named locations can be defined for commonly used groups of properties, 
with the syntax `brooklyn.location.named.your-group-name.`
followed by the relevant properties.
These can be accessed at runtime using the syntax `named:your-group-name` as the deployment location.

Some illustrative examples using named locations and
showing the syntax and properties above are as follows:

```bash
# Production pool of machines for my application (deploy to named:prod1)
brooklyn.location.named.prod1=byon:(hosts="10.9.1.1,10.9.1.2,produser2@10.9.2.{10,11,20-29}")
brooklyn.location.named.prod1.user=produser1
brooklyn.location.named.prod1.privateKeyFile=~/.ssh/produser_id_rsa
brooklyn.location.named.prod1.privateKeyPassphrase=s3cr3tCOMPANYpassphrase

# AWS using my company's credentials and image standard, then labelling images so others know they're mine
brooklyn.location.named.company-jungle=jclouds:aws-ec2:us-west-1
brooklyn.location.named.company-jungle.identity=BCDEFGHIJKLMNOPQRSTU  
brooklyn.location.named.company-jungle.privateKeyFile=~/.ssh/public_clouds/company_aws_id_rsa
brooklyn.location.named.company-jungle.imageId=ami-12345
brooklyn.location.named.company-jungle.minRam=2048
brooklyn.location.named.company-jungle.userMetadata=application=my-jungle-app,owner="Bob Johnson"
brooklyn.location.named.company-jungle.machineCreateAttempts=2

brooklyn.location.named.AWS\ Virginia\ Large\ Centos = jclouds:aws-ec2
brooklyn.location.named.AWS\ Virginia\ Large\ Centos.region = us-east-1
brooklyn.location.named.AWS\ Virginia\ Large\ Centos.imageId=us-east-1/ami-7d7bfc14
brooklyn.location.named.AWS\ Virginia\ Large\ Centos.user=root
brooklyn.location.named.AWS\ Virginia\ Large\ Centos.minRam=4096
```

Named locations can refer to other named locations using `named:xxx` as their value.
These will inherit the configuration and can override selected keys.
Properties set in the namespace of the provider (e.g. `b.l.jclouds.aws-ec2.KEY=VALUE`)
will be inherited by everything which extends AWS
Sub-prefix strings are also inherited up to `brooklyn.location.*`, 
except that they are filtered for single-word and other
known keys 
(so that we exclude provider-scoped properties when looking at sub-prefix keys).
The precedence for configuration defined at different levels is that the value
defined in the most specific context will apply.

This is rather straightforward and powerful to use,
although it sounds rather more complicated than it is!
The examples below should make it clear.
You could use the following to install
a public key on all provisioned machines,
an additional public key in all AWS machines, 
and no extra public key in `prod1`: 

<!-- tested in JcloudsLocationResolverTest -->
```bash
brooklyn.location.extraSshPublicKeyUrls=http://me.com/public_key
brooklyn.location.jclouds.aws-ec2.extraSshPublicKeyUrls="[ \"http://me.com/public_key\", \"http://me.com/aws_public_key\" ]"
brooklyn.location.named.prod1.extraSshPublicKeyUrls=
```

And in the example below, a config key is repeatedly overridden. 
Deploying `location: named:my-extended-aws` will result in an `aws-ec2` machine in `us-west-1` (by inheritance)
with `VAL6` for `KEY`:
  
```bash
brooklyn.location.KEY=VAL1
brooklyn.location.jclouds.KEY=VAL2
brooklyn.location.jclouds.aws-ec2.KEY=VAL3
brooklyn.location.jclouds.aws-ec2@us-west-1.KEY=VAL4
brooklyn.location.named.my-aws=jclouds:aws-ec2:us-west-1
brooklyn.location.named.my-aws.KEY=VAL5
brooklyn.location.named.my-extended-aws=named:my-aws
brooklyn.location.named.my-extended-aws.KEY=VAL6
```