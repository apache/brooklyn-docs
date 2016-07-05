---
section: Google Compute Engine (GCE)
title: Google Compute Engine
section_type: inline
section_position: 4
---

## Google Compute Engine (GCE)

### Credentials

GCE uses a service account e-mail address for the identity and a private key as the credential.

To obtain these from GCE, see the [jclouds instructions](https://jclouds.apache.org/guides/google).

An example of the expected format is shown below.
Note that when supplying the credential in a properties file, it should be one long line
with `\n` representing the new line characters:

    brooklyn.location.jclouds.google-compute-engine.identity=123456789012@developer.gserviceaccount.com
    brooklyn.location.jclouds.google-compute-engine.credential=-----BEGIN RSA PRIVATE KEY-----\nabcdefghijklmnopqrstuvwxyznabcdefghijk/lmnopqrstuvwxyzabcdefghij\nabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij+lm\nnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm\nnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxy\nzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk\nlmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvw\nxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghi\njklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstu\nvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefg\nhijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrs\ntuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcde\nfghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvw\n-----END RSA PRIVATE KEY-----


### Quotas

GCE accounts can have low default [quotas](https://cloud.google.com/compute/docs/resource-quotas).

It is easy to requesta quota increase by submitting a [quota increase form](https://support.google.com/cloud/answer/6075746?hl=en).


### Networks

GCE accounts often have a limit to the number of networks that can be created. One work around
is to manually create a network with the required open ports, and to refer to that named network
in Brooklyn's location configuration.

To create a network, see [GCE network instructions](https://cloud.google.com/compute/docs/networking#networks_1).

For example, for dev/demo purposes an "everything" network could be created that opens all ports.

|| Name                        || everything                  |
|| Description                 || opens all tcp ports         |
|| Source IP Ranges            || 0.0.0.0/0                   |
|| Allowed protocols and ports || tcp:0-65535 and udp:0-65535 |


