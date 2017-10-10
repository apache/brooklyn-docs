---
section: Google Compute Engine (GCE)
title: Google Compute Engine
section_type: inline
section_position: 5
---

## Google Compute Engine (GCE)

### Credentials

GCE uses a service account e-mail address for the identity and a private key as the credential.

To obtain credentials for GCE, use the GCE web page's "APIs & auth -> Credentials" page,
creating a "Service Account" of type JSON, then extracting the client_email as the identity and 
private_key as the credential. For more information, see the 
[jclouds instructions](https://jclouds.apache.org/guides/google).

An example of the expected format is shown below. Note that when supplying the credential in a 
properties file, it can either be one long line with `\n` representing the new line characters, 
or in YAML it can be split over multiple lines as below:

    location:
      jclouds:google-compute-engine:
        region: us-central1-a
        identity: 1234567890-somet1mesArand0mU1Dhere@developer.gserviceaccount.com
        credential: |
          -----BEGIN RSA PRIVATE KEY-----
          abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz
          0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmn
          opqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+ab
          cdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz01
          23456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnop
          qrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcd
          efghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123
          456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqr
          stuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdef
          ghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz012345
          6789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrst
          uvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefgh
          ijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz01234567
          89/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuv
          wxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghij
          klmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789
          /+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwx
          yz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijkl
          mnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+
          abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz
          0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+abcdefghijklmn
          opqrstuvwxyz0123456789/+abcdefghijklmnopqrstuvwxyz0123456789/+ab
          cdefghijklmnopqrstuvwxyz
          -----END RSA PRIVATE KEY-----

It is also possible to have the credential be the path of a local file that contains the key.
However, this can make it harder to setup and manage multiple Brooklyn servers (particularly
when using high availability mode).

Users are strongly recommended to use 
[externalized configuration](../ops/externalized-configuration.md) for better
credential management, for example using [Vault](https://www.vaultproject.io/).


### Quotas

GCE accounts can have low default [quotas](https://cloud.google.com/compute/docs/resource-quotas).

It is easy to request a quota increase by submitting a [quota increase form](https://support.google.com/cloud/answer/6075746?hl=en).


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

To configure the location to use this, you can include a location configuration option like:

    templateOptions:
      network: https://www.googleapis.com/compute/v1/projects/<project name>/global/networks/everything

