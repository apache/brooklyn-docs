---
title: Security Guidelines
layout: website-normal
---

## Brooklyn Server

### Web-console and REST API

Users are strongly encouraged to use HTTPS, rather than HTTP.

The use of LDAP is encouraged, rather than basic auth.

Configuration of "entitlements" is encouraged, to lock down access to the REST API for different 
users.


### Brooklyn user

Users are strongly discouraged from running Brooklyn as root.

For production use-cases (i.e. where Brooklyn will never deploy to "localhost"), the user under 
which Brooklyn is running should not have `sudo` rights.


### Persisted State

Use of an object store is recommended (e.g. using S3 compliant or Swift API) - thus making
use of the security features offered by the chosen object store.

File-based persistence is also supported. Permissions of the files will automatically
be 600 (i.e. read-write only by the owner). Care should be taken for permissions of the
relevant mount points, disks and directories.


## Credential Storage

For credential storage, users are strongly encouraged to consider using the "externalised 
configuration" feature. This allows credentials to be retrieved from a store managed by you, 
rather than being stored within YAML blueprints or `brooklyn.cfg`.

A secure credential store is strongly recommended, such as use of 
[HashiCorp's Vault](https://www.vaultproject.io) - see
`org.apache.brooklyn.core.config.external.vault.VaultExternalConfigSupplier`.


## Infrastructure Access

### Cloud Credentials and Access

Users are strongly encouraged to create separate cloud credentials for Brooklyn's API access.

Users are also encouraged to (where possible) configure the cloud provider for only minimal API 
access (e.g. using AWS IAM).

<!--
TODO: We should document the minimum requirements for AWS IAM required by Brooklyn
-->


### VM Image Credentials

Users are strongly discouraged from using hard-coded passwords within VM images. Most cloud 
providers/APIs provide a mechanism to instead set an auto-generated password or to create an 
entry in `~/.ssh/authorized_keys` (prior to the VM being returned by the cloud provider).

If a hard-coded credential is used, then Brooklyn can be configured with this "loginUser" and 
"loginUser.password" (or "loginUser.privateKeyData"), and can change the password and disable 
root login.


### VM Users

It is strongly discouraged to use the root user on VMs being created or managed by Brooklyn.
SSH-ing on the VM should be done on rare cases such as initial Apache Brooklyn setup,
Apache Brooklyn upgrade and other important maintenance occasions.

### SSH keys

Users are strongly encouraged to use SSH keys for VM access, rather than passwords.

This SSH key could be a file on the Brooklyn server. However, a better solution is to use the 
"externalised configuration" to return the "privateKeyData". This better supports upgrading of 
credentials.


## Install Artifact Downloads

When Brooklyn executes scripts on remote VMs to install software, it often requires downloading 
the install artifacts. For example, this could be from an RPM repository or to retrieve `.zip` 
installers.

By default, the RPM repositories will be whatever the VM image is configured with. For artifacts 
to be downloaded directly, these often default to the public site (or mirror) for that software 
product.

Where users have a private RPM repository, it is strongly encouraged to ensure the VMs are 
configured to point at this.

For other artifacts, users should consider hosting these artifacts in their own web-server and 
configuring Brooklyn to use this. See the documentation for 
`org.apache.brooklyn.core.entity.drivers.downloads.DownloadProducerFromProperties`.

## Controlling Sensitive Information in the Logs

Log messages which may contain sensitive information are normally logged at TRACE level.
Sensitive information is identified heuristically, including config keys and environment variables
which contain any of the words below (case insensitive):

- `password`
- `passwd` 
- `credential`
- `secret`
- `private`
- `access.cert`
- `access.key`

Logging should configured such that TRACE is excluded or appropriately secured
to prevent the values of these keys and variables from being logged at too high a level.
A commented sample configuration for enabling TRACE logging is available in 
the `org.ops4j.pax.logging.cfg` logging configuration file. 
With this configuration enabled, all TRACE log entries are written to the `brooklyn.trace.log` file.

Blueprint source code and some activity may be logged at DEBUG level or higher, 
so secrets should not be included in plain text in blueprints 
unless the Apache Brooklyn environment and its logs are appropriately secured.
It is recommend to use [Externalized Configuration](externalized-configuration.md) 
to store credentials securely externally and read them as needed
for blueprints and to prevent their inclusion in logs (and also in the UI). 

If it is desired to suppress information that is logged at DEBUG or higher level,
which should not ordinarily be needed but may be desired on occasion,
this can be done by setting filter(s) and/or appender(s) on the appropriate logging category in
`org.ops4j.pax.logging.cfg`. Some of the categories (or individual sub-categories of these) 
which may be relevant for exclusion or higher security are:

* `org.apache.brooklyn.core.typereg`:
  resolution of bundles and registration of types
* `org.apache.brooklyn.rest.resources`:
  log REST activity, including blueprints deployed
* `org.apache.brooklyn.camp.brooklyn.spi.creation`:
  creation of entities from CAMP
* `org.apache.brooklyn.camp.brooklyn.spi.dsl`:
  resolution of DSL expressions

